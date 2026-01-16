---
title: Package Skills as Plugins for Distribution
impact: LOW-MEDIUM
impactDescription: enables one-command installation and updates
tags: maint, plugins, distribution, packaging
---

## Package Skills as Plugins for Distribution

When distributing skills beyond a single project, package them as Claude Code plugins. Plugins provide versioned installation, automatic updates, and proper dependency management.

**Incorrect (manual file sharing):**

```markdown
# Installation Instructions

1. Clone this repo
2. Copy the `skills/` directory to `~/.claude/skills/`
3. Restart Claude Code
4. To update, re-clone and re-copy
```

```text
# Users must manually manage files
# No version tracking
# Updates overwrite customizations
# Dependencies not managed
```

**Correct (plugin packaging):**

```text
my-skills-plugin/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── api-generator/
│   │   └── SKILL.md
│   └── test-runner/
│       └── SKILL.md
└── README.md
```

```json
// .claude-plugin/plugin.json
{
  "name": "my-skills",
  "version": "1.0.0",
  "description": "Collection of development skills",
  "skills": {
    "auto-discover": true
  }
}
```

```markdown
# Installation

/plugin add github:myorg/my-skills-plugin
```

**Plugin benefits:**
| Feature | Manual | Plugin |
|---------|--------|--------|
| Installation | Multi-step | One command |
| Updates | Manual copy | `/plugin update` |
| Versioning | None | Automatic |
| Dependencies | Manual | Declared |
| Rollback | Manual restore | Version pinning |

Reference: [Claude Code Plugins](https://code.claude.com/docs/en/plugins)
