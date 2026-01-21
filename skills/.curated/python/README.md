# Python 3.11 Best Practices

A comprehensive performance optimization guide for Python 3.11+ applications, designed for AI agents and LLMs.

## Overview

This skill contains **42 rules** across **8 categories**, prioritized by impact from critical (async I/O patterns, data structure selection) to incremental (Python idioms). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics.

## Structure

```
python-3.11/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, org, references
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   ├── io-*.md           # I/O & Async rules (6)
│   ├── ds-*.md           # Data Structure rules (6)
│   ├── mem-*.md          # Memory rules (5)
│   ├── conc-*.md         # Concurrency rules (5)
│   ├── loop-*.md         # Loop rules (6)
│   ├── str-*.md          # String rules (4)
│   ├── func-*.md         # Function rules (4)
│   └── py-*.md           # Python Idiom rules (6)
└── assets/
    └── templates/
        └── _template.md  # Rule template for extensions
```

## Getting Started

### Installation

```bash
pnpm install
```

### Building AGENTS.md

```bash
pnpm build
```

### Validating the Skill

```bash
pnpm validate
```

## Creating a New Rule

1. Choose the appropriate category based on the rule's focus
2. Create a new file in `references/` with the pattern `{prefix}-{description}.md`
3. Use the template from `assets/templates/_template.md`
4. Run validation to ensure compliance

### Prefix Reference

| Category | Prefix | Impact |
|----------|--------|--------|
| I/O & Async Patterns | `io-` | CRITICAL |
| Data Structure Selection | `ds-` | CRITICAL |
| Memory Optimization | `mem-` | HIGH |
| Concurrency & Parallelism | `conc-` | HIGH |
| Loop & Iteration | `loop-` | MEDIUM |
| String Operations | `str-` | MEDIUM |
| Function & Call Overhead | `func-` | LOW-MEDIUM |
| Python Idioms & Micro | `py-` | LOW |

## Rule File Structure

Each rule file must have:

```markdown
---
title: Rule Title
impact: CRITICAL|HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10× improvement")
tags: prefix, technique, tool
---

## Rule Title

Brief explanation of WHY this matters (1-3 sentences).

**Incorrect (what's wrong):**

\`\`\`python
# Bad code example
\`\`\`

**Correct (what's right):**

\`\`\`python
# Good code example
\`\`\`
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{description}.md`

- **prefix**: Category identifier (3-8 chars)
- **description**: Kebab-case description of the rule

Examples:
- `io-async-gather.md`
- `ds-set-for-membership.md`
- `mem-generators.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Multiplicative impact, affects entire application (2-10×) |
| HIGH | Significant improvement in specific areas (20-50%) |
| MEDIUM | Noticeable improvement in common patterns (2-3×) |
| LOW-MEDIUM | Incremental gains in hot paths |
| LOW | Minor optimizations, best practices |

## Scripts

| Command | Description |
|---------|-------------|
| `pnpm build` | Compile references into AGENTS.md |
| `pnpm validate` | Validate skill structure and content |

## Contributing

1. Follow the rule template exactly
2. Ensure examples are production-realistic (no foo/bar)
3. Quantify impact where possible
4. Include authoritative references
5. Run validation before submitting

## Acknowledgments

Based on authoritative sources including:
- [Python 3.11 Release Notes](https://docs.python.org/3/whatsnew/3.11.html)
- [PEP 8 Style Guide](https://peps.python.org/pep-0008/)
- [Python Wiki - Performance Tips](https://wiki.python.org/moin/PythonSpeed/PerformanceTips)
- [Real Python](https://realpython.com/)
