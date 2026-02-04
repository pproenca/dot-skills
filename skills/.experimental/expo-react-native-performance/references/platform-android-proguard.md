---
title: Enable ProGuard for Android Release
impact: LOW-MEDIUM
impactDescription: 10-20% smaller APK size
tags: platform, android, proguard, bundle-size
---

## Enable ProGuard for Android Release

ProGuard shrinks, obfuscates, and optimizes Android code. It removes unused Java/Kotlin code from your APK, reducing size and improving load time.

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
// Full APK includes all library code, even unused
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

```proguard
# android/app/proguard-rules.pro
# Keep React Native
-keep class com.facebook.react.** { *; }
-keep class com.facebook.hermes.** { *; }

# Keep your app's models
-keep class com.yourapp.models.** { *; }

# Common rules for libraries
-dontwarn okio.**
-dontwarn javax.annotation.**
```

**Benefits:**
- 10-20% smaller APK
- Code obfuscation for security
- Dead code elimination

**Note:** Test thoroughly after enabling—ProGuard can break reflection-based code.

Reference: [Enable Proguard](https://reactnative.dev/docs/signed-apk-android#enabling-proguard-to-reduce-the-size-of-the-apk-optional)
