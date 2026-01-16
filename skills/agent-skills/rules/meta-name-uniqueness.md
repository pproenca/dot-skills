---
title: Ensure Skill Names Are Globally Unique
impact: CRITICAL
impactDescription: prevents silent overrides and unpredictable behavior
tags: meta, naming, conflicts, discovery
---

## Ensure Skill Names Are Globally Unique

Skill names must be unique within each scope (project, user, plugin). When names collide, higher-priority scopes silently override lower ones. Users see unpredictable behavior without any error.

**Incorrect (generic name collides with common plugins):**

```yaml
---
name: utils
description: General utility functions
---
# Collides with utils from anthropic/skills plugin
# Your skill silently overrides or gets overridden
```

**Correct (prefixed name avoids collisions):**

```yaml
---
name: acme-deployment-utils
description: ACME Corp deployment utility functions
---
# Unique namespace prevents collisions
# Clear ownership when multiple plugins installed
```

**Priority order (highest wins):**
1. Enterprise managed settings
2. Personal (~/.claude/skills/)
3. Project (.claude/skills/)
4. Plugin-provided skills

**When NOT to use prefixes:**
- Official Anthropic skills that define the standard
- Project-only skills never distributed externally

Reference: [Agent Skills - Claude Code Docs](https://code.claude.com/docs/en/skills)
