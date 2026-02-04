---
title: Enable Hermes JavaScript Engine
impact: CRITICAL
impactDescription: 40% faster startup, 30% less memory
tags: startup, hermes, javascript-engine, bundle
---

## Enable Hermes JavaScript Engine

Hermes is a JavaScript engine optimized for React Native that compiles JavaScript to bytecode ahead of time. This eliminates runtime compilation overhead, resulting in faster startup times and reduced memory usage.

**Incorrect (using JavaScriptCore, slower startup):**

```json
{
  "expo": {
    "jsEngine": "jsc"
  }
}
```

**Correct (using Hermes, optimized for mobile):**

```json
{
  "expo": {
    "jsEngine": "hermes"
  }
}
```

**Note:** Hermes is the default engine in Expo SDK 48+ and React Native 0.70+. Verify your app is using it by checking for `HermesInternal` in the JavaScript runtime.

**Benefits:**
- 40% faster app startup on average
- 30% reduction in memory usage
- Smaller app size (bytecode is more compact than JavaScript)

Reference: [Using Hermes](https://reactnative.dev/docs/hermes)
