# Rust Systems Programming Skill

Comprehensive Rust patterns and style guide for building reliable systems software.

## Overview

This skill provides 52 rules across 5 categories for writing idiomatic, maintainable Rust code for systems programming.

| Category | Rules | Impact |
|----------|-------|--------|
| Project Organization | 6 | HIGH |
| Module Structure | 6 | HIGH |
| Naming Conventions | 13 | HIGH |
| Type & Trait Patterns | 15 | HIGH |
| Error Handling | 12 | HIGH |

## Structure

```
rust-systems/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, references, metadata
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   ├── org-*.md          # Project organization rules (6)
│   ├── mod-*.md          # Module structure rules (6)
│   ├── name-*.md         # Naming convention rules (13)
│   ├── type-*.md         # Type & trait pattern rules (15)
│   └── err-*.md          # Error handling rules (12)
└── assets/
    └── templates/
        └── _template.md  # Rule template
```

## Getting Started

### Using in Claude Code

This skill automatically activates when you're working on:
- Writing new Rust code or modules
- Organizing Rust project structure
- Defining custom types, traits, or error handling
- Reviewing Rust code for style consistency
- Building systems tools, CLIs, or daemon processes

### Manual Commands

```bash
# Install dependencies (if contributing)
pnpm install

# Build AGENTS.md from rules
pnpm build

# Validate skill structure
pnpm validate
```

## Creating a New Rule

1. Determine the category based on the rule's primary concern
2. Use the appropriate prefix from the table in the Prefix Reference section
3. Copy `assets/templates/_template.md` as your starting point
4. Fill in frontmatter and content

### Prefix Reference

| Prefix | Category | Impact |
|--------|----------|--------|
| `org-` | Project Organization | HIGH |
| `mod-` | Module Structure | HIGH |
| `name-` | Naming Conventions | HIGH |
| `type-` | Type & Trait Patterns | HIGH |
| `err-` | Error Handling | HIGH |

## Rule File Structure

Each rule follows this template:

```markdown
---
title: Rule Title Here
impact: HIGH|MEDIUM|LOW
impactDescription: Quantified impact (e.g., "prevents type confusion bugs")
tags: prefix, technique, related-concepts
---

## Rule Title Here

1-3 sentences explaining WHY this matters.

**Incorrect (what's wrong):**

\`\`\`rust
// Bad example with comments explaining the issue
\`\`\`

**Correct (what's right):**

\`\`\`rust
// Good example with comments explaining the benefit
\`\`\`

**When NOT to use:**
- Exception 1
- Exception 2
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{description}.md`

Examples:
- `org-cargo-workspace.md` - Project organization, about Cargo workspaces
- `type-option-nullable-fields.md` - Type patterns, about using Option<T>
- `err-thiserror-enum.md` - Error handling, about thiserror derive

## Impact Levels

| Level | Description |
|-------|-------------|
| HIGH | Core patterns; violations cause maintainability issues |
| MEDIUM | Significant improvement in code quality |
| LOW | Incremental improvement, stylistic preference |

## Scripts

| Command | Description |
|---------|-------------|
| `pnpm build` | Compiles rules into AGENTS.md |
| `pnpm validate` | Validates skill structure and rules |

## Contributing

1. Check existing rules to avoid duplication
2. Use the rule template (`assets/templates/_template.md`)
3. Include both incorrect and correct examples
4. Add parenthetical descriptions to examples
5. Reference authoritative sources when available
6. Run validation before submitting

## Key Patterns

### Error Handling
- Use `thiserror` for library error types
- Use `anyhow` for application error handling
- Always include path context in IO errors
- Graceful degradation for non-critical operations

### Type Safety
- `Option<T>` for all nullable fields
- Newtype pattern for semantic type safety
- `bitflags!` for type-safe bit flags
- Associated types over generic parameters

### Project Organization
- Cargo workspace for multi-crate projects
- Feature-based crate grouping
- Flat module structure with `test.rs` co-location
- Dedicated `common` crate for shared utilities

## Acknowledgments

This skill draws from:
- [The Rust Book](https://doc.rust-lang.org/book/)
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- [The Rustonomicon](https://doc.rust-lang.org/nomicon/)

## License

MIT
