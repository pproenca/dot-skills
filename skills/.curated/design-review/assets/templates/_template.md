---
title: Rule Title Here
tags: prefix, concept
---

## Rule Title Here

Name the wrong default this rule corrects and its concrete consequence, in 1-3
sentences. Explain the *why* — the reviewer (and the author) generalises from the
reason, not the instruction. Do not restate something a competent author already
does correctly.

```css
/* The canonical fix. Real, domain-realistic class/component names — not foo/bar. */
.invoice-summary { color: hsl(222 47% 11%); }
```

Reference: [Source title](https://example.com)

<!-- Add an **Incorrect (…):** / **Correct (…):** pair ONLY when the wrong way is
     a genuine, common trap. Keep the diff minimal (same names, only the key line
     changes). A strawman foil is worse than a single good example.

     This is a taste/correctness skill, not a performance one — do NOT add
     `impact:` / `impactDescription:` frontmatter. Severity is assigned per
     finding at review time, in the output table, not baked into the rule. -->
