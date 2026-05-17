---
title: "{Action-Oriented Title — start with imperative verb like Use, Avoid, Map, Cache, Extract}"
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: "{quantified impact — examples: 2-10x improvement, prevents N-px drift, O(n) to O(log n), reduces snapshot false-positives by 90%}"
tags: "{prefix}, {technique-1}, {technique-2}, {related-concept}"
---

## {Repeat the Action-Oriented Title — must exactly match `title:` above}

{1-3 sentences explaining WHY this rule matters in the design-to-code conversion pipeline.
Focus on the cascade effect — what goes wrong if this rule is violated, and what
downstream stage owns the resulting regression. Avoid restating WHAT the rule says;
the model can derive the WHAT from the code examples.}

**Incorrect ({short problem label — e.g., "naïve passthrough", "missing reframing", "global threshold"}):**

```{language — typescript|tsx|css|svg|bash|text — use ```text for non-code diagrams}
{Production-realistic bad code. Include a comment block explaining the failure mode in
concrete terms — "Sketch shows X, browser shows Y, designer says wrong."
Do NOT use strawman code (foo, bar, baz, anyValue); use names that would appear in a
real converter (frame, gradient, attributedString, MSImmutableFlexGroupLayout, etc.).}
```

**Correct ({short solution label — e.g., "axis-aware reframing", "per-region budget", "subtree-equivalence dedup"}):**

```{language}
{The minimal-diff correct version. Annotate the key change with a comment that
explains the principle, not just the syntax. Tie back to the Sketch source primitive
where applicable (frame, style, layers, layout, flexItem, attributedString).}
```

{Optional sections — include any that apply, in this order:}

**Alternative ({context}):**
{When multiple valid approaches exist, document the alternative and when to prefer it.}

**When NOT to use this pattern:**
- {Exception 1 — when the rule's preconditions don't hold}
- {Exception 2 — when the cost outweighs the benefit}

**Implementation:**
{A reusable snippet (utility function, regex, lookup table) worth providing as-is.}

**Warning ({context}):**
{Highlight a gotcha — version-dependent behavior, undocumented Sketch quirk, browser
inconsistency. Be specific about which versions/contexts.}

**Verification:**
{When the user can confirm the rule is correctly applied — e.g., "snapshots should
pass at SSIM ≥ 0.99 in the affected region", or a 3-case table of expected outputs.}

Reference: [{Authoritative source title}]({URL})

---

### Notes on writing rules for this skill

**Cascade ordering matters more than rule count.** A great new CRITICAL rule (iter, tree,
layout) outweighs three new MEDIUM rules. If the proposed rule doesn't change behavior
upstream, it probably belongs in `style`, `type`, or `path` regardless of how "important"
it feels.

**Ground every rule in real Sketch primitives.** Reference the actual `_class` discriminator,
attribute name, or enum value (e.g., `MSImmutableFlexGroupLayout.flexDirection`, `borderOptions.position`).
This both proves the rule is real and gives the model the search term it needs to apply the rule.

**Quantify the impact.** "prevents 100% of multi-shadow z-order inversions" beats
"prevents shadow bugs." Use concrete numbers: pixel offsets, percent savings, complexity
classes, or "prevents N-class of failure entirely."

**Link related rules.** Use `[[rule-slug]]` to cross-reference — the model uses these as
navigation hints when chasing a bug back up the cascade.

**Code examples must be production-realistic.** No `foo/bar/baz`. Use names a Sketch
converter would actually produce: `frame`, `layers`, `style`, `attributedString`, `curvePoint`,
`hasClippingMask`. The names ARE the documentation — they tell the model what the input
data looks like.
