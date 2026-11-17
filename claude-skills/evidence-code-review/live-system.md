# Nachweis am laufenden System

Gehört zu Schritt 6 von `SKILL.md`. Nur lesen, wenn ein Finding an Laufzeitverhalten hängt (Security-Filter, Autokonfiguration, HTTP-Status, Serialisierung).

Ein echter Aufruf ist dann der stärkste Beleg. Der Skill darf den gebauten Dienst lokal starten, auf einem freien Port und mit der Konfiguration aus dem Repository, und ihn mit `curl` oder einem kleinen Testaufruf ansprechen. Regeln:

- nur lokal, keine Aufrufe gegen fremde oder produktive Systeme,
- keine Daten schreiben, die über den Test hinaus bestehen bleiben,
- Befehl, Anfrage und entscheidende Antwortzeilen (Statuscode, Header, Logzeile) kommen ins Feld `gegenprobe`, damit der Leser es nachstellen kann,
- den Prozess danach beenden und das im Chat bestätigen.

Gelingt der Nachweis, erhält das Finding den Status `nachgewiesen`.
