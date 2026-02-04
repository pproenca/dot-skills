---
title: Restart Metro After Configuration Changes
impact: CRITICAL
impactDescription: stale cache causes new themes and classes to be ignored
tags: build, metro, cache, restart
---

## Restart Metro After Configuration Changes

Metro caches configuration at startup. Changes to themes, breakpoints, or metro.config.js require a full restart with cache clear.

**Incorrect (just saving files after changes):**

```bash
# Made changes to metro.config.js or global.css
# Expecting hot reload to pick up new themes...
# New theme variables are undefined, styles missing
```

**Correct (restart with cache clear):**

```bash
# After any configuration changes:
npx expo start --clear

# Or for bare React Native:
npx react-native start --reset-cache
```

**Changes that require Metro restart:**

- Adding themes to `extraThemes` array
- Modifying CSS `@theme` variables
- Changing `cssEntryFile` or `dtsFile` paths
- Adding `@source` directives for monorepos
- Modifying custom breakpoints

**Debug tip:** If themes don't appear after restart, verify:
1. Theme is registered in `extraThemes`
2. Theme has `@variant` block in CSS
3. All themes define the same CSS variables

Reference: [Uniwind Metro Config](https://docs.uniwind.dev/api/metro-config)
