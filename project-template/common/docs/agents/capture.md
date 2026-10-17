# Capture map

| Fact | Where |
| --- | --- |
| Domain term | `GLOSSARY.md` |
| Hard-to-reverse decision | `docs/adr/NNNN-slug.md` |
| Other decision, or an agreed number | issue `decision` |
| Spec | issue `scope` + `ready-for-agent` |
| Idea for later | issue `future` |
| Shortcut or known limitation | issue `tech-debt` |
| Change outside the code | issue `manual-step` |
| Fix worth remembering | issue `ops-learning` |
| Outage or failed deploy | issue `incident` |
| Risk | issue `risk` |
| Bug | issue `bug` |

## Per skill

- `/grill-with-docs`, `/grill-me`: besides glossary and ADRs, open a `decision` issue per smaller decision and a `future` issue per parked idea.
- `/to-spec`: label `scope`. Out of Scope lists the `future` issues.
- `/to-tickets`: each ticket starts with `Part of #<spec>`.
- `/implement`, `/tdd`: `/capture` shortcuts, changes outside the code and hard fixes as they happen. New env vars go in `.env.example`.
- `/pr`: fill in Capture. A one-way door needs an ADR link.
- `/diagnosing-bugs`: after the fix, an `ops-learning` with symptom, cause, fix, verify. Production failures also get `incident`.
- `/wayfinder`: create the `wayfinder:*` labels first (see `issue-tracker.md`). A replaced ADR gets `Status: superseded by ADR-NNNN`.
