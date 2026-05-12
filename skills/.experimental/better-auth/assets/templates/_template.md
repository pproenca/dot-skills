---
title: {Imperative Action Title}
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: {quantified impact — e.g., "100x improvement", "prevents stale closures", "200ms savings"}
tags: {category-prefix}, {technique}, {tool}, {concept}
---

## {Imperative Action Title}

{1-3 sentences explaining WHY this matters. Focus on what goes wrong without this pattern and what the cascade effect is. The model generalizes from understood reasoning, not from dictation. Don't just say "use X" — explain what happens when you don't, in concrete terms.}

**Incorrect ({short label describing the problem}):**

```typescript
// Production-realistic counter-example, not a strawman
// Comments explaining the cost of this approach
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  // ... what's wrong
});
```

**Correct ({short label describing the solution}):**

```typescript
// Minimal diff from the incorrect example
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  // ... the right thing
});
```

{Optional sections — include only when they add value:}

**Alternative ({when applicable}):**

```typescript
// Different but equally valid approach for a specific context
```

**Common use cases:**
- {Scenario 1 where this rule applies}
- {Scenario 2}

**When NOT to use this pattern:**
- {Edge case where the rule's tradeoff doesn't pay off}

**Warning:** {Gotcha worth highlighting — specific failure mode, not generic caution}

**Benefits:**
- {Enumerable advantage 1}
- {Enumerable advantage 2}

Reference: [{Page Title}]({URL to canonical Better Auth docs})

---

## Authoring Notes

1. **First tag MUST be the category prefix** (`setup`, `db`, `route`, `session`, `auth`, `security`, `plugins`, `migrate`).
2. **Title MUST start with an imperative verb** ("Use", "Avoid", "Mount", "Configure", "Pair") — never starts with "Don't" or hedging language.
3. **Both Incorrect AND Correct blocks are required.** Each must have a language specifier on the code fence (`typescript`, `text`, `bash`, `sql`).
4. **Impact descriptions should be quantified** when possible: "2-10x improvement", "200ms savings", "O(n) to O(1)", or "prevents {specific problem}".
5. **No marketing language** — avoid "amazing", "powerful", "seamless", "magical", "blazing fast". The validator flags these as warnings.
6. **Annotations on Incorrect/Correct headers** use parenthetical style: `**Incorrect (no email verification):**` not `**Incorrect — no email verification:**`.
