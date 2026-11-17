# Issue links

## Verlinkung

A dependency that lives only in a sentence in a description is invisible on the board and in filters. Real relations belong into issue links.

Links are created with the Atlassian plugin via `executeWrite` with `createJiraIssueLink`. Look up the project's link type names first via `executeRead` with `listJiraIssueLinkTypes`. They are configured per site and often renamed.

- The link replaces any mention in the description. Never write a key into the text in addition to the link.
- Choose the type by what the relation really is, not "hängt zusammen mit" for everything:
  - **blockiert / wird blockiert von** for a hard order, where one ticket cannot start or finish before the other is done. Use it for the pieces that come out of a split in Check 1.
  - **hängt zusammen mit** for context worth knowing without implying an order.
  - **dupliziert** when the same work is already tracked elsewhere. Prefer closing one of the two over keeping both alive and linked.
  - **verursacht** between a change and the bug it produced.
- Parent and child is hierarchy, not a link. Don't add a "hängt zusammen mit" link on top of a Sub-Task relation.
- If two tickets could be worked on at the same time by two people, the relation is "hängt zusammen mit", not "blockiert".
- Propose the links in the draft together with the tickets so one confirmation covers them, then create them once the issues exist.
