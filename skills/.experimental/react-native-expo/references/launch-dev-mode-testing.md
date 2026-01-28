---
title: Disable Development Mode for Performance Testing
impact: CRITICAL
impactDescription: 2-5× faster execution in production mode
tags: launch, development-mode, profiling, testing, performance
---

## Disable Development Mode for Performance Testing

Development mode enables extensive error checking and logging that dramatically slows execution. Always test performance in production builds.

**Incorrect (testing performance in dev mode):**

```bash
# Running with Expo Go in development
npx expo start

# Profiling shows slow renders - but it's dev mode overhead
# Developer thinks app has performance issues
```

**Correct (testing in production mode):**

```bash
# Create a production build for testing
npx expo run:ios --configuration Release
npx expo run:android --variant release

# Or use EAS Build
eas build --profile production --platform all
```

```json
// eas.json - production profile
{
  "build": {
    "production": {
      "developmentClient": false,
      "distribution": "store"
    },
    "preview": {
      "distribution": "internal",
      "ios": {
        "simulator": true
      }
    }
  }
}
```

**Why it matters:**
- Dev mode adds runtime type checking
- Every component render triggers additional validation
- Console warnings add overhead
- Source maps and debugging hooks slow execution

**Development mode overhead includes:**
- PropTypes validation on every render
- Component stack trace generation
- React DevTools integration
- Extensive console logging

Reference: [Expo Development and Production Modes](https://docs.expo.dev/workflow/development-mode/)
