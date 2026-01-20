# Rust Refactoring Best Practices

Comprehensive refactoring and idiomatic patterns guide for Rust applications.

## Overview

This skill contains 44 rules across 8 categories, designed to help AI agents and developers write clean, idiomatic Rust code.

## Structure

```
rust-refactor/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version and reference information
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   ├── type-*.md         # Type safety rules (6 rules)
│   ├── own-*.md          # Ownership rules (6 rules)
│   ├── err-*.md          # Error handling rules (5 rules)
│   ├── api-*.md          # API design rules (6 rules)
│   ├── mod-*.md          # Module organization rules (5 rules)
│   ├── conv-*.md         # Conversion trait rules (5 rules)
│   ├── idiom-*.md        # Idiomatic pattern rules (6 rules)
│   └── iter-*.md         # Iterator rules (5 rules)
└── assets/
    └── templates/
        └── _template.md  # Template for new rules
```

## Getting Started

```bash
# Install dependencies (if in a workspace)
pnpm install

# Build the AGENTS.md file
pnpm build

# Validate the skill
pnpm validate
```

## Creating a New Rule

1. Choose the appropriate category prefix from the table below
2. Create a new file in `references/` with the pattern `{prefix}-{description}.md`
3. Copy the template from `assets/templates/_template.md`
4. Fill in the frontmatter and content
5. Run validation to ensure compliance

### Category Prefixes

| Category | Prefix | Impact |
|----------|--------|--------|
| Type Safety & Newtype Patterns | `type-` | CRITICAL |
| Ownership & Borrowing | `own-` | CRITICAL |
| Error Handling Patterns | `err-` | HIGH |
| API Design & Traits | `api-` | HIGH |
| Module & Visibility | `mod-` | MEDIUM-HIGH |
| Conversion Traits | `conv-` | MEDIUM |
| Idiomatic Patterns | `idiom-` | MEDIUM |
| Iterator & Collections | `iter-` | LOW-MEDIUM |

## Rule File Structure

Each rule file must have:

```markdown
---
title: Rule Title
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "prevents unit confusion bugs")
tags: category-prefix, technique1, technique2
---

## Rule Title

Brief explanation of WHY this matters.

**Incorrect (what's wrong):**

\`\`\`rust
// Bad code example
\`\`\`

**Correct (what's right):**

\`\`\`rust
// Good code example
\`\`\`

Reference: [Link text](URL)
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{kebab-case-description}.md`

Examples:
- `type-newtype-units.md`
- `own-prefer-borrowing.md`
- `err-use-result-not-panic.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Prevents major bugs or enables fundamental correctness |
| HIGH | Significant improvement to maintainability or safety |
| MEDIUM-HIGH | Important for clean architecture |
| MEDIUM | Improves code quality and readability |
| LOW-MEDIUM | Nice-to-have improvements |
| LOW | Minor polish and optimization |

## Scripts

| Script | Description |
|--------|-------------|
| `pnpm build` | Compile references into AGENTS.md |
| `pnpm validate` | Check skill against quality guidelines |

## Contributing

1. Follow the existing rule format exactly
2. Include both incorrect and correct code examples
3. Quantify impact where possible
4. Reference authoritative sources
5. Run validation before submitting

## Acknowledgments

Based on guidelines from:
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- [Rust Design Patterns](https://rust-unofficial.github.io/patterns/)
- [The Rust Programming Language](https://doc.rust-lang.org/book/)
- [Effective Rust](https://www.lurklurk.org/effective-rust/)
- [Clippy Lints](https://rust-lang.github.io/rust-clippy/)
