---
name: project-setup
description: Sets up a new coding project or retrofits an existing one with Martin's standards (coding standards, docs, ADRs, checks, CI, commit format). Started only by the user with /project-setup.
disable-model-invocation: true
---

# Project setup

Set up a project so that every later session finds the same standards: TDD, clean code, naming, docs, modular structure, one check command. Works for a new project and for an existing one. Everything shown to the user and every file written into the project is German, without dashes as punctuation and without semicolons.

Shared files, relative to this skill folder: `../../shared/project-setup/`. Template version: `VERSION` there.

## Rules for every run

- **Nothing is overwritten.** An existing file stays as it is. Every change to an existing file (a plugin in the build file, a pointer line in `CLAUDE.md`, missing lines in `.gitignore`) is its own line in the plan and happens only after the confirmation. Append only what is missing, never duplicate.
- **The existing state wins.** Every deviation from the standard (other build tool, other layout, other commit style, no Spring) appears in the plan as `Abweichung, bleibt`. Only if the user wants the standard as a goal, it becomes an ADR (Architecture Decision Record) with status `vorgeschlagen` in `docs/adr/`, numbered after the highest existing one. No mass change: no moving of packages, no reformatting of existing code (formatters only for changed files, see the language file).
- **Rules are copied, not linked.** The project gets its own copies with the marker `<!-- project-setup Vorlage vN -->` (or `# project-setup Vorlage vN`) in the first line, so it works without this repo.
- **No versions from memory.** The language files hold conventions only. Versions of frameworks, tools and CI actions are researched during the run.
- **Do not touch the user's environment.** If the build cannot reach its repository (for example a mirror in `~/.m2/settings.xml`), report it and run the check with a temporary override, never change the user's settings.
- Load `subagent-model-choice` before the first subagent. Copying and filling templates is `Mechanisch`, judging an existing project is `Analyse`, versions are `Recherche`.

## Steps

1. **Detect.** Read `.project-setup.yml` in the project root. If present, this is a second run: go to "Second run". Otherwise list what exists: language and build files, build wrapper, CI (`.github/workflows`, `.gitlab-ci.yml`, `.forgejo/workflows`), `CLAUDE.md`, `AGENTS.md`, `CODING_STANDARDS.md`, `docs/`, ADRs, hooks (`.githooks`, `.pre-commit-config.yaml`, `core.hooksPath`), Makefile or justfile, Renovate or Dependabot, `.editorconfig`, `.gitignore`, README, tests, the commit style of the last 20 commits (`nicht erkennbar` without commits) and the main branch (remote HEAD, else the current branch, else `main`). In an existing project run the build and tests once as a baseline. A failure there is reported and its fix becomes a plan line, it is not silently repaired. An empty or missing folder is a new project. For a large existing project delegate this to `Explore` with this list as the report format.
2. **Choose in dialog** with `AskUserQuestion`, at most four questions per call, each answer may be "Other". Offer only what the detection did not find as complete.
   - Language and CI platform. Only languages with a file in `languages/` and platforms with a file in `ci/` are available. Name the missing ones instead of improvising. If the project matches a language file only partly (Java without Spring), use the section `Bestand` of that file.
   - Building blocks (multiSelect, in two or three questions): `CODING_STANDARDS.md`, Definition of Done, `CLAUDE.md`/`AGENTS.md` pointers, arc42, ADRs, commit standard, basic files (`.editorconfig`, `.gitignore`, README), uniform commands (`check`, `test`, `lint`, `format`, `build`), test skeleton, modular structure, pre-commit hook, CI, dependency updates, security (gitleaks, dependency check in CI), final check. Security and final check are recommended, the others match what is missing.
   - Commit standard: combination (recommended, see `vorlagen/commit-standards.md`), pure Conventional Commits, or Martin's format without type. Ticket prefix (for example `CBD`) and AI note in commits: yes with the tool name, or none.
   - Uniform commands: justfile if `just` is installed and the user wants it, else Makefile.
   - Project name and a one-sentence description (`{{PROJEKTNAME}}`, `{{BESCHREIBUNG}}`). For an existing project propose both from README and code.
   - Questions from the language file (new project: build tool, group and package name) and from the CI file (for example Dependency Review in a private repository).
3. **Research versions** for everything the plan installs or pins, through a Haiku subagent. Stable releases only (no beta, RC, milestone or snapshot, also when a registry lists one as `latest`). Check that each version resolves where it is used (Maven Central, GitHub releases). Report one line per version: `Name | Version | Quelle (URL)`, or `unbelegt`.
4. **Show the plan** as a table: file or step, target path, `neu`, `vorhanden, bleibt`, `Änderung an Bestand` or `Abweichung, bleibt` (with `ADR` if chosen as a goal). Wait for the confirmation. Changes to the plan go back to step 2.
5. **Create.**
   - New project: the start command and the follow-up steps from the language file first (including one `format` run).
   - Existing project: the steps of the section `Bestand` in the language file (for example adding a missing build wrapper).
   - Templates from `vorlagen/` to the target paths below, every placeholder filled. Sample rows with the domain terms `Antrag` and `Mandant` (glossary in `architektur.md`) are replaced with terms of the project. The naming examples in `CODING_STANDARDS.md` stay, they illustrate the rule. A placeholder without a value is a question to the user, not an empty string. Language parts from the language file, CI from `ci/<platform>.md`.
   - `commit-standards.md` is not copied: insert the chosen variant without its heading into `{{COMMIT_STANDARD}}`, with the ticket prefix also in the example (`CBD` there is only a sample). Append the AI note section only if the AI note is not `keiner`.
   - Activate the hook (`make hooks` or `just hooks`). It needs `gitleaks`, name it in the report if it is missing.
   - Write `.project-setup.yml` with every file created from a template and its version.
6. **Check.** `check` runs green. Then the first test from the language file: write it, run it red, make it green with the smallest code. In an existing project ask for a small behavior to test this way. If the user names none, report that the existing tests run green and the red step was skipped. Report each run with the command and the result line. A failing check is fixed or reported, never skipped.
7. **Report** in German: created files, changed existing files, kept existing files, deviations and ADRs, versions with source, open points. Do not commit unless the user asks. Offer the commit with the chosen commit standard.

## Second run

Compare the project copies with the templates of the current `VERSION`. Show per file: unchanged, project changed it (keep, project wins), template is newer (show the diff of the template change, offer to apply). Offer building blocks that were not chosen before. Then continue with step 4. Update the version in `.project-setup.yml` only for applied files.

## Files and target paths

- `languages/<language>.md`: detection, questions, start command, existing projects, tools, commands, rules, layout, first test.
- `ci/<platform>.md`: pipeline, security jobs, dependency updates.
- `vorlagen/` to the project:

| Template | Target |
|---|---|
| `CODING_STANDARDS.md`, `CLAUDE.md`, `AGENTS.md`, `README.md`, `Makefile` or `justfile` | project root, same name |
| `definition-of-done.md`, `architektur.md` | `docs/` |
| `adr/*` | `docs/adr/` |
| `editorconfig` | `.editorconfig` |
| `githooks-pre-commit` | `.githooks/pre-commit`, executable |
| `project-setup.yml` | `.project-setup.yml` |
| `<language>/*` (for example `java/checkstyle.xml`) | as named in the language file (`config/checkstyle/checkstyle.xml`) |

Placeholders not filled from the dialog: `{{VORLAGENVERSION}}` from `VERSION`, `{{DATUM}}` today, `{{CMD_*}}`, `{{SPRACHREGELN}}` and `{{VORAUSSETZUNGEN}}` from the language file. `{{SPRACHE}}` and `{{CI_PLATTFORM}}` are the file names without `.md` (`java-spring`, `github-actions`). `{{COMMIT_VARIANTE}}`: `kombination`, `conventional` or `ohne_typ`.

`{{BAUSTEINE}}` is a YAML list of these names: `coding_standards`, `definition_of_done`, `agent_zeiger`, `arc42`, `adr`, `commit_standard`, `basisdateien`, `befehle`, `testgeruest`, `modulstruktur`, `pre_commit`, `ci`, `abhaengigkeiten`, `sicherheit`, `abschlusspruefung`. `{{DATEIEN}}` maps every target path created from a template or a reference file to the version, for example `.github/workflows/check.yml: 1` for a file built from `ci/github-actions.md`. Changes to existing files and files written freely (tests, further ADRs) are not listed.
