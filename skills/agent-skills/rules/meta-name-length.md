---
title: Keep Skill Names Under 64 Characters
impact: CRITICAL
impactDescription: 100% skill rejection by skills-ref validator
tags: meta, naming, limits, validation, skills-ref
---

## Keep Skill Names Under 64 Characters

The skills-ref validator enforces a 64-character maximum for skill names. Names exceeding this limit cause validation failure and cannot be published or distributed.

**Incorrect (exceeds 64-character limit):**

```yaml
---
name: enterprise-customer-relationship-management-data-synchronization-toolkit
description: Syncs CRM data
---
# 74 characters - exceeds limit
# skills-ref validate ./skills/enterprise-customer-...
# Error: Name cannot exceed 64 characters
```

**Correct (concise name under limit):**

```yaml
---
name: crm-sync
description: Synchronizes enterprise CRM data across platforms. Use when importing, exporting, or reconciling customer records.
---
# 8 characters - well under limit
# skills-ref validate ./skills/crm-sync/
# Validation passed
```

**Naming strategy:**
- Use common abbreviations (CRM, API, DB)
- Omit redundant words (tool, helper, utility)
- Focus on the action, not the domain
- Target 15-30 characters for optimal readability

**Validation command:**

```bash
# Check name length before creating skill
echo -n "my-skill-name" | wc -c  # Should be <= 64

# Or validate the full skill
skills-ref validate ./skills/my-skill/
```

Reference: [skills-ref validator](https://github.com/agentskills/agentskills/tree/main/skills-ref)
