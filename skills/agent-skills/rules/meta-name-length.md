---
title: Keep Skill Names Under 64 Characters
impact: CRITICAL
impactDescription: prevents truncation and discovery failures
tags: meta, naming, limits, validation
---

## Keep Skill Names Under 64 Characters

Skill names exceeding 64 characters get truncated in discovery systems, breaking skill matching and causing silent failures. Short, descriptive names also improve readability in skill listings.

**Incorrect (name too long, gets truncated):**

```yaml
---
name: enterprise-customer-relationship-management-data-synchronization-toolkit
description: Syncs CRM data
---
# 74 characters - exceeds limit
# Truncated to "enterprise-customer-relationship-management-data-synch..."
# Programmatic lookups fail silently
```

**Correct (concise name under limit):**

```yaml
---
name: crm-sync
description: Synchronizes enterprise CRM data across platforms. Use when importing, exporting, or reconciling customer records.
---
# 8 characters - well under limit
# Clear, memorable, works everywhere
```

**Naming strategy:**
- Use common abbreviations (CRM, API, DB)
- Omit redundant words (tool, helper, utility)
- Focus on the action, not the domain
- Target 15-30 characters for optimal readability

Reference: [Agent Skills - Claude Code Docs](https://code.claude.com/docs/en/skills)
