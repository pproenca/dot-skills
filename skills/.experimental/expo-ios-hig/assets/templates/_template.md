---
title: {Imperative verb} {object} {context}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {quantified or verb-led, e.g. "prevents X", "maintains 60fps", "enables Y"}
tags: {prefix}, {technique}, {library-if-mentioned}, {concept}
---

## {Imperative verb} {object} {context}

{1-3 sentences explaining WHY this matters for native feel — what reads as non-native or
breaks when you don't follow it, in concrete terms an agent can generalize from. Name the
platform behavior that is lost (the swipe-back gesture, the scroll-edge blur, VoiceOver's
announcement) rather than asserting "it feels better".}

**Incorrect ({the non-native choice}):**

```tsx
// Production-realistic Expo/RN code an agent might actually write.
// One comment explaining what native behavior is forfeited.
```

**Correct ({the native choice}):**

```tsx
// Minimal diff from the incorrect example — same names, same structure.
// One comment explaining what native behavior is now inherited.
```

{Optional sections, only when they add value:}

**Alternative ({context}):**
{A second valid approach, e.g. dropping to @expo/ui for cross-platform parity.}

**When NOT to use this pattern:**
- {A real exception where the "incorrect" choice is actually right.}

Reference: [{Authoritative title}]({url})
```

## Authoring conventions for this skill

- **Examples are TSX/Expo, never Swift.** Show the React Native / TypeScript decision. When the
  right answer is to bridge to native, point to `@expo/ui`, `expo-glass-effect`, or `expo-symbols`
  rather than re-documenting their APIs (that is the `expo-ui` skill's job).
- **The title starts with an imperative verb** (Use, Avoid, Adopt, Respect, Keep, Enable…) and
  matches the H2 exactly. The first tag is the category prefix from `_sections.md`.
- **The "incorrect" example is a genuine anti-pattern** an Expo developer would plausibly write —
  not a strawman — and the "correct" example is a minimal diff that a reviewer could paste in.
- **Anchor names in a realistic domain** (trails, reviews, saved items). No `foo`, `bar`,
  `MyComponent`, `data`, `temp`.
- **Reference current, authoritative sources**: Apple HIG, Expo docs, React Native docs, or the
  maintainer docs of a named library (Reanimated, Gesture Handler, FlashList).
