---
title: {Action-Oriented Title}
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: {quantified outcome — e.g., "prevents X", "enables Y", "reduces re-renders 5×"}
tags: {prefix}, {technique}, {tool}, {concept}
---

## {Title — matches frontmatter title verbatim}

{1-3 sentences explaining WHY this matters in @expo/ui's SwiftUI bridge — what goes wrong without
this pattern, what the cascade effect is. Always anchor the reasoning to the native bridge or
HIG. Don't dictate "use X" — explain what breaks when you don't.}

**Incorrect ({specific problem}):**

```tsx
{Production-realistic code. Use realistic domain names — never foo, bar, MyComponent.}
{Imports from '@expo/ui/swift-ui' and '@expo/ui/swift-ui/modifiers'.}
```

**Correct ({specific benefit}):**

```tsx
{Minimal diff from Incorrect — same variable names, same structure, only the key change.}
```

**Alternative ({context}):**

```tsx
{Optional — a second valid approach with a different tradeoff.}
```

**When NOT to use this pattern:**

- {Edge case where the rule doesn't apply}
- {Conditions that override the guidance}

Reference: [{authoritative title}]({URL — prefer developer.apple.com or @expo/ui source})
