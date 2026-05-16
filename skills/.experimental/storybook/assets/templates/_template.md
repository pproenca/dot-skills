---
title: {Action-Oriented Title — e.g., "Use X for Y", "Avoid Z"}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {quantified impact — "5-10x faster cold start", "prevents flaky CI runs"}
tags: {category-prefix}, {technique}, {tool}, {related-concept}
---

## {Title — same as frontmatter `title`}

{1-3 sentences explaining WHY this matters. Focus on the cascade effect: what tooling, what stage of the component lifecycle, what fails downstream when you skip this. The reader should finish the paragraph understanding the *reason*, not just the rule.}

**Incorrect ({short label of what's wrong}):**

```{ts|tsx|json|yml|bash|mdx}
{Bad code — production-realistic, not strawman.}
{// Inline comments explaining what breaks here.}
```

**Correct ({short label of what's right}):**

```{ts|tsx|json|yml|bash|mdx}
{Good code — minimal diff from incorrect.}
{// Inline comments explaining the benefit / what's now possible.}
```

{Optional sections — include only those that add real value:}

**Alternative ({when an alternative pattern is also valid}):**

```{lang}
{...}
```

**When NOT to use this pattern:**
- {Specific exception 1, with the rationale.}
- {Specific exception 2.}

**Why this matters:**
{Optional one-line summary if the cascade isn't obvious from the WHY paragraph above.}

Reference: [{title}]({url}), [{title}]({url})

---

## Rule conventions for this skill

- **Title pattern**: `Use X for Y`, `Avoid {anti-pattern}`, `{Verb} {object} {context}`. Imperative mood.
- **Filename**: `{prefix}-{kebab-case-slug}.md` matching the section prefix in `_sections.md`.
- **First tag**: MUST be the category prefix (`config`, `csf`, `args`, `deco`, `test`, `axe`, `docs`, `build`).
- **Examples**: realistic component names (`Card`, `LoginForm`, `DataTable`), not `Foo`/`Bar`. CSF3 + `satisfies Meta`. Use `storybook/test` import path (not `@storybook/test`).
- **Code language tags**: `tsx` for stories/components, `ts` for config/utils, `mdx` for MDX, `bash` for shell, `yml` for CI, `json` for package.json/config.json.
- **References**: official Storybook docs, addon docs, MDN/W3C for web platform, Chromatic docs for visual regression. Avoid tutorial sites.
