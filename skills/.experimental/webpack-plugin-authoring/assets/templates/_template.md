---
title: {Imperative-Verb Object [in Context]}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {quantified — "2-10x improvement" | "200ms savings" | "O(n) to O(1)" | "prevents <named failure>"}
tags: {category-prefix}, {technique}, {tool-or-api}, {related-concept}
---

## {Same as title — imperative form}

{1-3 sentences explaining WHY this matters. Focus on what goes wrong without this pattern: the cascade effect, the bug it produces in production, the cost it imposes at scale. Be specific — name the failure mode (e.g., "the dev-server overlay shows nothing meaningful", "persistent cache misses 95% of the time"). The model generalizes from understood reasoning, not from dictation — explain the mechanism, not just the rule.}

**Incorrect ({what's wrong — one phrase}):**

```js
// Production-realistic code drawn from how this is actually written.
// Avoid strawman examples like `const foo = bar`.

class MyExamplePlugin {
  apply(compiler) {
    // Annotate the offending line with a comment explaining the cost
    compiler.hooks.someHook.tap('MyExamplePlugin', /* ... */);
  }
}
```

**Correct ({what's right — one phrase}):**

```js
// Minimal diff from the incorrect version — the FIX should be clearly visible.

class MyExamplePlugin {
  apply(compiler) {
    compiler.hooks.theRightHook.tap('MyExamplePlugin', /* ... */);
  }
}
```

{Optional sections — include only if applicable:}

**Alternative ({when applicable}):**

```js
// Different valid approach for a specific scenario
```

**When NOT to use this pattern:**

- {Specific exception 1 — when the "wrong" thing is actually right}
- {Specific exception 2}

**Benefits:**

- {Concrete benefit 1}
- {Concrete benefit 2}

**Decision table / API summary:**

| Column 1 | Column 2 |
|---|---|
| Option A | When to use |
| Option B | When to use |

Reference: [{Authoritative source title}]({URL — webpack.js.org, github.com/webpack-contrib, vercel/next.js})

---

## Authoring checklist

Before adding a new rule:

- [ ] Filename matches `{prefix}-{kebab-case-slug}.md` where `{prefix}` is one of the 8 categories from `references/_sections.md`
- [ ] First tag in frontmatter is the category prefix
- [ ] Title is in imperative form (Use, Avoid, Cache, Match, Set...)
- [ ] `impactDescription` is quantified — Nx improvement, Nms saved, prevents <named failure>, or O(x) to O(y)
- [ ] Code examples are production-realistic (drawn from real plugins or written to that bar)
- [ ] Both Incorrect AND Correct sections present with `**Incorrect ({label}):**` exactly
- [ ] Code blocks have a language specifier (` ```js `, ` ```json `, ` ```text `)
- [ ] Reference link points to webpack.js.org, github.com/webpack, github.com/webpack-contrib, vercel/next.js, or another authoritative source
- [ ] After saving, run `node ${CLAUDE_PLUGIN_ROOT}/scripts/validate-skill.js /path/to/this/skill` to verify
- [ ] After saving, run `node ${CLAUDE_PLUGIN_ROOT}/scripts/build-agents-md.js /path/to/this/skill` to refresh `AGENTS.md`
