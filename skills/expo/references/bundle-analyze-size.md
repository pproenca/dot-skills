---
title: Analyze Bundle Size Before Release
impact: CRITICAL
impactDescription: identifies 30-70% of bundle bloat from unused dependencies
tags: bundle, analysis, visualization, dependencies
---

## Analyze Bundle Size Before Release

Use bundle visualization tools to identify large dependencies and dead code. Many apps ship with unused libraries that significantly increase download and parse time.

**Incorrect (blind dependency additions):**

```json
{
  "dependencies": {
    "moment": "^2.29.4",
    "lodash": "^4.17.21",
    "axios": "^1.6.0",
    "react-native-svg": "^14.0.0"
  }
}
```

**Correct (analyze and optimize):**

```bash
# Install bundle analyzer
npx react-native-bundle-visualizer

# Or use source-map-explorer
npx expo export --dump-sourcemap
npx source-map-explorer dist/bundles/ios-*.js
```

**Review and replace heavy dependencies:**

```json
{
  "dependencies": {
    "date-fns": "^2.30.0",
    "ky": "^1.2.0"
  }
}
```

**Common heavy dependencies to evaluate:**
| Library | Size | Alternative |
|---------|------|-------------|
| moment | 232KB | date-fns (13KB per function) |
| lodash | 72KB | lodash-es + direct imports |
| axios | 48KB | ky (3KB) or fetch |

**Bundle size targets:**
- Development: Track but don't optimize
- Production: < 2MB JavaScript bundle for fast startup
- Check bundle size in CI to prevent regressions

Reference: [React Native Bundle Visualizer](https://github.com/IjzerenHein/react-native-bundle-visualizer)
