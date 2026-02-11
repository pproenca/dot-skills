# Ruby Refactor Best Practices

Refactoring guidelines for Ruby applications. Contains 45 rules across 8 categories for improving code structure, design, and maintainability.

## Overview/Structure

```
ruby-refactor/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, organization, references
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   ├── struct-*.md       # Structure & decomposition rules
│   ├── cond-*.md         # Conditional simplification rules
│   ├── couple-*.md       # Coupling & dependencies rules
│   ├── idiom-*.md        # Ruby idioms rules
│   ├── data-*.md         # Data & value objects rules
│   ├── pattern-*.md      # Design patterns rules
│   ├── modern-*.md       # Modern Ruby 3.x rules
│   └── name-*.md         # Naming & readability rules
└── assets/
    └── templates/
        └── _template.md  # Rule template for extensions
```

## Getting Started

### Installation

```bash
# Clone or copy this skill to your project
cp -r ruby-refactor/ .claude/skills/ruby-refactor/

# Install dependencies (if using validation scripts)
pnpm install
```

### Build

```bash
# Build AGENTS.md from individual rules
pnpm build
# Or directly:
node scripts/build-agents-md.js .claude/skills/ruby-refactor
```

### Validate

```bash
# Validate skill structure and content
pnpm validate
# Or directly:
node scripts/validate-skill.js .claude/skills/ruby-refactor
```

## Creating a New Rule

1. Choose the appropriate category based on refactoring impact
2. Create a new file in `references/` following the naming convention
3. Use the template structure for consistency
4. Run validation to ensure compliance

### Prefix Reference

| Category | Prefix | Impact |
|----------|--------|--------|
| Structure & Decomposition | `struct-` | CRITICAL |
| Conditional Simplification | `cond-` | CRITICAL |
| Coupling & Dependencies | `couple-` | HIGH |
| Ruby Idioms | `idiom-` | HIGH |
| Data & Value Objects | `data-` | MEDIUM-HIGH |
| Design Patterns | `pattern-` | MEDIUM |
| Modern Ruby 3.x | `modern-` | MEDIUM |
| Naming & Readability | `name-` | LOW-MEDIUM |

## Rule File Structure

```markdown
---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "reduces coupling by 50%")
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
- `struct-extract-method.md`
- `cond-guard-clauses.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Root-cause smells that block all downstream refactoring |
| HIGH | Significant design improvement, reduces coupling or complexity |
| MEDIUM-HIGH | Notable improvement in specific design areas |
| MEDIUM | Measurable improvement in readability or extensibility |
| LOW-MEDIUM | Incremental improvement in code clarity |
| LOW | Polish-level improvements |

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
- [RuboCop Ruby Style Guide](https://github.com/rubocop/ruby-style-guide)
- [Shopify Ruby Style Guide](https://ruby-style-guide.shopify.dev/)
- [POODR (Sandi Metz)](https://www.poodr.com/)
- [Ruby Science (thoughtbot)](https://thoughtbot.com/ruby-science/)
- [Refactoring: Ruby Edition (Fowler/Fields)](https://martinfowler.com/books/refactoringRubyEd.html)
- [Refactoring Guru](https://refactoring.guru/refactoring/catalog)
- [Ruby 3.x Documentation](https://docs.ruby-lang.org/en/3.3/)
