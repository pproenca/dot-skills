---
title: Include All Required Frontmatter Fields
impact: CRITICAL
impactDescription: prevents 100% skill failures from missing metadata
tags: meta, frontmatter, yaml, validation
---

## Include All Required Frontmatter Fields

Every SKILL.md must have valid YAML frontmatter with `name` and `description` fields. Missing or malformed frontmatter causes silent loading failures—the skill appears in the directory but never activates.

**Incorrect (missing description field):**

```yaml
---
name: code-review
# Missing description field
---

# Code Review Instructions
...
# Skill loads but never triggers automatically
# Claude cannot determine when to use it
```

**Correct (all required fields present):**

```yaml
---
name: code-review
description: Reviews code for quality issues, security vulnerabilities, and performance problems. Use when reviewing PRs, auditing code, or checking for bugs.
---

# Code Review Instructions
...
# Skill triggers reliably when user mentions code review
```

**Field requirements:**
| Field | Required | Max Length | Format |
|-------|----------|------------|--------|
| name | Yes | 64 chars | lowercase, hyphens, numbers |
| description | Yes | 1024 chars | Third-person, trigger keywords |

Reference: [Agent Skills - Claude Code Docs](https://code.claude.com/docs/en/skills)
