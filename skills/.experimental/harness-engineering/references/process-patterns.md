# Process Patterns

Patterns that keep a harness-driven codebase healthy over time. These go into
the appropriate docs/ guide files during Phase 7.

## Doc-Gardening

Documentation rots. In an agent-driven codebase, stale docs are worse than no
docs — agents follow incorrect instructions with confidence.

### Pattern: Recurring Doc Scan

Set up a background task (agent or CI job) that periodically:
1. Checks every file path referenced in AGENTS.md and docs/ — flags broken links
2. Compares generated/ docs against the current schema/API — flags drift
3. Reviews exec-plans/active/ for plans that haven't been updated recently
4. Scans for TODO/FIXME comments older than a threshold
5. Opens targeted fix-up PRs for issues it can resolve

### Guidelines
- Fix stale docs immediately when discovered during other work
- Treat docs as code: review them in PRs, test links in CI
- Prefer deleting wrong docs over leaving them — no docs is better than misleading docs
- When a doc is updated, check its cross-links and update them too

## Garbage Collection

Agent-generated code accumulates entropy. Agents replicate patterns — including
uneven or suboptimal ones. Without active cleanup, quality degrades.

### Pattern: Golden-Principle Sweep

On a regular cadence (daily or weekly):
1. Scan the codebase for deviations from .harness/principles.yml
2. Grade domains against .harness/quality.yml and compare to last scores
3. Identify duplicated utility code that should be consolidated
4. Open targeted refactoring PRs (small, reviewable, automerge-able)

### The "AI Slop" Problem

The source article describes spending 20% of engineering time cleaning up agent
output. The solution: encode cleanup rules as principles and automate the sweep.

Signals to watch for:
- Hand-rolled helpers that duplicate shared utilities
- Inconsistent error handling patterns across domains
- Test files that test implementation details rather than behavior
- Overly defensive code (try/catch everywhere, redundant null checks)
- Dead code or unused imports accumulating

### Guidelines
- Treat tech debt like a high-interest loan: pay continuously, not in bursts
- Small, frequent cleanup PRs > large periodic refactors
- Capture each new anti-pattern as a principle when first identified
- Track cleanup progress in quality.yml scores

## Agent-to-Agent Review

As throughput increases, human review capacity becomes the bottleneck. Agent
review offloads mechanical checks while preserving human judgment for decisions.

### Pattern: Layered Review

1. **Self-review**: Agent reviews its own changes locally before opening a PR
   (check against principles, run tests, validate boundaries)
2. **Agent review**: A separate agent run reviews the PR against the harness
   specs (architecture, naming, principles, quality)
3. **Human review**: Humans review for judgment calls — business logic correctness,
   product sense, architectural direction
4. **Iterate**: Agent responds to all feedback and re-runs validation until clean

### Guidelines
- Agent review checks mechanical things: boundary violations, naming, principles
- Human review focuses on: correctness, product alignment, taste
- Over time, push more mechanical review to agents, reserve humans for judgment
- Capture review feedback as principle updates or doc improvements

## Merge Philosophy

In a high-throughput agent environment, conventional merge gates become
counterproductive.

### Principles
- **Short-lived PRs**: Changes should be small and merge quickly
- **Follow-up fixes over blocking**: If a non-critical issue is found post-merge,
  a follow-up PR is often cheaper than blocking the original
- **Test flake tolerance**: Address flakes with follow-up runs rather than blocking
  progress indefinitely
- **Corrections are cheap, waiting is expensive**: In a system where agent
  throughput exceeds human attention, fast iteration with fast correction
  outperforms slow, perfect merges

### When to Block
- Security-sensitive changes
- Breaking changes to public API contracts
- Changes that cross multiple domain boundaries
- Anything that affects data persistence or migration

## Feedback Encoding

Every bug, review comment, and user complaint is a signal. The harness should
capture these signals so they compound.

### Pattern: Signal → Rule Pipeline

1. Bug discovered or review feedback given
2. Determine: is this a one-off or a systemic pattern?
3. If systemic: add a principle to principles.yml, add a check to enforcement.yml,
   or update the relevant docs/ guide
4. If one-off: fix it and move on

### Guidelines
- When documentation falls short, promote the rule into code (lint, test, CI check)
- Capture the "why" alongside the "what" — principles without rationale get ignored
- Review feedback that keeps recurring = missing or unclear principle

## The "Promote to Code" Escalation Ladder

Knowledge in a harness-driven codebase has a natural escalation path. Each level
is more expensive to create but more reliable at preventing violations. When a
rule at one level keeps failing, promote it to the next.

```
Level 1: Tacit knowledge     → Lives in people's heads. Invisible to agents.
Level 2: Documentation       → Written in docs/. Agents can read it but may ignore it.
Level 3: Golden principle     → In principles.yml. Agents are told it matters, with rationale.
Level 4: Mechanical lint      → In enforcement.yml. Tooling flags violations automatically.
Level 5: Structural test      → Tests that verify architectural invariants at build time.
Level 6: CI gate              → Blocks merge until the rule is satisfied. Cannot be bypassed.
```

### When to Promote

- **Level 1 → 2**: When the same question gets asked twice. If two different
  agent runs make the same mistake because the knowledge was tacit, write it down.
- **Level 2 → 3**: When documentation exists but agents still violate it. The
  principle format (rule + rationale + examples) is more legible than prose.
- **Level 3 → 4**: When a principle is violated regularly despite being documented.
  Mechanical checking catches violations before they reach review.
- **Level 4 → 5**: When lint rules alone aren't sufficient — the violation is
  structural (e.g., dependency direction) rather than syntactic.
- **Level 5 → 6**: When a structural test exists but violations still slip through
  because the test isn't run before merge. Make it a blocking gate.

### When NOT to Promote

- Don't promote taste to a lint. "This code doesn't feel right" is a review
  comment, not an enforceable rule.
- Don't promote to a CI gate unless the rule is unambiguous and the check is
  reliable. Flaky gates erode trust faster than they prevent violations.
- Don't skip levels. A rule that jumps from tacit to CI gate is brittle because
  nobody documented the rationale, so nobody knows when to change it.

## Escalation Boundaries

Define what decisions require human judgment vs. what agents can resolve
autonomously. Without clear boundaries, agents either ask too much (blocking
throughput) or too little (making dangerous decisions silently).

### Pattern: Decision Classification

Classify decisions into three categories and document them in the process guide:

**Agent-autonomous** (proceed without asking):
- Code changes within a single domain that pass all tests
- Documentation updates that correct factual errors
- Dependency version bumps that pass CI
- Refactoring that doesn't change behavior
- Responding to review feedback with code changes

**Agent-with-notification** (proceed but tell a human):
- Changes that touch multiple domains
- New external dependencies
- Performance-sensitive code changes
- Changes to .harness/ configuration
- Quality score changes (upgrades or downgrades)

**Human-required** (stop and ask):
- Changes to public API contracts or persisted formats
- Security-sensitive changes (auth, encryption, access control)
- Architectural changes that affect domain boundaries
- Deleting or deprecating features
- Changes to escalation boundaries themselves

### How to Document

Add an `escalation` section to `.harness/config.yml`:

```yaml
escalation:
  autonomous:
    - single_domain_changes
    - doc_corrections
    - dependency_bumps
    - refactoring
    - review_response
  notify:
    - cross_domain_changes
    - new_dependencies
    - performance_sensitive
    - harness_config_changes
  human_required:
    - public_api_changes
    - security_changes
    - architectural_changes
    - feature_deprecation
    - escalation_boundary_changes
```

Revisit these boundaries as the harness matures. What starts as human-required
at Level 2 maturity may become agent-autonomous at Level 4.
