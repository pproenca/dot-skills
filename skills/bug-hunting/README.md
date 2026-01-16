# Bug Hunting Best Practices

Systematic bug hunting and debugging guidelines for software engineers. This skill provides a comprehensive framework for finding, investigating, and resolving software bugs efficiently.

## Overview

This skill contains 42 rules across 8 categories, covering the complete bug-hunting lifecycle from reproduction to prevention.

### Directory Structure

```
bug-hunting/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, organization, references
├── README.md             # This file
└── rules/
    ├── _sections.md      # Category definitions
    ├── repro-*.md        # Systematic reproduction rules
    ├── hypo-*.md         # Hypothesis-driven investigation rules
    ├── rca-*.md          # Root cause analysis rules
    ├── log-*.md          # Strategic logging rules
    ├── debug-*.md        # Debugger mastery rules
    ├── triage-*.md       # Bug triage and classification rules
    ├── pattern-*.md      # Common bug pattern rules
    └── prevent-*.md      # Prevention and verification rules
```

## Getting Started

### Installation

```bash
pnpm install
```

### Building

```bash
pnpm build
```

### Validation

```bash
pnpm validate
```

## Creating a New Rule

1. Determine the appropriate category and prefix
2. Create a new file in `rules/` following the naming convention
3. Use the rule template structure
4. Run validation to check compliance

### Category Prefixes

| Category | Prefix | Impact |
|----------|--------|--------|
| Systematic Reproduction | `repro-` | CRITICAL |
| Hypothesis-Driven Investigation | `hypo-` | CRITICAL |
| Root Cause Analysis | `rca-` | HIGH |
| Strategic Logging | `log-` | HIGH |
| Debugger Mastery | `debug-` | MEDIUM-HIGH |
| Bug Triage and Classification | `triage-` | MEDIUM |
| Common Bug Patterns | `pattern-` | MEDIUM |
| Prevention and Verification | `prevent-` | LOW |

## Rule File Structure

Each rule file should follow this template:

```markdown
---
title: Rule Title
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact description
tags: prefix, technique, related-concepts
---

## Rule Title

Brief explanation of WHY this matters (1-3 sentences).

**Incorrect (what's wrong):**

\`\`\`language
// Bad code example
\`\`\`

**Correct (what's right):**

\`\`\`language
// Good code example
\`\`\`

Reference: [Reference Title](URL)
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{description}.md`

Examples:
- `repro-minimal-reproduction.md`
- `hypo-binary-search.md`
- `pattern-race-condition.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Fundamental techniques that enable all other debugging |
| HIGH | Techniques that significantly reduce debugging time |
| MEDIUM-HIGH | Important techniques for efficient debugging |
| MEDIUM | Useful techniques that improve debugging quality |
| LOW-MEDIUM | Helpful techniques for specific scenarios |
| LOW | Best practices for long-term code quality |

## Scripts

- `pnpm validate` - Validate all rules against guidelines
- `pnpm build` - Compile rules into AGENTS.md
- `pnpm lint` - Check markdown formatting

## Contributing

1. Read the existing rules to understand the style and format
2. Ensure your rule has both incorrect and correct examples
3. Include a quantified impact description
4. Reference authoritative sources
5. Run validation before submitting

## References

- [MIT 6.031 - Reading 13: Debugging](http://web.mit.edu/6.031/www/fa17/classes/13-debugging/)
- [GeeksforGeeks - Debugging Approaches](https://www.geeksforgeeks.org/software-engineering-debugging-approaches/)
- [Atlassian - Bug Triage Best Practices](https://www.atlassian.com/agile/software-development/bug-triage)
- [IBM - Three Pillars of Observability](https://www.ibm.com/think/insights/observability-pillars)

## Acknowledgments

This skill draws on debugging best practices from academic computer science courses, industry engineering blogs, and established debugging methodologies including the scientific debugging method and root cause analysis frameworks.
