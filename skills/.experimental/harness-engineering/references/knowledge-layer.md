# Knowledge Layer: AGENTS.md, docs/, ARCHITECTURE.md

This reference provides templates and writing guidance for the knowledge artifacts
that give agents a map of the codebase.

## AGENTS.md Writing Guide

### Philosophy

AGENTS.md is a **table of contents**, not an encyclopedia. When everything is
"important," nothing is. A giant instruction file crowds out the task, the code,
and the relevant docs — agents end up pattern-matching locally instead of
navigating intentionally.

A good AGENTS.md:
- Fits in ~100 lines
- States the 3–5 rules that cause the most damage when violated
- Points to deeper sources of truth (never duplicates them)
- Tells agents where to look, not what to know
- Includes verification commands (build, test, lint)

### AGENTS.md Template

```markdown
# [Project Name] — Agent Guide

[1–2 sentences: what this project is and its primary purpose.]

## Non-Negotiable Rules

[3–5 rules. These are the ones that, if violated, cause real damage.
Be specific. Don't list general best practices — list THIS repo's critical
invariants.]

1. [Rule 1 — specific to this repo]
2. [Rule 2]
3. [Rule 3]

## Repository Map

- `ARCHITECTURE.md` — Domain boundaries, dependency rules, module map
- `docs/design-docs/` — Design history and decisions (see `docs/design-docs/index.md`)
- `docs/exec-plans/active/` — Work in progress
- `docs/product-specs/` — Feature specifications (see `docs/product-specs/index.md`)
- `docs/references/` — External documentation in agent-friendly format
- `.harness/` — Machine-readable harness configuration (domains, principles, rules)

## Tech Stack

[Brief: languages, frameworks, build system, key dependencies]

## Verification

Run these before marking work complete:

[Exact commands with working directory context]

## Code Organization

[Brief description of how the codebase is organized — domain structure,
key directories, where new code goes. 5–10 lines max.]
```

### Common Mistakes

- **Too long**: If AGENTS.md exceeds 120 lines, refactor into docs/ with pointers
- **Duplicating docs/**: AGENTS.md points to docs, it doesn't repeat them
- **Generic rules**: "Write clean code" is useless. "All API responses must use the
  ResponseEnvelope type from src/shared/types" is actionable
- **Stale references**: Every path in AGENTS.md must point to a real file
- **Missing verification**: Agents need to know how to check their own work

## Progressive Disclosure: The Structural Principle

Progressive disclosure isn't just a property of AGENTS.md — it's the design
principle for every document in the harness. Agents start with a small, stable
entry point and are taught where to look next, rather than being overwhelmed.

Without this, the harness recreates the "one big AGENTS.md" problem at the
file level — each doc becomes a wall of text that agents load entirely into
context.

### Structure Every Doc in Three Tiers

**Tier 1 — Summary** (2–3 sentences at the top)
Enough for an agent to decide: "Is this file relevant to my current task?"
If not, the agent stops reading here and moves on.

**Tier 2 — Key Decisions** (the 3–5 most important things)
The rules, patterns, or facts that agents need most often. These should be
scannable — tables, short lists, or bold callouts.

**Tier 3 — Full Detail**
Complete explanations, examples, edge cases, historical context. Agents read
this only when working deeply in this area.

### Example: A Domain Guide

```markdown
# Billing Domain Guide

Billing handles subscription management and payment processing via Stripe.
All payment operations go through the BillingService — never call Stripe
directly from other domains.

## Key Rules
- All money amounts use `Money` type from `src/billing/types` (never raw numbers)
- Webhook handlers must be idempotent (Stripe retries on failure)
- Payment state transitions must be persisted before acknowledging the webhook

## Architecture
[Detailed layer breakdown...]

## Stripe Integration
[API patterns, error handling, testing with test clocks...]
```

### How This Applies Across the Harness

| Artifact | Tier 1 | Tier 2 | Tier 3 |
|----------|--------|--------|--------|
| AGENTS.md | What the repo is | Non-negotiable rules | Pointers to docs/ |
| ARCHITECTURE.md | Architectural philosophy | Domain map + dependency rules | Per-domain detail |
| docs/\<DOMAIN\>.md | What the domain does | Key rules and patterns | Full implementation guide |
| design-docs/index.md | Purpose of design docs | Status table of all docs | Verification notes |
| exec-plans/active/*.md | Purpose of the plan | Progress + next steps | Full milestones + history |

## docs/ Structure Guide

### design-docs/

**index.md** — Catalogue of all design documents with:
- Title and one-line description
- Status: draft, accepted, superseded, deprecated
- Verification status: verified against current code, unverified, stale
- Date and author

**core-beliefs.md** — Agent-first operating principles for this specific repo.
Not generic software principles — beliefs that shape how agents should make
decisions in THIS codebase. Examples:
- "We prefer boring, well-documented technologies over cutting-edge ones because
  agents reason better about APIs with extensive training data."
- "We reimplement small utilities rather than pulling in large opaque dependencies
  because agents need to inspect and modify the full dependency surface."

### exec-plans/

Follow the ExecPlan format defined in PLANS.md (if the repo has one) or use
this minimal structure:

**active/** — Plans for in-flight work. Each plan is a living document with
progress tracking, decision logs, and acceptance criteria.

**completed/** — Finished plans kept for context. Future agents use these to
understand why the codebase looks the way it does.

**tech-debt-tracker.md** — Known technical debt with priority, impact, and
estimated effort. Updated as debt is discovered or resolved.

### product-specs/

**index.md** — Feature catalogue mapping user-facing features to:
- The spec document
- The primary code path / domain
- Current status (planned, in-progress, shipped)

**\<feature\>.md** — Each spec describes what the user can do (acceptance
criteria), not how the code works. Implementation details belong in the code
and design docs.

### references/

External documentation converted to agent-friendly format. When the repo
depends on a library or service whose docs are not in the training data (or
are newer than the training cutoff), include the relevant portions here.

Name files descriptively: `nextjs-app-router.md`, `stripe-webhooks.md`,
`internal-auth-api.md`.

### Domain guides (docs/\<DOMAIN\>.md)

Create these only when a domain needs guidance beyond what ARCHITECTURE.md
and the domain's code structure convey. Common examples:
- `FRONTEND.md` — Component patterns, state management, design system usage
- `DESIGN.md` — Design system reference, tokens, component API
- `RELIABILITY.md` — SLOs, retry patterns, circuit breaker configuration
- `SECURITY.md` — Threat model, auth boundaries, data classification
- `PLANS.md` — ExecPlan template and maintenance rules

Each guide should be self-contained enough that an agent reading it can
make correct decisions in that domain without additional context.

## ARCHITECTURE.md Template

```markdown
# Architecture

[2–3 sentences: architectural philosophy and primary constraints.]

## Domain Map

[Table or diagram showing the major domains and their relationships.]

| Domain | Path | Description | Key dependencies |
|--------|------|-------------|-----------------|
| [name] | [path] | [what it does] | [what it depends on] |

## Dependency Rules

[Explain the dependency direction rules. Which layers exist, what can
import what, where cross-cutting concerns enter.]

## Cross-Cutting Concerns

| Concern | Entry point | Used by |
|---------|------------|---------|
| [auth] | [providers/auth] | [all domains] |
| [telemetry] | [providers/telemetry] | [all domains] |

## Where New Code Goes

[Decision guide: given a new feature or change, how to determine which
domain it belongs to and which layer to put it in.]

## Key Interfaces

[List the 3–5 most important interfaces/types that bridge domains.
Name them by full path so agents can find them.]
```
