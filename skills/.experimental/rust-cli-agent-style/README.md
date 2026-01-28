# rust-cli-agent-style

Coding style patterns extracted from the OpenAI Codex Rust codebase.

## Overview

This skill captures the coding patterns, conventions, and best practices from [OpenAI Codex](https://github.com/openai/codex) (`codex-rs/` subdirectory) - a production Rust CLI/agent system with:

- 50 workspace crates
- 787 Rust source files
- Rust Edition 2024
- Strict error handling (deny unwrap/expect)
- Tokio async runtime

## Getting Started

```bash
# Install dependencies
pnpm install

# Build the skill
pnpm build

# Validate the skill
pnpm validate
```

## Key Patterns

### Error Handling (CRITICAL)

The codebase enforces `deny(clippy::unwrap_used, clippy::expect_used)` at the workspace level:

- Use `thiserror` for domain-specific error types
- Use `anyhow::Result` for application entry points
- Always add context with `.context()` for debugging
- Never use `unwrap()` or `expect()` in non-test code

### Workspace Organization

- Flat workspace structure with crates at root level
- Small utilities grouped under `utils/` subdirectory
- Shared test utilities in `tests/common/` crate
- kebab-case directories with `codex-` package prefix

### Async Patterns

- `#[async_trait]` for async trait methods
- `Send + Sync + 'static` bounds for concurrent traits
- `pub(crate)` for internal APIs

### Naming Conventions

- `try_` prefix for fallible constructors
- `with_` prefix for builder methods
- Consistent suffixes: `Error`, `Client`, `Provider`, `Manager`, `Handler`
- `is_`/`has_`/`should_` prefix for boolean functions

## Creating a New Rule

1. Create a new file in `references/` with the pattern `{prefix}-{slug}.md`
2. Use the template from `assets/templates/_template.md`
3. Include YAML frontmatter with title, impact, impactDescription, and tags
4. Add Incorrect and Correct code examples
5. Run validation to ensure the rule is properly formatted

## Rule File Structure

Each rule file follows this structure:

```markdown
---
title: Rule title here
impact: HIGH|MEDIUM|LOW|CRITICAL
impactDescription: Brief explanation of why this rule matters
tags: prefix, relevant, tags
---

# Rule Title

Brief description of the rule.

## Why This Matters

- Point 1
- Point 2

**Incorrect (what not to do):**

\`\`\`rust
// Bad example
\`\`\`

**Correct (recommended pattern):**

\`\`\`rust
// Good example
\`\`\`
```

## File Naming Convention

Rule files follow the pattern: `{category-prefix}-{descriptive-slug}.md`

| Category | Prefix | Example |
|----------|--------|---------|
| Error Handling | `err-` | `err-no-unwrap.md` |
| Organization | `org-` | `org-workspace-flat.md` |
| Component Patterns | `mod-` | `mod-async-trait-macro.md` |
| Cross-Crate | `cross-` | `cross-workspace-lints.md` |
| Naming Conventions | `name-` | `name-try-prefix-fallible.md` |
| Style | `style-` | `style-import-granularity.md` |

## Impact Levels

| Level | Description | When to Use |
|-------|-------------|-------------|
| CRITICAL | Must follow - violations cause runtime errors or security issues | Error handling, panic prevention |
| HIGH | Strongly recommended - significant code quality impact | Architecture, API design |
| MEDIUM | Recommended - improves maintainability | Naming, organization |
| LOW | Nice to have - minor improvements | Formatting preferences |

## Scripts

```bash
# Validate skill structure and rules
pnpm validate

# Build AGENTS.md from individual rules
pnpm build

# Validate with strict mode (fail on warnings)
pnpm validate --strict
```

## Rules by Category

| Category | Count | Impact |
|----------|-------|--------|
| Error Handling | 11 | CRITICAL/HIGH |
| Organization | 8 | HIGH/MEDIUM |
| Component Patterns | 12 | HIGH/MEDIUM |
| Cross-Crate | 2 | HIGH |
| Naming Conventions | 15 | MEDIUM |
| Style | 6 | MEDIUM |
| **Total** | **54** | |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add or modify rules following the file structure above
4. Run `pnpm validate` to ensure rules are properly formatted
5. Submit a pull request

## Source

Analyzed from [openai/codex](https://github.com/openai/codex) on 2026-01-28.
