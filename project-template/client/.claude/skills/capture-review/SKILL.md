---
name: capture-review
description: Weekly capture review for this client repo. Finds missing captures, drafts change requests for scope drift, and creates or updates docs/deliverables/ in one PR. Use when the user says /capture-review, or on the Friday schedule.
disable-model-invocation: true
argument-hint: "Period, default: last 7 days"
---

# Capture review

Run this weekly. Read these first:

- `.capture/project.yaml`
- `docs/agents/capture.md` and `docs/agents/capture-client.md`
- `docs/deliverables/README.md`

## Sources

- **GitHub:** issues, PRs and commits in this repo for the period.
- **Gmail:** label `clients/<slug>`.
- **Drive:** folder `Clients/<slug>/Meetings`.

Respect `ai_processing`:

- `metadata-only`: use subjects, dates and participants only.
- `redacted`: remove names, email addresses, phone numbers, IBAN and BSN before you quote anything.

Skip a source if its connector isn't available, and say so.

## Steps

1. **Gaps.** List:
    - meetings with no recap email
    - decisions in mail or transcripts with no matching issue, ADR or glossary entry
    - merged PRs whose Capture section is empty
2. **Scope drift.** Compare the issues opened this period with the open `scope` specs. Draft a `change-request` for anything new, and flag change requests that have no approval link.
3. **Hygiene.** Look for:
    - `dependency` issues past their date
    - `manual-step`, `ops-learning` and `incident` issues not yet reflected in their deliverable
4. **Deliverables.** Use the sources column in `docs/deliverables/README.md` to see which file each change touches.
    - If the file doesn't exist and you have real content for it, create it with the listed sections.
    - Leave a section heading out until you have content for it.
    - Cite issue numbers as sources.
    - Put everything in one PR on `docs/weekly-<YYYY-MM-DD>`.
5. **Status email.** Draft the weekly client email: short, warm, informal Dutch. Include decisions logged, done, next, open questions, and "Reply if anything is wrong."

## Output

First, one message with the gaps, draft issues and draft email. Create the issues and the PR only after the user says yes. Never send the email.

## Rules

- No secret values. No commits to `main`. No AI attribution in commits or PRs.
- Don't rewrite text the user edited by hand. Add to it, or ask.
