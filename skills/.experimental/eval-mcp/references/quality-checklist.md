# MCP Tool Quality Checklist

Testable criteria for MCP tool schemas. Each check has a pass/fail threshold used by `scripts/analyze-schemas.sh`. Source of truth for these criteria is `build-mcp-server/references/tool-design.md`.

---

## Description Quality

### DQ-1: Description Length
**Pass:** >= 20 characters
**Fail:** Missing or under 20 characters
**Why:** Short descriptions like "Searches for issues" give Claude nothing to disambiguate. Descriptions must say what the tool does, what it returns, and what it doesn't do.

### DQ-2: States What the Tool Does
**Pass:** Description contains an action verb describing the operation
**Fail:** Description is a noun phrase or lacks a clear action
**Why:** Claude reads descriptions as contracts. "Issue searcher" is ambiguous; "Search issues by keyword across title and body" is actionable.

### DQ-3: States What the Tool Returns
**Pass:** Description mentions return/output format (contains "return", "output", "result", "produce", "respond")
**Fail:** No mention of what comes back
**Why:** Claude needs to know whether a tool returns a list, a single item, a confirmation, or structured data to use it correctly in multi-step workflows.

### DQ-4: Disambiguates from Siblings
**Pass:** Description mentions what the tool does NOT do, or when to use a different tool
**Fail:** No negation or cross-reference
**Why:** When two tools overlap, each description should say when to use the OTHER one. Without this, Claude picks based on keyword similarity and frequently confuses siblings.

---

## Parameter Schema Quality

### PS-1: All Parameters Have Descriptions
**Pass:** 100% of parameters have a `description` field
**Fail:** Any parameter lacks a description
**Why:** The `.describe()` text shows up in the schema Claude sees. Omitting it forces Claude to guess what the parameter means from the name alone.

### PS-2: String Parameters Use Constraints
**Pass:** String parameters use `enum`, `pattern` (regex), or `format` where applicable
**Fail:** Bare `string` type for a constrained value (IDs, statuses, categories)
**Why:** Tight schemas prevent bad calls. `z.string()` for an ID lets Claude pass anything; `z.string().regex(/^usr_[a-z0-9]{12}$/)` validates at the schema level.

### PS-3: Number Parameters Have Bounds
**Pass:** Number parameters have `minimum`, `maximum`, or `default`
**Fail:** Unbounded number with no guidance
**Why:** Without bounds, Claude may pass 0, -1, or 999999. Bounds prevent nonsensical values and communicate intent.

### PS-4: Optional Parameters Document Defaults
**Pass:** Optional parameters describe their default behavior
**Fail:** Optional parameter with no hint about what happens when omitted
**Why:** Claude decides whether to include optional params based on the description. "Defaults to the caller's workspace" tells Claude it can usually skip this param.

---

## Annotation Coverage

### AC-1: Tool Has At Least One Annotation
**Pass:** `annotations` object exists with at least one hint
**Fail:** No annotations at all
**Why:** Annotations drive host UX (auto-approve for readonly, confirm for destructive). Missing annotations means the host assumes worst case.

### AC-2: Read-Only Tools Marked
**Pass:** Tools that don't modify state have `readOnlyHint: true`
**Fail:** Read-only tool without the annotation
**Why:** Hosts may auto-approve read-only calls, reducing user friction. Missing annotation means unnecessary confirmation prompts.

### AC-3: Destructive Tools Marked
**Pass:** Tools that delete or overwrite have `destructiveHint: true`
**Fail:** Destructive tool without the annotation
**Why:** Hosts show confirmation dialogs for destructive tools. Missing annotation means a delete could execute without warning.

---

## Tool Set Quality

### TS-1: Tool Count in Range
**Pass:** 1-15 tools (optimal), 15-30 (acceptable with warning)
**Fail:** 0 tools or 30+ tools
**Why:** Every tool schema consumes tokens in Claude's context window. 30 tools with rich schemas can eat 3-5k tokens before the conversation starts. Over 30, switch to search+execute.

### TS-2: No High Sibling Overlap
**Pass:** No two tools share > 50% of non-stopword description tokens
**Fail:** A pair exceeds the overlap threshold
**Why:** High overlap means Claude will confuse the pair. Either merge them, rename them, or add disambiguation to both descriptions.

### TS-3: Similar Tools Cross-Reference
**Pass:** Tools flagged as siblings in TS-2 reference each other in descriptions
**Fail:** Similar tools exist without cross-references
**Why:** The pattern from tool-design.md: `get_user — Fetch by ID. If you only have an email, use find_user_by_email.`

---

## Error Handling

### EH-1: Descriptions Mention Error Cases
**Pass:** Description or return docs mention at least one error condition
**Fail:** No mention of failure modes
**Why:** Tools that only describe the happy path leave Claude guessing when things fail. "Returns null if not found" is more useful than silence.

### EH-2: Error Returns Include Recovery Hints
**Pass:** Error responses use `isError: true` with a next-step suggestion
**Fail:** Bare error message or transport exception
**Why:** The hint turns a dead end into a next step: "Item not found. Use search_items to find valid IDs."

*Note: EH-2 is only testable at runtime, not via static schema analysis.*
