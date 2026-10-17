# Capture: where each skill stores what

Every Matt Pocock skill already writes somewhere: issues, `GLOSSARY.md` or `docs/adr/`. In this repo each skill also captures the facts we need later. This file says what each skill must capture extra, and where.

## Storage map

| Fact | Stored in | Label or path |
| --- | --- | --- |
| Domain term | `GLOSSARY.md` | via `/domain-modeling` |
| Hard-to-reverse decision | `docs/adr/NNNN-slug.md` | via `/domain-modeling` |
| Smaller decision, or an agreed number (volume, uptime, budget) | Issue form | `decision` |
| In-scope feature (spec) | Issue | `scope` + `ready-for-agent` |
| Parked idea for later | Issue | `future` |
| Shortcut, workaround, or known limitation we live with | Issue form | `tech-debt` |
| Change made outside the code | Issue form | `manual-step` |
| Fix worth remembering | Issue form | `ops-learning` |
| Outage or failed deploy | Issue | `incident` |
| Risk | Issue | `risk` |
| Bug | Issue | `bug` |

## Per skill

### `/grill-with-docs`, `/grill-me`

- Terms go to `GLOSSARY.md` and ADR-worthy decisions go to `docs/adr/`, as the skill already does.
- Each other decision goes in a `decision` issue, with the reason in one line.
- Ideas parked for later go in a `future` issue each.
- At the end, list the issues you created.

### `/to-spec`

- Label the spec `scope` as well as `ready-for-agent`.
- `## Out of Scope` lists the related `future` issues by number.

### `/to-tickets`

- Each ticket starts with `Part of #<spec>`.
- Infra or pipeline work gets its own ticket.

### `/implement` and `/tdd`

- While you work, run `/capture` immediately for:
  - a shortcut, which is `tech-debt`
  - anything changed outside the repo, which is `manual-step`
  - a fix that took real digging, which is `ops-learning`
- A new env var goes into `.env.example` in the same commit.

### `/code-review`

The Standards axis reads `CODING_STANDARDS.md`. Its **Capture** section makes a missed capture a finding.

### `/pr`

- Fill in the PR template's `## Capture` section. Each ticked box needs an issue number or a path.
- A one-way door (Merge Danger) needs an ADR link.
- `Closes #<ticket>` is required.

### `/diagnosing-bugs`

- After the fix, write an `ops-learning` issue or comment with symptom, cause, fix and how to verify.
- A production failure also gets an `incident` issue.

### `/wayfinder`

- The `wayfinder:*` labels are created on first use. See `docs/agents/issue-tracker.md`.
- Closed decision tickets that meet the ADR bar become ADRs. A replaced ADR gets `Status: superseded by ADR-NNNN`.

### `/handoff`

- A handoff file is temporary. Before writing it, make sure every durable fact is in an issue, ADR or glossary entry.

## Our skill

`/capture <what happened>` classifies one fact and opens the right labelled issue. You confirm first.
