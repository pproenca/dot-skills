---
title: Use Hermes Engine for Faster Startup
impact: CRITICAL
impactDescription: 30-50% faster startup time, reduced memory usage
tags: launch, hermes, engine, bytecode
---

## Use Hermes Engine for Faster Startup

Hermes compiles JavaScript to bytecode at build time, dramatically reducing startup time and memory usage. It is enabled by default in Expo SDK 52+ but verify your configuration.

**Incorrect (Hermes disabled or not configured):**

```json
{
  "expo": {
    "name": "MyApp",
    "jsEngine": "jsc"
  }
}
```

**Correct (Hermes enabled):**

```json
{
  "expo": {
    "name": "MyApp",
    "jsEngine": "hermes"
  }
}
```

**Verification (check Hermes is active):**

```typescript
import { Platform } from 'react-native'

const isHermes = () => !!global.HermesInternal

console.log('Hermes enabled:', isHermes())
// Should log: Hermes enabled: true
```

**Benefits:**
- Precompiled bytecode eliminates JavaScript parsing at startup
- Memory-mapped bytecode reduces RAM usage
- Faster garbage collection optimized for mobile

**Note:** Hermes is the default engine starting from React Native 0.70 and Expo SDK 47+. If you're on an older version, explicitly enable it.

Reference: [React Native Hermes Documentation](https://reactnative.dev/docs/hermes)
