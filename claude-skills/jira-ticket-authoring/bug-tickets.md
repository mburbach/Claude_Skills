# Bug-Tickets

A bug report answers different questions than planned work, so it gets its own structure. Use these sections instead of Ziel/Kontext/Aufgaben.

- **Beobachtetes Verhalten** is what the system actually does, described precisely and without interpretation. Quote the exact message, value or state.
- **Erwartetes Verhalten** is what it should do instead, plus where that expectation comes from: a spec, a ticket, a legal rule, or the behavior before a change.
- **Reproduktion** is a numbered list of steps with concrete test data, followed by how reliably it reproduces (immer, sporadisch, nur mit bestimmten Daten). If it is not reproducible yet, write that down explicitly instead of dropping the section.
- **Umgebung** is whatever is relevant to narrow it down: version or build, stage, browser, database, tenant, user role, time of occurrence.
- **Auswirkung** is who is affected, how often, and what the damage is (falsche Auszahlung, blockierter Prozess, kosmetisch). This drives priority, so it is not optional.
- **Analyse** is optional and holds what is already known about the cause: a stack trace excerpt, a suspected code location, a related change. Only write it when there is something concrete. A bug names the causing change here by content, never by key. The relation itself becomes a "verursacht" link.
- **Akzeptanzkriterien** work as usual and are usually two lines. The reproduction steps no longer produce the wrong behavior, and a regression test that fails without the fix is green with it.

Rules:

- Don't write a solution into the ticket before the cause is understood. If the fix is already clear and agreed, it belongs under Analyse, and the ticket stays a bug.
- Several separate defects in the same area are separate tickets, even when found in one session. Bundle them only when they share one cause and one fix.
