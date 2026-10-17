---
name: capture
description: Log one project fact as the right labelled GitHub issue (decision, change request, tech debt, manual step, ops learning, access grant, risk, and so on). Use when the user says /capture, or when you notice something worth logging during work and the user agrees.
argument-hint: "What happened, in a few words"
---

# Capture

Turn one fact into the right record, in one step. Read `docs/agents/capture.md` for the storage map.

## Process

1. **Classify** the fact into one type from the storage map. If it is a term or an ADR-worthy decision, hand over to `/domain-modeling` instead of opening an issue.
2. **Check for duplicates.** Run `gh issue list --label <type> --state open --search "<keywords>"`. If one exists, propose a comment on it instead of a new issue.
3. **Draft the issue.** For types with an issue form (`change-request`, `direction-change`, `tech-debt`, `manual-step`, `ops-learning`, `access-grant`, `decision`), fill in the same fields as the form in `.github/ISSUE_TEMPLATE/`. Keep it to a few lines, and use the words from `GLOSSARY.md`.
4. **Show the draft** as type, title and body, and wait for a yes. One short question if a required field is unknown, such as the owner or date of a dependency.
5. **Create it** with `gh issue create --label <type> --title ... --body ...`. Add `Part of #<n>` when it belongs to a spec or ticket.
6. **Reply with one line:** the issue number and title.

## Rules

- Never put a secret value in an issue. Write the secret's name and where it lives, such as `op://Clients/bakkerij/exact-api`.
- A `change-request` always gets `needs-triage` and an empty approval link. Never mark it ready.
- If the fact changes an existing decision, ADR or spec, say so. Propose a `direction-change` instead.
- Several facts at once: draft them all, confirm once, then create them.
