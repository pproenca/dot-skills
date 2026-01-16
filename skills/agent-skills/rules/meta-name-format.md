---
title: Use Lowercase Hyphenated Skill Names
impact: CRITICAL
impactDescription: 100% skill rejection by skills-ref validator
tags: meta, naming, discovery, filesystem, skills-ref
---

## Use Lowercase Hyphenated Skill Names

The skill name must use lowercase letters, digits, and hyphens only. The skills-ref validator enforces this constraint and rejects names with uppercase letters, spaces, or special characters.

**Incorrect (mixed case causes validation failure):**

```yaml
---
name: PDF-Processing
description: Handles PDF files
---
# skills-ref validate ./skills/PDF-Processing/
# Error: Name must be lowercase
```

**Incorrect (spaces not allowed):**

```yaml
---
name: pdf processing tool
description: Handles PDF files
---
# skills-ref validate ./skills/pdf processing tool/
# Error: Name can only contain letters, digits, and hyphens
```

**Correct (lowercase with hyphens):**

```yaml
---
name: pdf-processing
description: Handles PDF files
---
# Directory: skills/pdf-processing/SKILL.md
# skills-ref validate ./skills/pdf-processing/
# Validation passed
```

**Allowed characters:**
- Lowercase letters (a-z)
- Digits (0-9)
- Hyphens (-)
- Unicode letters for i18n support

**Benefits:**
- Passes skills-ref validation
- Consistent discovery across Windows, macOS, and Linux
- Valid URL slugs for plugin marketplaces

Reference: [skills-ref validator](https://github.com/agentskills/agentskills/tree/main/skills-ref)
