# Tool Description Optimization

How to improve MCP tool descriptions based on eval results. Read this during Phase 4 when analyzing confusion patterns and drafting rewrites.

---

## The Optimization Loop

```
Confusion matrix → Identify worst pairs → Rewrite descriptions → Retest → Compare
```

Each iteration should improve accuracy on the confused pairs without regressing on tools that already work. If a rewrite fixes one confusion but creates another, the descriptions need a different framing.

---

## Disambiguation Patterns

### Cross-Reference Siblings

When two tools get confused, each description should say when to use the OTHER:

**Before (confusing):**
```
get_user — Fetch a user from the database.
find_user — Look up a user in the system.
```

**After (disambiguated):**
```
get_user — Fetch a user by their ID (e.g., usr_abc123). If you only have an email address, use find_user_by_email instead.
find_user_by_email — Look up a user by email address. Returns null if not found. If you already have the user's ID, use get_user.
```

The key move: each description tells Claude exactly when this tool is wrong and which tool is right instead.

### Input-Type Routing

When tools accept different identifier types, make the input type the first distinguishing feature:

```
get_order — Fetch an order by its order ID (format: ORD-XXXXXX). Returns full order details including line items and shipping status.
lookup_order_by_email — Find all orders for a customer email address. Returns a list of order summaries (ID, date, total) — use get_order for full details.
```

### Scope Boundaries

When tools operate on different scopes of the same entity, define the boundary:

```
search_issues — Full-text keyword search across issue title and body. Returns up to `limit` results ranked by relevance. Does NOT filter by status, assignee, or date — use list_issues for structured filtering.
list_issues — Browse issues with structured filters (status, assignee, priority, date range). Returns a paginated list sorted by date. For keyword/text search, use search_issues.
```

---

## Negation Patterns

### Explicit Exclusion

State what the tool does NOT do when an adjacent capability exists:

```
search_issues — Search issues by keyword. Does NOT search comments or pull requests — use search_comments / search_prs for those.
```

### Capability Boundary

Define the edge of what the tool can do:

```
get_issue — Fetch issue metadata (title, status, assignee, labels). Does NOT include the comment thread — use list_comments for that.
```

### System Boundary

When a tool only works within one system:

```
create_issue — Create a new issue in the project tracker. Does NOT create tickets in Jira or Slack threads — this only operates on the internal tracker.
```

---

## Return Shape Documentation

### State the Shape

Tell Claude exactly what comes back:

```
search_items — Returns a JSON array of {id, title, score} objects, up to `limit` results.
```

### State Truncation

When results can be large, describe the truncation behavior:

```
Returns up to 50 results. If more exist, the response includes `hasMore: true` and a `cursor` for pagination.
```

### State What's NOT Returned

Prevent follow-up confusion:

```
Returns issue metadata only (title, status, labels). Does not include the full body or comments — use get_issue for the body and list_comments for the thread.
```

---

## Recovery Hint Patterns

### Next-Step Hints

When a tool call fails, the error should suggest what to do next:

```typescript
if (!item) {
  return {
    isError: true,
    content: [{
      type: "text",
      text: "Item 'xyz' not found. Use search_items to find valid IDs."
    }]
  };
}
```

### Alternative Suggestion

When the user's intent doesn't match this tool:

```
"This tool only searches by keyword. For filtering by date or status, use list_items with the appropriate filters."
```

---

## The suggestions.json Format

Phase 4 outputs improvement suggestions in this format:

```json
{
  "iteration": 1,
  "suggestions": [
    {
      "tool": "search_issues",
      "field": "description",
      "before": "Search issues by keyword.",
      "after": "Search issues by keyword across title and body. Returns up to `limit` results ranked by relevance. Does NOT filter by status or assignee — use list_issues for structured filtering.",
      "reason": "Confused with list_issues 40% of the time. Adding scope boundary and cross-reference should disambiguate.",
      "confused_with": "list_issues",
      "confusion_rate": 0.4
    }
  ]
}
```

**Fields:**
- `tool`: The tool to modify
- `field`: Which field to change (`description` or a param description like `param:status`)
- `before`: Current text
- `after`: Proposed replacement
- `reason`: Why this change should help (linked to eval data)
- `confused_with`: The sibling tool causing confusion (if applicable)
- `confusion_rate`: How often this tool was selected when the sibling was expected

---

## Applying Rewrites

1. The suggestions.json file contains before/after text for each tool
2. Find the tool registration in your server source code
3. Replace the description string with the `after` text
4. Restart the server
5. Re-run Phase 1-3 of eval-mcp into a new iteration
6. Compare accuracy: the confusion rate for the modified pair should drop

**Do not apply all suggestions at once.** Change one sibling pair per iteration so you can attribute accuracy changes to specific rewrites. If you change everything at once, you can't tell which rewrites helped and which hurt.
