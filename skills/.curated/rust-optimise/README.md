# Rust Optimise Best Practices

Performance optimization guidelines for Rust applications. Contains 42 rules across 8 categories for writing efficient Rust code.

## Overview/Structure

```
rust-optimise/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, organization, references
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   ├── mem-*.md          # Memory allocation rules
│   ├── own-*.md          # Ownership & borrowing rules
│   ├── ds-*.md           # Data structure rules
│   ├── iter-*.md         # Iterator rules
│   ├── async-*.md        # Async & concurrency rules
│   ├── algo-*.md         # Algorithm complexity rules
│   ├── comp-*.md         # Compile-time optimization rules
│   └── micro-*.md        # Micro-optimization rules
└── assets/
    └── templates/
        └── _template.md  # Rule template for extensions
```

## Getting Started

### Installation

```bash
# Clone or copy this skill to your project
cp -r rust-optimise/ .claude/skills/rust-optimise/

# Install dependencies (if using validation scripts)
pnpm install
```

### Build

```bash
# Build AGENTS.md from individual rules
pnpm build
# Or directly:
node scripts/build-agents-md.js .claude/skills/rust-optimise
```

### Validate

```bash
# Validate skill structure and content
pnpm validate
# Or directly:
node scripts/validate-skill.js .claude/skills/rust-optimise
```

## Creating a New Rule

1. Choose the appropriate category based on performance impact
2. Create a new file in `references/` following the naming convention
3. Use the template structure for consistency
4. Run validation to ensure compliance

### Prefix Reference

| Category | Prefix | Impact |
|----------|--------|--------|
| Memory Allocation | `mem-` | CRITICAL |
| Ownership & Borrowing | `own-` | CRITICAL |
| Data Structure Selection | `ds-` | HIGH |
| Iterator & Collection Patterns | `iter-` | HIGH |
| Async & Concurrency | `async-` | MEDIUM-HIGH |
| Algorithm Complexity | `algo-` | MEDIUM |
| Compile-Time Optimization | `comp-` | MEDIUM |
| Micro-optimizations | `micro-` | LOW |

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
- `mem-avoid-unnecessary-clone.md`
- `async-use-join-for-concurrent-futures.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Multiplicative impact, affects entire program execution |
| HIGH | Significant per-operation improvement |
| MEDIUM-HIGH | Notable improvement in specific scenarios |
| MEDIUM | Measurable improvement on hot paths |
| LOW-MEDIUM | Small but consistent improvement |
| LOW | Micro-optimization for tight loops |

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

- For idiomatic patterns, architecture, and code organization, see `rust-refactor` skill

## Acknowledgments

This skill synthesizes best practices from:
- [The Rust Performance Book](https://nnethercote.github.io/perf-book/)
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- [The Rustonomicon](https://doc.rust-lang.org/nomicon/)
- [Tokio Documentation](https://tokio.rs/)
