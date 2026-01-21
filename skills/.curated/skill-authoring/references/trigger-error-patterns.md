---
title: Include Error Patterns in Debugging Skills
impact: HIGH
impactDescription: enables automatic activation when errors occur
tags: trigger, errors, debugging, diagnostics
---

## Include Error Patterns in Debugging Skills

For skills that help diagnose or fix errors, include common error message patterns in the description. Claude can then activate the skill when users paste error messages.

**Incorrect (no error patterns):**

```yaml
---
name: typescript-debugger
description: Helps debug TypeScript code and resolve type issues.
---
```

```text
# User pastes "Type 'string' is not assignable to type 'number'"
# Skill doesn't recognize this as its domain
# User must explicitly request TypeScript help
```

**Correct (common error patterns included):**

```yaml
---
name: typescript-debugger
description: Resolves TypeScript compilation errors and type mismatches. This skill should be used when encountering type errors like "is not assignable to type", "Property does not exist", "Cannot find name", or TS error codes (TS2322, TS2339, TS2304).
---
```

```text
# User pastes "Type 'string' is not assignable to type 'number'"
# Matches "is not assignable to type"
# Skill automatically activates to help
```

**Error pattern strategies:**
- Include exact error message substrings
- Reference error code prefixes (TS, E, ERRNO)
- Mention common symptom descriptions
- Include stack trace patterns if relevant

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
