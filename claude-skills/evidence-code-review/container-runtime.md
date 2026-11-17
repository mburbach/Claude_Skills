# Container-Laufzeit für Tests

Gehört zu Schritt 2 von `SKILL.md`. Nur lesen, wenn Tests Docker oder Podman brauchen (etwa Testcontainers).

Der Skill darf die vorhandene Laufzeit **ohne Rückfrage** starten, zum Beispiel `systemctl --user start podman.socket` oder den Docker-Dienst. Pflicht dabei:

- im Chat ankündigen, was gestartet wird und wie es wieder gestoppt wird,
- im Bericht unter Lauffähigkeit festhalten, was gestartet wurde, mit welchen Umgebungsvariablen (`DOCKER_HOST`, `TESTCONTAINERS_RYUK_DISABLED` ...), damit jemand anderes den Build und die Findings genauso nachstellen kann,
- nach den Tests wieder in den Ausgangszustand zurückversetzen und das im Chat bestätigen.

Es wird nichts installiert. Fehlt die Laufzeit ganz, ist das ein Hinweis unter "So wird es lauffähig".
