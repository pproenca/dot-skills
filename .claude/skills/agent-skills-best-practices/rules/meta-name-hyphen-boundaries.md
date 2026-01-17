---
title: Never Start or End Names with Hyphens
impact: CRITICAL
impactDescription: 100% skill rejection by skills-ref validator
tags: meta, naming, validation, skills-ref
---

## Never Start or End Names with Hyphens

Skill names cannot start or end with hyphens. The skills-ref validator explicitly checks for this and rejects names with leading or trailing hyphens. This ensures consistent URL slugs and programmatic access patterns.

**Incorrect (leading hyphen):**

```yaml
---
name: -pdf-processor
description: Processes PDF files
---
# Validation error: name cannot start with hyphen
# skills-ref validate ./skills/-pdf-processor/
# Error: Name cannot start or end with hyphens
```

**Incorrect (trailing hyphen):**

```yaml
---
name: pdf-processor-
description: Processes PDF files
---
# Validation error: name cannot end with hyphen
# skills-ref validate ./skills/pdf-processor-/
# Error: Name cannot start or end with hyphens
```

**Correct (no boundary hyphens):**

```yaml
---
name: pdf-processor
description: Processes PDF files
---
# Valid: hyphens only between words
# skills-ref validate ./skills/pdf-processor/
# Validation passed
```

**Validation command:**

```bash
# Install skills-ref (Python 3.11+)
pip install skills-ref

# Validate skill directory
skills-ref validate ./skills/my-skill/
```

Reference: [skills-ref validator](https://github.com/agentskills/agentskills/tree/main/skills-ref)
