# Code Simplifier Skill

A comprehensive code simplification skill for AI agents and LLMs, containing 45 rules across 8 categories.

## Overview

This skill guides code simplification with a focus on:
- **Context-first approach**: Understand project conventions before making changes
- **Behavior preservation**: Change how code is written, never what it does
- **Scope discipline**: Focus on recently modified code, keep diffs small
- **Clarity over brevity**: Explicit, readable code beats clever one-liners

## Structure

```
code-simplifier/
├── SKILL.md                    # Entry point with quick reference
├── README.md                   # This file
├── metadata.json               # Version, organization, references
├── references/
│   ├── _sections.md            # Category definitions and ordering
│   ├── ctx-*.md                # Context Discovery rules (5)
│   ├── behave-*.md             # Behavior Preservation rules (6)
│   ├── scope-*.md              # Scope Management rules (5)
│   ├── flow-*.md               # Control Flow rules (7)
│   ├── name-*.md               # Naming and Clarity rules (5)
│   ├── dup-*.md                # Duplication Reduction rules (5)
│   ├── dead-*.md               # Dead Code Elimination rules (5)
│   └── idiom-*.md              # Language Idioms rules (7)
└── assets/
    └── templates/
        └── _template.md        # Template for new rules
```

## Getting Started

```bash
# No installation required - this is a documentation-only skill
# For development/validation:
pnpm install   # Install validation dependencies (optional)
pnpm build     # Build/compile AGENTS.md from source rules
pnpm validate  # Validate skill structure and content
```

1. Read `SKILL.md` for an overview and quick reference
2. Check `references/_sections.md` to understand category priorities
3. Reference individual rules as needed during code simplification tasks

## Creating a New Rule

1. Copy `assets/templates/_template.md` to `references/{prefix}-{slug}.md`
2. Fill in frontmatter: title, impact, impactDescription, tags
3. Write WHY explanation (1-3 sentences)
4. Add incorrect and correct code examples
5. Update `SKILL.md` quick reference section

## Rule File Structure

Each rule file follows this format:

```markdown
---
title: Rule Title
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "reduces nesting by 40%")
tags: prefix, technique, related-concepts
---

## Rule Title

WHY this matters (1-3 sentences).

**Incorrect (what's wrong):**
\`\`\`language
Bad example
\`\`\`

**Correct (what's right):**
\`\`\`language
Good example - minimal diff from incorrect
\`\`\`
```

## File Naming Convention

- Prefix must match category: `ctx-`, `behave-`, `scope-`, `flow-`, `name-`, `dup-`, `dead-`, `idiom-`
- Slug should be descriptive: `early-return`, `preserve-outputs`, `rule-of-three`
- Examples: `flow-early-return.md`, `behave-preserve-api.md`, `dup-rule-of-three.md`

## Impact Levels

| Level | Description | When to Use |
|-------|-------------|-------------|
| CRITICAL | Must follow, violations cause bugs or breaking changes | Context discovery, behavior preservation |
| HIGH | Strongly recommended, violations harm maintainability | Scope management, control flow |
| MEDIUM-HIGH | Recommended for clarity and consistency | Naming conventions |
| MEDIUM | Good practice, apply when beneficial | Duplication, dead code |
| LOW-MEDIUM | Nice to have, language-specific optimizations | Language idioms |

## Scripts

Validate the skill structure and content:

```bash
node ~/.claude/plugins/cache/dot-claude/dev-skill/*/scripts/validate-skill.js ./code-simplifier
```

## Contributing

1. Follow the rule template exactly
2. Ensure the first tag matches the file prefix
3. Use production-realistic code examples (no foo/bar/baz)
4. Quantify impact where possible
5. Include "When NOT to Apply" section for complex rules
6. Run validation before submitting
