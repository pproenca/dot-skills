---
title: Implement Three-Level Progressive Disclosure
impact: MEDIUM-HIGH
impactDescription: reduces token usage by 60-80% while maintaining capability
tags: prog, disclosure, tokens, architecture
---

## Implement Three-Level Progressive Disclosure

Structure skill content across three disclosure levels: metadata at startup, full SKILL.md when activated, and supplementary files when needed. This prevents context exhaustion while enabling deep functionality.

**Incorrect (everything in one file):**

```markdown
# PDF Processor

## Instructions
[50 lines of core instructions]

## Complete API Reference
[500 lines of API documentation]

## All File Format Details
[300 lines of format specs]

## Every Example
[400 lines of examples]
```

```text
# 1250+ lines loaded on first activation
# ~2500 tokens consumed immediately
# Most content never used in typical session
```

**Correct (three-level disclosure):**

```text
pdf-processor/
├── SKILL.md           # Level 2: Core instructions (~100 lines)
├── api-reference.md   # Level 3: Loaded when API help needed
├── formats.md         # Level 3: Loaded for format questions
└── examples.md        # Level 3: Loaded when examples requested
```

```yaml
# Level 1: SKILL.md frontmatter (always loaded)
---
name: pdf-processor
description: Extract text, tables, and forms from PDFs.
---
```

```markdown
# Level 2: SKILL.md body (loaded on activation)

## Quick Start
Extract text with `extractText(pdf)`. For advanced API options,
see [api-reference.md](api-reference.md).

## Supported Formats
PDF 1.0-2.0 supported. For format details,
see [formats.md](formats.md).
```

**Disclosure levels:**
| Level | When Loaded | Content |
|-------|-------------|---------|
| 1 | Session start | name, description (~50 tokens) |
| 2 | Skill activation | SKILL.md body (~200 tokens) |
| 3 | On demand | Reference files (~500+ tokens each) |

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
