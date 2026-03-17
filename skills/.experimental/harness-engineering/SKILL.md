---
name: harness-engineering
description: >
  Set up or update the agent-first engineering harness for any repository.
  Implements the complete scaffolding that makes AI coding agents effective:
  knowledge maps (AGENTS.md as a concise TOC), structured documentation,
  architecture boundaries, enforcement rules (.harness/*.yml specs), quality
  scoring, and process patterns for agent-driven development.

  Use this skill whenever someone wants to make a repo agent-ready, set up
  AGENTS.md or docs/ structure, define domain boundaries or golden principles,
  generate .harness/ configuration, audit agent readiness, or update an
  existing harness. Also trigger when a user reports problems with agent
  effectiveness, context management, or architectural drift — these are
  symptoms of a missing or stale harness.

  Trigger on: "harness this repo", "set up harness", "agent-first setup",
  "make this agent-ready", "update the harness", "assess agent readiness",
  "set up AGENTS.md", "organize for agents", or any discussion about
  structuring a codebase for AI agent workflows.
---

# Harness: Agent-First Engineering Scaffolding

The harness is the scaffolding that makes coding agents effective in a repository.
It encodes the knowledge, boundaries, and rules that an agent needs to reason
about the full business domain directly from the repo itself.

The philosophy: **agents execute, humans steer**. The engineer's job is not to
write code but to design environments, specify intent, and build feedback loops.
The harness is what makes this possible.

## Why It Matters

From the agent's point of view, anything it can't access in-context while running
effectively doesn't exist. Slack discussions, Google Docs, tacit team knowledge —
all invisible. The harness makes this knowledge legible by encoding it as
repository-local, versioned artifacts.

A well-harnessed repo gives agents:
- A **map** (AGENTS.md) — where to look, not what to memorize
- **Boundaries** (domain specs) — what can depend on what
- **Rules** (golden principles) — taste encoded as enforceable invariants
- **Quality baselines** (scoring) — where the gaps are

Without this scaffolding, agents replicate whatever patterns they find — including
bad ones. The harness is what prevents entropy from compounding.

## Harness Maturity Model

The harness is built incrementally. Each level builds on the previous — don't
try to jump from Level 0 to Level 4 in one pass. Assess the current level and
build toward the next.

| Level | Name | What it enables | Key artifacts |
|-------|------|----------------|---------------|
| 0 | Unharnessed | Agents guess everything — no map, no rules | Nothing |
| 1 | Map | Agents know where to look and what the codebase does | AGENTS.md, ARCHITECTURE.md, docs/ |
| 2 | Rules | Agents know what's allowed and what isn't | .harness/principles.yml, enforcement.yml, domains.yml |
| 3 | Feedback | Agents self-correct via quality signals and process patterns | .harness/quality.yml, doc-gardening, GC sweeps |
| 4 | Autonomy | Agents operate independently with defined escalation boundaries | Worktree isolation, escalation rules, agent-to-agent review |

Each level compounds. A repo at Level 2 without Level 1 has rules nobody can
find. A repo at Level 3 without Level 2 has quality grades but no way to
enforce improvement. Build the foundation first.

During assessment (Phase 1), determine the current maturity level. During
planning (Phase 2), target the next level — not all levels at once. Repeat
the harness workflow to climb.

**Critical exception**: for repos where agents are actively writing code
(agent-first or agent-assisted), architecture boundaries (domain definitions
and the forward-only dependency rule) should be co-created alongside the
knowledge layer, not deferred to a separate Level 2 pass. The article is
explicit: strict architecture is a day-one prerequisite for agent-driven
development, not a scaling concern. Without boundaries, agents produce code
faster than entropy can be contained.

## Multi-Turn Workflow

Building a harness is interactive. Work through the phases below, presenting
results and waiting for user confirmation at each phase boundary. The user may
want to skip, reorder, or expand phases — follow their lead.

```
Phase 1: Assess    → Analyze the repo, report agent readiness
Phase 2: Plan      → Propose a tailored harness, user confirms
Phase 3: Knowledge → AGENTS.md, docs/, ARCHITECTURE.md
Phase 4: Domains   → Identify domains, map layers, generate .harness/domains.yml
Phase 5: Enforce   → Golden principles, rules → .harness/principles.yml, enforcement.yml
Phase 6: Quality   → Grade domains → .harness/quality.yml
Phase 7: Process   → Doc-gardening, GC, review patterns
Phase 8: Verify    → Cross-check everything, report completeness
```

### Depth-First Bootstrap

Build the harness depth-first, not breadth-first. Early harness work is slower
than expected — not because the repo is broken, but because the environment is
underspecified. Each phase unlocks the next:

- AGENTS.md unlocks docs/ (agents know where to put deeper content)
- docs/ unlocks architecture awareness (agents can read domain context)
- Architecture specs unlock correct domain identification
- Domain specs unlock meaningful enforcement rules
- Enforcement rules unlock quality scoring (you can't grade what you can't check)

When something fails, the fix is almost never "try harder." Ask: **what
capability or context is missing?** Then build that piece first.

For **updates** to an existing harness, the same phases apply but the assessment
diffs against current .harness/ specs and only what has drifted gets updated.

## Phase 1: Assess

Examine the repository across every harness layer. The goal is understanding
what exists, what's missing, and what's misaligned — not immediately fixing things.

**What to examine:**

| Area | What to look for |
|------|-----------------|
| Structure | Directories, languages, package manifests, monorepo vs single-package |
| Tech stack | Frameworks, build systems, deployment targets, dependency managers |
| Agent config | AGENTS.md, CLAUDE.md, .cursor/, .github/copilot/, any existing agent instructions |
| Documentation | README, docs/, architecture docs, ADRs, inline doc comments |
| Code organization | Domain structure, module boundaries, import patterns, dependency graph |
| Tests | Frameworks, coverage, CI gates, test organization |
| Observability | Logging patterns (structured?), metrics, error handling, tracing |
| Process | PR templates, review workflow, CI/CD configuration |
| Team config | Agent-first (agents write 90%+ code), agent-assisted (mixed), or agent-ready (preparing for future agent use) |
| Dependencies | Are external libraries agent-legible? Stable APIs, good docs, training data representation? |

Read `references/assessment.md` for the detailed checklist and scoring rubric.

**Team configuration shapes the harness**: an agent-first repo needs strong
enforcement and GC from day one. An agent-assisted repo needs clear boundaries
but can rely more on human review. An agent-ready repo mostly needs the
knowledge layer.

**Output:** An Agent Readiness Report — a structured summary of current state per
layer, key findings, and recommended harness components (prioritized).

Present the report and wait for the user to confirm or adjust before planning.

## Phase 2: Plan

Propose a harness plan tailored to this specific repo. Not every repo needs every
component — right-size based on the assessment.

**Sizing by maturity level:**

| Current level | Target | What to build |
|--------------|--------|---------------|
| 0 → 1 | Map | AGENTS.md, ARCHITECTURE.md, core docs/ structure |
| 1 → 2 | Rules | .harness/domains.yml, principles.yml, enforcement.yml |
| 2 → 3 | Feedback | .harness/quality.yml, doc-gardening, GC patterns |
| 3 → 4 | Autonomy | Worktree isolation, escalation boundaries, agent review |

Also consider repo size — a small repo (< 5k LOC) may only need Level 1–2,
while a large codebase (50k+ LOC) benefits from all four levels.

The plan should list every artifact to be created or updated, grouped by phase,
with a brief note on what each one does. Present it as a checklist the user can
approve, modify, or trim.

Wait for confirmation before implementing.

## Phase 3: Knowledge Layer

Build the artifacts that give agents a map of the codebase.

### AGENTS.md (~100 lines)

The single most important file. It is a **routing table**, not an encyclopedia.

It should contain:
- 3–5 non-negotiable rules (the ones that cause the most damage when violated)
- Pointers to deeper docs: `ARCHITECTURE.md`, `docs/`, active plans
- How to verify work (build/test commands)
- What the repo is and how it's structured (2–3 sentences)

Everything else belongs in `docs/`. If AGENTS.md exceeds ~100 lines, it's too long
and should be refactored into docs/ with pointers.

### docs/ Directory

```
docs/
├── design-docs/
│   ├── index.md              # Catalogue with verification status
│   └── core-beliefs.md       # Agent-first operating principles
├── exec-plans/
│   ├── active/               # In-flight work
│   ├── completed/            # Done work (context for future agents)
│   └── tech-debt-tracker.md  # Known debt with priority
├── generated/                # Auto-generated (DB schema, API specs)
├── product-specs/
│   ├── index.md              # Feature catalogue
│   └── <feature>.md
├── references/               # External docs in agent-friendly format
├── PRODUCT_SENSE.md          # Product principles, personas, domain sensitivity
└── <DOMAIN>.md               # Domain guides (only those relevant to the repo)
```

Every file in docs/ should follow progressive disclosure structure:
1. **Summary** (2–3 sentences) — enough for an agent to decide if this file is relevant
2. **Key decisions** — the 3–5 most important things, up front
3. **Details** — full content for agents that need to go deeper
4. **Pointers** — links to related docs for further context

This prevents the "one big AGENTS.md" problem from recurring at the file level.
Agents should be able to read just the summary of each doc and navigate to the
right one, rather than loading every file into context.

Only create what the repo actually needs. Each file should contain real content
derived from the assessment — not boilerplate.

### ARCHITECTURE.md

Top-level domain map answering: what are the domains, how do they relate,
what are the dependency rules, where does new code go.

Read `references/knowledge-layer.md` for templates and writing guidance.
Read `references/core-beliefs.md` for the core beliefs template and content guide.

## Phase 4: Architecture Layer

Define domain boundaries and dependency rules as machine-readable specs.

### Domain Identification

A domain is a **vertical slice** — a tracer bullet that cuts through all
integration layers end-to-end, from data shapes to user-facing output. It is
NOT a horizontal technical layer.

**The litmus test**: can you trace a user action from UI through runtime,
service, repo, and types — and does that path stay within one coherent business
concept? If yes, that's a domain.

```
CORRECT (vertical slices):        WRONG (horizontal layers):
┌─────────┐ ┌──────────┐         ┌──────────────────────────┐
│ Billing  │ │ Onboard  │         │ controllers/             │ ← NOT a domain
│ ┌─────┐  │ │ ┌─────┐  │         │ models/                  │ ← NOT a domain
│ │Types│  │ │ │Types│  │         │ services/                │ ← NOT a domain
│ │Confg│  │ │ │Confg│  │         │ utils/                   │ ← NOT a domain
│ │Repo │  │ │ │Svc  │  │         └──────────────────────────┘
│ │Svc  │  │ │ │UI   │  │
│ │UI   │  │ │ └─────┘  │
│ └─────┘  │ └──────────┘
└─────────┘
```

Look for business concepts, not technical functions:
- "billing", "onboarding", "search" = domains (vertical, own their full stack)
- "controllers", "utils", "testing", "tooling" = layers or concerns (horizontal)

Read `references/architecture-layer.md` for detailed identification heuristics
and the tracer-bullet test.

### Layer Structure

Within each domain, code is organized into layers:

```
Types → Config → Repo → Service → Runtime → UI
```

**The key rule: dependencies flow forward only.** A `types` module never imports
from `service`. Cross-cutting concerns (auth, telemetry, feature flags) enter
through a single explicit interface called Providers.

Not every domain has every layer. A CLI tool might only have Types → Config →
Service → Runtime. A library might only have Types → Service. Map what exists.

### Generate .harness/domains.yml

Create the domain specification. Read `references/yml-schemas.md` for the schema
and `references/architecture-layer.md` for identification heuristics.

## Phase 5: Enforcement Layer

Encode architectural taste as machine-readable rules. The goal: enforce boundaries
centrally, allow autonomy locally.

### Golden Principles (.harness/principles.yml)

Identify 5–10 opinionated rules specific to this repo. Each principle needs:
- **What**: The rule itself
- **Why**: Why it matters (what goes wrong without it)
- **How to check**: lint, structural test, review, or manual inspection
- **Examples**: Concrete good/bad code snippets from this codebase

Start with principles from the assessment — patterns that are already causing
problems, or invariants that are currently maintained manually but should be
enforced.

### Mechanical Rules (.harness/enforcement.yml)

Concrete rules that tooling can check:
- Naming conventions for files, types, functions
- File size limits
- Structured logging requirements
- Import boundary checks
- Test coverage expectations

### Agent-Legible Error Messages

This is one of the highest-leverage patterns in the entire harness. Every
enforcement rule MUST include a `violation_message` template with four parts:
1. **What's wrong** — the specific violation
2. **Why it matters** — rationale linked to a principle
3. **How to fix it** — concrete remediation steps
4. **Where to look** — file paths or doc pointers

Lint error messages are a delivery mechanism for injecting remediation
instructions into an agent's context at the exact moment it needs them. Generic
messages ("boundary violation in X") are nearly useless. Rich messages
("X imports from Y, violating forward-only rule. Fix: inject via Providers.
See: ARCHITECTURE.md#cross-cutting") let agents self-correct immediately.

### Generate Enforcement Code

The .harness/*.yml specs describe rules. But specs that nothing checks are
documentation that rots — the same problem the harness is designed to prevent.

For every enforcement rule, also generate at minimum one concrete artifact:
- **Lint configuration**: ESLint/Ruff/Clippy config that enforces naming,
  imports, or structural rules — with agent-legible error messages
- **CI workflow**: GitHub Actions / CI job that validates AGENTS.md links,
  docs/ cross-references, or knowledge freshness
- **Structural test**: A test file that validates architectural invariants
  (e.g., import direction, domain boundary compliance)
- **Script**: A validation script that checks file size limits, banned
  patterns, or naming conventions

Even stub implementations are better than nothing. A lint rule with a TODO
body is more valuable than a perfectly documented YAML spec that nothing reads.

Read `references/enforcement-layer.md` for the principles catalog and patterns.
Read `references/yml-schemas.md` for schemas.

## Phase 6: Quality Scoring

Grade each domain across standardized dimensions.

**Dimensions:** code quality, test coverage, documentation, observability,
reliability, security.

**Scale:** A (exemplary) through F (missing/broken).

The initial scoring is a baseline. Future harness updates compare current state
against these grades to track improvement or detect drift.

Generate `.harness/quality.yml` with scores, gap notes, and review dates.
Read `references/quality-scoring.md` for the rubric.

## Phase 6.5: Operational Legibility (if applicable)

For repos with a running application (web app, API, service), assess whether
agents can observe the app, not just the code. The article's team made the
running application directly legible to agents — this is what enabled 6+ hour
autonomous agent sessions.

**Assess and recommend:**
- **Worktree-bootable**: Can the app boot per git worktree so each agent run
  gets an isolated instance? If not, flag this as a high-priority gap.
- **Browser automation**: For UI apps — can agents drive the app via Chrome
  DevTools Protocol (screenshots, DOM snapshots, navigation)?
- **Observability**: Can agents query logs (LogQL), metrics (PromQL), and
  traces (TraceQL) from their own instance?
- **Ephemeral state**: Are logs, metrics, and app state torn down when the
  agent's task completes?

This phase is only relevant for repos with runnable applications. Libraries,
CLI tools, and infrastructure repos can skip it.

## Phase 7: Process Patterns

Document the patterns that keep a harness-driven codebase healthy over time.
These go into the appropriate `docs/` guide files.

- **Doc-gardening**: Recurring scans for stale or incorrect documentation
- **Garbage collection**: Identifying and cleaning up pattern drift, duplicated
  helpers, or accumulated "AI slop" — this is urgent, not optional. Without
  automated GC, agent-generated codebases degrade fast enough to consume 20%
  of engineering time in manual cleanup
- **Agent review**: At Level 3+ maturity, agent-to-agent review should be the
  primary quality gate, not a supplement to human review. Humans review for
  judgment calls only (business logic, product decisions, architectural direction).
  The progression: L1-2 humans review everything → L3 agents pre-review,
  humans spot-check → L4 agent-to-agent review, humans only for escalations.
- **Merge philosophy**: Short-lived PRs, follow-up fixes over indefinite blocking.
  **Prerequisite**: this is only appropriate when automated enforcement is in place
  (Level 2+ maturity), test coverage catches regressions, and agents can generate
  follow-up fixes. Without these, relaxed merge gates are reckless.
- **Feedback encoding**: How review comments and bugs become doc updates or rules
- **Escalation boundaries**: Define what decisions require human judgment vs.
  what agents can resolve autonomously — prevents both over-asking (slow) and
  under-asking (dangerous)

Read `references/process-patterns.md` for templates.

## Phase 8: Verify

After implementation, verify the harness is coherent:

- [ ] Every path referenced in AGENTS.md exists
- [ ] All cross-links in docs/ resolve
- [ ] .harness/*.yml files have valid structure
- [ ] domains.yml domains correspond to actual code directories
- [ ] ARCHITECTURE.md reflects the real module structure
- [ ] Quality scores have been populated for all identified domains
- [ ] Knowledge base structure matches knowledge.yml config

Report findings. Fix issues before marking the harness complete.

## Update Flow

When updating an existing harness:

1. **Detect drift**: Compare .harness/ specs against the actual codebase
   - New directories/modules not in domains.yml
   - Docs referencing deleted or moved files
   - Quality scores older than the configured review cadence
   - Principles being violated in recently added code
2. **Propose targeted updates**: Don't rebuild — update only what drifted
3. **Implement changes**: Same phase structure, but scoped to the drift
4. **Re-verify**: Run the full verification checklist

## .harness/ Directory

All machine-readable harness configuration lives in `.harness/` at the repo root.

```
.harness/
├── config.yml         # Harness metadata, version, tech stack summary
├── domains.yml        # Business domain definitions + layer rules
├── principles.yml     # Golden principles with rationale + examples
├── enforcement.yml    # Mechanical rules (naming, limits, logging, imports)
├── quality.yml        # Per-domain quality grades + gap tracking
└── knowledge.yml      # Knowledge base structure configuration
```

See `references/yml-schemas.md` for complete schemas with examples.

## Adaptation by Tech Stack

The harness is tech-agnostic but the implementation adapts:

- **Naming conventions**: camelCase for JS/TS, snake_case for Python/Rust
- **Layer names**: May differ — "repo" might be "repository" or "data-access"
- **Build commands**: Vary per stack — capture in AGENTS.md
- **Dependency enforcement**: Import style differs between module systems
- **Logging**: Different structured logging libraries per ecosystem

Identify the stack during assessment and adapt all templates accordingly.
Don't force conventions from one ecosystem onto another.
