# Debugging Best Practices

Comprehensive debugging methodology skill for AI coding agents. Based on research from Andreas Zeller's "Why Programs Fail" and academic debugging curricula.

## Overview

This skill provides 54 rules across 10 categories to help developers debug systematically instead of randomly. Rules are prioritized by impact, from critical problem definition techniques to prevention practices.

| Category | Rules | Impact |
|----------|-------|--------|
| Problem Definition | 6 | CRITICAL |
| Hypothesis-Driven Search | 6 | CRITICAL |
| Observation Techniques | 6 | HIGH |
| Root Cause Analysis | 5 | HIGH |
| Tool Mastery | 6 | MEDIUM-HIGH |
| Bug Triage and Classification | 5 | MEDIUM |
| Common Bug Patterns | 7 | MEDIUM |
| Fix Verification | 4 | MEDIUM |
| Anti-Patterns | 5 | MEDIUM |
| Prevention & Learning | 4 | LOW-MEDIUM |

## Structure

```
debugging/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, references, metadata
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   ├── prob-*.md         # Problem definition rules (6)
│   ├── hypo-*.md         # Hypothesis-driven search rules (6)
│   ├── obs-*.md          # Observation technique rules (6)
│   ├── rca-*.md          # Root cause analysis rules (5)
│   ├── tool-*.md         # Tool mastery rules (6)
│   ├── triage-*.md       # Bug triage rules (5)
│   ├── pattern-*.md      # Common bug pattern rules (7)
│   ├── verify-*.md       # Fix verification rules (4)
│   ├── anti-*.md         # Anti-pattern rules (5)
│   └── prev-*.md         # Prevention rules (4)
└── assets/
    └── templates/
        └── _template.md  # Rule template
```

## Getting Started

### Using in Claude Code

This skill automatically activates when you're working on:
- Debugging code issues or exceptions
- Investigating stack traces or errors
- Root cause analysis for bugs
- Troubleshooting unexpected behavior
- Bug triage and prioritization

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
2. Use the appropriate prefix from the table below
3. Copy `assets/templates/_template.md` as your starting point
4. Fill in frontmatter and content

### Prefix Reference

| Prefix | Category | Impact |
|--------|----------|--------|
| `prob-` | Problem Definition | CRITICAL |
| `hypo-` | Hypothesis-Driven Search | CRITICAL |
| `obs-` | Observation Techniques | HIGH |
| `rca-` | Root Cause Analysis | HIGH |
| `tool-` | Tool Mastery | MEDIUM-HIGH |
| `triage-` | Bug Triage and Classification | MEDIUM |
| `pattern-` | Common Bug Patterns | MEDIUM |
| `verify-` | Fix Verification | MEDIUM |
| `anti-` | Anti-Patterns | MEDIUM |
| `prev-` | Prevention & Learning | LOW-MEDIUM |

## Rule File Structure

Each rule follows this template:

```markdown
---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10× faster localization")
tags: prefix, technique, related-concepts
---

## Rule Title Here

1-3 sentences explaining WHY this matters for debugging effectiveness.

**Incorrect (what's wrong):**

\`\`\`language
// Bad example with comments explaining the cost
\`\`\`

**Correct (what's right):**

\`\`\`language
// Good example with comments explaining the benefit
\`\`\`

Reference: [Link](https://example.com)
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{description}.md`

Examples:
- `prob-reproduce-before-debug.md` - Problem definition, about reproducing bugs first
- `hypo-binary-search.md` - Hypothesis-driven, about binary search localization
- `tool-conditional-breakpoints.md` - Tool mastery, about conditional breakpoints

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Core debugging methodology; skipping causes wasted hours |
| HIGH | Major improvement in debugging effectiveness |
| MEDIUM-HIGH | Significant impact on specific debugging workflows |
| MEDIUM | Noticeable improvement in debugging quality |
| LOW-MEDIUM | Incremental improvement and long-term benefits |
| LOW | Minor optimization |

## Scripts

| Command | Description |
|---------|-------------|
| `pnpm build` | Compiles rules into AGENTS.md |
| `pnpm validate` | Validates skill structure and rules |

## Contributing

1. Check existing rules to avoid duplication
2. Use the rule template (`assets/templates/_template.md`)
3. Include both incorrect and correct examples
4. Quantify impact where possible
5. Reference authoritative sources
6. Run validation before submitting

## Key Principles

1. **Reproduce Before Debugging** - Never debug until you can reliably trigger the bug
2. **Apply Scientific Method** - Form hypotheses, predict outcomes, test systematically
3. **Binary Search Localization** - Narrow down by 50% with each checkpoint
4. **Find WHERE Before WHAT** - Locate first, understand second
5. **One Change at a Time** - Isolate variables to avoid confounding
6. **Question Assumptions** - Many bugs hide behind unquestioned beliefs

## Acknowledgments

This skill draws from:
- [Why Programs Fail](https://www.whyprogramsfail.com/) - Andreas Zeller
- [MIT 6.031 - Debugging](https://web.mit.edu/6.031/www/sp17/classes/11-debugging/)
- [Cornell CS312 - Debugging Techniques](https://www.cs.cornell.edu/courses/cs312/2006fa/lectures/lec26.html)
- [VS Code Debugging](https://code.visualstudio.com/docs/debugtest/debugging)

## License

MIT
