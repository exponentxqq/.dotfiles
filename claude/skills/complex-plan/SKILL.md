---
name: complex-plan
description: Use when the user wants to plan a complex multi-step feature or change with full design spec and task breakdown before implementing.
---

# complex-plan

## Overview

End-to-end planning flow: explore codebase → brainstorm approaches → write design spec → user approval → break into tasks.

## When to Use

- User asks to "plan", "设计", or "规划" a complex feature before coding
- Multi-file, multi-module changes that need architectural decisions
- NOT for simple single-file fixes or obvious implementations

## Steps

1. **Clarify scope** (if needed)

   If the input is vague, use **AskUserQuestion** to clarify:
   - What exactly should be built/changed?
   - Any constraints or preferences?

2. **Explore the codebase**

   Use structural search first, then Read/Grep as fallback:
   - `smart_search` to find related code by keyword or symbol
   - Read relevant files to understand current implementation

3. **Brainstorm approach**

   Generate 2-3 possible approaches with tradeoffs. For each:
   - One-line summary
   - Key tradeoff (what you gain vs. what you lose)
   - Effort estimate (small/medium/large)

   Present via **AskUserQuestion** and wait for user selection.

4. **Write design spec**

   Write the design to `docs/superpowers/specs/<date>-<slug>-design.md`:

   ```markdown
   # <Title> Design

   ## Goal
   <one paragraph>

   ## Approach
   <selected approach description>

   ## Key Changes
   - <file/component>: <what changes and why>
   - ...

   ## Data Flow
   <if applicable>

   ## Open Questions
   <if any>
   ```

5. **Wait for approval**

   Present the design and ask user to approve. Do not proceed until approved.

6. **Break into tasks**

   Write the plan to `docs/superpowers/plans/<date>-<slug>-implementation.md`:

   ```markdown
   # <Title> Implementation Plan

   ## Tasks
   1. **<task title>** — <description>
      - Files: <list>
      - Depends on: <task # or none>
   2. ...
   ```

   Create corresponding items via **TaskCreate** tool.

7. **Ready to implement**

   Summarize:
   - Design doc location
   - Plan doc location
   - Number of tasks
   - Ask: "Ready to implement? Or adjust the plan first?"

**Guardrails**

- Always explore before designing — never design based on assumptions alone
- Keep the design concise (one screen), not a novel
- Tasks should be independently committable where possible
- If the user says "可以" (okay), treat it as full approval and proceed immediately
- Follow the existing spec/plan file naming convention in the project
