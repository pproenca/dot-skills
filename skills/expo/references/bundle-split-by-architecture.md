---
title: Generate Architecture-Specific APKs
impact: HIGH
impactDescription: 30-50% smaller APK download size
tags: bundle, apk, architecture, android
---

## Generate Architecture-Specific APKs

Generate separate APKs for each CPU architecture instead of a universal APK. Users only download the binary for their device's architecture.

**Incorrect (universal APK):**

```groovy
// android/app/build.gradle
android {
    defaultConfig {
        ndk {
            abiFilters "armeabi-v7a", "arm64-v8a", "x86", "x86_64"
        }
    }
}
```

**Correct (architecture splits):**

```groovy
// android/app/build.gradle
android {
    splits {
        abi {
            enable true
            reset()
            include "armeabi-v7a", "arm64-v8a", "x86", "x86_64"
            universalApk false  // Don't generate universal APK
        }
    }
}
```

**For Expo managed workflow (eas.json):**

```json
{
  "build": {
    "production": {
      "android": {
        "buildType": "apk",
        "gradleCommand": ":app:assembleRelease"
      }
    }
  }
}
```

**App Bundle (recommended for Play Store):**

```json
{
  "build": {
    "production": {
      "android": {
        "buildType": "app-bundle"
      }
    }
  }
}
```

**Size comparison:**
| Type | Size |
|------|------|
| Universal APK | 80MB |
| arm64-v8a APK | 45MB |
| AAB (App Bundle) | Play Store delivers optimized |

**Note:** Google Play Store requires AAB format since August 2021, which automatically serves architecture-specific installs.

Reference: [Expo Build Configuration](https://docs.expo.dev/build/eas-json/)
