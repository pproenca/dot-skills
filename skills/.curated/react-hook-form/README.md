# React Hook Form Best Practices Skill

Corrective guidance for React Hook Form — the decisions that go wrong by default.

## Overview

This skill provides 35 rules across 7 categories. Every rule names a decision that a capable model gets wrong by default; rules that merely restated correct library behaviour were removed in 2.0.0. Verified against **react-hook-form 7.82.0** (July 2026), with every code block type-checked under `tsc --strict` against the real package types.

### Directory Structure

```
react-hook-form/
├── SKILL.md                    # Entry point with quick reference
├── AGENTS.md                   # Compiled comprehensive guide (TOC over references/)
├── metadata.json               # Version, org, references
├── README.md                   # This file
├── assets/
│   └── templates/
│       └── _template.md        # Rule template
└── references/
    ├── _sections.md            # Category definitions and impact ordering
    ├── formcfg-*.md            # Form configuration rules (9)
    ├── sub-*.md                # Field subscription rules (7)
    ├── ctrl-*.md               # Controlled component rules (2)
    ├── valid-*.md              # Validation pattern rules (4)
    ├── formstate-*.md          # State management rules (6)
    ├── array-*.md              # Field array rules (4)
    └── integ-*.md              # Integration pattern rules (3)
```

## Validating

This skill is validated by the repo-level tooling, not by per-skill scripts:

```bash
npm run validate                                     # structural validation of every skill
node /path/to/dev-skill/scripts/validate-skill.js .  # discipline-aware validation of this skill
```

## Creating a New Rule

1. Choose the appropriate category prefix:

| Category | Prefix | Impact |
|----------|--------|--------|
| Form Configuration | `formcfg-` | CRITICAL |
| Field Subscription | `sub-` | CRITICAL |
| Controlled Components | `ctrl-` | HIGH |
| Validation Patterns | `valid-` | HIGH |
| State Management | `formstate-` | MEDIUM-HIGH |
| Field Arrays | `array-` | MEDIUM-HIGH |
| Integration Patterns | `integ-` | MEDIUM |

2. Create a new file: `references/{prefix}-{slug}.md`

3. Use the rule template from `assets/templates/_template.md`

4. Add the rule to the SKILL.md quick reference and to the AGENTS.md table of contents (entries are ordered alphabetically by title within each section).

## Rule File Structure

```markdown
---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: What the rule prevents or enables
tags: prefix, keyword1, keyword2
---

## Rule Title Here

Brief explanation of WHY this matters (1-3 sentences).

**Incorrect (description of problem):**

\`\`\`typescript
// Bad code with comment on key line
\`\`\`

**Correct (description of solution):**

\`\`\`typescript
// Good code with minimal diff from incorrect
\`\`\`

Reference: [Documentation Link](https://example.com)
```

## File Naming Convention

Rules follow the pattern: `{prefix}-{slug}.md`

- **prefix**: Category identifier from `_sections.md` (lowercase letters only)
- **slug**: Kebab-case description of the rule

Examples:
- `formcfg-validation-mode.md`
- `sub-usewatch-over-watch.md`
- `ctrl-usecontroller-isolation.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Cascade effect on entire form performance |
| HIGH | Significant impact on specific operations |
| MEDIUM-HIGH | Notable improvement for common patterns |
| MEDIUM | Measurable improvement in specific scenarios |
| LOW-MEDIUM | Minor optimization for edge cases |
| LOW | Best practice with minimal performance impact |

## Companion Skill

`react-hook-form-audit` is a static-analysis skill that detects violations of these rules in a Next.js App Router codebase and links each finding back to the corresponding file in `references/`.

## Contributing

1. Read existing rules in the same category for style consistency
2. Ensure incorrect/correct examples have minimal diff
3. Typecheck every example against the pinned react-hook-form version before committing
4. Include authoritative reference links
5. Run validation before submitting

## Acknowledgments

Based on official React Hook Form documentation, the library's shipped type definitions, and community best practices.
