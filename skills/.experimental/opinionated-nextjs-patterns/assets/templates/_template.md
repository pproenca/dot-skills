---
title: {Action-Oriented Rule Title}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {Quantified outcome — e.g., "prevents cross-tenant data leaks", "saves 200ms per request", "2-10x faster builds"}
tags: {category-prefix}, {technique}, {tool-if-mentioned}, {related-concept}
---

## {Same as title above}

{1-3 sentences explaining WHY this matters in concrete terms. Describe what goes wrong without this pattern — the cascade effect, the failure mode, the specific bug class it prevents. The model generalises from understood reasoning, so this section is the highest-signal part of the rule. Avoid "Always do X" or "Never do Y" without saying *why*; the reasoning is what lets the model apply the pattern correctly in novel situations.}

**Incorrect ({short label for what's wrong}):**

```{language: ts|tsx|sql|json|bash|text}
// Production-realistic code — not strawman.
// Annotate with parenthetical comments explaining the cost.
const result = badPattern();
// Cost: what goes wrong, in concrete terms.
```

**Correct ({short label for what's right}):**

```{language}
// Minimal diff from the Incorrect example — same structure, fixed pattern.
const result = goodPattern();
// Benefit: what this gains, in concrete terms.
```

{Optional sections — include only when they add clarity:}

**Alternative ({short context}):**

```{language}
// When multiple valid approaches exist, show the second one.
const result = alternativePattern();
```

**When NOT to use this pattern:**

- {Edge case 1 with a specific signal — "if you have a single-row table" or "if the data is already paginated server-side"}
- {Edge case 2}

**Why this isn't ({common counterargument}):** {1-2 sentences addressing the most likely pushback. Often the reader's instinct is "this seems excessive" — pre-empt it.}

**Where this matters most:** {Concrete situations where this rule pays off — the hottest path, the most common bug, the highest-stakes feature.}

Reference: [{Source title}]({URL})

---

### Authoring Guidelines

**Required frontmatter fields:**

| Field | Format | Example |
|-------|--------|---------|
| `title` | Imperative phrase | "Use `authActionClient` for Authenticated Mutations" |
| `impact` | One of: CRITICAL, HIGH, MEDIUM-HIGH, MEDIUM, LOW-MEDIUM, LOW | `HIGH` |
| `impactDescription` | Quantified: "Nx", "Nms", "O(x) to O(y)", "%", "prevents X", "saves Y", "reduces Z" | `prevents cross-tenant data leaks` |
| `tags` | Comma-separated. First tag MUST be the category prefix | `auth, supabase, rls, server-client` |

**Quote the title in frontmatter** when it contains a colon (`:`), backticks containing colons, or any special YAML character:

```yaml
title: "Use `auth: false` for Webhook Routes"
```

**Title patterns:**

| Pattern | When | Example |
|---------|------|---------|
| `Use X for Y` | Recommending a tool / pattern | "Use `revalidatePath()` After Mutations" |
| `Avoid X` | Prohibiting | "Avoid Deep Imports from `@app/ui/src/*`" |
| `{Verb} {Object} in {Context}` | Contextual action | "Cache Workspace Loaders in `cache()`" |
| `{X} for {Y}` | Tool + use case | "`Promise.all` for Independent Reads" |

**Impact description patterns:**

| Type | Pattern | Example |
|------|---------|---------|
| Multiplier | `N-Mx improvement` | `2-10x faster` |
| Time | `N-Mms savings` | `200-500ms saved per page load` |
| Complexity | `O(x) to O(y)` | `O(n) to O(1)` |
| Prevention | `prevents {problem}` | `prevents cross-tenant data leaks` |
| Reduction | `reduces {thing} by N%` | `reduces bundle by 30%` |
| Saving | `saves {thing}` | `saves a hydration round-trip` |

**Language patterns:**

| Do | Don't |
|----|-------|
| Imperative: "Use", "Wrap", "Mark", "Embed" | Hedging: "consider", "you might want to" |
| Specific quantities: "200ms savings" | Vague: "faster", "significant improvement" |
| Concrete reasoning: "because X causes Y" | Dictation: "MUST do X" without reasoning |
| Production-realistic code | Strawman: `function foo() { return bar; }` |

**Filename convention:** `{prefix}-{kebab-case-title}.md` — e.g., `auth-use-standard-server-client.md`. The prefix MUST match the first tag and MUST be defined in `_sections.md`.

**Reference URLs:** prefer (1) official Next.js docs, (2) the prescribed library's official docs (next-safe-action, TanStack Query, React Hook Form, Zod, shadcn/ui, Base UI, next-intl, pino, Turborepo), (3) official backend docs (Supabase, Drizzle, Prisma) for the example, (4) MDN for web platform APIs. Avoid tutorial sites, Stack Overflow, personal blogs without benchmark data.
