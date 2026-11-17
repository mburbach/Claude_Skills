#!/usr/bin/env bash
# Prüft deutsche Markdown-Skilltexte auf Gedankenstriche und Semikola.
# Aufruf: stilpruefung.sh [DATEI...], ohne Argumente alle codex-skills/**/*.md.
set -euo pipefail

# Pfade relativ zum Repo-Wurzelordner
cd "$(git rev-parse --show-toplevel)"

if [ "$#" -eq 0 ]; then
  # Alle Skill-Dateien im Repo
  mapfile -t dateien < <(find codex-skills -type f -name '*.md' | sort)
else
  dateien=()
  for datei in "$@"; do
    # Nur Markdown unter codex-skills/ und shared/, alles andere still überspringen
    case "$datei" in
      codex-skills/*.md|shared/*.md) dateien+=("$datei") ;;
    esac
  done
fi

# Nichts zu prüfen, awk würde sonst von stdin lesen
if [ "${#dateien[@]}" -eq 0 ]; then exit 0; fi

awk '
# Zustand pro Datei zurücksetzen
FNR == 1 { fm = 0; fence = "" }

# YAML-Front-Matter überspringen (nur am Dateianfang)
FNR == 1 && /^---[ \t]*$/ { fm = 1; next }
fm { if (/^---[ \t]*$/) fm = 0; next }

# Zeile ohne führende Einrückung für die Fence-Erkennung
{ t = $0; sub(/^[ \t]+/, "", t) }

# Fenced Code-Block öffnen (mindestens drei Zeichen), Fence-Zeile selbst überspringen
!fence && match(t, /^(```+|~~~+)/) { fence = substr(t, 1, RLENGTH); next }
# Schließen nur mit gleichem Zeichen in mindestens gleicher Länge, so bleiben verschachtelte Blöcke offen
fence {
  f = t; sub(/[ \t]+$/, "", f)
  if (f ~ /^(```+|~~~+)$/ && substr(f, 1, 1) == substr(fence, 1, 1) && length(f) >= length(fence)) fence = ""
  next
}

# Inline-Code entfernen, dann auf Treffer prüfen
{
  zeile = $0
  gsub(/`[^`]*`/, "", zeile)
  liste = zeile; sub(/^[ \t]*- /, "", liste)   # führender Listenmarker ist kein Bindestrich
  if (index(zeile, " – ") || index(zeile, "—") || index(liste, " - ") || index(zeile, ";")) {
    print FILENAME ":" FNR ": " $0
    treffer = 1
  }
}

END { exit treffer }
' "${dateien[@]}"
