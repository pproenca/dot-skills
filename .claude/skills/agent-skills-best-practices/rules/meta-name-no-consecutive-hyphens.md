---
title: Avoid Consecutive Hyphens in Names
impact: CRITICAL
impactDescription: 100% skill rejection by skills-ref validator
tags: meta, naming, validation, skills-ref
---

## Avoid Consecutive Hyphens in Names

Skill names cannot contain consecutive hyphens (`--`). The skills-ref validator rejects names with double or multiple consecutive hyphens. This prevents ambiguous word boundaries and ensures clean URL slugs.

**Incorrect (double hyphen):**

```yaml
---
name: pdf--processor
description: Processes PDF files
---
# Validation error: consecutive hyphens not allowed
# skills-ref validate ./skills/pdf--processor/
# Error: Name cannot contain consecutive hyphens
```

**Incorrect (multiple consecutive hyphens):**

```yaml
---
name: enterprise---crm---sync
description: Syncs enterprise CRM data
---
# Validation error: triple hyphens not allowed
# Ambiguous word boundaries
```

**Correct (single hyphens only):**

```yaml
---
name: pdf-processor
description: Processes PDF files
---
# Valid: single hyphens between words
# skills-ref validate ./skills/pdf-processor/
# Validation passed
```

**Common causes:**
- Find-and-replace errors when renaming
- Copy-paste from URLs with encoded characters
- Automated slug generation without normalization

**Prevention pattern:**

```javascript
// Normalize skill names before creating directories
function normalizeSkillName(name) {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9-]/g, '-')
    .replace(/-+/g, '-')  // Collapse consecutive hyphens
    .replace(/^-|-$/g, ''); // Remove boundary hyphens
}
```

Reference: [skills-ref validator](https://github.com/agentskills/agentskills/tree/main/skills-ref)
