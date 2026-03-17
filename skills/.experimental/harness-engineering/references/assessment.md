# Assessment Checklist & Scoring

Use this checklist during Phase 1 to evaluate a repository's agent readiness.
Score each layer, then summarize findings in the Agent Readiness Report.

## Checklist

### 1. Knowledge Layer

- [ ] AGENTS.md or equivalent exists
  - Is it concise (~100 lines) or bloated?
  - Does it function as a TOC or as a monolithic instruction manual?
  - Does it point to deeper docs or try to contain everything?
- [ ] docs/ directory exists with organized content
  - Design docs with index and verification status?
  - Execution plans (active and completed)?
  - Product/feature specs?
  - External references in agent-friendly format?
- [ ] ARCHITECTURE.md or equivalent exists
  - Does it describe domain boundaries?
  - Does it map dependencies?
  - Is it current or stale?
- [ ] README provides orientation
  - Quick start, what the project does, how to contribute

### 2. Architecture Layer

- [ ] Clear domain/module boundaries visible in directory structure
- [ ] Dependency patterns are intentional (not spaghetti imports)
- [ ] Cross-cutting concerns have defined entry points
- [ ] No circular dependencies between major modules
- [ ] Layer separation exists (even if informal)

### 3. Enforcement Layer

- [ ] Linting configured (ESLint, Ruff, clippy, etc.)
- [ ] Formatting enforced (Prettier, Black, rustfmt)
- [ ] CI runs checks automatically
- [ ] Import restrictions or boundary checks exist
- [ ] Naming conventions are followed (even if not enforced)
- [ ] File size is reasonable (no 2000+ line files)
- [ ] Structured logging is used (not ad-hoc console.log/print)

### 3.5 Operational Isolation

- [ ] App is bootable per git worktree (isolated instances per change)
- [ ] Each worktree gets its own logs, metrics, and state
- [ ] State is torn down when the task completes
- [ ] Multiple agent runs can work in parallel without stepping on each other
- [ ] Long-running agent sessions (multi-hour) are supported without resource leaks

### 4. Quality Layer

- [ ] Tests exist and run in CI
- [ ] Coverage is tracked
- [ ] Error handling is consistent
- [ ] Observability exists (logging, metrics, tracing)
- [ ] Security boundaries are defined
- [ ] Known tech debt is tracked somewhere

### 5. Process Layer

- [ ] PR/review workflow is defined
- [ ] CI/CD pipeline exists
- [ ] Documentation is maintained alongside code
- [ ] Tech debt is addressed periodically (not just accumulated)
- [ ] Escalation boundaries are defined (what requires human judgment)
- [ ] Agent autonomy levels are documented (what agents can merge/deploy/decide)

## Scoring Rubric

Score each layer on a 1–5 scale:

| Score | Meaning |
|-------|---------|
| 5 | Fully harnessed — comprehensive, enforced, current |
| 4 | Well structured — most components present, minor gaps |
| 3 | Partially structured — some components, inconsistent coverage |
| 2 | Minimal — basic structure but largely unenforced or stale |
| 1 | Absent — no meaningful harness in this layer |

**Overall agent readiness** = average of layer scores:
- 4.0+ = Well harnessed, focus on updates and refinement
- 3.0–3.9 = Partially harnessed, targeted improvements needed
- 2.0–2.9 = Under-harnessed, significant scaffolding needed
- < 2.0 = Unharnessed, full build-out required

## Maturity Level Assessment

In addition to per-layer scores, determine the overall harness maturity level:

| Level | Name | Criteria |
|-------|------|----------|
| 0 | Unharnessed | No agent config, no structured docs, no architectural documentation |
| 1 | Map | AGENTS.md exists and functions as a TOC, ARCHITECTURE.md present, basic docs/ |
| 2 | Rules | .harness/ specs exist with domain definitions, golden principles, enforcement rules |
| 3 | Feedback | Quality scoring active, doc-gardening and GC processes running, feedback encoding |
| 4 | Autonomy | Worktree isolation, escalation boundaries defined, agent-to-agent review operational |

A repo's maturity level is the highest level where ALL criteria are met.
Partial completion of a level means you're "in progress" toward that level.

Report the maturity level in the Agent Readiness Report alongside the layer scores.

## Agent Readiness Report Template

```markdown
# Agent Readiness Report: [repo-name]

## Summary
- **Tech stack**: [languages, frameworks, build tools]
- **Repo size**: [approximate LOC, file count]
- **Overall readiness**: [score] / 5

## Layer Scores

| Layer | Score | Notes |
|-------|-------|-------|
| Knowledge | X/5 | [brief finding] |
| Architecture | X/5 | [brief finding] |
| Enforcement | X/5 | [brief finding] |
| Quality | X/5 | [brief finding] |
| Process | X/5 | [brief finding] |

## Maturity Level
**Current**: Level [X] — [Name]
**Target**: Level [X+1] — [Name]
**Gaps to next level**: [what's missing]

## Key Findings
- [What's working well]
- [What's missing]
- [What's misaligned or stale]

## Recommended Harness Components (prioritized)
1. [Highest impact item]
2. [Next priority]
3. ...

## Domains Identified
- [domain-1]: [brief description, path]
- [domain-2]: [brief description, path]
- ...
```

## Update Assessment Additions

When assessing an existing harness, also check:

- **Drift**: domains.yml domains vs actual directory structure
- **Staleness**: last_reviewed dates in quality.yml vs current date
- **Coverage**: new code directories not covered by any domain spec
- **Violations**: recently added code that breaks principles.yml rules
- **Link rot**: AGENTS.md and docs/ references that point to moved/deleted files

Report drift as a diff: what the spec says vs what the code shows.
