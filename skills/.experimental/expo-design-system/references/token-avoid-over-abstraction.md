---
title: Avoid Abstracting Tokens Beyond Three Layers
impact: MEDIUM
impactDescription: reduces indirection that slows onboarding and review
tags: token, abstraction, simplicity, maintainability
---

## Avoid Abstracting Tokens Beyond Three Layers

A token factory that resolves names through several maps makes it impossible to tell what color a component actually uses without running the app. The raw-to-semantic-to-component hierarchy is enough; adding string-keyed lookups or generator functions on top trades readability for flexibility you rarely need.

**Incorrect (a four-level lookup nobody can trace):**

```typescript
// resolves through aliasMap → semanticMap → palette via a dotted string key
const resolveToken = (key: string) => palette[aliasMap[semanticMap[key]]]
const accent = resolveToken('button.primary.background.default.enabled')

const styles = StyleSheet.create(() => ({
  bookButton: { backgroundColor: accent }, // what color is this? unknowable by reading
}))
```

**Correct (three plain layers you can read top to bottom):**

```typescript
const palette = { teal500: '#0F766E' }
const colors = { accent: palette.teal500 }
const components = { buttonPrimaryBackground: colors.accent }

const styles = StyleSheet.create((theme) => ({
  bookButton: { backgroundColor: theme.components.buttonPrimaryBackground },
}))
// A reviewer traces buttonPrimaryBackground to accent to teal500 in three hops,
// each a literal object lookup rather than a runtime function.
```

Reference: [Unistyles theming](https://www.unistyl.es/v3/guides/theming/)
