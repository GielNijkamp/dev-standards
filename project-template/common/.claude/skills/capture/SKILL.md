---
name: capture
description: Log one project fact as a labelled GitHub issue. Use on /capture, or when you notice a decision, shortcut, change outside the code, hard fix, incident or risk during work.
argument-hint: "What happened"
---

# Capture

1. Pick the type from `docs/agents/capture.md`. A term or an ADR-worthy decision goes to `/domain-modeling` instead.
2. Check for duplicates: `gh issue list --label <type> --search "<words>"`. Comment on an existing issue if one fits.
3. Draft the issue with the fields below. Show it and wait for a yes.
4. Run `gh issue create --label <type> --title ... --body ...`. Add `Part of #<n>` if it belongs to a spec or ticket.
5. Reply with the number and title.

## Fields

Use each field as a `### <name>` heading in the body.

- `decision`: Decision and why · Decided by, date · Source
- `tech-debt`: What and where · Why · Cost of leaving it · Fix and effort
- `manual-step`: System and environment · What changed · Move into code? (yes / follow-up / no)
- `ops-learning`: Symptom · Cause · Fix (commands) · Verify
- `incident`: Start, end · Impact · Cause · Fix · Follow-ups
- `risk`: Risk · Likelihood (1–5) · Impact (1–5) · Owner · Mitigation
- `future`: Idea · Why later

## Rules

- No secret values. Write the name and store, such as `op://Clients/x/api-key`.
- If it changes an earlier decision, say so and supersede it.
- Several facts at once: draft all, confirm once.
