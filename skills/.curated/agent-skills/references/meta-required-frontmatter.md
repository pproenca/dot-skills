---
title: Include All Required Frontmatter Fields
impact: CRITICAL
impactDescription: 100% skill rejection by skills-ref validator
tags: meta, frontmatter, yaml, validation, skills-ref
---

## Include All Required Frontmatter Fields

Every SKILL.md must have valid YAML frontmatter with `name` and `description` fields. The skills-ref validator requires both fields and rejects skills with missing or empty values.

**Incorrect (missing description field):**

```yaml
---
name: code-review
---
# skills-ref validate ./skills/code-review/
# Error: description is required
```

**Incorrect (empty name):**

```yaml
---
name: ""
description: Reviews code for quality issues
---
# skills-ref validate ./skills/code-review/
# Error: name must be non-empty
```

**Correct (all required fields present):**

```yaml
---
name: code-review
description: Reviews code for quality issues, security vulnerabilities, and performance problems. Use when reviewing PRs, auditing code, or checking for bugs.
---

# Code Review Instructions
...
# skills-ref validate ./skills/code-review/
# Validation passed
```

**Field requirements (per skills-ref):**

| Field | Required | Max Length | Format |
|-------|----------|------------|--------|
| name | Yes | 64 chars | lowercase, hyphens, digits |
| description | Yes | 1024 chars | non-empty string |

**Validation command:**

```bash
skills-ref validate ./skills/my-skill/
# Or extract properties as JSON
skills-ref read-properties ./skills/my-skill/
```

Reference: [skills-ref validator](https://github.com/agentskills/agentskills/tree/main/skills-ref)
