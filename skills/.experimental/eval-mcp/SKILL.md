---
name: eval-mcp
description: Use this skill when the user asks to "evaluate MCP tools", "test tool selection", "improve tool descriptions", "check MCP schema quality", "eval my MCP server", or wants to measure whether Claude uses their MCP tools correctly. Tests tool selection accuracy, analyzes schema quality, and iteratively optimizes descriptions. Companion to build-mcp-server.
---

# Evaluate MCP Tools

Tool descriptions are prompt engineering — they land directly in Claude's context window and determine whether Claude picks the right tool with the right arguments. This skill makes tool quality **measurable and improvable** instead of guesswork.

Three levels of testing, each building on the last:
1. **Static Analysis** — deterministic schema quality checks (no Claude calls)
2. **Selection Testing** — does Claude pick the right tool for each intent?
3. **Description Optimization** — iterative improvement based on confusion patterns

## When to Apply

- User wants to check if their MCP tool schemas are well-designed
- User wants to test whether Claude selects the right tools for user intents
- User is debugging tool confusion (Claude picks the wrong tool)
- User wants to optimize tool descriptions for better selection accuracy
- User has finished scaffolding with `build-mcp-server` and wants to validate quality

## Workflow Overview

```
Phase 1: Connect → Phase 2: Static Analysis → Phase 3: Selection Testing → Phase 4: Optimize
                                                            ↑__________________________|
```

Phase 4 loops back: apply rewrites → refetch schemas → retest → compare accuracy.

## Prerequisites

- **Node.js >= 18** — required for the MCP Inspector CLI (`npx`)
- **jq** — required for schema analysis scripts
- **A running MCP server** — the server must respond to `tools/list`. Use `build-mcp-server/scripts/test-server.sh` to verify connectivity first.

---

## Phase 1 — Connect & Inventory

Connect to the user's MCP server and fetch the tool schemas.

### 1a: Get connection details

Ask the user how to reach their server:
- **HTTP/SSE**: URL (e.g., `http://localhost:3000/mcp`)
- **stdio**: spawn command (e.g., `node dist/server.js`)

### 1b: Fetch tool schemas

```bash
bash scripts/fetch-tools.sh <url-or-command> <transport> <workspace>/tools.json
```

This calls `tools/list` via the MCP Inspector CLI and saves the schemas.

### 1c: Display inventory

Show a summary table:

```markdown
| # | Tool | Description (preview) | Params | Annotations |
|---|------|-----------------------|--------|-------------|
| 1 | search_issues | Search issues by keyword... | 3 | readOnlyHint |
| 2 | create_issue | Create a new issue... | 4 | — |
```

Flag tool count: 1-15 optimal, 15-30 warning, 30+ excessive (consider search+execute pattern).

### 1d: Create workspace

Create workspace at `{server-name}-eval/` adjacent to the skill directory or in the user's project:

```
{server-name}-eval/
├── tools.json
├── evals/
│   └── evals.json
└── iteration-N/
```

---

## Phase 2 — Static Analysis

Run deterministic quality checks — no Claude calls needed. This gives immediate feedback during development.

### 2a: Run analysis

```bash
bash scripts/analyze-schemas.sh <workspace>/tools.json <workspace>/iteration-N/static-analysis.json
```

### 2b: Display results

Show per-tool quality scores. Read [`references/quality-checklist.md`](references/quality-checklist.md) for the criteria being checked.

```markdown
| Tool | Desc | Params | Schema | Annotations | Overall | Issues |
|------|------|--------|--------|-------------|---------|--------|
| search_issues | 3/3 | 3/3 | 2/3 | 2/3 | 2.5 | No negation |
| create_issue | 1/3 | 1/3 | 0/3 | 0/3 | 0.5 | 4 issues |
```

### 2c: Flag sibling pairs

If the analysis found tools with high description overlap, highlight them as confusion risks:

```markdown
### Sibling Pairs (confusion risk)
| Tool A | Tool B | Overlap | Risk |
|--------|--------|---------|------|
| search_issues | list_issues | 52% | HIGH |
```

### 2d: Decision point

If critical issues exist (missing descriptions, zero annotations), recommend fixing them before Phase 3. Static issues create noise in selection testing — fix the obvious problems first, then measure the subtle ones.

If all tools score well, proceed to Phase 3.

---

## Phase 3 — Selection Testing

Test whether Claude picks the right tool for each user intent. This is the core eval.

### 3a: Generate test intents

Read [`references/eval-patterns.md`](references/eval-patterns.md) for intent generation patterns.

For each tool, generate:
- **3 should-trigger intents** — direct, implicit, and casual phrasings
- **2 should-not-trigger intents** — near-miss and keyword overlap

For each sibling pair flagged in Phase 2:
- **1 disambiguation intent per tool** — tests whether Claude picks the RIGHT sibling

Present all intents to the user for review. Ask if any should be added, removed, or modified.

### 3b: Save intents

Save to `{workspace}/evals/evals.json`:

```json
{
  "server_name": "my-server",
  "generated_from": "tools.json",
  "intents": [
    {
      "id": 1,
      "intent": "Are there any open bugs related to checkout?",
      "expected_tool": "search_issues",
      "type": "should_trigger",
      "target_tool": "search_issues",
      "notes": "Implicit intent — doesn't name the action"
    }
  ]
}
```

### 3c: Run selection tests

For each intent, spawn a subagent that receives:
1. The full tool schemas from tools.json (formatted as they'd appear in Claude's context)
2. The user intent text
3. Instructions to select exactly one tool and provide arguments, or decline if no tool fits

The subagent prompt:

```
You have access to the following MCP tools:

{tool schemas as JSON}

A user sends this message:
"{intent text}"

Which tool would you call? Respond with JSON:
{
  "selected_tool": "tool_name" or null,
  "arguments": { ... } or {},
  "reasoning": "One sentence explaining your choice"
}

If no tool fits the user's request, set selected_tool to null.
Select exactly ONE tool. Do not suggest calling multiple tools.
```

Save each result to `{workspace}/iteration-N/selection/intent-{ID}/result.json`.

Launch all selection tests in parallel for efficiency.

### 3d: Grade results

```bash
bash scripts/grade-selection.sh \
  <workspace>/iteration-N/selection \
  <workspace>/evals/evals.json \
  <workspace>/iteration-N/benchmark.json
```

### 3e: Display results

```markdown
## Selection Results — Iteration N

**Accuracy:** 82% (41/50 correct)

| Metric | Count |
|--------|-------|
| Correct | 41 |
| Wrong tool | 5 |
| False accept | 2 |
| False reject | 2 |

### Per-Tool Accuracy
| Tool | Precision | Recall |
|------|-----------|--------|
| search_issues | 0.90 | 0.85 |
| create_issue | 1.00 | 1.00 |

### Worst Confusions
| Expected | Selected Instead | Times |
|----------|-----------------|-------|
| list_issues | search_issues | 3 |
| get_user | find_user_by_email | 2 |
```

---

## Phase 4 — Optimize & Iterate

Analyze confusion patterns and suggest description improvements. Read [`references/optimization.md`](references/optimization.md) for rewrite patterns.

### 4a: Analyze confusions

For each confused pair (from worst_confusions):
1. Read both tools' current descriptions
2. Identify why they're confusing (missing negation, overlapping scope, no cross-reference)
3. Draft a specific rewrite following the disambiguation patterns in optimization.md

### 4b: Present suggestions

```markdown
## Suggested Improvements

### search_issues ↔ list_issues (confused 3 times)

**search_issues — Before:**
> Search issues by keyword.

**search_issues — After:**
> Search issues by keyword across title and body. Returns up to `limit` results ranked by relevance. Does NOT filter by status, assignee, or date — use list_issues for structured filtering.

**Reason:** Adding scope boundary and cross-reference to disambiguate from list_issues.
```

Save to `{workspace}/iteration-N/suggestions.json` (format defined in optimization.md).

### 4c: Apply and retest

After the user applies the rewrites to their server code:

1. Restart the server
2. Re-run Phase 1 to refetch tools.json (descriptions may have changed)
3. Re-run Phase 2 for updated static analysis
4. Re-run Phase 3 into `iteration-N+1` using the same evals.json
5. Compare accuracy:

```markdown
## Iteration Comparison

| Metric | Iteration 1 | Iteration 2 | Delta |
|--------|------------|------------|-------|
| Accuracy | 82% | 94% | +12% |
| search↔list confusion | 3 | 0 | -3 |
```

### 4d: Iteration guidance

- Change **one sibling pair per iteration** so you can attribute improvements
- If accuracy plateaus, the remaining confusions may need architectural changes (merging tools, renaming, or restructuring the tool surface)
- Stop when accuracy exceeds 90% or when remaining confusions are in ambiguous edge cases that humans would also struggle with

---

## Reference Files

Read these when you reach the relevant phase — not upfront:

- [`references/quality-checklist.md`](references/quality-checklist.md) — Testable quality criteria for tool schemas (Phase 2)
- [`references/eval-patterns.md`](references/eval-patterns.md) — How to write tool selection test intents (Phase 3)
- [`references/optimization.md`](references/optimization.md) — How to improve descriptions from eval results (Phase 4)

## Related Skills

- `build-mcp-server` — Design and scaffold MCP servers (run this first, then eval-mcp to validate)
- `build-mcp-app` — MCP servers with interactive UI widgets
