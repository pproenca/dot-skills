---
title: Match Skill Name to Directory Name
impact: CRITICAL
impactDescription: prevents discovery failures and maintenance confusion
tags: meta, naming, directory, filesystem
---

## Match Skill Name to Directory Name

The `name` field in frontmatter must exactly match the containing directory name. Mismatches cause discovery failures on some systems and create maintenance confusion when updating skills.

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
# Some discovery systems fail
# Developers confused when searching for skill
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
# Consistent naming across filesystem and metadata
# Easy to locate skill source from any reference
```

**Benefits:**
- Reliable discovery across all platforms
- Simple mental model: directory = skill name
- Easy grep/search for skill references

Reference: [Agent Skills - Claude Code Docs](https://code.claude.com/docs/en/skills)
