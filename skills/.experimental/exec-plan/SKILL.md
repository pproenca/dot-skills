---
name: exec-plan
description: |
  Manage the lifecycle of ExecPlans — self-contained, living specifications for multi-step work.
  Creates plans in the correct format, enforces living section updates, and handles the
  active → completed transition. Use for any work expected to take more than one session or
  touching more than 3 files.
  Triggers: "create a plan", "write a plan", "start plan", "continue plan", "resume plan",
  "finish plan", "complete plan", multi-step features, refactors, or tasks spanning sessions.
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
---

# ExecPlan — Lifecycle Management

**Announce at start:** "Using the exec-plan skill."

## What is an ExecPlan

A self-contained, living document that a fresh agent session can follow to deliver observable, working behavior. Lives in `docs/exec-plans/`. The format follows the specification in `docs/PLANS.md`.

An ExecPlan is NOT a todo list. It is a narrative that tells the story of a change: why it matters, what the codebase looks like now, what it should look like after, and how to prove it worked.

## When to use this skill

- **Required** for multi-step or multi-file work, new features, refactors, or tasks expected to take more than about an hour.
- **Optional** for trivial fixes, but if you skip it for a substantial task, state the reason.
- **Always** when resuming work from a previous session.

## The Three Modes

### Mode 1: CREATE a new plan

When starting new multi-step work:

1. Read `docs/PLANS.md` for the template and requirements.
2. Create the plan at `docs/exec-plans/active/{descriptive-kebab-name}.md`.
3. Fill ALL sections from the template. Non-negotiable sections:
   - **Purpose / Big Picture** — what the user can see/do after the change
   - **Progress** — empty checkboxes for each milestone
   - **Surprises & Discoveries** — start with `(none yet)`
   - **Decision Log** — start with `(none yet)`
   - **Outcomes & Retrospective** — start with `(fill when complete)`
   - **Context and Orientation** — full file paths, term definitions, current state
   - **Plan of Work** — narrative milestones with goal → work → result → proof
   - **Concrete Steps** — exact commands with expected outputs
   - **Validation and Acceptance** — observable proof of success
   - **Idempotence and Recovery** — how to retry or roll back
4. Every file path must be absolute from repo root.
5. Every term must be defined inline — assume the reader knows nothing.
6. Commit the plan before starting implementation.

### Mode 2: CONTINUE an existing plan

When resuming work or executing the next milestone:

1. Read the plan file in `docs/exec-plans/active/`.
2. Find the first unchecked item in Progress.
3. Before starting work, check: are there any Surprises from previous sessions that affect this task?
4. Execute the milestone following the Plan of Work.
5. **After each completed milestone, IMMEDIATELY update the plan:**
   - Check the Progress item with a timestamp: `- [x] (YYYY-MM-DD HH:MMZ) Description`
   - Add any Surprises & Discoveries encountered
   - Add any Decision Log entries for choices made
6. Commit the plan update alongside the code changes.
7. Run the Validation commands to confirm success.

**CRITICAL: Never claim a milestone is done without updating the plan file.** The plan IS the persistence mechanism. If you don't update it, the next session will redo the work.

### Mode 3: COMPLETE a plan

When all milestones are done:

1. Fill the **Outcomes & Retrospective** section:
   - What was achieved vs what was planned
   - Any remaining gaps
   - Lessons learned
   - Unexpected benefits or costs
2. Move the file: `git mv docs/exec-plans/active/{name}.md docs/exec-plans/completed/{name}.md`
3. Commit with message: `docs: complete exec-plan {name}`

## Quality Checks

Before committing any plan (new or updated), verify:

- [ ] Purpose describes user-visible behavior, not just code changes
- [ ] Progress has timestamps on completed items
- [ ] Context names files by full path from repo root
- [ ] All terms are defined inline (no "see external doc" for critical terms)
- [ ] Validation has exact commands AND expected outputs
- [ ] Recovery section explains rollback for each risky step
- [ ] Surprises section is up to date (even if empty)
- [ ] Decision Log captures any choices made during implementation

## Anti-patterns

- **Checklist without narrative**: "- [ ] Edit file X" tells the next session nothing. WHY edit it? WHAT changes? HOW to verify?
- **External references for critical context**: "See ARCHITECTURE.md for details" — the plan must be self-contained. Copy the relevant context in.
- **Forgetting to update Progress**: The most common failure. If you finish a milestone and don't check the box with a timestamp, the next session will redo it.
- **Leaving completed plans in active/**: After all milestones are done, MOVE to completed/. Active plans should only be unfinished work.
- **Skipping Validation**: "Tests pass" is not acceptance. "The `isValid` computed property no longer exists in the file, verified by `grep -n isValid file.swift` returning no results" IS acceptance.

## Integration with other skills

- Before implementing plan milestones that involve TCA code: invoke `/pfw-composable-architecture`
- Before implementing plan milestones that involve debugging: invoke the `debug` skill
- Before implementing plan milestones that involve refactoring: invoke the `refactor` skill
- Before implementing plan milestones that involve API design: invoke the `rest-api-design` skill
- After completing all plan milestones: invoke `refactor` skill for a final cleanup pass
