---
title: Document All Tool Parameters
impact: MEDIUM
impactDescription: prevents parameter errors and improves usability
tags: mcp, parameters, documentation, schema
---

## Document All Tool Parameters

Every MCP tool parameter needs a clear description, type, and constraints. Missing documentation causes Claude to guess parameter values, leading to API errors and failed tool calls.

**Incorrect (minimal parameter documentation):**

```json
{
  "name": "search_users",
  "inputSchema": {
    "type": "object",
    "properties": {
      "q": {"type": "string"},
      "n": {"type": "integer"},
      "s": {"type": "string"}
    }
  }
}
```

```text
# "q" - query? queue? what format?
# "n" - number of what? max? min?
# "s" - sort? status? string of what?
# Claude guesses wrong values
```

**Correct (full parameter documentation):**

```json
{
  "name": "search_users",
  "description": "Searches users by name, email, or role",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "Search term to match against user name, email, or role"
      },
      "limit": {
        "type": "integer",
        "description": "Maximum number of results to return (1-100, default 20)",
        "minimum": 1,
        "maximum": 100,
        "default": 20
      },
      "sort_by": {
        "type": "string",
        "description": "Field to sort results by",
        "enum": ["name", "email", "created_at", "last_login"],
        "default": "name"
      }
    },
    "required": ["query"]
  }
}
```

```text
# Clear parameter names
# Descriptions explain purpose and format
# Constraints prevent invalid values
# Defaults reduce required inputs
```

Reference: [MCP Specification](https://modelcontextprotocol.io/specification)
