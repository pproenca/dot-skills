---
title: Return Actionable Error Messages
impact: MEDIUM
impactDescription: enables Claude to self-correct and retry
tags: mcp, errors, messages, recovery
---

## Return Actionable Error Messages

When MCP tools fail, return error messages that explain what went wrong and how to fix it. Generic errors leave Claude unable to recover, causing repeated failures or giving up entirely.

**Incorrect (generic error messages):**

```json
{
  "error": {
    "code": -1,
    "message": "Operation failed"
  }
}
```

```text
# "Operation failed" - what operation? why?
# Claude has no information to self-correct
# User sees "I encountered an error"
# No path forward
```

**Correct (actionable error with guidance):**

```json
{
  "error": {
    "code": 422,
    "message": "Invalid date format",
    "details": {
      "field": "start_date",
      "received": "2024-1-5",
      "expected": "ISO 8601 format (YYYY-MM-DD)",
      "example": "2024-01-05"
    }
  }
}
```

```text
# Identifies exact field with problem
# Shows what was received
# Explains expected format
# Provides working example
# Claude can retry with corrected value
```

**Error message components:**
| Component | Purpose | Example |
|-----------|---------|---------|
| code | Error category | 422 (validation), 404 (not found) |
| message | Human-readable summary | "Invalid date format" |
| field | Which parameter failed | "start_date" |
| received | What was provided | "2024-1-5" |
| expected | What format is needed | "YYYY-MM-DD" |
| example | Working value | "2024-01-05" |

Reference: [MCP Best Practices](https://modelcontextprotocol.info/docs/best-practices/)
