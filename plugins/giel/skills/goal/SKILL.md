---
name: goal
description: Reach any goal with the fewest tokens. Sizes and types the problem, then answers it alone or fans out to cheap parallel subagents; Fable leads only large, high-stakes goals. Use when the user types /goal or asks to work a goal, research question or decision through end to end.
---

# /goal
Agent names: with the plugin, prefix giel: (giel:researcher). Explore has no prefix.

## Pocock skills
Use them where they fit; they live per repo, so outside a repo fall back to the steps below.
- Decisions only the user can make: /grill-me (small) or /grill-with-docs (in a repo).
- The goal is "build something": hand over to the pipeline: /to-spec, /to-tickets,
  then /implement-spec or /implement, then /code-review. /wayfinder for a large build project.
- CHAOTIC: /diagnosing-bugs. COMPLEX: /prototype for the experiments.
- A research subquestion in a repo: /research.
- Phase boundaries and long goals: /ask-matt to choose continue, new session or subagent;
  /handoff before the context runs out.
- Skills that spawn agents (/implement-spec, /code-review, /research) run from the main session only.
- A subquestion that needs someone other than the user: you draft the message with the Socratic
  skills (socratic-reply, socratic-question-check, socratic-conversation); the user sends it.
  On a reply, reread the thread and the Person context first.

## 1. Frame (you, no subagents)
- Problem statement: one precise question, what success looks like, constraints,
  and what "good enough" means for the decision.
- Read what is known first: memory, the repo, this conversation, lessons.md next to this file.
- If a decision only the user can make blocks everything, ask now (max 3 questions).
  Otherwise continue and list your assumptions.

## 2. Size and type it; tell the user both in one line
Size sets how many subagents:
- SMALL: one question, 3-10 tool calls. Do it yourself.
- MEDIUM: 2-4 independent subquestions. 2-4 subagents; you synthesise.
- LARGE: 5+ subquestions, or ambiguous, high-stakes or hard to reverse.
  strategist BREAKDOWN first, then its subquestions, then strategist SYNTHESIS.
Type sets the method:
- CLEAR: best practice applies. Answer directly.
- COMPLICATED: the answer exists but needs analysis. Research.
- COMPLEX: nobody can know it upfront (markets, people, new offers).
  Research what is knowable; propose 1-3 small safe-to-fail experiments for the rest (/prototype).
- CHAOTIC: something is broken now. Stabilise first, analyse after (/diagnosing-bugs).
Subquestions that depend on each other run in order, not in parallel.

## 3. Hypothesis first, then break it down
- Write your provisional answer.
- Split the goal into subquestions that test it: no overlap, no gaps.
  Drop any whose answer could not change the decision.
- Cheapest tier that can answer each:
  Explore (Haiku): local files, code, repo docs.
  researcher (Sonnet): web or docs facts, prices, comparisons.
  general subagent (Sonnet): calculations in code, drafting, implementation.
  deep-researcher (Opus): conflicting sources, or costly if wrong.
- One correct answer that code can produce = a code task, not a reasoning task.
  Recurring work: a rerunnable script beats an agent that reasons again.
- A better approach than the user's plan: a researcher checks official docs and best
  practices first; propose it only with those sources.
Brief template:
  Chain: <one line per level, from the goal down to this subquestion>
  Objective: <one question>
  Context: <file paths, URLs, issue numbers: pointers, not pasted content>
  Person (if one is involved): <who, how the user relates to them, the thread so far, what the user wants>
  Tools and sources: <allowed>
  Stop when: <answered, or N tool calls>
  Not yours: <neighbouring subquestions>
  Return: max 10 lines, ending with "Serves: <chain line>" and
    "Changes the hypothesis: yes/no + one sentence".
  If only the user can answer: stop and return
    "Blocked: needs Giel. Question: <one line>. Serves: <chain line>. Assumed meanwhile: <assumption>."
  Skill: <the Pocock skill to use, if one fits, e.g. tdd for implementation>
  Never spawn subagents.

## 4. Run
- Launch all independent subagents in one message, in the background. Don't redo their work.
- Write each return to goals/<slug>/<n>-<name>.md yourself.
  goals/ sits in the repo (on a branch), or in ~/goals/<context>/ outside a repo.

## 5. Check, escalate, stop
- Read the returns. Open a findings file only when returns conflict or are thin.
- Weak or conflicting answer: rerun one tier up (Haiku, Sonnet, Opus), once per subquestion.
  After that, report the gap. Never escalate a needs-Giel block.
- Needs-Giel blocks: collect them.
  Block everything: ask the user at once, max 3 questions, each with three options:
  the answer, access to the source (folder, connector), or continue on the assumption.
  Block one branch: continue on the assumption; mark the conclusions that rest on it.
  Unattended run: write them to goals/<slug>/questions.md, notify the user, stop that branch.
- Stop when the answer meets "good enough", or when no return changes the hypothesis.

## 6. Synthesise
- SMALL or MEDIUM: you. LARGE: strategist SYNTHESIS with the returns and file paths.
- To the user: the answer, the bottleneck (the one constraint that blocks the goal),
  the decision it supports, open risks, sources. Per key claim, its source type:
  own, official, secondary, web or model. Under 300 words unless asked.
- Another round only if it would change a decision. Ask first.

## 7. Next actions
End with 1-3 actions aimed at the bottleneck, as if-then plans: "When <situation>, I <action>."
One of them handles the main obstacle.

## 8. Leave a trace
- Per agent run, append one line to goals/<slug>/trace.tsv with a single printf, not by reasoning:
  date, slug, chain line, agent, model, result in a few words, changes hypothesis y/n, needs-Giel y/n.
- outcome.md: the expected result and a check date. Set a reminder with the scheduling tool if
  there is one; otherwise the monthly retro lists overdue checks. On that date, ask what happened
  and for a 1-5 score, and append both to trace.tsv.
- Answers the user gave: store them in the repo docs or memory, so no agent asks again.
- A correction from the user: propose one line for lessons.md in a dev-standards PR.
- If the goal becomes something to build: propose a repo via new-project.sh.

## Budget guards
- Max 8 subagents per round. Max 2 rounds without asking.
- No Fable on SMALL or MEDIUM goals. Opus workers only as deep-researcher or an escalation.
