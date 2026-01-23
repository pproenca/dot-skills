## Task Management

- Always use TaskCreate for any task with 2+ steps
- Break tasks into small, atomic units (carpaccio slicing)
- Each task should be completable in a single focused action
- Include acceptance criteria in task descriptions
- Set up task dependencies with addBlockedBy/addBlocks

## Development Workflow - TDD Required

- **Red-Green-Refactor**: Write failing test first, then implementation
- For every feature task, create a preceding test task that blocks it:
1. "Write failing test for X" (test task)
2. "Implement X to pass test" (blocked by test task)
3. "Refactor X" (blocked by implementation)
- Never mark implementation tasks complete until tests pass
- Test tasks must include specific assertions in description

## Plan Mode

- At the end of each plan, give me a list of unresolved questions to answer, if any. Use the AskUserQuestions to clarify.
- Make sure that the plan leads to comprensive list of tasks, dependencies defined where possible, it's better to slice tasks like carpaccio than overly broad tasks
