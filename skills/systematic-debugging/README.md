# Systematic Debugging Best Practices

A comprehensive debugging methodology skill for AI coding agents, based on research from Andreas Zeller's "Why Programs Fail" and academic debugging curricula.

## Overview

This skill provides 42 rules across 8 categories to help developers debug systematically instead of randomly. Rules are prioritized by impact, from critical problem definition techniques to prevention practices.

## Categories

| Category | Impact | Rules | Focus |
|----------|--------|-------|-------|
| Problem Definition | CRITICAL | 6 | Reproducing and defining bugs clearly |
| Hypothesis-Driven Search | CRITICAL | 6 | Scientific method, binary search |
| Observation Techniques | HIGH | 6 | Logging, breakpoints, tracing |
| Root Cause Analysis | HIGH | 5 | 5 Whys, fault propagation |
| Tool Mastery | MEDIUM-HIGH | 6 | Debugger features |
| Fix Verification | MEDIUM | 4 | Confirming fixes work |
| Anti-Patterns | MEDIUM | 5 | What NOT to do |
| Prevention & Learning | LOW-MEDIUM | 4 | Postmortems, documentation |

## Key Principles

1. **Reproduce Before Debugging** - Never debug until you can reliably trigger the bug
2. **Apply Scientific Method** - Form hypotheses, predict outcomes, test systematically
3. **Binary Search Localization** - Narrow down by 50% with each checkpoint
4. **Find WHERE Before WHAT** - Locate first, understand second
5. **One Change at a Time** - Isolate variables to avoid confounding
6. **Question Assumptions** - Many bugs hide behind unquestioned beliefs

## Installation

```bash
npx add-skill pproenca/dot-skills --skill systematic-debugging
```

## File Structure

```
systematic-debugging/
├── SKILL.md           # Entry point with quick reference
├── AGENTS.md          # Full compiled guide
├── metadata.json      # Version and references
├── README.md          # This file
└── rules/
    ├── _sections.md   # Category definitions
    ├── prob-*.md      # Problem definition rules
    ├── hypo-*.md      # Hypothesis-driven search rules
    ├── obs-*.md       # Observation technique rules
    ├── rca-*.md       # Root cause analysis rules
    ├── tool-*.md      # Tool mastery rules
    ├── verify-*.md    # Fix verification rules
    ├── anti-*.md      # Anti-pattern rules
    └── prev-*.md      # Prevention rules
```

## References

- [Why Programs Fail](https://www.whyprogramsfail.com/) - Andreas Zeller
- [MIT 6.031 - Debugging](https://web.mit.edu/6.031/www/sp17/classes/11-debugging/)
- [Cornell CS312 - Debugging Techniques](https://www.cs.cornell.edu/courses/cs312/2006fa/lectures/lec26.html)
- [VS Code Debugging](https://code.visualstudio.com/docs/debugtest/debugging)

## License

MIT
