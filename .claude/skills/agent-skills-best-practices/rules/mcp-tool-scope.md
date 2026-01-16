---
title: Design Single-Purpose Tools
impact: MEDIUM
impactDescription: improves tool selection precision and reduces errors
tags: mcp, scope, single-purpose, design
---

## Design Single-Purpose Tools

Each MCP tool should do one thing well. Multi-purpose tools with many optional parameters confuse Claude's tool selection and increase the chance of incorrect usage.

**Incorrect (multi-purpose tool with mode parameter):**

```json
{
  "name": "manage_users",
  "description": "Creates, updates, deletes, or retrieves users",
  "inputSchema": {
    "type": "object",
    "properties": {
      "action": {
        "type": "string",
        "enum": ["create", "update", "delete", "get", "list"]
      },
      "user_id": {"type": "string"},
      "user_data": {"type": "object"},
      "filters": {"type": "object"}
    }
  }
}
```

```text
# 5 actions with different required parameters
# Claude must understand modal behavior
# Easy to pass wrong combination
# Error messages complex to generate
```

**Correct (separate tools for each action):**

```json
{
  "tools": [
    {
      "name": "create_user",
      "description": "Creates a new user account",
      "inputSchema": {
        "properties": {
          "name": {"type": "string", "description": "User's full name"},
          "email": {"type": "string", "description": "User's email address"}
        },
        "required": ["name", "email"]
      }
    },
    {
      "name": "get_user",
      "description": "Retrieves user profile by ID",
      "inputSchema": {
        "properties": {
          "user_id": {"type": "string", "description": "User's unique identifier"}
        },
        "required": ["user_id"]
      }
    },
    {
      "name": "delete_user",
      "description": "Permanently deletes a user account",
      "inputSchema": {
        "properties": {
          "user_id": {"type": "string", "description": "User's unique identifier"}
        },
        "required": ["user_id"]
      }
    }
  ]
}
```

```text
# Each tool has clear purpose
# Required parameters obvious
# Claude selects correct tool directly
# Simpler error handling per tool
```

Reference: [MCP Best Practices](https://modelcontextprotocol.info/docs/best-practices/)
