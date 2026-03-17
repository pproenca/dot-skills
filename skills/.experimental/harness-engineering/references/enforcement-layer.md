# Enforcement Layer: Principles, Rules, and Taste

This reference covers golden principles, mechanical enforcement rules, and
patterns for encoding taste into the codebase.

## Golden Principles

Golden principles are opinionated rules that keep a codebase coherent for agents.
They are specific to each repo — not generic best practices. The key insight:
agents replicate patterns they see. If the codebase has drift, agents amplify it.
Principles arrest this entropy.

### Principle Catalogue

These are starting points. Adapt to the specific repo's needs and challenges.

#### Parse, Don't Validate
**Rule**: Transform data at system boundaries into typed structures immediately.
Don't pass raw data through and validate later.

**Why**: When raw data flows through multiple layers, agents add ad-hoc validation
everywhere. Parsing at boundaries centralizes this — agents downstream can trust
the types.

**Enforcement**: lint / structural test
**Severity**: error

#### Shared Utilities Over Hand-Rolled Helpers
**Rule**: Use shared utility packages for common operations. Don't write one-off
helpers that duplicate logic.

**Why**: Agents copy patterns they find. Scattered helpers breed more scattered
helpers. Centralized utilities mean agents use the right pattern by default.

**Enforcement**: review / structural test
**Severity**: warning

#### No YOLO Data
**Rule**: Don't probe data shapes speculatively. Validate at boundaries or use
typed SDKs so code never builds on guessed shapes.

**Why**: Agents are confident about code they generate, even when it's based on
incorrect assumptions about data shapes. Typed boundaries catch this.

**Enforcement**: lint
**Severity**: error

#### Explicit Error Boundaries
**Rule**: Define where errors are caught and how they're reported. Don't let
exceptions propagate implicitly through multiple layers.

**Why**: Agents add try/catch blocks wherever they see potential errors. Without
clear boundaries, error handling becomes inconsistent and redundant.

**Enforcement**: review
**Severity**: warning

#### Single Source of Truth for Configuration
**Rule**: Each configuration value has exactly one canonical source. No
duplicated env vars, no hardcoded values that should be in config.

**Why**: Agents pull configuration from wherever they find it first. If the same
value exists in three places, agents will read from the wrong one.

**Enforcement**: lint / structural test
**Severity**: error

#### Structured Logging Everywhere
**Rule**: Use the project's structured logger. No ad-hoc console.log, print,
or fmt.Println for operational output.

**Why**: Structured logs are queryable. Agents that emit unstructured logs create
blind spots in observability. When agents can query their own logs, they can
self-diagnose issues.

**Enforcement**: lint
**Severity**: error

### Writing Principles for a Specific Repo

When creating principles for a repo:

1. **Start from the assessment** — What patterns are already causing problems?
   What invariants are maintained manually but should be enforced?
2. **Be specific** — "Write clean code" is useless. "All API responses must use
   ResponseEnvelope<T> from src/shared/types/response.ts" is actionable.
3. **Explain the agent angle** — Why does this principle matter specifically in an
   agent-driven codebase? What goes wrong when agents ignore it?
4. **Include examples from the actual codebase** — Real code > hypothetical code.
5. **Keep to 5–10** — Too many principles become non-guidance. Prioritize the ones
   that would cause the most damage if violated.

## Mechanical Enforcement Rules

These are concrete rules that tooling can check automatically.

### Naming Conventions

Define patterns per entity type. Adapt to the language ecosystem:

| Entity | TypeScript | Python | Swift | Go |
|--------|-----------|--------|-------|-----|
| Files | kebab-case | snake_case | PascalCase | snake_case |
| Types/Classes | PascalCase | PascalCase | PascalCase | PascalCase |
| Functions | camelCase | snake_case | camelCase | PascalCase (exported) |
| Constants | SCREAMING_SNAKE | SCREAMING_SNAKE | camelCase | PascalCase |
| Schemas | PascalCase + Schema suffix | PascalCase + Schema suffix | — | — |

Include exceptions for conventional files: README.md, AGENTS.md, Makefile, etc.

### File Limits

- **Max lines per file**: 300–500 depending on language (smaller for scripts,
  larger for generated code)
- **Max functions per file**: 10–15
- **Max cyclomatic complexity**: Per-function threshold (e.g., 10)

These limits prevent the accumulation of god-files that agents can't reason about
in context.

### Import Rules

- **Boundary checking**: Enforce the forward-only dependency rule from domains.yml
- **External dependency limits**: Cap how many external packages a single module
  can import (prevents kitchen-sink dependencies)
- **Banned imports**: Explicitly list patterns that should never be used
  (e.g., importing internals from another domain)

### Test Requirements

- **Boundary tests required**: System boundaries (API endpoints, database access,
  external service calls) must have test coverage
- **Coverage targets for new code**: Typically 80%+ for new code, tracking overall
  trends rather than enforcing a global minimum
- **Test naming conventions**: Consistent naming helps agents find and understand
  existing tests

## Agent-Legible Error Messages

This is one of the most impactful and least obvious patterns in the article.
When enforcement rules fire, the error messages should be written for agents
to read and act on — not just for humans to squint at.

A human sees a lint error and knows from experience what to do. An agent sees
a lint error and needs the error message itself to contain enough context to
fix the issue without consulting any other document.

### Pattern: Remediation-Rich Error Messages

Every custom lint or structural check should include:
1. **What's wrong** — the specific violation
2. **Why it matters** — brief rationale (link to principle if applicable)
3. **How to fix it** — concrete remediation steps
4. **Where to look** — file paths or documentation pointers

### Example

**Bad error message:**
```
Error: Boundary violation in billing/service.ts
```

**Good error message:**
```
Error: Boundary violation — billing/service.ts imports from auth/repo.ts

The forward-only dependency rule prohibits Service from importing Repo of
another domain. Cross-cutting concerns must enter through Providers.

To fix: inject the auth dependency via the billing Providers interface.
See: ARCHITECTURE.md#cross-cutting-concerns, .harness/domains.yml
```

### In .harness/enforcement.yml

When defining enforcement rules, include a `message_template` field that
the tooling can use to generate agent-legible error messages:

```yaml
imports:
  boundary_check: true
  violation_message: |
    Boundary violation — {{source_file}} imports from {{target_file}}.
    The {{rule_name}} rule prohibits {{source_layer}} from importing
    {{target_layer}} of another domain.
    To fix: {{remediation}}
    See: ARCHITECTURE.md#cross-cutting-concerns, .harness/domains.yml
```

This pattern extends to all enforcement: naming violations should suggest
the correct name, file size violations should suggest how to split,
logging violations should show the correct structured logging call.

## CI Integration Patterns

The harness specs become most valuable when CI enforces them:

1. **Knowledge freshness check**: CI job validates that AGENTS.md references
   point to real files, docs/ cross-links resolve, and generated docs are current
2. **Architecture boundary check**: Validate import patterns against domains.yml
   layer rules
3. **Principle compliance**: Run linters/checks for each enforceable principle
4. **Quality review reminder**: Flag domains whose quality.yml scores haven't been
   reviewed within the configured cadence

These CI jobs can be implemented incrementally. Start with knowledge freshness
(cheapest to implement, high impact) and add architectural checks as the tooling
matures.
