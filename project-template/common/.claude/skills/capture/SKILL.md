---
name: capture
description: Log one project fact as the right labelled GitHub issue (decision, tech debt, manual step, ops learning, incident, risk, future). Use when the user says /capture, or when you notice something worth logging during work and the user agrees.
argument-hint: "What happened, in a few words"
---

# Capture

Turn one fact into the right record, in one step. The storage map is in `docs/agents/capture.md`.

## Process

1. **Classify** the fact into one type from the storage map. If it is a term or an ADR-worthy decision, hand over to `/domain-modeling` instead of opening an issue.
2. **Check for duplicates.** Run `gh issue list --label <type> --state open --search "<keywords>"`. If one exists, propose a comment on it instead.
3. **Draft the issue.** For types with an issue form in `.github/ISSUE_TEMPLATE/`, fill in the same fields as the form. Keep it to a few lines, and use the words from `GLOSSARY.md`.
4. **Show the draft** as type, title and body, and wait for a yes. Ask one short question if a required field is unknown.
5. **Create it** with `gh issue create --label <type> --title ... --body ...`. Add `Part of #<n>` when it belongs to a spec or ticket.
6. **Reply with one line:** the issue number and title.

## Rules

- Never put a secret value in an issue. Write the secret's name and where it lives, such as `op://Clients/bakkerij/exact-api`.
- If the fact changes an earlier decision, ADR or spec, say so, and supersede the ADR or decision.
- Several facts at once: draft them all, confirm once, then create them.
