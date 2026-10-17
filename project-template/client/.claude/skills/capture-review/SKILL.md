---
name: capture-review
description: Weekly review of a client repo. Finds missing captures, flags scope drift, and writes docs/deliverables/ in one PR. Use on /capture-review or the Friday schedule.
disable-model-invocation: true
argument-hint: "Period (default: last 7 days)"
---

# Capture review

Read `.capture/project.yaml` and `docs/agents/capture.md` first.

**Sources:**

- this repo: issues, PRs, commits
- Gmail label `clients/<slug>`
- Drive folder `Clients/<slug>/Meetings`

Follow `ai_processing`. If a connector is missing, skip that source and say so.

## Steps

1. **Gaps:**
    - meetings without a recap email
    - decisions in mail or transcripts with no issue or ADR
    - merged PRs with an empty Capture section
2. **Scope:**
    - new issues outside the `scope` specs: draft a `change-request` for each
    - change requests without an approval link: flag them
3. **Overdue:** `dependency` issues past their date.
4. **Deliverables:** update the files the period's facts touch. Create a file only when it has real content, and only with the sections you can fill. Cite issue numbers. Put everything in one PR on `docs/weekly-<date>`.
5. **Status email:** draft it in short, informal Dutch: decisions, done, next, open questions, "reply if anything is wrong". Never send it.

Show the gaps, draft issues and email first. Create the issues and the PR after a yes.

## Deliverable files

| File | Sources | Sections |
| --- | --- | --- |
| `01-sow.md` | `scope`, `out-of-scope`, `change-request`, `dependency`, project.yaml | objective, in/out of scope, milestones, approver, dependencies, acceptance, change control, fees, change log |
| `02-solution-design.md` | ADRs, `decision` | goals, constraints, C4 context/containers, flows, deployment, ADR index, NFRs |
| `03-code-handover.md` | merged PRs, tags, lockfiles | ownership, release and SHA, IP, dependencies and licences |
| `04-infrastructure.md` | IaC, `manual-step` | setup, environments, resources, env vars (names), manual steps, cost |
| `05-tests-and-quality.md` | CI, AC ids, `bug` | plan, results, AC traceability, data checks, defects, verdict |
| `06-cicd.md` | workflows | flow, environments, secret names, deploy, rollback, release |
| `07-runbook.md` | `ops-learning`, `incident` | overview, access, alerts, common failures, escalation, backup and restore |
| `08-data.md` | schemas, lineage | sources, dictionary, lineage, owners, personal data (AVG) |
| `09-access.md` | `access-grant` | access, secrets (names), transfers, revocation |
| `10-monitoring.md` | alert config, `incident` | SLOs, alerts, routing, dashboards |
| `11-knowledge-transfer.md` | ADRs, glossary, runbook | plan, sessions, Q&A, readiness, support window |
| `12-acceptance.md` | AC ids, CI, UAT | criteria and evidence, open items, decision, warranty end |
| `13-known-issues.md` | `tech-debt`, `risk`, `future` | debt, risks, security, next steps |

## Rules

- No secret values. No commits to `main`. No AI attribution.
- Don't rewrite text someone edited by hand. Add to it, or ask.
