# Agent Skills Best Practices

Comprehensive design and development guide for AI agent skills, including Claude Code skills and MCP tools. This skill helps you create reliable, maintainable, and efficient skills that trigger accurately and execute correctly.

## Overview

This skill contains 43 rules across 8 categories, organized by impact level:

| Category | Rules | Impact |
|----------|-------|--------|
| Skill Metadata Design | 6 | CRITICAL |
| Description Engineering | 7 | CRITICAL |
| Content Structure | 6 | HIGH |
| Trigger Optimization | 5 | HIGH |
| Progressive Disclosure | 5 | MEDIUM-HIGH |
| MCP Tool Design | 6 | MEDIUM |
| Testing and Validation | 4 | MEDIUM |
| Maintenance and Distribution | 4 | LOW-MEDIUM |

## Structure

```
agent-skills/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, references, metadata
├── README.md             # This file
└── rules/
    ├── _sections.md      # Category definitions
    ├── _template.md      # Rule template
    ├── meta-*.md         # Skill metadata rules (6)
    ├── desc-*.md         # Description engineering rules (7)
    ├── struct-*.md       # Content structure rules (6)
    ├── trigger-*.md      # Trigger optimization rules (5)
    ├── prog-*.md         # Progressive disclosure rules (5)
    ├── mcp-*.md          # MCP tool design rules (6)
    ├── test-*.md         # Testing rules (4)
    └── maint-*.md        # Maintenance rules (4)
```

## Getting Started

### Using in Claude Code

This skill automatically activates when you're working on:
- Creating new Claude Code skills
- Writing SKILL.md files
- Designing MCP tools
- Testing skill activation

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
3. Copy `rules/_template.md` as your starting point
4. Fill in frontmatter and content

### Prefix Reference

| Prefix | Category | Impact |
|--------|----------|--------|
| `meta-` | Skill Metadata Design | CRITICAL |
| `desc-` | Description Engineering | CRITICAL |
| `struct-` | Content Structure | HIGH |
| `trigger-` | Trigger Optimization | HIGH |
| `prog-` | Progressive Disclosure | MEDIUM-HIGH |
| `mcp-` | MCP Tool Design | MEDIUM |
| `test-` | Testing and Validation | MEDIUM |
| `maint-` | Maintenance and Distribution | LOW-MEDIUM |

## Rule File Structure

Each rule follows this template:

```markdown
---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10× improvement")
tags: prefix, technique, related-concepts
---

## Rule Title Here

1-3 sentences explaining WHY this matters.

**Incorrect (what's wrong):**

\`\`\`yaml
# Bad example
\`\`\`

**Correct (what's right):**

\`\`\`yaml
# Good example
\`\`\`

Reference: [Link](https://example.com)
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{description}.md`

Examples:
- `meta-name-format.md` - Metadata category, about name formatting
- `desc-trigger-keywords.md` - Description category, about trigger keywords
- `mcp-tool-naming.md` - MCP category, about tool naming

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Skill fails to function without this |
| HIGH | Major degradation in reliability or usability |
| MEDIUM-HIGH | Significant impact on specific workflows |
| MEDIUM | Noticeable improvement in quality |
| LOW-MEDIUM | Incremental improvement |
| LOW | Minor optimization |

## Scripts

| Command | Description |
|---------|-------------|
| `pnpm build` | Compiles rules into AGENTS.md |
| `pnpm validate` | Validates skill structure and rules |

## Contributing

1. Check existing rules to avoid duplication
2. Use the rule template (`rules/_template.md`)
3. Include both incorrect and correct examples
4. Quantify impact where possible
5. Reference authoritative sources
6. Run validation before submitting

## Acknowledgments

This skill draws from:
- [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [MCP Best Practices](https://modelcontextprotocol.info/docs/best-practices/)
- [Prompt Engineering Guide](https://www.promptingguide.ai/)

## License

Apache 2.0
