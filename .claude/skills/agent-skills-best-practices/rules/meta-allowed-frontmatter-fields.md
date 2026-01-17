---
title: Only Use Allowed Frontmatter Fields
impact: CRITICAL
impactDescription: 100% skill rejection by skills-ref validator
tags: meta, frontmatter, validation, skills-ref
---

## Only Use Allowed Frontmatter Fields

SKILL.md frontmatter must only contain recognized fields. The skills-ref validator enforces a strict allowlist and rejects skills with unexpected fields. This ensures forward compatibility and prevents silent failures.

**Allowed fields:**

| Field | Required | Max Length | Description |
|-------|----------|------------|-------------|
| `name` | Yes | 64 chars | Skill identifier (lowercase, hyphens, digits) |
| `description` | Yes | 1024 chars | What the skill does and when to use it |
| `license` | No | - | License identifier (e.g., MIT, Apache-2.0) |
| `allowed-tools` | No | - | Tool patterns the skill requires (experimental) |
| `metadata` | No | - | Custom key-value pairs for client-specific data |
| `compatibility` | No | 500 chars | Version or platform compatibility info |

**Incorrect (unknown field):**

```yaml
---
name: code-review
description: Reviews code for quality issues
author: John Doe
version: 1.0.0
---
# Validation error: unexpected fields
# skills-ref validate ./skills/code-review/
# Error: Unexpected fields in frontmatter: author, version
```

**Correct (only allowed fields):**

```yaml
---
name: code-review
description: Reviews code for quality issues, security vulnerabilities, and performance problems. Use when reviewing PRs or auditing code.
license: MIT
metadata:
  author: John Doe
  version: 1.0.0
---
# Valid: custom data goes in metadata field
# skills-ref validate ./skills/code-review/
# Validation passed
```

**Migration guide:**

| Old Field | Migration |
|-----------|-----------|
| `author` | Move to `metadata.author` |
| `version` | Move to `metadata.version` |
| `tags` | Move to `metadata.tags` |
| `category` | Move to `metadata.category` |

Reference: [skills-ref validator](https://github.com/agentskills/agentskills/tree/main/skills-ref)
