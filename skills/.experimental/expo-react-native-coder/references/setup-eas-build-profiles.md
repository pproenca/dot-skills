---
title: Configure EAS Build Profiles for Each Environment
impact: HIGH
impactDescription: enables consistent builds across development, preview, and production
tags: setup, eas, build, configuration, ci-cd
---

## Configure EAS Build Profiles for Each Environment

Define separate build profiles in `eas.json` for development, preview, and production environments with appropriate settings for each.

**Incorrect (single profile for all environments):**

```json
{
  "build": {
    "production": {
      "distribution": "store"
    }
  }
}
```

**Correct (distinct profiles per environment):**

```json
{
  "cli": {
    "version": ">= 5.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "ios": {
        "simulator": true
      },
      "env": {
        "EXPO_PUBLIC_ENVIRONMENT": "development"
      }
    },
    "preview": {
      "distribution": "internal",
      "channel": "preview",
      "env": {
        "EXPO_PUBLIC_ENVIRONMENT": "preview"
      }
    },
    "production": {
      "distribution": "store",
      "channel": "production",
      "env": {
        "EXPO_PUBLIC_ENVIRONMENT": "production"
      }
    }
  },
  "submit": {
    "production": {}
  }
}
```

**Note:** Use `channel` to group builds for EAS Update. Development builds include `expo-dev-client` for debugging.

Reference: [Configure EAS Build with eas.json - Expo Documentation](https://docs.expo.dev/build/eas-json/)
