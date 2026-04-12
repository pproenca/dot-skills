---
title: {Action-Oriented Rule Title in Title Case}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {quantified impact — e.g. "2-10× improvement", "prevents stale closures", "O(n) to O(1)"}
tags: {category-prefix}, {technique}, {concept}
---

## {Action-Oriented Rule Title in Title Case}

{One-to-three sentences explaining WHY this rule matters. Focus on the cascade effect —
what goes wrong when the rule is not followed, and how the problem propagates to every
downstream stage. This is the most important part of the rule; LLMs generalise better
from understood reasoning than from dictation. Do not say "always do X" — explain what
happens when you do not, in concrete terms the model can internalise.}

**Incorrect ({specific failure mode in 3-6 words}):**

```{language}
# Production-realistic bad code — not a strawman.
# Keep it under 20 lines. Use realistic names like seeker, provider,
# listing, booking, requestId — never foo, bar, MyComponent, doSomething.
```

**Correct ({specific benefit in 3-6 words}):**

```{language}
# Production-realistic good code that differs minimally from the incorrect version —
# only the key insight changes. Same variable names, same structure, different
# behaviour where it matters. Under 20 lines.
```

Reference: [{Authoritative Source Title}]({https://url-to-primary-source})

## Authoring Checklist

Before saving, verify:

- [ ] Frontmatter has `title`, `impact`, `impactDescription`, `tags`
- [ ] First tag matches the category prefix from `_sections.md`
- [ ] Impact level is consistent with sibling rules in the same category
- [ ] Impact description is quantified (contains a number, verb like `prevents` / `reduces` / `enables`, or `O(n)` notation)
- [ ] The H2 title matches the frontmatter title exactly
- [ ] Both code blocks have a language specifier (```typescript, ```python, ```json)
- [ ] Both annotations `(failure mode)` and `(benefit)` are specific, not `(bad)` or `(good)`
- [ ] No vague language: `might want`, `perhaps`, `it is recommended`, `you may want`
- [ ] No marketing language: `powerful`, `seamless`, `amazing`, `blazing fast`
- [ ] No generic names: `foo`, `bar`, `MyComponent`, `doSomething`, `processData`
- [ ] Reference is from primary maintainer, peer-reviewed research, or production engineering blog
- [ ] Rule validates with `node scripts/validate-skill.js {skill-dir}` with no new errors
