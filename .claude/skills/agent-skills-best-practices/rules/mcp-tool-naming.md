---
title: Use Clear Action-Object Tool Names
impact: MEDIUM
impactDescription: improves tool selection accuracy by 40%
tags: mcp, naming, tools, discoverability
---

## Use Clear Action-Object Tool Names

Name MCP tools with a verb-object pattern that describes exactly what the tool does. Claude selects tools based on name matching, so unclear names cause wrong tool selection or missed opportunities.

**Incorrect (vague or noun-only names):**

```json
{
  "tools": [
    {"name": "data", "description": "Handles data operations"},
    {"name": "processor", "description": "Processes things"},
    {"name": "helper", "description": "Helps with tasks"}
  ]
}
```

```text
# "data" - data what? get? set? delete?
# "processor" - process what? how?
# Claude can't determine when to use these
```

**Correct (verb-object pattern):**

```json
{
  "tools": [
    {"name": "get_user_profile", "description": "Retrieves user profile data by user ID"},
    {"name": "update_user_settings", "description": "Updates user account settings"},
    {"name": "delete_user_session", "description": "Invalidates and removes user session"}
  ]
}
```

```text
# "get_user_profile" - clear action (get) and object (user_profile)
# "update_user_settings" - precise operation
# Claude matches user request to correct tool
```

**Naming patterns:**
| Action | Example Names |
|--------|---------------|
| Read | get_*, fetch_*, list_*, search_* |
| Create | create_*, add_*, insert_* |
| Update | update_*, set_*, modify_* |
| Delete | delete_*, remove_*, clear_* |
| Process | process_*, transform_*, validate_* |

Reference: [MCP Best Practices](https://modelcontextprotocol.info/docs/best-practices/)
