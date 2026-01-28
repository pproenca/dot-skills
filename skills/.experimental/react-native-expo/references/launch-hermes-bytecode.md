---
title: Enable Hermes with Bytecode Compilation
impact: CRITICAL
impactDescription: 30-50% faster startup time
tags: launch, hermes, bytecode, startup, android, ios
---

## Enable Hermes with Bytecode Compilation

Hermes compiles JavaScript to bytecode at build time, eliminating runtime parsing. This is the single largest startup improvement available.

**Incorrect (UTF-8 bundle, parsed at runtime):**

```json
// app.json - missing or disabled Hermes
{
  "expo": {
    "jsEngine": "jsc"
  }
}
```

```bash
# Building with --no-bytecode flag
npx expo export --no-bytecode
# UTF-8 bundles require full parsing at startup
```

**Correct (Hermes bytecode, pre-compiled):**

```json
// app.json - Hermes enabled (default in Expo SDK 48+)
{
  "expo": {
    "jsEngine": "hermes"
  }
}
```

```bash
# Default export includes bytecode
npx expo export
# Bytecode bundles skip parsing entirely
```

**Why it matters:**
- Parsing JavaScript is expensive on mobile CPUs
- Hermes bytecode is already optimized for execution
- Memory usage is lower with Hermes
- Garbage collection is more efficient

**When NOT to use this pattern:**
- Only when debugging bundle contents with `--no-bytecode`
- Never ship UTF-8 bundles to production

Reference: [Expo Development Mode Documentation](https://docs.expo.dev/workflow/development-mode/)
