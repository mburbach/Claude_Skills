#!/usr/bin/env bash
# Files and updates tickets in a self-hosted Vikunja instance over the REST API.
# API choice: classic /api/v1 (the instance also serves /api/v2, but v1 is
# stable and covers everything needed here).
# Endpoints: GET /projects/{p}/tasks, PUT /projects/{p}/tasks,
# PUT /tasks/{id}/labels, PUT /tasks/{id}/comments, GET/POST /tasks/{id}.
#
# Env: VIKUNJA_URL (default https://tasks.hashit.de)
#      VIKUNJA_TOKEN_FILE (default ~/.config/vikunja/claude.token)
# Needs: curl, jq, pandoc (for create and comment).

set -euo pipefail

BASE="${VIKUNJA_URL:-https://tasks.hashit.de}"
TOKEN_FILE="${VIKUNJA_TOKEN_FILE:-$HOME/.config/vikunja/claude.token}"
PROJECT=13
LABEL=46

usage() {
  cat <<'USG'
Usage:
  vikunja-ticket.sh [--project ID] [--no-label] find TERM
  vikunja-ticket.sh [--project ID] [--no-label] create TITLE FILE
  vikunja-ticket.sh comment TASK_ID FILE
  vikunja-ticket.sh done TASK_ID
  vikunja-ticket.sh -h

find     lists open tasks matching TERM: id<TAB>identifier<TAB>title
create   FILE is Markdown, "-" reads stdin. Prints id<TAB>identifier<TAB>URL
comment  adds a Markdown comment (FILE or "-")
done     marks the task done
Defaults: project 13, label 46 (retro) on created tasks.
USG
}

die() { printf 'vikunja-ticket: %s\n' "$*" >&2; exit 1; }

[ -r "$TOKEN_FILE" ] || die "token file not readable: $TOKEN_FILE"
HDR="$(mktemp)"
trap 'rm -f "$HDR"' EXIT
chmod 600 "$HDR"
printf 'Authorization: Bearer %s\n' "$(tr -d '[:space:]' < "$TOKEN_FILE")" > "$HDR"

# api METHOD PATH [JSON_BODY] [curl args...]; prints response body, dies on HTTP error.
api() {
  local method="$1" path="$2" body="${3:-}" out code
  shift 3 || shift $#
  out="$(mktemp)"
  local args=(-sS -o "$out" -w '%{http_code}' -X "$method" -H "@$HDR" -H 'Content-Type: application/json')
  [ -n "$body" ] && args+=(--data-binary "$body")
  code="$(curl "${args[@]}" "$@" "$BASE/api/v1$path")" || { rm -f "$out"; die "request failed: $method $path"; }
  if [ "${code:0:1}" != 2 ]; then
    local msg
    msg="$(jq -r '.message // empty' "$out" 2>/dev/null || true)"
    rm -f "$out"
    die "HTTP $code on $method $path: ${msg:-no message}"
  fi
  cat "$out"; rm -f "$out"
}

# md2html FILE: Markdown to HTML; -raw_html keeps placeholders like <Datum>.
md2html() {
  local f="$1"
  if [ "$f" = "-" ]; then pandoc -f markdown-raw_html -t html
  else [ -r "$f" ] || die "file not readable: $f"; pandoc -f markdown-raw_html -t html "$f"; fi
}

while [ $# -gt 0 ]; do
  case "$1" in
    --project) [ $# -ge 2 ] || die "--project needs an ID"; PROJECT="$2"; shift 2 ;;
    --no-label) LABEL=""; shift ;;
    -h|--help) usage; exit 0 ;;
    *) break ;;
  esac
done

cmd="${1:-}"; [ -n "$cmd" ] || { usage >&2; exit 2; }
shift
case "$cmd" in
  find)
    [ $# -eq 1 ] || { usage >&2; exit 2; }
    api GET "/projects/$PROJECT/tasks" "" -G --data-urlencode 'filter=done = false' \
      --data-urlencode "s=$1" --data-urlencode 'per_page=100' |
      jq -r '.[] | [.id, (.identifier // ""), .title] | @tsv'
    ;;
  create)
    [ $# -eq 2 ] || { usage >&2; exit 2; }
    html="$(md2html "$2")"
    resp="$(api PUT "/projects/$PROJECT/tasks" "$(jq -n --arg t "$1" --arg d "$html" '{title:$t,description:$d}')")"
    id="$(jq -r '.id' <<<"$resp")"
    if [ -n "$LABEL" ]; then
      api PUT "/tasks/$id/labels" "$(jq -n --argjson l "$LABEL" '{label_id:$l}')" >/dev/null
    fi
    printf '%s\t%s\t%s/tasks/%s\n' "$id" "$(jq -r '.identifier // ""' <<<"$resp")" "$BASE" "$id"
    ;;
  comment)
    [ $# -eq 2 ] || { usage >&2; exit 2; }
    [[ "$1" =~ ^[0-9]+$ ]] || die "TASK_ID must be a number"
    html="$(md2html "$2")"
    api PUT "/tasks/$1/comments" "$(jq -n --arg c "$html" '{comment:$c}')" >/dev/null
    ;;
  done)
    [ $# -eq 1 ] || { usage >&2; exit 2; }
    [[ "$1" =~ ^[0-9]+$ ]] || die "TASK_ID must be a number"
    task="$(api GET "/tasks/$1")"
    api POST "/tasks/$1" "$(jq -c '.done=true' <<<"$task")" >/dev/null
    ;;
  *) usage >&2; exit 2 ;;
esac
