# Bestehende Tickets ändern

Someone else may have written the ticket, and other people may already have planned around it. Editing is additive by default.

- Read the current issue before touching it. Never send a description that was composed without seeing what is in the field right now.
- Add to what is there instead of replacing it. Keep the original wording even when your own phrasing would be tighter. A wholesale rewrite destroys the record of who meant what and makes the change unreviewable for the author.
- A full replacement needs an explicit instruction from the user for that specific ticket.
- Show what will change before writing: which section, the current text, the new text. A short before and after is enough. The confirmation rule from step 5 applies unchanged.
- When the addition is a contribution to the discussion rather than a change to the specification, for example a finding from the review pass on a ticket that belongs to someone else, write a comment instead of editing the description.
- Keep the section order of the template when you add a missing section.
- Every edit notifies the watchers. Collect several changes to the same issue into one edit.
- When the description holds images or attachments, read it with `responseContentFormat: html` and write it back with `contentFormat: html`. In the default markdown format `editJiraIssue` drops inline media.
