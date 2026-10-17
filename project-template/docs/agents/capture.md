# Capture: where each skill stores what

Every Matt Pocock skill already writes somewhere: issues, `GLOSSARY.md` or `docs/adr/`. In this repo each skill also captures the facts the client deliverables need. This file says what each skill must capture extra, and where.

## Storage map

| Fact | Stored in | Label or path | Feeds deliverable |
| --- | --- | --- | --- |
| Domain term | `GLOSSARY.md` | via `/domain-modeling` | Data docs, KT |
| Hard-to-reverse decision | `docs/adr/NNNN-slug.md` | via `/domain-modeling` | Solution design |
| Smaller decision | Issue | `decision` | Solution design, CI/CD, IaC |
| In-scope feature (spec) | Issue | `scope` + `ready-for-agent` | SOW, Acceptance |
| Excluded or parked ask | Issue | `out-of-scope` or `future` | SOW, Known issues |
| Acceptance criterion | Spec issue, `## Acceptance Criteria` section | `AC-<spec>-<n>` | Tests, Acceptance |
| Client-stated number (volume, uptime, budget) | Issue | `nfr` | Solution design, Monitoring |
| Assumption or client dependency | Issue | `assumption` or `dependency` | SOW, Known issues |
| New client ask | Issue form `change-request` | `change-request` | SOW, Acceptance |
| Direction change | Issue form `direction-change` | `direction-change` | All affected deliverables |
| Shortcut or workaround | Issue form `tech-debt` | `tech-debt` | Known issues |
| Change made outside code | Issue form `manual-step` | `manual-step` | IaC, Runbook |
| Fix worth remembering | Issue form `ops-learning` | `ops-learning` | Runbook, Monitoring |
| Access granted, secret created | Issue form `access-grant` | `access-grant` | Access transfer |
| Outage or failed deploy | Issue | `incident` | Runbook, Monitoring, Known issues |
| Bug | Issue | `bug` + `sev:*` | Tests, Acceptance, Known issues |
| Risk | Issue | `risk` | Known issues |
| Topic the client team must learn | Issue | `kt-topic` | Knowledge transfer |
| Lesson learned | `docs/deliverables/13-known-issues.md`, Lessons section | via `/retro` | Known issues |

## Per skill

### `/grill-with-docs`, `/grill-me` (via `/grilling` and `/domain-modeling`)

- Terms go to `GLOSSARY.md` and ADR-worthy decisions go to `docs/adr/`, as the skill already does.
- Each other decision that comes up goes in a `decision` issue, with the reason in one line.
- Anything the client said is out goes in an `out-of-scope` issue. Anything parked for later goes in a `future` issue.
- Numbers the client states (users, volume, uptime, deadline, budget) go in an `nfr` issue each.
- Anything we rely on from the client (access, test data, a person) goes in a `dependency` issue, with an owner and a date.
- At the end, list the issues you created.

### `/to-spec`

- Add an `## Acceptance Criteria` section after `## User Stories`. Number each criterion `AC-<spec issue>-<n>` and make it testable: Given / When / Then, or a measurable check.
- Label the spec `scope` as well as `ready-for-agent`.
- `## Out of Scope` must list every related `out-of-scope` issue by number.
- If the spec implements an approved `change-request`, link it on the first line: `Implements #<n>`.

### `/to-tickets`

- Each ticket names the acceptance criteria it delivers: `Delivers: AC-12-1, AC-12-3`.
- Each ticket starts with `Part of #<spec>`.
- Infra or pipeline work needs its own ticket, never hidden inside a feature ticket.

### `/implement` and `/tdd`

- Test names include the AC id where a test proves one: `AC-12-1: shop can confirm tomorrow's order`.
- While you work, run `/capture` immediately for:
  - a shortcut, which is `tech-debt`
  - anything changed outside the repo: a console, DNS, a manual migration, which is `manual-step`
  - a fix that took real digging, which is `ops-learning`
  - any access or secret you set up, which is `access-grant`, with the name only
- A new env var goes into `.env.example` in the same commit.
- A new dependency: note its licence in the PR if it isn't MIT, BSD or Apache.

### `/code-review`

The Standards axis reads `CODING_STANDARDS.md`. Its **Capture** section makes missing captures a finding, for example a TODO without an issue, a new env var missing from `.env.example`, or an infra change without docs.

### `/pr`

- Fill in the `## Capture` section of the PR template. Each ticked box needs an issue number or a path.
- **A one-way door needs an ADR.** If Merge Danger says *one-way*, link the ADR.
- `Closes #<ticket>` is required.

### `/triage`

- A new client ask becomes an `enhancement` with `change-request`. It stays `needs-triage` until the issue's **Client approval link** field is filled in. Only then may it move to `ready-for-agent` or `ready-for-human`. CI enforces this.
- A client-reported bug becomes `bug`, plus `sev:critical`, `sev:high`, `sev:medium` or `sev:low`.
- Rejected asks go to `wontfix` and are also labelled `out-of-scope`, so the SOW lists them.

### `/diagnosing-bugs`

- After the fix, write an `ops-learning` comment or issue with the symptom, cause, fix and how to verify it. The runbook is built from these.
- A production failure also gets the `incident` label, with the start and end times.

### `/wayfinder`

- Use it for a direction change too big for one session. The map's Destination names the change.
- Still open a `direction-change` issue linked to the map, so the deliverables see it.
- Closed decision tickets that meet the ADR bar become ADRs. The old ADR gets `Status: superseded by ADR-NNNN`.

### `/retro`

- At each milestone, append 3–5 lines to the Lessons section of `docs/deliverables/13-known-issues.md`.

### `/handoff`

- A handoff file is temporary. Before writing it, make sure every durable fact from the session is already in an issue, ADR or glossary entry.

## Our own skills

- `/capture <what happened>`: classifies one fact and opens the right labelled issue. You confirm first.
- `/capture-review`: the weekly review from the Version 0 plan. It finds gaps, drafts change requests, and updates `docs/deliverables/` in one PR.
