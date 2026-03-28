# Tool Selection Eval Patterns

How to generate test intents that measure whether Claude picks the right tool. Read this before Phase 3 of the eval workflow.

---

## Should-Trigger Intents

Intents that should cause a specific tool to be selected. Generate 3 per tool, varying formality and directness.

### Direct Request
Name the action explicitly. Easiest to get right — tests basic description matching.

```
Tool: create_issue
Intent: "Create a new issue titled 'Login timeout on mobile'"
```

### Implicit Intent
Describe the need without naming the action. Tests whether the description captures the use case, not just keywords.

```
Tool: search_issues
Intent: "Are there any open bugs related to the checkout flow?"
```

### Casual / Domain Jargon
Use informal language or domain-specific terms. Tests description robustness beyond formal phrasing.

```
Tool: update_issue
Intent: "Can you bump issue 42 to high priority? It's blocking the release."
```

### Key rule
Never use the tool's exact name in the intent. You're testing whether the description drives selection, not whether Claude can pattern-match on the tool name.

---

## Should-NOT-Trigger Intents

Intents that should cause Claude to decline (select no tool). Generate 2 per tool, testing different failure modes.

### Near-Miss (Adjacent Capability)
Share vocabulary with a real tool but request something it can't do.

```
Available: search_issues (searches issues by keyword)
Intent: "Search the pull requests for mentions of the auth refactor"
Why decline: No PR search tool exists. The keyword "search" overlaps but the domain is wrong.
```

### Keyword Overlap (Wrong Semantics)
Use the same verbs/nouns but for a fundamentally different operation.

```
Available: create_issue, add_comment
Intent: "Create a new Slack channel for the team"
Why decline: "Create" overlaps but the target system is completely different.
```

### Beyond Capability
Request something no tool in the set can do.

```
Available: [issue tracker tools]
Intent: "Deploy the latest build to staging"
Why decline: No deployment tools exist in this server.
```

---

## Disambiguation Intents

For tool pairs flagged as siblings (high description overlap), generate intents that test whether Claude picks the RIGHT sibling. These are the highest-value tests.

### Input-Type Disambiguation

```
Tools: get_user (by ID), find_user_by_email (by email)
Intent: "Look up the user with email john@example.com"
Expected: find_user_by_email (not get_user)
Why: Tests whether descriptions clarify which input type each accepts.
```

### Scope Disambiguation

```
Tools: search_issues (keyword search), list_issues (browse with filters)
Intent: "Show me all critical issues from this week"
Expected: list_issues (filter by severity + date, not keyword search)
Why: Tests whether "search" vs "list/filter" distinction is clear.
```

### Action Disambiguation

```
Tools: update_issue (modify fields), add_comment (append note)
Intent: "Add a note to issue 42 saying the fix is deployed"
Expected: add_comment (not update_issue)
Why: Tests whether "add a note" maps to comment, not field update.
```

---

## Edge Cases

Include 2-3 edge cases per eval set.

### Empty / Meaningless Intent
```
Intent: ""
Expected: none (decline)
```

### Multi-Tool Intent
```
Intent: "Find the issue about login bugs and add a comment saying it's fixed"
Expected: search_issues (first tool in the sequence)
Note: Selection tests pick ONE tool. Multi-step sequences are out of scope — the test validates the first selection.
```

### Negated Intent
```
Intent: "Don't create a new issue, just search for existing ones about login"
Expected: search_issues (not create_issue)
Why: Tests whether Claude parses negation correctly and doesn't keyword-match on "create."
```

---

## Intent Writing Guidelines

1. **Natural language only.** Write as a real user would — include context, vary formality, allow typos if natural.
2. **Never use the tool name.** Test description quality, not name matching. "Run the search_issues tool" is useless.
3. **One intent, one expected tool.** Each intent maps to exactly one tool (or none). Multi-tool intents test the first step.
4. **Include domain context.** "Find the login bug" is generic; "Check if there's already a ticket for the 504 errors on /api/checkout" is realistic.
5. **Vary across tools.** Don't cluster all intents on the most obvious tool. Less-used tools often have the worst descriptions.

---

## How Many Intents?

| Tool Count | Should-Trigger | Should-Not | Disambiguation | Total |
|-----------|---------------|-----------|----------------|-------|
| 3-5 tools | 3 per tool | 2 per tool | 1 per sibling pair | ~20-30 |
| 6-10 tools | 3 per tool | 2 per tool | 1 per sibling pair | ~35-60 |
| 11-15 tools | 2 per tool | 1 per tool | 1 per sibling pair | ~40-60 |

Keep total under 60 for practical cost. Each intent is one Claude call.
