# Rust Refactor Best Practices

Architectural refactoring guide for Rust applications. Contains 91 rules across 10 categories covering type safety, ownership, error handling, API design, project organization, module structure, naming, conversions, idiomatic patterns, and iterators.

## Overview/Structure

```
rust-refactor/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, organization, references
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   ├── type-*.md         # Type safety & patterns rules
│   ├── own-*.md          # Ownership & borrowing rules
│   ├── err-*.md          # Error handling rules
│   ├── api-*.md          # API design & traits rules
│   ├── org-*.md          # Project organization rules
│   ├── mod-*.md          # Module & visibility rules
│   ├── name-*.md         # Naming convention rules
│   ├── conv-*.md         # Conversion traits rules
│   ├── idiom-*.md        # Idiomatic patterns rules
│   └── iter-*.md         # Iterator & collections rules
└── assets/
    └── templates/
        └── _template.md  # Rule template for extensions
```

## Getting Started

### Installation

```bash
# Clone or copy this skill to your project
cp -r rust-refactor/ .claude/skills/rust-refactor/

# Install dependencies (if using validation scripts)
pnpm install
```

### Build

```bash
# Build AGENTS.md from individual rules
pnpm build
# Or directly:
node scripts/build-agents-md.js .claude/skills/rust-refactor
```

### Validate

```bash
# Validate skill structure and content
pnpm validate
# Or directly:
node scripts/validate-skill.js .claude/skills/rust-refactor
```

## Creating a New Rule

1. Choose the appropriate category based on impact level
2. Create a new file in `references/` following the naming convention
3. Use the template structure for consistency
4. Run validation to ensure compliance

### Prefix Reference

| Category | Prefix | Impact |
|----------|--------|--------|
| Type Safety & Patterns | `type-` | CRITICAL |
| Ownership & Borrowing | `own-` | CRITICAL |
| Error Handling | `err-` | HIGH |
| API Design & Traits | `api-` | HIGH |
| Project Organization | `org-` | HIGH |
| Module & Visibility | `mod-` | MEDIUM-HIGH |
| Naming Conventions | `name-` | MEDIUM-HIGH |
| Conversion Traits | `conv-` | MEDIUM |
| Idiomatic Patterns | `idiom-` | MEDIUM |
| Iterator & Collections | `iter-` | LOW-MEDIUM |

## Rule File Structure

```markdown
---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10x improvement")
tags: prefix, technique, related-concepts
---

## Rule Title Here

Brief explanation (1-3 sentences) of why this matters.

**Incorrect:**

\`\`\`rust
// Bad example with comments explaining cost
\`\`\`

**Correct:**

\`\`\`rust
// Good example with comments explaining benefit
\`\`\`

Reference: [Source](url)
```

## File Naming Convention

Files follow the pattern: `{prefix}-{description}.md`

- `prefix`: Category identifier (3-8 chars)
- `description`: Kebab-case description of the rule

Examples:
- `type-newtype-invariants.md`
- `err-two-tier-strategy.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Prevents entire classes of bugs at compile time |
| HIGH | Significant improvement to code maintainability |
| MEDIUM-HIGH | Notable improvement in code organization |
| MEDIUM | Measurable improvement in idiomatic patterns |
| LOW-MEDIUM | Small but consistent improvement |
| LOW | Minor improvement for specific scenarios |

## Scripts

| Script | Description |
|--------|-------------|
| `build-agents-md.js` | Compiles all rules into AGENTS.md |
| `validate-skill.js` | Validates structure and content |

## Contributing

1. Read existing rules to understand the style
2. Create your rule using the template
3. Run validation before submitting
4. Ensure all code examples compile
5. Include authoritative references

## Related Skills

- For performance optimization, see `rust-optimise` skill

## Acknowledgments

This skill synthesizes best practices from:
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- [Rust Design Patterns](https://rust-unofficial.github.io/patterns/)
- [Effective Rust](https://www.lurklurk.org/effective-rust/)
- [Clippy Lints](https://rust-lang.github.io/rust-clippy/)
