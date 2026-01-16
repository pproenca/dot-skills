---
title: Enable ProGuard for Android Release Builds
impact: HIGH
impactDescription: 10-30% smaller APK, removes unused Java/Kotlin code
tags: bundle, proguard, android, minification
---

## Enable ProGuard for Android Release Builds

ProGuard shrinks and obfuscates Java/Kotlin code, removing unused classes and methods from the native bundle. This reduces APK size and improves security.

**Incorrect (ProGuard disabled):**

```groovy
// android/app/build.gradle
android {
    buildTypes {
        release {
            minifyEnabled false
            shrinkResources false
        }
    }
}
```

**Correct (ProGuard enabled):**

```groovy
// android/app/build.gradle
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

**Required ProGuard rules for React Native:**

```proguard
# proguard-rules.pro

# React Native
-keep class com.facebook.react.** { *; }
-keep class com.facebook.hermes.** { *; }

# Hermes
-keep class com.facebook.jni.** { *; }

# Expo modules (add as needed)
-keep class expo.modules.** { *; }

# Keep native methods
-keepclassmembers class * {
    @com.facebook.react.uimanager.annotations.ReactProp *;
}
```

**For Expo managed workflow:**

ProGuard is enabled by default in production builds. Custom rules can be added via config plugins.

**Benefits:**
- Removes unused classes and methods
- Obfuscates code for basic protection
- Optimizes bytecode
- Shrinks resources

Reference: [Android ProGuard Documentation](https://developer.android.com/build/shrink-code)
