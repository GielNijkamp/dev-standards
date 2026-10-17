---
name: capture-review
description: Weekly capture review for this client repo. Finds missing captures, drafts change requests for scope drift, and updates docs/deliverables/ in one PR. Use when the user says /capture-review, or on the Friday schedule.
disable-model-invocation: true
argument-hint: "Period, default: last 7 days"
---

# Capture review

Run this weekly. Read `.capture/project.yaml` and `docs/agents/capture.md` first.

## Sources

- **GitHub:** issues, PRs and commits in this repo for the period.
- **Gmail:** label `clients/<slug>`.
- **Drive:** folder `Clients/<slug>/Meetings`.

Respect `ai_processing`. With `metadata-only`, use subjects, dates and participants only. With `redacted`, remove names, email addresses, phone numbers, IBAN and BSN before you quote anything. Skip a source if its connector isn't available, and say so.

## Steps

1. **Gaps.** List:
    - meetings in the period with no recap email
    - decisions in mail or transcripts with no matching issue, ADR or glossary entry
    - merged PRs whose Capture section is empty
2. **Scope drift.** Compare the issues opened this period with the open `scope` specs. Draft a `change-request` for anything new. Flag change requests that have no approval link.
3. **Hygiene.** Look for:
    - `dependency` issues past their date
    - `manual-step` issues not yet reflected in `docs/deliverables/04-infrastructure.md`
    - `ops-learning` and `incident` issues not yet in `07-runbook.md`
4. **Deliverables.** Update the files in `docs/deliverables/` that the period's issues touch. Use the storage map to see which file each label feeds. Cite issue numbers as sources. Put everything in one PR on `docs/weekly-<YYYY-MM-DD>`.
5. **Status email.** Draft the weekly client status email: short, warm, informal Dutch. Include decisions logged, done, next, open questions, and "Reply if anything is wrong."

## Output

First, one message with the gaps, the draft issues and the draft email. Create the issues and the PR only after the user says yes. Never send the email: it stays a draft for the user to send.

## Rules

- No secret values. No commits to `main`. No AI attribution in commits or PRs.
- Don't rewrite text in a deliverable that the user edited by hand. Add to it, or ask.
