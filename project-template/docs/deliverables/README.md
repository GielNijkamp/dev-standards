# Deliverables

These are the client deliverables for this project. They are filled in while we work, mostly by `/capture-review`, from the sources each file lists. The storage map in `docs/agents/capture.md` says which label feeds which file.

| # | File | Main sources | When it must be complete |
| --- | --- | --- | --- |
| 01 | [SOW](01-sow.md) | `scope`, `out-of-scope`, `change-request`, `assumption`, `dependency` | Proposal, then each approved CR |
| 02 | [Solution design](02-solution-design.md) | `docs/adr/`, `decision`, `nfr` | Design sign-off |
| 03 | [Code handover](03-code-handover.md) | Merged PRs, tags, lockfiles, contract IP clause | Close |
| 04 | [Infrastructure](04-infrastructure.md) | IaC, `manual-step`, baseline exports | Go-live, close |
| 05 | [Tests and quality](05-tests-and-quality.md) | CI results, AC ids in specs, `bug` | UAT, close |
| 06 | [CI/CD](06-cicd.md) | Workflow files, environment settings | First pipeline |
| 07 | [Runbook](07-runbook.md) | `ops-learning`, `incident`, setup commands | Go-live |
| 08 | [Data](08-data.md) | Schemas, lineage, column comments | Go-live, close |
| 09 | [Access](09-access.md) | `access-grant`, IAM export at close | Close |
| 10 | [Monitoring](10-monitoring.md) | Alert config, `nfr`, `incident` | Go-live |
| 11 | [Knowledge transfer](11-knowledge-transfer.md) | `kt-topic`, ADRs, runbook, recordings | Before handover |
| 12 | [Acceptance](12-acceptance.md) | AC ids, CI results, UAT sheet, delivery email | Delivery |
| 13 | [Known issues](13-known-issues.md) | `tech-debt`, `known-issue`, `risk`, `future`, `/retro` | Close |

Every claim in a deliverable cites its source: an issue number, an ADR, a file path or a date.
