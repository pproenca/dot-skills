---
title: {Action-Oriented Title}
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: {quantified or "prevents {problem}" impact — e.g. "prevents a blank widget", "eliminates a second round-trip"}
tags: {prefix}, {technique-1}, {technique-2}, {concept}
---

## {Title}

{1-3 sentences explaining WHY this matters for chat apps — what breaks in the model routing,
the iframe render, the bridge, or directory review without it, and what the agent should
generalise. Teach the reasoning, not just the rule. State plainly when the pattern is overkill.}

**Incorrect ({problem label}):**

```typescript
// Production-realistic anti-pattern. Comment explains the cost.
// Use ```tsx for component code, ```css for styling, ```json for manifests/metadata.
```

**Correct ({solution label}):**

```typescript
// Minimal diff from the incorrect example. Comment explains the benefit.
```

**When NOT to apply:**
- {Realistic exception 1}
- {Realistic exception 2}

Reference: [{Title}]({URL})

<!--
Authoring notes for this skill:
- First tag MUST equal the file prefix (tool, wire, bridge, display, state, sec, design, dist).
- Title must equal the H2 exactly and start with an imperative verb.
- Code fences must declare a letter-only language (typescript, tsx, css, json).
- Avoid placeholder names (foo, temp, MyComponent) — use domain-realistic names.
- Avoid hedging ("might", "maybe") and marketing words ("seamless", "powerful").
- Cross-link related rules with [[rule-file-name-without-extension]].
- Run: node <plugin>/scripts/build-agents-md.js <skill-dir>  then  validate-skill.js <skill-dir>
-->
