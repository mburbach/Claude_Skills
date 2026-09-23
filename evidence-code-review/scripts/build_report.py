#!/usr/bin/env python3
"""Setzt die Review-Daten (JSON) in das HTML-Template ein.

Aufruf: build_report.py <review.json> <ausgabe.html>
"""
import html
import json
import sys
from pathlib import Path

TEMPLATE = Path(__file__).resolve().parent.parent / "assets" / "report-template.html"
SCHWERE = {"Blocker", "Sollte", "Nit", "Frage"}
KATEGORIEN = {"Sicherheit", "Korrektheit", "Tests", "Architektur", "Wartbarkeit", "Stil"}


def pruefen(daten):
    fehler = []
    ids = set()
    for i, f in enumerate(daten.get("findings", [])):
        fid = f.get("id", "")
        if not fid or not fid.replace("-", "").isalnum():
            fehler.append(f"Finding {i}: id fehlt oder enthält unerlaubte Zeichen")
        if fid in ids:
            fehler.append(f"Finding {fid}: id doppelt")
        ids.add(fid)
        if f.get("schwere") not in SCHWERE:
            fehler.append(f"Finding {fid}: schwere '{f.get('schwere')}' unbekannt")
        if f.get("kategorie") not in KATEGORIEN:
            fehler.append(f"Finding {fid}: kategorie '{f.get('kategorie')}' unbekannt")
        if not f.get("auszuege"):
            fehler.append(f"Finding {fid}: kein Code-Auszug")
        for feld in ("titel", "ort", "warum", "gegenprobe", "vorschlag"):
            if not f.get(feld):
                fehler.append(f"Finding {fid}: Feld '{feld}' ist leer")
    return fehler


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    daten = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    fehler = pruefen(daten)
    if fehler:
        sys.exit("Bericht unvollständig:\n  " + "\n  ".join(fehler))

    eingebettet = (
        json.dumps(daten, ensure_ascii=False)
        .replace("&", "\\u0026")
        .replace("<", "\\u003c")
        .replace(">", "\\u003e")
        .replace(" ", "\\u2028")
        .replace(" ", "\\u2029")
    )
    titel = daten.get("meta", {}).get("titel") or "Code Review"
    seite = TEMPLATE.read_text(encoding="utf-8")
    seite = seite.replace("__TITLE__", html.escape(titel), 1)
    seite = seite.replace("/*__REVIEW_DATA__*/null", eingebettet, 1)
    Path(sys.argv[2]).write_text(seite, encoding="utf-8")
    print(f"{sys.argv[2]}: {len(daten.get('findings', []))} Findings")


if __name__ == "__main__":
    main()
