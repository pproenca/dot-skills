## What This Repo Is

dot-skills is a curated collection of Agent Skills (markdown rule packs + scripts).

- `skills/.curated/` — stable, published skills
- `skills/.experimental/` — new / in-progress skills. **New skills start here.**
- Skills are authored and evolved with the dev-skill plugin: `/dev-skill:new`, `:ingest`, `:evolve`, `:validate`.
- dev-skill disciplines: distillation / composition / investigation / extraction.
  **Don't mix disciplines in one skill dir** — adding a `scripts/` dir to a distillation
  skill flips its detected discipline and breaks validation. Build a sibling skill instead.

## Definition of Done — run before every commit

When asked to "run all the skill validation and audit scripts" (or before committing skill changes):

```bash
npm run validate                          # skills-ref: structural validation of every skill
node scripts/check-versions.mjs           # flag STALE/DIRTY skill versions
scripts/generate-readme-tables --update   # regenerate README skill tables
npm test                                   # skills-ref validator test suite
```

Fix every reported issue, then commit & push. A goal is not complete until verified.

## Task Management

- Always use TaskCreate for any task with 2+ steps
- Break tasks into small, atomic units (carpaccio slicing)
- Each task should be completable in a single focused action
- Include acceptance criteria in task descriptions
- Set up task dependencies with addBlockedBy/addBlocks

## Development Workflow — Validator-First

Most work here is authoring markdown rule files, so the validators are the test gate
(the equivalent of red-green-refactor):

1. **Red** — run the validator and read the failures:
   - whole repo: `npm run validate`
   - single skill while authoring: dev-skill's discipline-aware `validate-skill.js` (`/dev-skill:validate <path>`)
2. **Green** — fix rule files until the validator reports **0 errors**.
3. **Refactor** — tighten wording / dedupe rules, then re-validate to stay green.

- Never consider a skill done while the validator reports errors.
- When changing the tooling itself (`scripts/`, `tests/`), keep classic TDD: add/extend
  a fixture in `tests/`, watch it fail, then make `npm test` pass.

## Plan Mode

- At the end of each plan, give me a list of unresolved questions to answer, if any. Use the AskUserQuestions to clarify.
- Make sure that the plan leads to comprensive list of tasks, dependencies defined where possible, it's better to slice tasks like carpaccio than overly broad tasks

## Gotchas

- **Skill `description` ≤ 1024 chars** (enforced by skills-ref). This is the most common
  validation failure — check length before committing a new or edited SKILL.md.
- **README tables are generated** — always run `scripts/generate-readme-tables --update`;
  never hand-edit the skill tables in README.md (they get clobbered).
- **Per-skill validation** during authoring uses dev-skill's `validate-skill.js`, which is
  separate from `skills-ref` and discipline-aware; aim for 0 errors.
