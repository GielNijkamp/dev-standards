# Deliverables

The client deliverables for this project. `/capture-review` creates each file the first time it has content, using the names and sections below, and updates it from then on.

| File | Main sources | Complete by |
| --- | --- | --- |
| `01-sow.md` | `scope`, `out-of-scope`, `change-request`, `dependency`, `.capture/project.yaml` | Proposal, then each approved CR |
| `02-solution-design.md` | `docs/adr/`, `decision` | Design sign-off |
| `03-code-handover.md` | Merged PRs, tags, lockfiles, contract IP clause | Close |
| `04-infrastructure.md` | IaC, `manual-step`, baseline exports | Go-live, close |
| `05-tests-and-quality.md` | CI results, AC ids, `bug` | UAT, close |
| `06-cicd.md` | Workflow files, environment settings | First pipeline |
| `07-runbook.md` | `ops-learning`, `incident`, setup commands | Go-live |
| `08-data.md` | Schemas, lineage, column comments | Go-live, close |
| `09-access.md` | `access-grant`, IAM export at close | Close |
| `10-monitoring.md` | Alert config, `decision` (targets), `incident` | Go-live |
| `11-knowledge-transfer.md` | ADRs, glossary, runbook, recordings | Before handover |
| `12-acceptance.md` | AC ids, CI results, UAT sheet, delivery email | Delivery |
| `13-known-issues.md` | `tech-debt`, `risk`, `future`, `/retro` lessons | Close |

## Sections per file

- **01 SOW:** objective, in scope, out of scope, deliverables, milestones, roles and approver, client dependencies, assumptions, acceptance, change control, privacy, fees, change log
- **02 Solution design:** goals, constraints, context and containers (C4), critical flows and lineage, deployment, cross-cutting (auth, secrets, logging, backup), ADR index, NFRs, risks
- **03 Code handover:** ownership, release tag and SHA, IP (deed or licence, pre-existing IP excluded), dependencies and licences, conventions, open branches
- **04 Infrastructure:** bootstrap, environments, resources, env vars (name, purpose, secret yes/no, store), manual steps, cost, drift and teardown
- **05 Tests and quality:** test plan, results and coverage, AC traceability, data quality checks, defects, waivers, verdict
- **06 CI/CD:** flow, workflows and triggers, environments and promotion, secret names, branch protection, deploy, rollback (last tested), release
- **07 Runbook:** overview and SLA, access, dashboards and logs, one entry per alert, routine ops, common failures, escalation, backup and restore (RTO, RPO, last test)
- **08 Data:** sources, dictionary, lineage, contracts, refresh and SLAs, owners, personal data and AVG Art. 30
- **09 Access:** access inventory, secrets inventory (names only), ownership transfers, rotation log, revocation log, sign-off
- **10 Monitoring:** SLOs, alert rules, routing, dashboards, logging, pipeline notifications, uptime checks
- **11 Knowledge transfer:** plan, agenda, recordings, Q&A, readiness scores, support window, sign-off
- **12 Acceptance:** contract ref, criteria and evidence, UAT, open items, decision and basis, invoice and warranty end, signatures
- **13 Known issues:** summary, bugs and limitations, debt register, risk register, security findings, lessons, next steps

Every claim in a deliverable cites its source: an issue number, an ADR, a file path or a date.
