# Ruby Dev Best Practices

Performance optimization guidelines for Ruby applications. Contains 42 rules across 8 categories for writing efficient Ruby code.

## Overview/Structure

```
ruby-dev/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, organization, references
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   ├── alloc-*.md        # Object allocation rules
│   ├── enum-*.md         # Collection & enumeration rules
│   ├── io-*.md           # I/O & database rules
│   ├── str-*.md          # String handling rules
│   ├── meth-*.md         # Method & dispatch rules
│   ├── ds-*.md           # Data structure rules
│   ├── conc-*.md         # Concurrency rules
│   └── runtime-*.md      # Runtime & configuration rules
└── assets/
    └── templates/
        └── _template.md  # Rule template for extensions
```

## Getting Started

### Installation

```bash
# Clone or copy this skill to your project
cp -r ruby-dev/ .claude/skills/ruby-dev/

# Install dependencies (if using validation scripts)
pnpm install
```

### Build

```bash
# Build AGENTS.md from individual rules
pnpm build
# Or directly:
node scripts/build-agents-md.js .claude/skills/ruby-dev
```

### Validate

```bash
# Validate skill structure and content
pnpm validate
# Or directly:
node scripts/validate-skill.js .claude/skills/ruby-dev
```

## Creating a New Rule

1. Choose the appropriate category based on performance impact
2. Create a new file in `references/` following the naming convention
3. Use the template structure for consistency
4. Run validation to ensure compliance

### Prefix Reference

| Category | Prefix | Impact |
|----------|--------|--------|
| Object Allocation | `alloc-` | CRITICAL |
| Collection & Enumeration | `enum-` | CRITICAL |
| I/O & Database | `io-` | HIGH |
| String Handling | `str-` | HIGH |
| Method & Dispatch | `meth-` | MEDIUM-HIGH |
| Data Structures | `ds-` | MEDIUM |
| Concurrency | `conc-` | MEDIUM |
| Runtime & Configuration | `runtime-` | LOW-MEDIUM |

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

**Incorrect (description of what's wrong):**

\`\`\`ruby
# Bad example with comments explaining cost
\`\`\`

**Correct (description of what's right):**

\`\`\`ruby
# Good example with comments explaining benefit
\`\`\`

Reference: [Source](url)
```

## File Naming Convention

Files follow the pattern: `{prefix}-{description}.md`

- `prefix`: Category identifier (3-8 chars)
- `description`: Kebab-case description of the rule

Examples:
- `alloc-freeze-constants.md`
- `io-eager-load-associations.md`

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
4. Ensure all code examples are syntactically correct
5. Include authoritative references

## Acknowledgments

This skill synthesizes best practices from:
- [Ruby Documentation](https://docs.ruby-lang.org)
- [RuboCop Ruby Style Guide](https://github.com/rubocop/ruby-style-guide)
- [Shopify Engineering Blog](https://shopify.engineering)
- [Rails at Scale](https://railsatscale.com)
- [Datadog Ruby Performance](https://www.datadoghq.com/blog/ruby-performance-optimization/)
- [Ruby Performance Optimization (Pragmatic Bookshelf)](https://pragprog.com/titles/adrpo/ruby-performance-optimization/)
