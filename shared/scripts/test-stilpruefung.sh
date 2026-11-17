#!/usr/bin/env bash
# Tests für stilpruefung.sh in einem Wegwerf-Repo unter mktemp, das Repo selbst bleibt unberührt.
set -euo pipefail

skript="$(cd "$(dirname "$0")" && pwd)/stilpruefung.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
git init -q "$tmp"
mkdir -p "$tmp/codex-skills/demo"
cd "$tmp"

fehler=0

# Schreibt den Inhalt von stdin nach DATEI und prüft den Exit-Code (1 = Treffer, 0 = kein Treffer)
pruefe() {
  local name=$1 soll=$2 datei=$3
  cat > "$datei"
  local ist=0
  "$skript" "$datei" >/dev/null || ist=$?
  if [ "$ist" -ne "$soll" ]; then
    echo "FEHLER: $name (Exit $ist, erwartet $soll)"
    fehler=1
  fi
}

pruefe "En-Dash mit Leerzeichen ist Treffer" 1 codex-skills/demo/a.md <<'EOF'
Ein Satz – mit Strich.
EOF

pruefe "Semikolon ist Treffer" 1 codex-skills/demo/b.md <<'EOF'
Erst das eine; dann das andere.
EOF

pruefe "Bindestrich zwischen Wörtern ist Treffer" 1 codex-skills/demo/c.md <<'EOF'
Wort - Wort.
EOF

pruefe "Listenpunkt ist kein Treffer" 0 codex-skills/demo/d.md <<'EOF'
- item
  - verschachtelt
EOF

pruefe "Semikolon im Codeblock ist kein Treffer" 0 codex-skills/demo/e.md <<'EOF'
Text.

```bash
echo a; echo b
```
EOF

pruefe "Semikolon in verschachteltem Codeblock ist kein Treffer" 0 codex-skills/demo/h.md <<'EOF'
````markdown
```java
a.set(1);
```
````
EOF

pruefe "Semikolon im Inline-Code ist kein Treffer" 0 codex-skills/demo/f.md <<'EOF'
Nutze `a;b` hier.
EOF

pruefe "Front Matter wird ignoriert" 0 codex-skills/demo/g.md <<'EOF'
---
title: a; b
---
Ein sauberer Satz.
EOF

pruefe "Datei außerhalb codex-skills wird übersprungen" 0 anderes.md <<'EOF'
Semikolon; und – Strich.
EOF

if [ "$fehler" -eq 0 ]; then
  echo "OK"
else
  exit 1
fi
