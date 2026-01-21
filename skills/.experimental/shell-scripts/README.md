# Shell Scripts Best Practices Skill

A comprehensive best practices guide for shell scripting (bash and POSIX sh), designed for AI agents and LLMs.

## Overview

This skill contains **48 rules** across **9 categories**, prioritized by impact:

| Impact | Categories |
|--------|-----------|
| CRITICAL | Safety & Security, Portability |
| HIGH | Error Handling, Variables & Data |
| MEDIUM-HIGH | Quoting & Expansion |
| MEDIUM | Functions & Structure, Testing & Conditionals |
| LOW-MEDIUM | Performance |
| LOW | Style & Formatting |

## Getting Started

```bash
# Install dependencies
pnpm install

# Build AGENTS.md from rule files
pnpm build

# Validate the skill
pnpm validate
```

## Usage

### For AI Agents

Point your agent to `SKILL.md` for a quick reference, or `AGENTS.md` for the complete compiled guide with all rules inline.

### For Humans

Browse the `references/` directory for individual rules with detailed examples.

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Entry point with quick reference |
| `AGENTS.md` | Complete compiled guide |
| `metadata.json` | Version and references |
| `references/_sections.md` | Category definitions |
| `references/*.md` | Individual rules |
| `assets/templates/_template.md` | Template for new rules |

## Creating a New Rule

1. Copy the template file
2. Fill in the frontmatter and content
3. Place in the `references/` directory
4. Rebuild AGENTS.md

## Rule File Structure

Each rule file follows this structure:

```markdown
---
title: Rule Title
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified benefit (e.g., "2-10× improvement")
tags: category-prefix, technique, related-concepts
---

## Rule Title

Brief explanation of WHY this matters.

**Incorrect (what's wrong):**

\`\`\`bash
# Bad example
\`\`\`

**Correct (what's right):**

\`\`\`bash
# Good example
\`\`\`

Reference: [Source](url)
```

## File Naming Convention

Rule files follow the pattern: `{category-prefix}-{descriptive-slug}.md`

Examples:
- `safety-command-injection.md`
- `err-strict-mode.md`
- `perf-builtins-over-external.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Security vulnerabilities or failures across environments |
| HIGH | Cascading errors or data corruption |
| MEDIUM-HIGH | Common bugs affecting multiple operations |
| MEDIUM | Maintenance burden or subtle logic errors |
| LOW-MEDIUM | Performance issues that multiply in loops |
| LOW | Style and readability improvements |

## Scripts

| Script | Description |
|--------|-------------|
| `build-agents-md.js` | Compiles rule files into AGENTS.md |
| `validate-skill.js` | Validates skill against quality checklist |

## Contributing

To contribute a new rule:

1. Copy `assets/templates/_template.md` to `references/{prefix}-{slug}.md`
2. Fill in the frontmatter: title, impact, impactDescription, tags
3. Write the rule with **Incorrect** and **Correct** code examples
4. Run `pnpm validate` to check for issues
5. Run `pnpm build` to regenerate AGENTS.md
6. Submit a pull request

## Key Sources

- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [ShellCheck](https://www.shellcheck.net/)
- [Greg's Wiki](https://mywiki.wooledge.org/)
- [POSIX Shell Specification](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)
