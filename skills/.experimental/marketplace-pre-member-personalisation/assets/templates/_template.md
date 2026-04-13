---
title: {Action-Oriented Rule Title in Title Case}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {quantified or pattern-verb impact — e.g. "enables X", "reduces Y", "prevents Z", "2-10× improvement"}
tags: {category-prefix}, {technique}, {research-concept}
---

## {Action-Oriented Rule Title in Title Case}

{One-to-three sentences explaining WHY this rule matters. Ground the explanation in
primary research where possible — cite the author and the specific claim. This is the
most important part of the rule; LLMs generalise better from understood reasoning than
from dictation. Do not say "always do X" — explain what the research shows, what goes
wrong when the rule is not followed, and how the visitor's specific psychological or
market-level situation produces the downstream effect.}

**Incorrect ({specific failure mode in 3-6 words}):**

```{language}
// Production-realistic bad code — not a strawman.
// Keep it under 20 lines. Use realistic names: seeker, provider,
// visitor, anon_session, request_id, trust_score, kennel_rate —
// never foo, bar, MyComponent, doSomething.
```

**Correct ({specific benefit in 3-6 words}):**

```{language}
// Production-realistic good code that differs minimally from the incorrect version —
// only the key insight changes. Same variable names, same structure, different
// behaviour where it matters. Under 20 lines.
```

Reference: [{Primary Research Source}](https://url-to-paper-or-book-or-engineering-blog)

## Authoring Checklist

Before saving, verify:

- [ ] Frontmatter has `title`, `impact`, `impactDescription`, `tags`
- [ ] First tag matches the category prefix from `_sections.md`
- [ ] Impact description uses a pattern verb (enables, reduces, prevents, avoids, saves) or quantifies
- [ ] The H2 title matches the frontmatter title exactly (no hyphens in the first word — breaks the imperative regex)
- [ ] Both code blocks have a language specifier (```typescript, ```python, ```json)
- [ ] Both annotations `(failure mode)` and `(benefit)` are specific, not `(bad)` or `(good)`
- [ ] No vague language: `might`, `perhaps`, `maybe`, `it is recommended`
- [ ] No marketing language: `powerful`, `magic`, `seamless`, `blazing fast`
- [ ] No generic names: `foo`, `bar`, `MyComponent`, `doSomething`, `processData`
- [ ] The explanation cites primary research or a foundational text where the claim is established
- [ ] Rule validates with `node scripts/validate-skill.js {skill-dir}` with no new errors
