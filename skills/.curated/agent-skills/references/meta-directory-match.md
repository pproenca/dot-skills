---
title: Match Skill Name to Directory Name
impact: CRITICAL
impactDescription: 100% skill rejection by skills-ref validator
tags: meta, naming, directory, filesystem, skills-ref
---

## Match Skill Name to Directory Name

The `name` field in frontmatter must exactly match the containing directory name. The skills-ref validator enforces this constraint using Unicode normalization (NFKC) to compare names.

**Incorrect (name does not match directory):**

```text
skills/
└── pdf-tools/           # Directory name
    └── SKILL.md
```

```yaml
---
name: pdf-processing     # Different from directory!
description: Handles PDF files
---
# skills-ref validate ./skills/pdf-tools/
# Error: Name must match the skill directory name
```

**Correct (name matches directory exactly):**

```text
skills/
└── pdf-processing/      # Directory name
    └── SKILL.md
```

```yaml
---
name: pdf-processing     # Matches directory
description: Handles PDF files
---
# skills-ref validate ./skills/pdf-processing/
# Validation passed
```

**Unicode normalization:**

The validator uses NFKC normalization, so these would match:
- `caf\u00e9` (precomposed) matches `cafe\u0301` (decomposed)
- Compatibility characters are normalized

**Benefits:**
- Passes skills-ref validation
- Reliable discovery across all platforms
- Simple mental model: directory = skill name

Reference: [skills-ref validator](https://github.com/agentskills/agentskills/tree/main/skills-ref)
