---
title: Keep SKILL.md Under 500 Lines
impact: HIGH
impactDescription: prevents context exhaustion and token waste
tags: struct, length, tokens, progressive-disclosure
---

## Keep SKILL.md Under 500 Lines

The main SKILL.md file should stay under 500 lines. Longer files consume excessive tokens when loaded and may trigger context management. Move detailed content to referenced files.

**Incorrect (monolithic 2000+ line file):**

```markdown
# API Generator

## Instructions
[100 lines of core instructions]

## Complete API Reference
[500 lines of OpenAPI spec]

## All Error Codes
[300 lines of error documentation]

## Full Examples
[800 lines of example code]

## Changelog
[300 lines of version history]
```

```text
# 2000+ lines loaded on every activation
# ~4000 tokens consumed immediately
# Most content rarely needed
```

**Correct (core file with references):**

```markdown
# API Generator

## Instructions
[100 lines of core instructions]

## API Reference
For complete API documentation, see [api-reference.md](api-reference.md)

## Error Handling
For error codes, see [errors.md](errors.md)

## Examples
For usage examples, see [examples.md](examples.md)
```

```text
# 150 lines in main file
# ~300 tokens on activation
# Details loaded only when needed
```

**File splitting strategy:**
| Content Type | Location |
|--------------|----------|
| Core instructions | SKILL.md |
| API reference | reference.md |
| Examples | examples.md |
| Error codes | errors.md |
| Executable code | scripts/ |

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)
