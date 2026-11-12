---
name: grill-me
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, get grilled on a design, or uses any 'grill' trigger phrases like "grill me".
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Cap each round at 3–5 questions. If the frontier is larger, ask the most load-bearing questions first — the ones the most other decisions hang off. The rest naturally become next round's frontier as their siblings settle.

Format a round like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

## Carrier by host

When the host provides a structured question tool (DSH: `ask_user_question`), deliver each round through it: one tool call per round, one entry per frontier question. The entry's question text carries the background (why this is being asked now and what the answer changes) and the explanation a markdown round would have carried. Each option carries a description of how it differs from the others; when the choice involves code, configuration, or structure, include a concrete example. Put the recommended option first and mark it as the recommendation (on DSH, append "(Recommended)" to its label).

When the host provides no such tool, keep the ❓ **Q1** / ➡️ markdown round format shown above unchanged.

Both carriers share the same method: the design tree, the frontier, 3–5 questions per round, recommendations worded so "yes" accepts them, and recomputing the frontier after each answer.

Word each question so "yes" accepts your recommended answer.

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
