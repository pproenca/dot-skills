---
title: Use Lowercase Hyphenated Skill Names
impact: CRITICAL
impactDescription: prevents discovery failures and cross-platform issues
tags: meta, naming, discovery, filesystem
---

## Use Lowercase Hyphenated Skill Names

The skill name must match the directory name and use lowercase with hyphens. Mixed case or special characters cause discovery failures on case-sensitive filesystems and break URL routing in skill registries.

**Incorrect (mixed case and spaces cause failures):**

```yaml
---
name: PDF Processing Tool
description: Handles PDF files
---
# Discovery fails on Linux/macOS due to case mismatch
# Spaces break URL routing in plugin marketplaces
```

**Correct (lowercase hyphenated matches directory):**

```yaml
---
name: pdf-processing
description: Handles PDF files
---
# Directory: skills/pdf-processing/SKILL.md
# Works consistently across all platforms
```

**Benefits:**
- Consistent discovery across Windows, macOS, and Linux
- Valid URL slugs for plugin marketplaces
- Predictable programmatic access via Automation API

Reference: [Agent Skills - Claude Code Docs](https://code.claude.com/docs/en/skills)
