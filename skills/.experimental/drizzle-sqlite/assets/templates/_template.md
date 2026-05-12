---
title: {Action-Oriented Rule Title}
impact: {CRITICAL | HIGH | MEDIUM-HIGH | MEDIUM | LOW-MEDIUM | LOW}
impactDescription: {quantified impact — e.g., "2-10x improvement", "prevents stale closures", "O(n) to O(log n)"}
tags: {prefix}, {technique}, {tool-if-mentioned}, {related-concept}
---

## {Same as title}

{1-3 sentence WHY block. Explain the cascade effect, what breaks without this pattern, and the SQLite or Drizzle constraint that motivates it. Concrete, specific, no hedging.}

**Incorrect ({problem label — e.g., "select * scans every column"}):**

```typescript
{Bad code — production-realistic, not strawman}
{// Comments explaining the cost}
```

**Correct ({solution label — e.g., "projection narrows the query"}):**

```typescript
{Good code — minimal diff from incorrect}
{// Comments explaining the benefit}
```

{Optional sections — include only the ones that help:}

**Alternative ({context}):**

```typescript
{Alternative valid approach when applicable}
```

**When NOT to use this pattern:**
- {Specific exception 1}
- {Specific exception 2}

**Driver matrix / SQLite version note (only when relevant):**
- ✅ better-sqlite3 — full support
- ✅ libsql / Turso — full support
- ⚠️ Cloudflare D1 — works, but {caveat}

Reference: [{Title}]({URL}) · [{Optional second reference}]({URL})

---

### Authoring notes (delete before committing)

**Title patterns:**

| Pattern | When | Example |
|---------|------|---------|
| `Avoid {anti-pattern}` | Prohibiting | Avoid count(*) over large tables |
| `Use {X} for {Y}` | Recommending | Use inArray for batch lookups |
| `{Verb} {Object} in {Context}` | Contextual | Wrap multi-statement writes in db.transaction() |

**Impact descriptions:**

| Type | Pattern | Example |
|------|---------|---------|
| Multiplier | `N-Mx improvement` | `2-10x improvement` |
| Time | `Nms savings` | `eliminates 50ms network call` |
| Complexity | `O(x) to O(y)` | `O(n) to O(log n)` |
| Prevention | `prevents {problem}` | `prevents orphan rows` |

**Tags:**
1. First tag MUST be the category prefix (e.g., `schema`, `query`).
2. Add 2-5 more tags for techniques, tools, concepts.
3. Lowercase, hyphenated for multi-word.

**Code examples:**
- TypeScript, with imports shown.
- Production-realistic — show table definitions or column shapes when needed for context.
- Minimal diff between incorrect and correct, so the change is visually obvious.
- Comments explain the cost / benefit, not the syntax.
- Use real driver names (`better-sqlite3`, `libsql`, `bun:sqlite`) — never "your driver".
