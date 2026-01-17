---
title: Enable New Architecture for Synchronous Native Communication
impact: CRITICAL
impactDescription: significant startup improvement, eliminates bridge serialization overhead
tags: launch, new-architecture, jsi, turbomodules
---

## Enable New Architecture for Synchronous Native Communication

The New Architecture replaces the async JSON bridge with JSI (JavaScript Interface), enabling synchronous communication between JavaScript and native code. This eliminates serialization overhead and reduces startup latency.

**Incorrect (old architecture with bridge):**

```json
{
  "expo": {
    "name": "MyApp",
    "newArchEnabled": false
  }
}
```

**Correct (New Architecture enabled):**

```json
{
  "expo": {
    "name": "MyApp",
    "newArchEnabled": true
  }
}
```

**For bare React Native projects:**

```javascript
// android/gradle.properties
newArchEnabled=true

// ios/Podfile
ENV['RCT_NEW_ARCH_ENABLED'] = '1'
```

**Benefits:**
- Direct JavaScript to native calls without JSON serialization
- Lazy loading of native modules (TurboModules)
- Concurrent rendering support (Fabric)
- Synchronous layout access eliminates flickering

**When NOT to enable:**
- Legacy third-party libraries without New Architecture support
- Apps using native modules not yet migrated to TurboModules
- When testing reveals regressions in specific native functionality

**Note:** New Architecture is enabled by default in Expo SDK 52+ for new projects. Existing projects may need migration. Check library compatibility before enabling.

Reference: [React Native New Architecture](https://reactnative.dev/blog/2024/10/23/the-new-architecture-is-here)
