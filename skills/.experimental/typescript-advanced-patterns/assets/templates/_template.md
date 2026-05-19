---
title: {Action-Oriented Title}
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: {quantified or capability-stated impact}
tags: {prefix}, {technique-1}, {technique-2}, {concept}
---

## {Title}

{1-3 sentences explaining WHY this pattern matters — what breaks without it, what cascade
effect it has, and what the model should generalise from. Aim to teach the reasoning, not
dictate the rule. For "advanced" rules, also state plainly when it's overkill.}

**Incorrect ({problem label}):**

```typescript
// Production-realistic anti-pattern. Comment explains the cost.
```

**Correct ({solution label}):**

```typescript
// Minimal diff from the incorrect example. Comment explains the benefit.
```

**When NOT to apply:**
- {Realistic exception 1}
- {Realistic exception 2}

**Scope delta** (if rule overlaps with `typescript-refactor` or `.curated/typescript`):
- Existing rule: `[[other-rule-slug]]` covers {what they cover}.
- This rule extends to {what this rule adds beyond that}.

Reference: [{Title}]({URL})
