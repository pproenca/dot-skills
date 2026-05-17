---
title: {Imperative Action-Oriented Title — start with a verb}
impact: CRITICAL | HIGH | MEDIUM-HIGH | MEDIUM | LOW-MEDIUM | LOW
impactDescription: {quantified impact — prefer "prevents X" or a measurable metric}
tags: {category-prefix}, {technique}, {tool-or-concept}, {related-concept}
---

## {Title — repeat the frontmatter title}

{1-3 sentences explaining WHY this matters. State the design-propagation cascade: what
goes wrong without this pattern, and how the wrong decision propagates to every
endpoint / every SDK / every client integration. This is the highest-signal part of
the rule — the model generalises from understood reasoning, not from dictation.}

{Optional 1-2 more sentences with context: when the pattern applies, why Stripe in
particular landed on this approach, or the historical incident that motivated it.}

**Incorrect ({short label naming what's wrong}):**

```{language: json | text | python | javascript | sql | yaml | bash}
{Bad code — production-realistic, not strawman. Include enough context that the
problem is visible, but no more than needed.}
```

```text
// Annotation block explaining the failure mode.
// What breaks, when, how often, and why.
// Keep concrete — name the specific bug, not "this might cause issues".
```

**Correct ({short label naming what's right}):**

```{language}
{Good code — minimal diff from the incorrect version where possible, so the
reader sees the exact transformation. Include enough context to be a complete example.}
```

```text
// Annotation block explaining why this works.
// What's better, what's prevented, what's enabled.
// Cross-reference related rules with [[slug]] or markdown link.
```

{Optional sections — include only when they add value. Don't include empty sections.}

**Alternative ({context}):**
{When two approaches are both valid, describe the alternative and when to pick it.}

**When NOT to use this pattern:**
- {Specific exception, with the trigger condition that flips the recommendation}
- {Another exception, if any}

**Benefits:**
- {Enumerable advantage that didn't fit in the prose above}
- {Another, if any — keep the list short}

**Common use cases:**
- {Where the pattern shows up in practice}
- {Another instance, if any}

**Warning ({context}):**
{Something that's easy to get subtly wrong even when following the rule.}

Reference: [{Source Title}]({URL}), [{Second Source}]({URL2})

---

## Authoring checklist

When adding a new rule, verify:

- [ ] Filename is `{category-prefix}-{slug}.md` (e.g., `resource-prefixed-string-ids.md`)
- [ ] First tag in frontmatter matches the category prefix
- [ ] Title starts with an imperative verb (`Use`, `Avoid`, `Prefer`, `Discriminate`, `Pluralize`, ...)
- [ ] `impactDescription` is quantified — starts with "prevents X" or names a measurable metric
- [ ] WHY explanation is 1-3 sentences, not boilerplate
- [ ] Both incorrect and correct code blocks have language tags (`json`, `text`, `python`, `bash`, ...)
- [ ] Annotation blocks (the `//`-comment blocks) use `text` as the language
- [ ] At least one Reference link to a canonical source (Stripe docs, Stripe blog, Brandur, etc.)
- [ ] Cross-references to related rules use `[`slug`](slug.md)` markdown links

## Naming conventions for new categories

If proposing a new top-level category:

- Prefix: 3-8 lowercase chars, hyphen-terminated when used in filenames
- Add to `references/_sections.md` with an `**Impact:**` line and a one-sentence rationale
- Position in the file by **design propagation impact** — earlier = harder to undo
- Re-run `validate-skill.js --sections-only` after editing `_sections.md`
- Re-run `build-agents-md.js` after adding rules so `AGENTS.md` reflects the new category
