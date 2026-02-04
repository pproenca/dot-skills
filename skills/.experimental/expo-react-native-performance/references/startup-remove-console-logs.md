---
title: Remove Console Logs in Production
impact: CRITICAL
impactDescription: eliminates JS thread bottleneck
tags: startup, console, babel, production
---

## Remove Console Logs in Production

Console.log statements cause JavaScript thread bottlenecks in production builds. Each log serializes data and sends it across the bridge, blocking execution. Use a Babel plugin to automatically strip console statements from production bundles.

**Incorrect (console.log in production code):**

```typescript
// api/users.ts
export async function fetchUsers(): Promise<User[]> {
  const response = await fetch('/api/users');
  const users = await response.json();
  console.log('Fetched users:', users);  // Blocks JS thread in production
  return users;
}
```

**Correct (Babel strips console in production):**

```javascript
// babel.config.js
module.exports = function (api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    env: {
      production: {
        plugins: ['transform-remove-console'],
      },
    },
  };
};
```

Install the plugin: `npm install babel-plugin-transform-remove-console --save-dev`

**When to keep console statements:**
- Use `console.error` for critical errors you need in crash reports
- Wrap debug logs in `__DEV__` checks instead of relying solely on Babel

Reference: [React Native Performance](https://reactnative.dev/docs/performance)
