---
title: {Imperative Title — start with Avoid / Use / Replace / Lift / Collapse / etc.}
impact: {CRITICAL | HIGH | MEDIUM-HIGH | MEDIUM | LOW-MEDIUM | LOW}
impactDescription: {use a quantification verb: "eliminates ...", "reduces ...", "prevents ...", or a metric "5-20 lines", "O(n) to O(1)"}
tags: {category-prefix}, {technique}, {concept}, {concept}
---

## {Imperative Title — copy from the title field}

{1-3 sentences explaining WHY this matters. State the cost of the anti-pattern: what
goes wrong, what cascades, what the maintenance burden is. Avoid hedging — the reader
should leave understanding the principle so they can apply it to novel cases.}

**Incorrect ({short label — what's wrong}):**

```typescript
{Production-realistic code that exhibits the anti-pattern. Annotate the bad parts with
// comments that show the cost.}
```

**Correct ({short label — what's right}):**

```typescript
{The cleaned-up version. Make it a minimal diff from the incorrect form so the
transformation is visible. Annotate with // comments showing the win.}
```

{If multiple legitimate approaches exist, use:}

**Correct (option A — {description}):**

```typescript
{Option A code}
```

**Correct (option B — {description}):**

```typescript
{Option B code}
```

{Optional sections — include the ones that help:}

**Symptoms:**

- {Observable signal that this anti-pattern is present}
- {Another signal}

**When NOT to use this pattern:**

- {A legitimate case where the anti-pattern is actually correct, with the reason}
- {Another exception}

**Variations / related patterns:**

- {Sibling pattern}
- {Related rule with a `[[link]]`}

Reference: [{Title}]({URL})

---

## Notes for skill authors

This skill targets **judgment gaps**, not lint-able mechanical issues. When adding a rule:

1. **Check it's not lint-able.** Could `knip`, `eslint`, `ruff`, `tsc`, or `prettier` catch this? If yes, the rule belongs in a different skill (e.g. `code-simplifier`).
2. **Check it's not algorithmic.** Performance-complexity rules go in `complexity-optimizer`.
3. **The fix should require *judgment* about intent, modelling, or framing** — not just pattern matching.
4. **Show the cascade.** The strongest rules explain why this anti-pattern *multiplies* downstream cost.
5. **Include "When NOT to use this pattern."** Every rule has a legitimate exception. Naming it is what turns a rigid rule into transferable judgment.

The eight category prefixes are fixed: `reinvent-`, `frame-`, `dup-`, `derive-`, `proc-`, `spec-`, `defense-`, `types-`. If a new rule doesn't fit one of these, the category structure may need to evolve before the rule lands — open a discussion before adding a ninth prefix.
