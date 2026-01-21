---
title: Use allowed-tools for Safety Constraints
impact: MEDIUM
impactDescription: prevents accidental destructive operations
tags: mcp, allowed-tools, safety, permissions
---

## Use allowed-tools for Safety Constraints

Restrict which tools a skill can use via the `allowed-tools` frontmatter field. This prevents accidental file modifications during read-only operations or unintended command execution.

**Incorrect (no tool restrictions):**

```yaml
---
name: code-analyzer
description: Analyzes code for quality issues
---

# Code Analyzer

Analyze the codebase and report issues...
```

```text
# Skill has access to all tools
# Claude might edit files while "analyzing"
# Claude might run commands to "check" things
# Unintended side effects possible
```

**Correct (explicit tool restrictions):**

```yaml
---
name: code-analyzer
description: Analyzes code for quality issues
allowed-tools: Read, Grep, Glob
---

# Code Analyzer

Analyze the codebase and report issues...
```

```text
# Only read-only tools available
# Cannot edit files during analysis
# Cannot execute arbitrary commands
# Safe by design
```

**Common restriction patterns:**
| Skill Type | Allowed Tools |
|------------|---------------|
| Read-only analysis | Read, Grep, Glob |
| Code modification | Read, Edit, Write |
| Git operations | Bash(git:*) |
| Specific language | Bash(python:*), Bash(node:*) |
| Full access | Omit allowed-tools |

**Wildcard syntax:**
- `Bash(git:*)` - Only git commands
- `Bash(npm:*)` - Only npm commands
- `Bash(python scripts/*.py)` - Only specific scripts

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)
