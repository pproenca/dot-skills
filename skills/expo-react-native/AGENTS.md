# Expo React Native

**Version 0.1.0**  
Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization guide for Expo React Native applications, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (launch time, bundle size) to incremental (memory management). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Launch Time Optimization](#1-launch-time-optimization) — **CRITICAL**
   - 1.1 [Control Splash Screen Visibility During Asset Loading](#11-control-splash-screen-visibility-during-asset-loading)
   - 1.2 [Defer Non-Critical Initialization Until After First Render](#12-defer-non-critical-initialization-until-after-first-render)
   - 1.3 [Enable New Architecture for Synchronous Native Communication](#13-enable-new-architecture-for-synchronous-native-communication)
   - 1.4 [Minimize Imports in Root App Component](#14-minimize-imports-in-root-app-component)
   - 1.5 [Preload Critical Assets During Splash Screen](#15-preload-critical-assets-during-splash-screen)
   - 1.6 [Use Hermes Engine for Faster Startup](#16-use-hermes-engine-for-faster-startup)
2. [Bundle Size Optimization](#2-bundle-size-optimization) — **CRITICAL**
   - 2.1 [Analyze Bundle Size Before Release](#21-analyze-bundle-size-before-release)
   - 2.2 [Avoid Barrel File Imports](#22-avoid-barrel-file-imports)
   - 2.3 [Enable ProGuard for Android Release Builds](#23-enable-proguard-for-android-release-builds)
   - 2.4 [Generate Architecture-Specific APKs](#24-generate-architecture-specific-apks)
   - 2.5 [Remove Unused Dependencies](#25-remove-unused-dependencies)
   - 2.6 [Subset Custom Fonts to Used Characters](#26-subset-custom-fonts-to-used-characters)
   - 2.7 [Use Lightweight Library Alternatives](#27-use-lightweight-library-alternatives)
3. [List Virtualization](#3-list-virtualization) — **HIGH**
   - 3.1 [Avoid Inline Functions in List renderItem](#31-avoid-inline-functions-in-list-renderitem)
   - 3.2 [Avoid key Prop Inside FlashList Items](#32-avoid-key-prop-inside-flashlist-items)
   - 3.3 [Configure List Batch Rendering for Scroll Performance](#33-configure-list-batch-rendering-for-scroll-performance)
   - 3.4 [Memoize List Item Components](#34-memoize-list-item-components)
   - 3.5 [Provide Accurate estimatedItemSize for FlashList](#35-provide-accurate-estimateditemsize-for-flashlist)
   - 3.6 [Provide getItemLayout for Fixed-Height FlatList Items](#36-provide-getitemlayout-for-fixed-height-flatlist-items)
   - 3.7 [Use FlashList Instead of FlatList for Large Lists](#37-use-flashlist-instead-of-flatlist-for-large-lists)
4. [Image Optimization](#4-image-optimization) — **HIGH**
   - 4.1 [Lazy Load Off-Screen Images](#41-lazy-load-off-screen-images)
   - 4.2 [Preload Critical Above-the-Fold Images](#42-preload-critical-above-the-fold-images)
   - 4.3 [Resize Images to Display Size](#43-resize-images-to-display-size)
   - 4.4 [Use BlurHash or ThumbHash Placeholders](#44-use-blurhash-or-thumbhash-placeholders)
   - 4.5 [Use expo-image Instead of React Native Image](#45-use-expo-image-instead-of-react-native-image)
   - 4.6 [Use WebP Format for Smaller File Sizes](#46-use-webp-format-for-smaller-file-sizes)
5. [Navigation Performance](#5-navigation-performance) — **MEDIUM-HIGH**
   - 5.1 [Avoid Deeply Nested Navigators](#51-avoid-deeply-nested-navigators)
   - 5.2 [Optimize Screen Options to Reduce Navigation Overhead](#52-optimize-screen-options-to-reduce-navigation-overhead)
   - 5.3 [Prefetch Data Before Navigation](#53-prefetch-data-before-navigation)
   - 5.4 [Unmount Inactive Tab Screens to Save Memory](#54-unmount-inactive-tab-screens-to-save-memory)
   - 5.5 [Use Native Stack Navigator for Performance](#55-use-native-stack-navigator-for-performance)
6. [Re-render Prevention](#6-re-render-prevention) — **MEDIUM**
   - 6.1 [Avoid Anonymous Components in JSX](#61-avoid-anonymous-components-in-jsx)
   - 6.2 [Avoid Overusing Context for Frequently Changing State](#62-avoid-overusing-context-for-frequently-changing-state)
   - 6.3 [Enable React Compiler for Automatic Memoization](#63-enable-react-compiler-for-automatic-memoization)
   - 6.4 [Memoize Expensive Components with React.memo](#64-memoize-expensive-components-with-reactmemo)
   - 6.5 [Memoize Expensive Computations with useMemo](#65-memoize-expensive-computations-with-usememo)
   - 6.6 [Split Components to Isolate Frequently Updating State](#66-split-components-to-isolate-frequently-updating-state)
   - 6.7 [Stabilize Callbacks with useCallback](#67-stabilize-callbacks-with-usecallback)
7. [Animation Performance](#7-animation-performance) — **MEDIUM**
   - 7.1 [Defer Heavy Work During Animations with InteractionManager](#71-defer-heavy-work-during-animations-with-interactionmanager)
   - 7.2 [Enable useNativeDriver for Animated API](#72-enable-usenativedriver-for-animated-api)
   - 7.3 [Prefer Transform Animations Over Layout Animations](#73-prefer-transform-animations-over-layout-animations)
   - 7.4 [Use Gesture Handler with Reanimated for Gesture-Driven Animations](#74-use-gesture-handler-with-reanimated-for-gesture-driven-animations)
   - 7.5 [Use Reanimated for UI Thread Animations](#75-use-reanimated-for-ui-thread-animations)
8. [Memory Management](#8-memory-management) — **LOW-MEDIUM**
   - 8.1 [Abort Fetch Requests on Component Unmount](#81-abort-fetch-requests-on-component-unmount)
   - 8.2 [Avoid Closure-Based Memory Leaks in Callbacks](#82-avoid-closure-based-memory-leaks-in-callbacks)
   - 8.3 [Clean Up Subscriptions and Timers in useEffect](#83-clean-up-subscriptions-and-timers-in-useeffect)
   - 8.4 [Profile Memory Usage with Development Tools](#84-profile-memory-usage-with-development-tools)
   - 8.5 [Release Heavy Resources When Not Needed](#85-release-heavy-resources-when-not-needed)

---

## 1. Launch Time Optimization

**Impact: CRITICAL**

App startup is the first user impression. Time to Interactive directly affects user retention and app store ratings.

### 1.1 Control Splash Screen Visibility During Asset Loading

**Impact: CRITICAL (prevents white flash and improves perceived startup time)**

Keep the native splash screen visible while loading critical assets like fonts and images. This prevents the jarring white flash users see when the app renders before assets are ready.

**Incorrect (splash hides before assets load):**

```typescript
import { useEffect, useState } from 'react'
import { View, Text } from 'react-native'

export default function App() {
  const [fontsLoaded, setFontsLoaded] = useState(false)

  useEffect(() => {
    loadFonts().then(() => setFontsLoaded(true))
  }, [])

  if (!fontsLoaded) {
    return null  // White screen while fonts load
  }

  return <HomeScreen />
}
```

**Correct (splash stays until assets ready):**

```typescript
import { useEffect, useState, useCallback } from 'react'
import { View, Text } from 'react-native'
import * as SplashScreen from 'expo-splash-screen'

SplashScreen.preventAutoHideAsync()

export default function App() {
  const [fontsLoaded, setFontsLoaded] = useState(false)

  useEffect(() => {
    loadFonts().then(() => setFontsLoaded(true))
  }, [])

  const onLayoutRootView = useCallback(async () => {
    if (fontsLoaded) {
      await SplashScreen.hideAsync()
    }
  }, [fontsLoaded])

  if (!fontsLoaded) {
    return null  // Splash screen still visible
  }

  return <HomeScreen onLayout={onLayoutRootView} />
}
```

Reference: [Expo SplashScreen Documentation](https://docs.expo.dev/versions/latest/sdk/splash-screen/)

### 1.2 Defer Non-Critical Initialization Until After First Render

**Impact: CRITICAL (reduces Time to Interactive by 200-500ms)**

Analytics, crash reporting, and other non-critical services should initialize after the first meaningful render. This prioritizes showing content to the user.

**Incorrect (all initialization blocks startup):**

```typescript
import { useEffect } from 'react'
import * as Analytics from 'expo-analytics'
import * as Sentry from '@sentry/react-native'
import { initializeDatabase } from './database'
import { syncOfflineData } from './sync'

export default function App() {
  useEffect(() => {
    // All of this runs before user sees anything
    Analytics.initialize('key')
    Sentry.init({ dsn: 'dsn' })
    initializeDatabase()
    syncOfflineData()
  }, [])

  return <HomeScreen />
}
```

**Correct (deferred initialization):**

```typescript
import { useEffect } from 'react'
import { InteractionManager } from 'react-native'
import * as Analytics from 'expo-analytics'
import * as Sentry from '@sentry/react-native'
import { initializeDatabase } from './database'
import { syncOfflineData } from './sync'

export default function App() {
  useEffect(() => {
    // Defer non-critical work until after animations complete
    const task = InteractionManager.runAfterInteractions(() => {
      Analytics.initialize('key')
      Sentry.init({ dsn: 'dsn' })
      initializeDatabase()
      syncOfflineData()
    })

    return () => task.cancel()
  }, [])

  return <HomeScreen />
}
```

**Alternative (setTimeout for simple cases):**

```typescript
useEffect(() => {
  const timer = setTimeout(() => {
    Analytics.initialize('key')
  }, 1000)  // Delay 1 second after mount

  return () => clearTimeout(timer)
}, [])
```

Reference: [React Native InteractionManager](https://reactnative.dev/docs/interactionmanager)

### 1.3 Enable New Architecture for Synchronous Native Communication

**Impact: CRITICAL (significant startup improvement, eliminates bridge serialization overhead)**

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

### 1.4 Minimize Imports in Root App Component

**Impact: HIGH (reduces initial bundle parse time by 100-300ms)**

The root App component and its imports are parsed synchronously at startup. Move heavy imports to screens that need them and use dynamic imports for non-critical features.

**Incorrect (heavy imports in root):**

```typescript
// App.tsx - all imports parsed at startup
import { NavigationContainer } from '@react-navigation/native'
import { createNativeStackNavigator } from '@react-navigation/native-stack'
import HomeScreen from './screens/HomeScreen'
import ProfileScreen from './screens/ProfileScreen'
import SettingsScreen from './screens/SettingsScreen'
import AdminDashboard from './screens/AdminDashboard'
import AnalyticsScreen from './screens/AnalyticsScreen'
import { Chart } from 'react-native-charts-wrapper'  // Heavy library
import { Editor } from '@monaco-editor/react'  // Heavy library

const Stack = createNativeStackNavigator()

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Profile" component={ProfileScreen} />
        {/* ... many more screens */}
      </Stack.Navigator>
    </NavigationContainer>
  )
}
```

**Correct (lazy imports for non-critical screens):**

```typescript
// App.tsx - minimal imports
import { lazy, Suspense } from 'react'
import { NavigationContainer } from '@react-navigation/native'
import { createNativeStackNavigator } from '@react-navigation/native-stack'
import HomeScreen from './screens/HomeScreen'
import LoadingScreen from './components/LoadingScreen'

const ProfileScreen = lazy(() => import('./screens/ProfileScreen'))
const SettingsScreen = lazy(() => import('./screens/SettingsScreen'))
const AdminDashboard = lazy(() => import('./screens/AdminDashboard'))

const Stack = createNativeStackNavigator()

export default function App() {
  return (
    <NavigationContainer>
      <Suspense fallback={<LoadingScreen />}>
        <Stack.Navigator>
          <Stack.Screen name="Home" component={HomeScreen} />
          <Stack.Screen name="Profile" component={ProfileScreen} />
          <Stack.Screen name="Settings" component={SettingsScreen} />
          <Stack.Screen name="Admin" component={AdminDashboard} />
        </Stack.Navigator>
      </Suspense>
    </NavigationContainer>
  )
}
```

**Note:** With Hermes and memory-mapped bytecode, the benefit of code splitting is reduced compared to web. Focus on deferring heavy libraries like chart libraries and rich text editors.

### 1.5 Preload Critical Assets During Splash Screen

**Impact: CRITICAL (eliminates asset loading delays after app renders)**

Load fonts, icons, and critical images while the splash screen is visible. This ensures assets are ready when the first screen renders, avoiding layout shifts and missing content.

**Incorrect (assets load after render):**

```typescript
import { useEffect, useState } from 'react'
import { Image, View } from 'react-native'

export default function ProfileScreen() {
  const [profile, setProfile] = useState(null)

  useEffect(() => {
    fetchProfile().then(setProfile)
  }, [])

  return (
    <View>
      <Image source={{ uri: profile?.avatarUrl }} />  {/* Loads on demand */}
    </View>
  )
}
```

**Correct (critical assets preloaded):**

```typescript
import { useEffect, useState, useCallback } from 'react'
import { Image, View } from 'react-native'
import * as SplashScreen from 'expo-splash-screen'
import * as Font from 'expo-font'
import { Asset } from 'expo-asset'

SplashScreen.preventAutoHideAsync()

async function loadResourcesAsync() {
  await Promise.all([
    Font.loadAsync({
      'Inter-Bold': require('./assets/fonts/Inter-Bold.ttf'),
    }),
    Asset.loadAsync([
      require('./assets/images/logo.png'),
      require('./assets/images/placeholder-avatar.png'),
    ]),
  ])
}

export default function App() {
  const [resourcesLoaded, setResourcesLoaded] = useState(false)

  useEffect(() => {
    loadResourcesAsync().then(() => setResourcesLoaded(true))
  }, [])

  const onLayoutRootView = useCallback(async () => {
    if (resourcesLoaded) {
      await SplashScreen.hideAsync()
    }
  }, [resourcesLoaded])

  if (!resourcesLoaded) return null

  return <RootNavigator onLayout={onLayoutRootView} />
}
```

Reference: [Expo Asset Documentation](https://docs.expo.dev/versions/latest/sdk/asset/)

### 1.6 Use Hermes Engine for Faster Startup

**Impact: CRITICAL (30-50% faster startup time, reduced memory usage)**

Hermes compiles JavaScript to bytecode at build time, dramatically reducing startup time and memory usage. It is enabled by default in Expo SDK 52+ but verify your configuration.

**Incorrect (Hermes disabled or not configured):**

```json
{
  "expo": {
    "name": "MyApp",
    "jsEngine": "jsc"
  }
}
```

**Correct (Hermes enabled):**

```json
{
  "expo": {
    "name": "MyApp",
    "jsEngine": "hermes"
  }
}
```

**Verification (check Hermes is active):**

```typescript
import { Platform } from 'react-native'

const isHermes = () => !!global.HermesInternal

console.log('Hermes enabled:', isHermes())
// Should log: Hermes enabled: true
```

**Benefits:**
- Precompiled bytecode eliminates JavaScript parsing at startup
- Memory-mapped bytecode reduces RAM usage
- Faster garbage collection optimized for mobile

**Note:** Hermes is the default engine starting from React Native 0.70 and Expo SDK 47+. If you're on an older version, explicitly enable it.

Reference: [React Native Hermes Documentation](https://reactnative.dev/docs/hermes)

---

## 2. Bundle Size Optimization

**Impact: CRITICAL**

Smaller bundles mean faster downloads, faster parsing by Hermes, and reduced memory pressure during startup.

### 2.1 Analyze Bundle Size Before Release

**Impact: CRITICAL (identifies 30-70% of bundle bloat from unused dependencies)**

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

### 2.2 Avoid Barrel File Imports

**Impact: CRITICAL (200-800ms bundle parse reduction, smaller memory footprint)**

Import directly from source files instead of barrel files (index.js re-exports). Barrel files force the bundler to load entire libraries even when you only need one component.

**Incorrect (imports entire library):**

```typescript
import { Camera, MapView, Notifications } from '@/components'
// Loads ALL exports from components/index.ts

import { format, parse, isValid } from 'date-fns'
// Loads entire date-fns library
```

**Correct (direct imports):**

```typescript
import Camera from '@/components/Camera'
import MapView from '@/components/MapView'
import Notifications from '@/components/Notifications'

import format from 'date-fns/format'
import parse from 'date-fns/parse'
import isValid from 'date-fns/isValid'
```

**Alternative (configure optimizePackageImports in Metro):**

```javascript
// metro.config.js
const { getDefaultConfig } = require('expo/metro-config')

const config = getDefaultConfig(__dirname)

config.transformer.unstable_optimizePackageImports = [
  'date-fns',
  'lodash',
  '@expo/vector-icons',
]

module.exports = config
```

**Common barrel file offenders:**
- `@expo/vector-icons` - import specific icon set instead
- `lodash` - use `lodash-es` or direct imports
- Component libraries with index.ts re-exports

Reference: [Metro Configuration](https://metrobundler.dev/docs/configuration/)

### 2.3 Enable ProGuard for Android Release Builds

**Impact: HIGH (10-30% smaller APK, removes unused Java/Kotlin code)**

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

### 2.4 Generate Architecture-Specific APKs

**Impact: HIGH (30-50% smaller APK download size)**

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

### 2.5 Remove Unused Dependencies

**Impact: CRITICAL (100-500KB reduction per removed library)**

Audit your package.json regularly for unused dependencies. Libraries installed for experimentation often remain, bloating the bundle even if never imported.

**Incorrect (unused dependencies remain):**

```json
{
  "dependencies": {
    "@react-native-async-storage/async-storage": "^1.21.0",
    "expo": "^52.0.0",
    "react": "18.2.0",
    "react-native": "0.76.0",
    "react-native-chart-kit": "^6.12.0",
    "react-native-maps": "^1.8.0",
    "react-native-svg": "^14.0.0",
    "victory-native": "^36.6.0"
  }
}
```

**Correct (audited and cleaned):**

```bash
# Find unused dependencies
npx depcheck

# Output example:
# Unused dependencies
# * react-native-chart-kit
# * victory-native
# * react-native-maps

# Remove unused
npm uninstall react-native-chart-kit victory-native react-native-maps
```

**Resulting clean package.json:**

```json
{
  "dependencies": {
    "@react-native-async-storage/async-storage": "^1.21.0",
    "expo": "^52.0.0",
    "react": "18.2.0",
    "react-native": "0.76.0",
    "react-native-svg": "^14.0.0"
  }
}
```

**Automate in CI:**

```yaml
# .github/workflows/check-deps.yml
- name: Check for unused dependencies
  run: npx depcheck --ignores="@types/*,typescript"
```

**Note:** Some dependencies may appear unused but are required by Metro plugins or native modules. Use `--ignores` flag for legitimate cases.

### 2.6 Subset Custom Fonts to Used Characters

**Impact: MEDIUM-HIGH (50-90% font file size reduction)**

Custom fonts often include thousands of glyphs for multiple languages. Subset fonts to include only the characters your app actually uses.

**Incorrect (full font file):**

```typescript
// Using complete font file (400KB+)
import * as Font from 'expo-font'

await Font.loadAsync({
  'Inter-Bold': require('./assets/fonts/Inter-Bold.ttf'),  // 300KB
  'Inter-Regular': require('./assets/fonts/Inter-Regular.ttf'),  // 290KB
})
```

**Correct (subsetted fonts):**

```bash
# Subset font using fonttools (Python)
pip install fonttools brotli

# Subset to Latin characters only
pyftsubset Inter-Bold.ttf \
  --unicodes="U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+2000-206F" \
  --output-file="Inter-Bold-subset.ttf"
```

```typescript
// Using subsetted font file (40KB)
import * as Font from 'expo-font'

await Font.loadAsync({
  'Inter-Bold': require('./assets/fonts/Inter-Bold-subset.ttf'),  // 40KB
  'Inter-Regular': require('./assets/fonts/Inter-Regular-subset.ttf'),  // 38KB
})
```

**Alternative (use Google Fonts with expo-google-fonts):**

```typescript
import { useFonts, Inter_700Bold } from '@expo-google-fonts/inter'

// Google Fonts are already optimized and cached
const [fontsLoaded] = useFonts({
  Inter_700Bold,
})
```

**Common Unicode ranges:**
| Range | Description |
|-------|-------------|
| U+0000-00FF | Latin Basic + Supplement |
| U+0100-017F | Latin Extended-A |
| U+0400-04FF | Cyrillic |
| U+0600-06FF | Arabic |

Reference: [fonttools Documentation](https://fonttools.readthedocs.io/)

### 2.7 Use Lightweight Library Alternatives

**Impact: HIGH (50-200KB savings per replaced library)**

Replace heavy libraries with lightweight alternatives that provide the same functionality. Many popular libraries have smaller, more focused replacements.

**Incorrect (heavy libraries for simple tasks):**

```json
{
  "dependencies": {
    "moment": "^2.29.4",
    "lodash": "^4.17.21",
    "axios": "^1.6.0",
    "uuid": "^9.0.0"
  }
}
```

```typescript
import moment from 'moment'  // 232KB
import _ from 'lodash'  // 72KB
import axios from 'axios'  // 48KB
import { v4 as uuidv4 } from 'uuid'  // 12KB
```

**Correct (lightweight alternatives):**

```json
{
  "dependencies": {
    "date-fns": "^2.30.0",
    "ky": "^1.2.0"
  }
}
```

```typescript
import { format, parseISO } from 'date-fns'  // ~3KB per function
import ky from 'ky'  // 3KB

// Use built-in crypto for UUIDs
import * as Crypto from 'expo-crypto'
const uuid = Crypto.randomUUID()

// Use native array methods instead of lodash
const filtered = items.filter(x => x.active)
const mapped = items.map(x => x.name)
const unique = [...new Set(items)]
```

**Library replacements:**

| Heavy Library | Size | Alternative | Size |
|---------------|------|-------------|------|
| moment | 232KB | date-fns | ~3KB/fn |
| lodash | 72KB | Native methods | 0KB |
| axios | 48KB | ky or fetch | 3KB/0KB |
| uuid | 12KB | expo-crypto | built-in |
| classnames | 2KB | Template literals | 0KB |
| numeral | 33KB | Intl.NumberFormat | 0KB |

**Using native Intl APIs:**

```typescript
// Instead of numeral.js
const formatCurrency = (amount) =>
  new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(amount)

// Instead of moment for relative time
const formatRelative = (date) =>
  new Intl.RelativeTimeFormat('en', { numeric: 'auto' }).format(
    Math.round((date - Date.now()) / (1000 * 60 * 60 * 24)),
    'day'
  )
```

**When heavy libraries are justified:**
- Complex date manipulation (moment-timezone for timezone math)
- Deep cloning with circular refs (lodash.cloneDeep)
- HTTP interceptors and retry logic (axios)

---

## 3. List Virtualization

**Impact: HIGH**

Lists are ubiquitous in mobile apps. Unoptimized lists cause jank, blank frames, and memory exhaustion.

### 3.1 Avoid Inline Functions in List renderItem

**Impact: HIGH (prevents component recreation on every render)**

Inline arrow functions in renderItem create new function instances on every parent render, causing all list items to re-render even when data hasn't changed.

**Incorrect (inline function recreated every render):**

```typescript
import { FlashList } from '@shopify/flash-list'

function ProductList({ products, onAddToCart }) {
  return (
    <FlashList
      data={products}
      renderItem={({ item }) => (
        <ProductCard
          product={item}
          onAddToCart={() => onAddToCart(item.id)}  // New function every render
        />
      )}
      estimatedItemSize={120}
    />
  )
}
```

**Correct (stable callback references):**

```typescript
import { useCallback } from 'react'
import { FlashList } from '@shopify/flash-list'

function ProductList({ products, onAddToCart }) {
  const renderItem = useCallback(({ item }) => (
    <ProductCard
      product={item}
      productId={item.id}
      onAddToCart={onAddToCart}
    />
  ), [onAddToCart])

  return (
    <FlashList
      data={products}
      renderItem={renderItem}
      estimatedItemSize={120}
    />
  )
}

// ProductCard receives productId and calls onAddToCart(productId) internally
const ProductCard = memo(function ProductCard({ product, productId, onAddToCart }) {
  const handlePress = useCallback(() => {
    onAddToCart(productId)
  }, [productId, onAddToCart])

  return (
    <Pressable onPress={handlePress}>
      <Text>{product.name}</Text>
    </Pressable>
  )
})
```

**Alternative (extract to named component):**

```typescript
function ProductList({ products, onAddToCart }) {
  return (
    <FlashList
      data={products}
      renderItem={ProductCardRenderer}
      extraData={onAddToCart}
      estimatedItemSize={120}
    />
  )
}

const ProductCardRenderer = memo(({ item, extraData }) => (
  <ProductCard product={item} onAddToCart={extraData} />
))
```

### 3.2 Avoid key Prop Inside FlashList Items

**Impact: HIGH (preserves cell recycling, prevents performance degradation)**

Using the `key` prop inside FlashList item components breaks cell recycling. FlashList needs to reuse component instances, but `key` forces React to create new instances.

**Incorrect (key breaks recycling):**

```typescript
import { FlashList } from '@shopify/flash-list'

function ProductList({ products }) {
  return (
    <FlashList
      data={products}
      renderItem={({ item }) => (
        <View key={item.id}>  {/* Breaks recycling! */}
          <ProductImage key={`img-${item.id}`} uri={item.imageUrl} />
          <Text key={`name-${item.id}`}>{item.name}</Text>
          <Text key={`price-${item.id}`}>{item.price}</Text>
        </View>
      )}
      estimatedItemSize={120}
    />
  )
}
// FlashList falls back to FlatList behavior, losing performance benefits
```

**Correct (no key props inside items):**

```typescript
import { FlashList } from '@shopify/flash-list'

function ProductList({ products }) {
  return (
    <FlashList
      data={products}
      renderItem={({ item }) => (
        <View>
          <ProductImage uri={item.imageUrl} />
          <Text>{item.name}</Text>
          <Text>{item.price}</Text>
        </View>
      )}
      keyExtractor={item => item.id}  // Use keyExtractor instead
      estimatedItemSize={120}
    />
  )
}
// Cell recycling works properly
```

**When mapping child arrays, use index (acceptable in recycled context):**

```typescript
function ProductCard({ product }) {
  return (
    <View>
      <Text>{product.name}</Text>
      {product.tags.map((tag, index) => (
        <Tag key={index} label={tag} />  // Index key OK for stable arrays
      ))}
    </View>
  )
}
```

**Note:** This rule is specific to FlashList. In regular React components and FlatList, keys are important for reconciliation.

Reference: [FlashList Performance Tips](https://shopify.github.io/flash-list/docs/fundamentals/performant-components)

### 3.3 Configure List Batch Rendering for Scroll Performance

**Impact: MEDIUM-HIGH (reduces blank areas during fast scrolling)**

Tune FlatList's batch rendering props to balance memory usage against scroll smoothness. The defaults are conservative and may show blank areas during fast scrolling.

**Incorrect (default settings cause blank areas):**

```typescript
import { FlatList } from 'react-native'

function ArticleList({ articles }) {
  return (
    <FlatList
      data={articles}
      renderItem={({ item }) => <ArticleCard article={item} />}
      keyExtractor={item => item.id}
      // Default: windowSize=21, maxToRenderPerBatch=10
      // May show blank areas on fast scroll
    />
  )
}
```

**Correct (tuned for fast scrolling):**

```typescript
import { FlatList } from 'react-native'

function ArticleList({ articles }) {
  return (
    <FlatList
      data={articles}
      renderItem={({ item }) => <ArticleCard article={item} />}
      keyExtractor={item => item.id}
      windowSize={11}  // Render 5 screens above and below
      maxToRenderPerBatch={5}  // Render 5 items per batch
      updateCellsBatchingPeriod={50}  // 50ms between batches
      initialNumToRender={10}  // Initial visible items
      removeClippedSubviews={true}  // Unmount off-screen items
    />
  )
}
```

**Configuration guide:**

| Prop | Lower Value | Higher Value |
|------|-------------|--------------|
| windowSize | Less memory, more blanks | More memory, fewer blanks |
| maxToRenderPerBatch | Smoother UI, more blanks | More blanks during scroll, faster fill |
| initialNumToRender | Faster initial render | Better initial scroll |

**For different use cases:**

```typescript
// Memory-constrained (long lists, complex items)
windowSize={5}
maxToRenderPerBatch={3}

// Smooth scrolling priority (short lists, simple items)
windowSize={21}
maxToRenderPerBatch={10}
```

**Note:** FlashList handles batching automatically and usually doesn't need these tweaks. Prefer FlashList for new code.

Reference: [Optimizing FlatList Configuration](https://reactnative.dev/docs/optimizing-flatlist-configuration)

### 3.4 Memoize List Item Components

**Impact: HIGH (prevents re-render of all items when list data changes)**

Wrap list item components in `React.memo()` to prevent re-rendering unchanged items when the list data updates. This is essential for smooth scrolling performance.

**Incorrect (all items re-render on any change):**

```typescript
import { FlashList } from '@shopify/flash-list'

function MessageItem({ message, onDelete }) {
  return (
    <View style={styles.messageContainer}>
      <Text style={styles.sender}>{message.sender}</Text>
      <Text style={styles.content}>{message.content}</Text>
      <Text style={styles.time}>{formatTime(message.timestamp)}</Text>
      <IconButton icon="delete" onPress={() => onDelete(message.id)} />
    </View>
  )
}

function MessageList({ messages, onDeleteMessage }) {
  return (
    <FlashList
      data={messages}
      renderItem={({ item }) => (
        <MessageItem message={item} onDelete={onDeleteMessage} />
      )}
      estimatedItemSize={80}
    />
  )
}
// All MessageItems re-render when any message changes
```

**Correct (memoized items only re-render when their props change):**

```typescript
import { memo, useCallback } from 'react'
import { FlashList } from '@shopify/flash-list'

const MessageItem = memo(function MessageItem({ message, onDelete }) {
  return (
    <View style={styles.messageContainer}>
      <Text style={styles.sender}>{message.sender}</Text>
      <Text style={styles.content}>{message.content}</Text>
      <Text style={styles.time}>{formatTime(message.timestamp)}</Text>
      <IconButton icon="delete" onPress={() => onDelete(message.id)} />
    </View>
  )
})

function MessageList({ messages, onDeleteMessage }) {
  const renderItem = useCallback(({ item }) => (
    <MessageItem message={item} onDelete={onDeleteMessage} />
  ), [onDeleteMessage])

  return (
    <FlashList
      data={messages}
      renderItem={renderItem}
      estimatedItemSize={80}
    />
  )
}
// Only changed MessageItems re-render
```

**Custom comparison for complex items:**

```typescript
const MessageItem = memo(
  function MessageItem({ message, onDelete }) {
    // ... component body
  },
  (prevProps, nextProps) => {
    // Only re-render if these specific fields change
    return (
      prevProps.message.id === nextProps.message.id &&
      prevProps.message.content === nextProps.message.content &&
      prevProps.message.isRead === nextProps.message.isRead
    )
  }
)
```

Reference: [React.memo Documentation](https://react.dev/reference/react/memo)

### 3.5 Provide Accurate estimatedItemSize for FlashList

**Impact: HIGH (eliminates layout recalculation, smoother initial render)**

FlashList uses `estimatedItemSize` to pre-calculate scroll positions and optimize rendering. An accurate estimate prevents layout jumps and improves initial render performance.

**Incorrect (missing or inaccurate estimate):**

```typescript
import { FlashList } from '@shopify/flash-list'

function MessageList({ messages }) {
  return (
    <FlashList
      data={messages}
      renderItem={({ item }) => <MessageBubble message={item} />}
      // Missing estimatedItemSize - FlashList will warn
    />
  )
}
```

**Correct (measured estimate):**

```typescript
import { FlashList } from '@shopify/flash-list'

function MessageList({ messages }) {
  return (
    <FlashList
      data={messages}
      renderItem={({ item }) => <MessageBubble message={item} />}
      estimatedItemSize={85}  // Measured average height
    />
  )
}

// How to measure: render a few items and log their heights
// <View onLayout={(e) => console.log(e.nativeEvent.layout.height)}>
```

**For variable height items, use getItemType:**

```typescript
import { FlashList } from '@shopify/flash-list'

function FeedList({ items }) {
  return (
    <FlashList
      data={items}
      renderItem={({ item }) => {
        if (item.type === 'image') return <ImagePost post={item} />
        if (item.type === 'video') return <VideoPost post={item} />
        return <TextPost post={item} />
      }}
      getItemType={item => item.type}
      estimatedItemSize={200}  // Average across all types
    />
  )
}
```

**Note:** FlashList v2+ with New Architecture handles item sizing automatically. This rule applies to FlashList v1 or when using `legacyImplementation`. Check performance warnings in development mode for sizing issues.

Reference: [FlashList estimatedItemSize](https://shopify.github.io/flash-list/docs/usage#estimateditemsize)

### 3.6 Provide getItemLayout for Fixed-Height FlatList Items

**Impact: HIGH (eliminates async layout measurement, instant scroll-to-index)**

When all list items have the same height, provide `getItemLayout` to skip asynchronous layout measurement. This enables instant `scrollToIndex` and prevents blank areas during fast scrolling.

**Incorrect (async layout measurement):**

```typescript
import { FlatList } from 'react-native'

const ITEM_HEIGHT = 72

function ContactList({ contacts }) {
  const listRef = useRef(null)

  const scrollToContact = (index) => {
    listRef.current?.scrollToIndex({ index, animated: true })
    // May fail or show blank area while measuring
  }

  return (
    <FlatList
      ref={listRef}
      data={contacts}
      renderItem={({ item }) => (
        <ContactRow contact={item} style={{ height: ITEM_HEIGHT }} />
      )}
      keyExtractor={item => item.id}
    />
  )
}
```

**Correct (pre-calculated layout):**

```typescript
import { FlatList } from 'react-native'

const ITEM_HEIGHT = 72

function ContactList({ contacts }) {
  const listRef = useRef(null)

  const getItemLayout = useCallback((data, index) => ({
    length: ITEM_HEIGHT,
    offset: ITEM_HEIGHT * index,
    index,
  }), [])

  const scrollToContact = (index) => {
    listRef.current?.scrollToIndex({ index, animated: true })
    // Instant scroll, no measurement needed
  }

  return (
    <FlatList
      ref={listRef}
      data={contacts}
      renderItem={({ item }) => (
        <ContactRow contact={item} style={{ height: ITEM_HEIGHT }} />
      )}
      keyExtractor={item => item.id}
      getItemLayout={getItemLayout}
    />
  )
}
```

**With separators:**

```typescript
const ITEM_HEIGHT = 72
const SEPARATOR_HEIGHT = 1

const getItemLayout = (data, index) => ({
  length: ITEM_HEIGHT,
  offset: (ITEM_HEIGHT + SEPARATOR_HEIGHT) * index,
  index,
})
```

**Note:** Only use `getItemLayout` when ALL items have the exact same height. For variable heights, use FlashList with `estimatedItemSize` instead.

Reference: [React Native FlatList getItemLayout](https://reactnative.dev/docs/flatlist#getitemlayout)

### 3.7 Use FlashList Instead of FlatList for Large Lists

**Impact: HIGH (54% FPS improvement, 82% CPU reduction via cell recycling)**

FlashList uses cell recycling like native iOS UITableView and Android RecyclerView, dramatically reducing memory usage and improving scroll performance compared to FlatList's virtualization.

**Incorrect (FlatList for large datasets):**

```typescript
import { FlatList } from 'react-native'

function ProductList({ products }) {
  return (
    <FlatList
      data={products}  // 1000+ items
      renderItem={({ item }) => <ProductCard product={item} />}
      keyExtractor={item => item.id}
    />
  )
}
// FlatList mounts/unmounts components, causing jank during fast scrolling
```

**Correct (FlashList with cell recycling):**

```typescript
import { FlashList } from '@shopify/flash-list'

function ProductList({ products }) {
  return (
    <FlashList
      data={products}
      renderItem={({ item }) => <ProductCard product={item} />}
      estimatedItemSize={120}  // Required: approximate item height
      keyExtractor={item => item.id}
    />
  )
}
// FlashList reuses components, maintaining smooth 60fps
```

**Installation:**

```bash
npx expo install @shopify/flash-list
```

**Performance metrics (FlashList v1 benchmarks):**
| Metric | FlatList | FlashList |
|--------|----------|-----------|
| Average FPS | 36.9 | 56.9 |
| CPU Usage | 198.9% | 36.5% |
| JS Thread | >90% | <10% |

**Note:** FlashList v2+ (2025) with New Architecture provides further improvements and automatic item sizing.

**When to use FlatList:**
- Lists with < 50 simple items
- Highly dynamic item heights that can't be estimated
- When FlashList compatibility issues arise

Reference: [FlashList Documentation](https://shopify.github.io/flash-list/)

---

## 4. Image Optimization

**Impact: HIGH**

Images are often the largest assets. Unoptimized images cause memory pressure, slow renders, and network bottlenecks.

### 4.1 Lazy Load Off-Screen Images

**Impact: MEDIUM-HIGH (reduces initial memory footprint and network requests)**

Only load images when they're about to become visible. For lists, FlashList handles this automatically. For grids and custom layouts, implement manual lazy loading.

**Incorrect (all images load immediately):**

```typescript
import { Image } from 'expo-image'
import { ScrollView } from 'react-native'

function PhotoGallery({ photos }) {
  return (
    <ScrollView>
      {photos.map(photo => (
        <Image
          key={photo.id}
          source={{ uri: photo.url }}
          style={styles.photo}
        />  // All 100 images start loading immediately
      ))}
    </ScrollView>
  )
}
// Network saturated, high memory usage
```

**Correct (images load when visible):**

```typescript
import { Image } from 'expo-image'
import { FlashList } from '@shopify/flash-list'

function PhotoGallery({ photos }) {
  return (
    <FlashList
      data={photos}
      renderItem={({ item }) => (
        <Image
          source={{ uri: item.url }}
          style={styles.photo}
          contentFit="cover"
        />
      )}
      estimatedItemSize={200}
      numColumns={3}
    />
  )
}
// FlashList only renders visible items + buffer
```

**Manual lazy loading with visibility detection:**

```typescript
import { Image } from 'expo-image'
import { View, useWindowDimensions } from 'react-native'
import { useRef, useState, useCallback } from 'react'

function LazyImage({ source, style }) {
  const [isVisible, setIsVisible] = useState(false)
  const { height: screenHeight } = useWindowDimensions()

  const handleLayout = useCallback((event) => {
    const { y } = event.nativeEvent.layout
    // Load if within 2 screens of viewport
    if (y < screenHeight * 2) {
      setIsVisible(true)
    }
  }, [screenHeight])

  return (
    <View style={style} onLayout={handleLayout}>
      {isVisible ? (
        <Image source={source} style={style} />
      ) : (
        <View style={[style, styles.placeholder]} />
      )}
    </View>
  )
}
```

**expo-image recyclingKey for list image recycling:**

```typescript
<FlashList
  data={products}
  renderItem={({ item }) => (
    <Image
      source={{ uri: item.imageUrl }}
      recyclingKey={item.id}  // Helps with image recycling in lists
      style={styles.productImage}
    />
  )}
  estimatedItemSize={120}
/>
```

Reference: [expo-image recyclingKey](https://docs.expo.dev/versions/latest/sdk/image/#recyclingkey)

### 4.2 Preload Critical Above-the-Fold Images

**Impact: MEDIUM-HIGH (eliminates loading delay for first visible images)**

Preload images that appear immediately when a screen loads. This ensures they're ready to display without network delay.

**Incorrect (images load on render):**

```typescript
import { Image } from 'expo-image'

function HomeScreen() {
  return (
    <View>
      <Image
        source={{ uri: 'https://cdn.example.com/hero-banner.webp' }}
        style={styles.heroBanner}
        // Network request starts when component mounts
      />
    </View>
  )
}
```

**Correct (preloaded during splash screen):**

```typescript
import { Image } from 'expo-image'
import * as SplashScreen from 'expo-splash-screen'

SplashScreen.preventAutoHideAsync()

const criticalImages = [
  'https://cdn.example.com/hero-banner.webp',
  'https://cdn.example.com/logo.webp',
]

async function preloadImages() {
  await Promise.all(
    criticalImages.map(uri => Image.prefetch(uri))
  )
}

export default function App() {
  const [ready, setReady] = useState(false)

  useEffect(() => {
    preloadImages().then(() => setReady(true))
  }, [])

  useEffect(() => {
    if (ready) {
      SplashScreen.hideAsync()
    }
  }, [ready])

  if (!ready) return null

  return <RootNavigator />
}
```

**Prefetch before navigation:**

```typescript
import { Image } from 'expo-image'
import { useRouter } from 'expo-router'

function ProductListItem({ product }) {
  const router = useRouter()

  const handlePress = async () => {
    // Start prefetching before navigation completes
    Image.prefetch(product.fullImageUrl)
    router.push(`/product/${product.id}`)
  }

  return (
    <Pressable onPress={handlePress}>
      <Image source={{ uri: product.thumbnailUrl }} />
      <Text>{product.name}</Text>
    </Pressable>
  )
}
```

**useImage hook for preloading with metadata:**

```typescript
import { useImage } from 'expo-image'

function ProductDetail({ productId }) {
  const imageSource = useImage(`https://cdn.example.com/products/${productId}.webp`)

  if (!imageSource) {
    return <LoadingSkeleton />
  }

  return (
    <Image
      source={imageSource}
      style={{ width: imageSource.width, height: imageSource.height }}
    />
  )
}
```

Reference: [expo-image Prefetching](https://docs.expo.dev/versions/latest/sdk/image/#prefetching)

### 4.3 Resize Images to Display Size

**Impact: HIGH (50-90% memory reduction for oversized images)**

Loading a 4000x3000 image into a 100x100 avatar wastes memory and slows rendering. Resize images server-side or use expo-image's automatic resizing.

**Incorrect (full-resolution image for small display):**

```typescript
import { Image } from 'expo-image'

function UserAvatar({ user }) {
  return (
    <Image
      source={{ uri: user.profilePhotoUrl }}  // 4032x3024 original
      style={{ width: 48, height: 48 }}
      // 35MB in memory for a tiny avatar
    />
  )
}
```

**Correct (request resized image):**

```typescript
import { Image } from 'expo-image'
import { PixelRatio } from 'react-native'

function UserAvatar({ user }) {
  // Request image at actual pixel size needed
  const size = 48 * PixelRatio.get()  // 144px on 3x device
  const resizedUrl = `${user.profilePhotoUrl}?w=${size}&h=${size}&fit=cover`

  return (
    <Image
      source={{ uri: resizedUrl }}
      style={{ width: 48, height: 48 }}
      contentFit="cover"
    />
  )
}
```

**For local images, use ImageManipulator:**

```typescript
import * as ImageManipulator from 'expo-image-manipulator'

async function resizeImage(uri, targetWidth, targetHeight) {
  const result = await ImageManipulator.manipulateAsync(
    uri,
    [{ resize: { width: targetWidth, height: targetHeight } }],
    { compress: 0.8, format: ImageManipulator.SaveFormat.JPEG }
  )
  return result.uri
}
```

**Image CDN URL patterns:**

```typescript
// Cloudinary
`https://res.cloudinary.com/demo/image/upload/w_100,h_100,c_fill/${imageId}`

// Imgix
`https://example.imgix.net/image.jpg?w=100&h=100&fit=crop`

// AWS CloudFront + Lambda@Edge
`${baseUrl}?width=100&height=100`
```

**Note:** Always account for pixel density with `PixelRatio.get()` to avoid blurry images on high-DPI screens.

Reference: [expo-image-manipulator Documentation](https://docs.expo.dev/versions/latest/sdk/imagemanipulator/)

### 4.4 Use BlurHash or ThumbHash Placeholders

**Impact: MEDIUM-HIGH (eliminates layout shift, improves perceived loading speed)**

Show a compact placeholder while images load to prevent layout shift and improve perceived performance. BlurHash encodes an image preview in ~20-30 characters.

**Incorrect (no placeholder, content jumps):**

```typescript
import { Image } from 'expo-image'

function ProductCard({ product }) {
  return (
    <View>
      <Image
        source={{ uri: product.imageUrl }}
        style={{ width: 200, height: 200 }}
        // Blank space, then sudden image appearance
      />
      <Text>{product.name}</Text>
    </View>
  )
}
```

**Correct (BlurHash placeholder):**

```typescript
import { Image } from 'expo-image'

function ProductCard({ product }) {
  return (
    <View>
      <Image
        source={{ uri: product.imageUrl }}
        placeholder={{ blurhash: product.blurhash }}
        contentFit="cover"
        transition={300}
        style={{ width: 200, height: 200 }}
      />
      <Text>{product.name}</Text>
    </View>
  )
}
```

**Generate BlurHash on backend:**

```typescript
// Node.js with sharp and blurhash
import { encode } from 'blurhash'
import sharp from 'sharp'

async function generateBlurhash(imagePath) {
  const { data, info } = await sharp(imagePath)
    .raw()
    .ensureAlpha()
    .resize(32, 32, { fit: 'inside' })
    .toBuffer({ resolveWithObject: true })

  return encode(
    new Uint8ClampedArray(data),
    info.width,
    info.height,
    4,  // x components
    3   // y components
  )
}
// Returns: "LEHV6nWB2yk8pyo0adR*.7kCMdnj"
```

**ThumbHash alternative (preserves aspect ratio):**

```typescript
import { Image } from 'expo-image'

function ProductCard({ product }) {
  return (
    <Image
      source={{ uri: product.imageUrl }}
      placeholder={{ thumbhash: product.thumbhash }}
      style={{ width: 200, height: 200 }}
    />
  )
}
```

**Include hash in API response:**

```json
{
  "id": "prod_123",
  "name": "Running Shoes",
  "imageUrl": "https://cdn.example.com/shoes.webp",
  "blurhash": "LEHV6nWB2yk8pyo0adR*.7kCMdnj"
}
```

Reference: [BlurHash](https://blurha.sh/) | [ThumbHash](https://evanw.github.io/thumbhash/)

### 4.5 Use expo-image Instead of React Native Image

**Impact: HIGH (built-in caching, memory optimization, faster loading)**

expo-image provides built-in disk and memory caching, placeholder support, and uses performant native libraries (SDWebImage on iOS, Glide on Android) under the hood.

**Incorrect (React Native Image without caching):**

```typescript
import { Image, View } from 'react-native'

function UserAvatar({ user }) {
  return (
    <View>
      <Image
        source={{ uri: user.avatarUrl }}
        style={{ width: 48, height: 48, borderRadius: 24 }}
      />
    </View>
  )
}
// No disk caching - reloads on every mount
// No placeholder - shows nothing while loading
```

**Correct (expo-image with caching and placeholder):**

```typescript
import { Image } from 'expo-image'
import { View } from 'react-native'

const blurhash = 'LEHV6nWB2yk8pyo0adR*.7kCMdnj'

function UserAvatar({ user }) {
  return (
    <View>
      <Image
        source={{ uri: user.avatarUrl }}
        placeholder={{ blurhash }}
        contentFit="cover"
        transition={200}
        style={{ width: 48, height: 48, borderRadius: 24 }}
        cachePolicy="disk"
      />
    </View>
  )
}
```

**Installation:**

```bash
npx expo install expo-image
```

**Cache policies:**

```typescript
// Memory only - fastest, clears on app close
cachePolicy="memory"

// Disk - persists across sessions
cachePolicy="disk"

// Memory and disk - best of both
cachePolicy="memory-disk"

// No caching - always fetch
cachePolicy="none"
```

**Benefits over React Native Image:**
- Automatic disk and memory caching
- BlurHash/ThumbHash placeholders
- Automatic resizing to container size
- Better memory management
- Animated image support (GIF, WebP)

Reference: [expo-image Documentation](https://docs.expo.dev/versions/latest/sdk/image/)

### 4.6 Use WebP Format for Smaller File Sizes

**Impact: HIGH (25-35% smaller than JPEG, 26% smaller than PNG)**

WebP provides superior compression compared to JPEG and PNG while maintaining quality. Both iOS and Android fully support WebP.

**Incorrect (unoptimized PNG/JPEG):**

```typescript
import { Image } from 'expo-image'

function ProductGallery({ images }) {
  return (
    <View>
      {images.map(img => (
        <Image
          key={img.id}
          source={{ uri: img.pngUrl }}  // 500KB PNG
          style={styles.productImage}
        />
      ))}
    </View>
  )
}
```

**Correct (WebP format):**

```typescript
import { Image } from 'expo-image'

function ProductGallery({ images }) {
  return (
    <View>
      {images.map(img => (
        <Image
          key={img.id}
          source={{ uri: img.webpUrl }}  // 175KB WebP (same quality)
          style={styles.productImage}
        />
      ))}
    </View>
  )
}
```

**Convert local assets to WebP:**

```bash
# Using cwebp (install via Homebrew: brew install webp)
cwebp -q 80 input.png -o output.webp

# Batch convert
for f in assets/images/*.png; do
  cwebp -q 80 "$f" -o "${f%.png}.webp"
done
```

**Request WebP from image CDN:**

```typescript
// Cloudinary - automatic format selection
`https://res.cloudinary.com/demo/image/upload/f_auto/${imageId}`

// Imgix
`https://example.imgix.net/image.jpg?fm=webp&q=80`

// Direct WebP URL
`${baseUrl}/images/${imageId}.webp`
```

**Format comparison:**
| Format | 1000x1000 Photo | Transparency |
|--------|-----------------|--------------|
| PNG | 2.5 MB | Yes |
| JPEG | 150 KB | No |
| WebP | 100 KB | Yes |

**Note:** For animated images, WebP also outperforms GIF with smaller file sizes and better quality.

Reference: [WebP Documentation](https://developers.google.com/speed/webp)

---

## 5. Navigation Performance

**Impact: MEDIUM-HIGH**

Navigation transitions affect perceived performance. Improper stack management causes memory leaks and stuttering.

### 5.1 Avoid Deeply Nested Navigators

**Impact: MEDIUM (reduces navigation complexity and memory overhead)**

Each navigation layer adds overhead. Keep navigation structure flat where possible and avoid nesting navigators more than 2-3 levels deep.

**Incorrect (deeply nested navigators):**

```typescript
// 4+ levels of nesting
function App() {
  return (
    <NavigationContainer>
      <Drawer.Navigator>  {/* Level 1 */}
        <Drawer.Screen name="Main">
          {() => (
            <Tab.Navigator>  {/* Level 2 */}
              <Tab.Screen name="Home">
                {() => (
                  <Stack.Navigator>  {/* Level 3 */}
                    <Stack.Screen name="Feed">
                      {() => (
                        <Stack.Navigator>  {/* Level 4 - excessive */}
                          <Stack.Screen name="Post" component={PostScreen} />
                        </Stack.Navigator>
                      )}
                    </Stack.Screen>
                  </Stack.Navigator>
                )}
              </Tab.Screen>
            </Tab.Navigator>
          )}
        </Drawer.Screen>
      </Drawer.Navigator>
    </NavigationContainer>
  )
}
```

**Correct (flattened structure):**

```typescript
// app/_layout.tsx - Root with tabs
import { Tabs } from 'expo-router'

export default function RootLayout() {
  return (
    <Tabs>
      <Tabs.Screen name="(home)" />
      <Tabs.Screen name="(search)" />
      <Tabs.Screen name="(profile)" />
    </Tabs>
  )
}

// app/(home)/_layout.tsx - Stack within tab
import { Stack } from 'expo-router'

export default function HomeLayout() {
  return (
    <Stack>
      <Stack.Screen name="index" />
      <Stack.Screen name="post/[id]" />
      <Stack.Screen name="user/[id]" />
    </Stack>
  )
}
```

**Use modal presentation instead of nested stacks:**

```typescript
// app/_layout.tsx
import { Stack } from 'expo-router'

export default function RootLayout() {
  return (
    <Stack>
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
      <Stack.Screen
        name="modal"
        options={{ presentation: 'modal' }}
      />
      <Stack.Screen
        name="fullscreen"
        options={{ presentation: 'fullScreenModal' }}
      />
    </Stack>
  )
}
```

**Navigation architecture guidelines:**
- Root: Tabs or Drawer (1 level)
- Per-tab: Stack (2 levels total)
- Modals: Separate from tabs (parallel, not nested)
- Maximum recommended: 3 levels

Reference: [Expo Router Navigation Patterns](https://docs.expo.dev/router/basics/common-navigation-patterns/)

### 5.2 Optimize Screen Options to Reduce Navigation Overhead

**Impact: MEDIUM (reduces header recalculation and re-renders)**

Define screen options statically when possible and avoid inline functions that cause re-renders. Dynamic headers should use minimal dependencies.

**Incorrect (inline options cause re-renders):**

```typescript
import { Stack } from 'expo-router'

export default function Layout() {
  const theme = useTheme()

  return (
    <Stack>
      <Stack.Screen
        name="profile"
        options={{
          headerStyle: { backgroundColor: theme.colors.primary },
          headerTintColor: theme.colors.text,
          headerTitle: () => <CustomTitle />,  // Recreated every render
        }}
      />
    </Stack>
  )
}
```

**Correct (stable options with memoization):**

```typescript
import { Stack } from 'expo-router'
import { useMemo } from 'react'

export default function Layout() {
  const theme = useTheme()

  const profileOptions = useMemo(() => ({
    headerStyle: { backgroundColor: theme.colors.primary },
    headerTintColor: theme.colors.text,
    headerTitle: CustomTitle,  // Component reference, not inline function
  }), [theme.colors.primary, theme.colors.text])

  return (
    <Stack>
      <Stack.Screen name="profile" options={profileOptions} />
    </Stack>
  )
}
```

**Define static options in screen file:**

```typescript
// app/profile.tsx
import { Stack } from 'expo-router'

export default function ProfileScreen() {
  return (
    <>
      <Stack.Screen
        options={{
          title: 'Profile',
          headerLargeTitle: true,
        }}
      />
      <ProfileContent />
    </>
  )
}
```

**Dynamic titles with navigation.setOptions:**

```typescript
function ProductScreen() {
  const { id } = useLocalSearchParams()
  const { data: product } = useQuery(['product', id], fetchProduct)
  const navigation = useNavigation()

  useEffect(() => {
    if (product) {
      navigation.setOptions({ title: product.name })
    }
  }, [product?.name, navigation])

  return <ProductDetail product={product} />
}
```

**Avoid in screen options:**
- Inline arrow functions
- Object literals (create new reference each render)
- Heavy computations
- Hooks (use parent component instead)

### 5.3 Prefetch Data Before Navigation

**Impact: MEDIUM-HIGH (eliminates loading state on destination screen)**

Start fetching data for the next screen before navigation completes. This eliminates the loading spinner on the destination screen.

**Incorrect (fetch on screen mount):**

```typescript
// ProductListScreen.tsx
function ProductListItem({ product }) {
  const router = useRouter()

  return (
    <Pressable onPress={() => router.push(`/product/${product.id}`)}>
      <Text>{product.name}</Text>
    </Pressable>
  )
}

// ProductDetailScreen.tsx
function ProductDetailScreen() {
  const { id } = useLocalSearchParams()
  const [product, setProduct] = useState(null)

  useEffect(() => {
    fetchProduct(id).then(setProduct)  // Fetch starts after navigation
  }, [id])

  if (!product) return <LoadingSpinner />  // User sees loading state

  return <ProductDetail product={product} />
}
```

**Correct (prefetch before navigation):**

```typescript
import { useQueryClient } from '@tanstack/react-query'

// ProductListScreen.tsx
function ProductListItem({ product }) {
  const router = useRouter()
  const queryClient = useQueryClient()

  const handlePress = () => {
    // Start prefetching immediately
    queryClient.prefetchQuery({
      queryKey: ['product', product.id],
      queryFn: () => fetchProduct(product.id),
    })
    router.push(`/product/${product.id}`)
  }

  return (
    <Pressable onPress={handlePress}>
      <Text>{product.name}</Text>
    </Pressable>
  )
}

// ProductDetailScreen.tsx
function ProductDetailScreen() {
  const { id } = useLocalSearchParams()
  const { data: product } = useQuery({
    queryKey: ['product', id],
    queryFn: () => fetchProduct(id),
  })

  // Data often ready immediately due to prefetch
  if (!product) return <LoadingSpinner />

  return <ProductDetail product={product} />
}
```

**Prefetch on hover/focus (web-like pattern):**

```typescript
function ProductListItem({ product }) {
  const router = useRouter()
  const queryClient = useQueryClient()

  const prefetchProduct = useCallback(() => {
    queryClient.prefetchQuery({
      queryKey: ['product', product.id],
      queryFn: () => fetchProduct(product.id),
      staleTime: 30000,  // Consider fresh for 30 seconds
    })
  }, [product.id, queryClient])

  return (
    <Pressable
      onPressIn={prefetchProduct}  // Start prefetch on touch down
      onPress={() => router.push(`/product/${product.id}`)}
    >
      <Text>{product.name}</Text>
    </Pressable>
  )
}
```

Reference: [TanStack Query Prefetching](https://tanstack.com/query/latest/docs/framework/react/guides/prefetching)

### 5.4 Unmount Inactive Tab Screens to Save Memory

**Impact: MEDIUM-HIGH (reduces memory footprint by releasing inactive screen resources)**

By default, tab screens stay mounted when inactive. For memory-heavy screens, enable `unmountOnBlur` to release resources when the user switches tabs.

**Incorrect (all tabs stay mounted):**

```typescript
import { Tabs } from 'expo-router'

export default function TabLayout() {
  return (
    <Tabs>
      <Tabs.Screen name="home" />
      <Tabs.Screen name="map" />  {/* Heavy MapView stays in memory */}
      <Tabs.Screen name="camera" />  {/* Camera stays active */}
      <Tabs.Screen name="profile" />
    </Tabs>
  )
}
// All 4 screens consume memory simultaneously
```

**Correct (heavy screens unmount when inactive):**

```typescript
import { Tabs } from 'expo-router'

export default function TabLayout() {
  return (
    <Tabs>
      <Tabs.Screen name="home" />
      <Tabs.Screen
        name="map"
        options={{ unmountOnBlur: true }}  // Releases MapView memory
      />
      <Tabs.Screen
        name="camera"
        options={{ unmountOnBlur: true }}  // Stops camera when hidden
      />
      <Tabs.Screen name="profile" />
    </Tabs>
  )
}
```

**With React Navigation:**

```typescript
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs'

const Tab = createBottomTabNavigator()

function TabNavigator() {
  return (
    <Tab.Navigator>
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen
        name="Map"
        component={MapScreen}
        options={{ unmountOnBlur: true }}
      />
      <Tab.Screen
        name="Camera"
        component={CameraScreen}
        options={{ unmountOnBlur: true }}
      />
    </Tab.Navigator>
  )
}
```

**Screens that benefit from unmountOnBlur:**
- Map views (react-native-maps)
- Camera/video screens
- Heavy chart/visualization screens
- WebView screens
- Screens with many images

**Trade-offs:**
- State is lost on unmount (use external state management)
- Slight delay when re-mounting
- Better for memory-constrained devices

Reference: [React Navigation Tab Options](https://reactnavigation.org/docs/bottom-tab-navigator/#unmountonblur)

### 5.5 Use Native Stack Navigator for Performance

**Impact: MEDIUM-HIGH (2× smoother transitions, 30% lower memory per screen)**

Use native stack navigation (UINavigationController on iOS, Fragment on Android) instead of JavaScript-based stack navigators. Native stacks provide smoother transitions and better memory management.

**Incorrect (JavaScript stack navigator):**

```typescript
import { createStackNavigator } from '@react-navigation/stack'

const Stack = createStackNavigator()

function AppNavigator() {
  return (
    <Stack.Navigator>
      <Stack.Screen name="Home" component={HomeScreen} />
      <Stack.Screen name="Profile" component={ProfileScreen} />
    </Stack.Navigator>
  )
}
// JS-based animations, higher memory usage, can drop frames
```

**Correct (native stack navigator):**

```typescript
import { createNativeStackNavigator } from '@react-navigation/native-stack'

const Stack = createNativeStackNavigator()

function AppNavigator() {
  return (
    <Stack.Navigator>
      <Stack.Screen name="Home" component={HomeScreen} />
      <Stack.Screen name="Profile" component={ProfileScreen} />
    </Stack.Navigator>
  )
}
// Native animations, optimal memory, smooth 60fps
```

**With Expo Router (native by default):**

```typescript
// app/_layout.tsx
import { Stack } from 'expo-router'

export default function Layout() {
  return (
    <Stack>
      <Stack.Screen name="index" options={{ title: 'Home' }} />
      <Stack.Screen name="profile" options={{ title: 'Profile' }} />
    </Stack>
  )
}
// Expo Router uses native stack by default
```

**When to use JS stack:**
- Complex custom header animations
- Shared element transitions (use react-native-shared-element-transition)
- Full control over gesture handling

**Benefits of native stack:**
- Native platform animations (iOS swipe-back, Android slide)
- Better memory management (native view lifecycle)
- Consistent behavior with native apps
- Hardware-accelerated transitions

Reference: [Expo Router Stack](https://docs.expo.dev/router/advanced/stack/)

---

## 6. Re-render Prevention

**Impact: MEDIUM**

Unnecessary re-renders waste CPU cycles, block the JS thread, and cause frame drops during interactions.

### 6.1 Avoid Anonymous Components in JSX

**Impact: MEDIUM (prevents component unmount/remount on every parent render)**

Defining components inline within JSX creates new component types on every render, causing React to unmount and remount them instead of updating.

**Incorrect (anonymous component recreated each render):**

```typescript
function ProductPage({ productId }) {
  const [quantity, setQuantity] = useState(1)

  return (
    <View>
      <ProductHeader productId={productId} />

      {/* Anonymous component - new type every render */}
      {(() => {
        const PriceDisplay = () => (
          <View>
            <Text>Price: ${calculatePrice(productId, quantity)}</Text>
          </View>
        )
        return <PriceDisplay />
      })()}

      <QuantitySelector value={quantity} onChange={setQuantity} />
    </View>
  )
}
// PriceDisplay unmounts and remounts on every quantity change
```

**Correct (named component outside render):**

```typescript
function PriceDisplay({ productId, quantity }) {
  const price = calculatePrice(productId, quantity)
  return (
    <View>
      <Text>Price: ${price}</Text>
    </View>
  )
}

function ProductPage({ productId }) {
  const [quantity, setQuantity] = useState(1)

  return (
    <View>
      <ProductHeader productId={productId} />
      <PriceDisplay productId={productId} quantity={quantity} />
      <QuantitySelector value={quantity} onChange={setQuantity} />
    </View>
  )
}
// PriceDisplay updates in place, preserving state
```

**Also incorrect (component defined inside render):**

```typescript
function ProductPage({ productId }) {
  const [quantity, setQuantity] = useState(1)

  // Component defined inside - new type every render
  const PriceDisplay = () => (
    <Text>Price: ${calculatePrice(productId, quantity)}</Text>
  )

  return (
    <View>
      <PriceDisplay />  {/* Remounts on every render */}
    </View>
  )
}
```

**Correct alternatives:**

```typescript
// Option 1: Inline JSX (no component wrapper needed)
function ProductPage({ productId }) {
  const [quantity, setQuantity] = useState(1)

  return (
    <View>
      <Text>Price: ${calculatePrice(productId, quantity)}</Text>
    </View>
  )
}

// Option 2: useMemo for expensive render (rare)
function ProductPage({ productId }) {
  const [quantity, setQuantity] = useState(1)

  const priceElement = useMemo(() => (
    <Text>Price: ${calculatePrice(productId, quantity)}</Text>
  ), [productId, quantity])

  return <View>{priceElement}</View>
}
```

**Signs of this anti-pattern:**
- Component state resets unexpectedly
- Animations restart on parent re-render
- Input fields lose focus when typing

### 6.2 Avoid Overusing Context for Frequently Changing State

**Impact: MEDIUM (prevents global re-renders from state updates)**

Context triggers re-renders in ALL consuming components when any part of the value changes. Use context for low-frequency updates (theme, auth) and dedicated state libraries for high-frequency updates.

**Incorrect (all consumers re-render on any change):**

```typescript
const AppContext = createContext(null)

function AppProvider({ children }) {
  const [user, setUser] = useState(null)
  const [cart, setCart] = useState([])
  const [notifications, setNotifications] = useState([])
  const [theme, setTheme] = useState('light')

  // Single context with everything
  const value = { user, cart, notifications, theme, setCart, setTheme }

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>
}

// Every component using AppContext re-renders when cart updates
function Header() {
  const { user, theme } = useContext(AppContext)  // Re-renders on cart change
  return <HeaderContent user={user} theme={theme} />
}
```

**Correct (split contexts by update frequency):**

```typescript
// Low-frequency contexts
const AuthContext = createContext(null)
const ThemeContext = createContext(null)

// High-frequency state with Zustand
import { create } from 'zustand'

const useCartStore = create((set) => ({
  items: [],
  addItem: (item) => set((state) => ({ items: [...state.items, item] })),
  removeItem: (id) => set((state) => ({
    items: state.items.filter(item => item.id !== id)
  })),
}))

function Header() {
  const { user } = useContext(AuthContext)  // Only re-renders on auth change
  const theme = useContext(ThemeContext)
  return <HeaderContent user={user} theme={theme} />
}

function CartButton() {
  const itemCount = useCartStore((state) => state.items.length)
  // Only re-renders when item count changes, not on every cart update
  return <Badge count={itemCount} />
}
```

**Alternative: Memoize context value:**

```typescript
function AppProvider({ children }) {
  const [user, setUser] = useState(null)
  const [theme, setTheme] = useState('light')

  const value = useMemo(
    () => ({ user, theme, setUser, setTheme }),
    [user, theme]
  )

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>
}
```

**Context use cases:**
| Use Case | Solution |
|----------|----------|
| Theme (infrequent) | Context |
| Auth state (infrequent) | Context |
| Cart items (frequent) | Zustand/Jotai |
| Form state (frequent) | Local state or React Hook Form |
| Real-time data (frequent) | TanStack Query + subscriptions |

Reference: [Zustand Documentation](https://github.com/pmndrs/zustand)

### 6.3 Enable React Compiler for Automatic Memoization

**Impact: MEDIUM (automatic useMemo/useCallback insertion, reduced manual optimization)**

React Compiler automatically adds memoization to your components, eliminating the need for manual `useMemo`, `useCallback`, and `memo` in most cases.

**Incorrect (manual memoization everywhere):**

```typescript
const ProductCard = memo(function ProductCard({ product, onAddToCart }) {
  const formattedPrice = useMemo(
    () => formatCurrency(product.price),
    [product.price]
  )

  const handlePress = useCallback(
    () => onAddToCart(product.id),
    [product.id, onAddToCart]
  )

  return (
    <Pressable onPress={handlePress}>
      <Text>{product.name}</Text>
      <Text>{formattedPrice}</Text>
    </Pressable>
  )
})
```

**Correct (React Compiler handles optimization):**

```typescript
// With React Compiler enabled, write simple code
function ProductCard({ product, onAddToCart }) {
  const formattedPrice = formatCurrency(product.price)

  const handlePress = () => onAddToCart(product.id)

  return (
    <Pressable onPress={handlePress}>
      <Text>{product.name}</Text>
      <Text>{formattedPrice}</Text>
    </Pressable>
  )
}
// Compiler automatically adds memoization where beneficial
```

**Enable in Expo SDK 53+:**

```json
{
  "expo": {
    "experiments": {
      "reactCompiler": true
    }
  }
}
```

**Enable in Expo SDK 52 (manual setup):**

```bash
npx expo install babel-plugin-react-compiler
```

```javascript
// babel.config.js
module.exports = function (api) {
  api.cache(true)
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      ['babel-plugin-react-compiler', {}],
    ],
  }
}
```

**When manual memoization is still needed:**
- Expensive computations the compiler can't detect
- Third-party components requiring stable references
- useEffect with dependencies that shouldn't change

**Verify compiler is working:**

```bash
# Check compiled output
npx react-compiler-healthcheck
```

Reference: [React Compiler Documentation](https://react.dev/learn/react-compiler)

### 6.4 Memoize Expensive Components with React.memo

**Impact: MEDIUM (prevents cascading re-renders from parent updates)**

Wrap components that receive stable props in `React.memo()` to prevent re-renders when the parent component updates but the props haven't changed.

**Incorrect (re-renders on every parent update):**

```typescript
function ProductCard({ product, onAddToCart }) {
  return (
    <View style={styles.card}>
      <Image source={{ uri: product.imageUrl }} style={styles.image} />
      <Text style={styles.name}>{product.name}</Text>
      <Text style={styles.price}>${product.price}</Text>
      <Button title="Add to Cart" onPress={() => onAddToCart(product.id)} />
    </View>
  )
}

function ProductList({ products, cartCount }) {
  const handleAddToCart = useCallback((id) => addToCart(id), [])

  return (
    <View>
      <Text>Cart: {cartCount}</Text>  {/* Updates frequently */}
      {products.map(product => (
        <ProductCard
          key={product.id}
          product={product}
          onAddToCart={handleAddToCart}
        />  {/* All cards re-render when cartCount changes */}
      ))}
    </View>
  )
}
```

**Correct (memoized components skip re-renders):**

```typescript
const ProductCard = memo(function ProductCard({ product, onAddToCart }) {
  return (
    <View style={styles.card}>
      <Image source={{ uri: product.imageUrl }} style={styles.image} />
      <Text style={styles.name}>{product.name}</Text>
      <Text style={styles.price}>${product.price}</Text>
      <Button title="Add to Cart" onPress={() => onAddToCart(product.id)} />
    </View>
  )
})

function ProductList({ products, cartCount }) {
  const handleAddToCart = useCallback((id) => addToCart(id), [])

  return (
    <View>
      <Text>Cart: {cartCount}</Text>
      {products.map(product => (
        <ProductCard
          key={product.id}
          product={product}
          onAddToCart={handleAddToCart}  // Stable reference
        />  {/* Cards only re-render if product or callback changes */}
      ))}
    </View>
  )
}
```

**Custom comparison for complex props:**

```typescript
const ProductCard = memo(
  function ProductCard({ product, onAddToCart }) {
    // ... component body
  },
  (prevProps, nextProps) => {
    return prevProps.product.id === nextProps.product.id &&
           prevProps.product.price === nextProps.product.price
  }
)
```

**When to use memo:**
- List item components
- Components below frequently updating parents
- Components with expensive render logic
- Components receiving stable object/array props

**When NOT to use memo:**
- Components that always receive new props
- Very simple components (memo overhead > render cost)
- Components that need to always re-render

Reference: [React.memo Documentation](https://react.dev/reference/react/memo)

### 6.5 Memoize Expensive Computations with useMemo

**Impact: MEDIUM (prevents redundant calculations on every render)**

Use `useMemo` to cache expensive calculations that don't need to run on every render. This is especially important for filtering, sorting, or transforming large datasets.

**Incorrect (recalculates on every render):**

```typescript
function OrderHistory({ orders, filterStatus }) {
  // Runs on EVERY render, even when orders/filterStatus unchanged
  const filteredOrders = orders.filter(order => order.status === filterStatus)
  const sortedOrders = filteredOrders.sort((a, b) =>
    new Date(b.createdAt) - new Date(a.createdAt)
  )
  const totalAmount = sortedOrders.reduce((sum, order) => sum + order.total, 0)

  return (
    <View>
      <Text>Total: ${totalAmount}</Text>
      <FlashList data={sortedOrders} renderItem={OrderRow} />
    </View>
  )
}
```

**Correct (memoized computations):**

```typescript
function OrderHistory({ orders, filterStatus }) {
  const filteredOrders = useMemo(() =>
    orders.filter(order => order.status === filterStatus),
    [orders, filterStatus]
  )

  const sortedOrders = useMemo(() =>
    [...filteredOrders].sort((a, b) =>
      new Date(b.createdAt) - new Date(a.createdAt)
    ),
    [filteredOrders]
  )

  const totalAmount = useMemo(() =>
    sortedOrders.reduce((sum, order) => sum + order.total, 0),
    [sortedOrders]
  )

  return (
    <View>
      <Text>Total: ${totalAmount}</Text>
      <FlashList data={sortedOrders} renderItem={OrderRow} />
    </View>
  )
}
```

**Memoize object/array props to prevent child re-renders:**

```typescript
function ChartScreen({ data }) {
  // Without useMemo, new object reference every render
  const chartConfig = useMemo(() => ({
    backgroundColor: '#ffffff',
    backgroundGradientFrom: '#ffffff',
    backgroundGradientTo: '#ffffff',
    color: (opacity = 1) => `rgba(0, 122, 255, ${opacity})`,
  }), [])

  const chartData = useMemo(() => ({
    labels: data.map(d => d.label),
    datasets: [{ data: data.map(d => d.value) }],
  }), [data])

  return <LineChart data={chartData} chartConfig={chartConfig} />
}
```

**When to use useMemo:**
- Filtering/sorting large arrays (100+ items)
- Complex calculations (aggregations, transformations)
- Creating object/array props for memoized children
- Derived state from props

**When NOT to use useMemo:**
- Simple calculations
- Primitives (strings, numbers, booleans)
- Values that change every render anyway

Reference: [React useMemo Documentation](https://react.dev/reference/react/useMemo)

### 6.6 Split Components to Isolate Frequently Updating State

**Impact: MEDIUM (reduces re-render scope from N components to 1-3)**

Extract frequently updating state into small, dedicated components. This prevents re-rendering the entire parent tree when only a small piece of UI needs to update.

**Incorrect (entire form re-renders on each keystroke):**

```typescript
function CheckoutForm() {
  const [cardNumber, setCardNumber] = useState('')
  const [expiry, setExpiry] = useState('')
  const [cvv, setCvv] = useState('')
  const [billingAddress, setBillingAddress] = useState({})
  const [items, setItems] = useState(initialItems)

  return (
    <View>
      <OrderSummary items={items} />  {/* Re-renders on every keystroke */}
      <ShippingOptions />  {/* Re-renders on every keystroke */}

      <TextInput
        value={cardNumber}
        onChangeText={setCardNumber}
        placeholder="Card Number"
      />
      <TextInput
        value={expiry}
        onChangeText={setExpiry}
        placeholder="MM/YY"
      />
      <TextInput
        value={cvv}
        onChangeText={setCvv}
        placeholder="CVV"
      />

      <BillingAddressForm
        address={billingAddress}
        onChange={setBillingAddress}
      />  {/* Re-renders on every keystroke */}
    </View>
  )
}
```

**Correct (isolated state in focused components):**

```typescript
function CheckoutForm() {
  const [items] = useState(initialItems)

  return (
    <View>
      <OrderSummary items={items} />
      <ShippingOptions />
      <PaymentFields />  {/* Card inputs isolated here */}
      <BillingAddressSection />  {/* Address inputs isolated here */}
      <SubmitButton />
    </View>
  )
}

// Isolated component with its own state
function PaymentFields() {
  const [cardNumber, setCardNumber] = useState('')
  const [expiry, setExpiry] = useState('')
  const [cvv, setCvv] = useState('')

  return (
    <View>
      <TextInput
        value={cardNumber}
        onChangeText={setCardNumber}
        placeholder="Card Number"
      />
      <TextInput
        value={expiry}
        onChangeText={setExpiry}
        placeholder="MM/YY"
      />
      <TextInput
        value={cvv}
        onChangeText={setCvv}
        placeholder="CVV"
      />
    </View>
  )
}

function BillingAddressSection() {
  const [address, setAddress] = useState({})
  // Only this section re-renders when address changes
  return <BillingAddressForm address={address} onChange={setAddress} />
}
```

**Common state isolation patterns:**
- Search input with results list
- Timer/counter displays
- Form sections with validation
- Real-time updating values (prices, counts)

**Lift state up only when necessary:**
When components need to share state, lift it to the nearest common ancestor, not to the root.

### 6.7 Stabilize Callbacks with useCallback

**Impact: MEDIUM (prevents child re-renders from callback recreation)**

Wrap event handlers in `useCallback` when passing them to memoized children. Without this, new function references on every render break `React.memo`.

**Incorrect (new callback breaks child memo):**

```typescript
const SearchResult = memo(function SearchResult({ item, onSelect }) {
  return (
    <Pressable onPress={() => onSelect(item.id)}>
      <Text>{item.title}</Text>
    </Pressable>
  )
})

function SearchScreen() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  const navigation = useNavigation()

  const handleSelect = (id) => {
    navigation.navigate('Detail', { id })
  }  // New function every render - breaks memo

  return (
    <View>
      <TextInput value={query} onChangeText={setQuery} />
      {results.map(item => (
        <SearchResult
          key={item.id}
          item={item}
          onSelect={handleSelect}  // Always new reference
        />
      ))}
    </View>
  )
}
```

**Correct (stable callback with useCallback):**

```typescript
const SearchResult = memo(function SearchResult({ item, onSelect }) {
  return (
    <Pressable onPress={() => onSelect(item.id)}>
      <Text>{item.title}</Text>
    </Pressable>
  )
})

function SearchScreen() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  const navigation = useNavigation()

  const handleSelect = useCallback((id) => {
    navigation.navigate('Detail', { id })
  }, [navigation])  // Stable reference

  return (
    <View>
      <TextInput value={query} onChangeText={setQuery} />
      {results.map(item => (
        <SearchResult
          key={item.id}
          item={item}
          onSelect={handleSelect}
        />
      ))}
    </View>
  )
}
```

**Functional updates avoid dependencies:**

```typescript
// Instead of depending on count
const increment = useCallback(() => {
  setCount(count + 1)
}, [count])  // Recreated when count changes

// Use functional update - no dependency
const increment = useCallback(() => {
  setCount(c => c + 1)
}, [])  // Never recreated
```

**When to use useCallback:**
- Passing callbacks to memoized children
- Callbacks used in useEffect dependencies
- Callbacks stored in refs

**When NOT to use useCallback:**
- Callbacks only used locally
- Components that aren't memoized
- Simple components where re-render is cheap

Reference: [React useCallback Documentation](https://react.dev/reference/react/useCallback)

---

## 7. Animation Performance

**Impact: MEDIUM**

Smooth 60fps animations require running on the native UI thread. JS thread animations cause jank and dropped frames.

### 7.1 Defer Heavy Work During Animations with InteractionManager

**Impact: MEDIUM (maintains 60fps by deferring 100-500ms of JS work)**

Use `InteractionManager.runAfterInteractions` to schedule CPU-intensive work after animations and transitions complete. This ensures smooth 60fps animations.

**Incorrect (heavy work during navigation transition):**

```typescript
function ProductDetailScreen({ route }) {
  const { productId } = route.params
  const [relatedProducts, setRelatedProducts] = useState([])
  const [reviews, setReviews] = useState([])

  useEffect(() => {
    // Starts immediately, competes with navigation animation
    fetchRelatedProducts(productId).then(setRelatedProducts)
    fetchReviews(productId).then(setReviews)
    processAnalytics(productId)
  }, [productId])

  return <ProductDetailContent />
}
// Navigation transition stutters
```

**Correct (defers work until after transition):**

```typescript
import { InteractionManager } from 'react-native'

function ProductDetailScreen({ route }) {
  const { productId } = route.params
  const [relatedProducts, setRelatedProducts] = useState([])
  const [reviews, setReviews] = useState([])

  useEffect(() => {
    // Wait for navigation animation to complete
    const task = InteractionManager.runAfterInteractions(() => {
      fetchRelatedProducts(productId).then(setRelatedProducts)
      fetchReviews(productId).then(setReviews)
      processAnalytics(productId)
    })

    return () => task.cancel()
  }, [productId])

  return <ProductDetailContent />
}
// Smooth navigation, then data loads
```

**With loading states:**

```typescript
function ProductDetailScreen({ route }) {
  const { productId } = route.params
  const [isReady, setIsReady] = useState(false)
  const [data, setData] = useState(null)

  useEffect(() => {
    const task = InteractionManager.runAfterInteractions(async () => {
      const result = await fetchProductDetails(productId)
      setData(result)
      setIsReady(true)
    })

    return () => task.cancel()
  }, [productId])

  if (!isReady) {
    return <ProductDetailSkeleton />  // Show skeleton during animation
  }

  return <ProductDetailContent data={data} />
}
```

**Create custom interaction handles for long animations:**

```typescript
import { InteractionManager } from 'react-native'

function ComplexAnimation() {
  const startAnimation = () => {
    const handle = InteractionManager.createInteractionHandle()

    // Run your animation
    Animated.timing(value, { ... }).start(() => {
      // Clear handle when animation completes
      InteractionManager.clearInteractionHandle(handle)
    })
  }
}
```

Reference: [InteractionManager Documentation](https://reactnative.dev/docs/interactionmanager)

### 7.2 Enable useNativeDriver for Animated API

**Impact: MEDIUM (offloads animation to native thread, prevents JS thread blocking)**

When using React Native's built-in Animated API, always enable `useNativeDriver: true` to run animations on the native UI thread instead of the JavaScript thread.

**Incorrect (animation runs on JS thread):**

```typescript
import { Animated } from 'react-native'

function FadeInView({ children }) {
  const opacity = useRef(new Animated.Value(0)).current

  useEffect(() => {
    Animated.timing(opacity, {
      toValue: 1,
      duration: 300,
      // Missing useNativeDriver - runs on JS thread
    }).start()
  }, [])

  return <Animated.View style={{ opacity }}>{children}</Animated.View>
}
// Animation competes with JS work, may drop frames
```

**Correct (animation runs on native thread):**

```typescript
import { Animated } from 'react-native'

function FadeInView({ children }) {
  const opacity = useRef(new Animated.Value(0)).current

  useEffect(() => {
    Animated.timing(opacity, {
      toValue: 1,
      duration: 300,
      useNativeDriver: true,  // Runs on UI thread
    }).start()
  }, [])

  return <Animated.View style={{ opacity }}>{children}</Animated.View>
}
// Smooth animation regardless of JS thread activity
```

**Supported properties with useNativeDriver:**
- `opacity`
- `transform` (translateX, translateY, scale, rotate, etc.)

**Not supported (use Reanimated instead):**
- `width`, `height`
- `backgroundColor`
- `borderRadius`
- `margin`, `padding`
- Layout properties

**Parallel animations:**

```typescript
Animated.parallel([
  Animated.timing(opacity, {
    toValue: 1,
    duration: 300,
    useNativeDriver: true,
  }),
  Animated.spring(scale, {
    toValue: 1,
    useNativeDriver: true,
  }),
]).start()
```

**Note:** If you need to animate layout properties (height, width, position), use React Native Reanimated instead, which supports all style properties on the native thread.

Reference: [Animated API useNativeDriver](https://reactnative.dev/docs/animations#using-the-native-driver)

### 7.3 Prefer Transform Animations Over Layout Animations

**Impact: MEDIUM (avoids layout recalculation on every frame)**

Animating `transform` properties (translateX, scale, rotate) is significantly faster than animating layout properties (width, height, margin) because transforms don't trigger layout recalculation.

**Incorrect (animates layout properties):**

```typescript
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
} from 'react-native-reanimated'

function ExpandingCard() {
  const height = useSharedValue(100)

  const animatedStyle = useAnimatedStyle(() => ({
    height: height.value,  // Triggers layout recalculation
  }))

  const expand = () => {
    height.value = withTiming(300)
  }

  return (
    <Animated.View style={[styles.card, animatedStyle]}>
      <CardContent />
    </Animated.View>
  )
}
// Layout recalculates on every animation frame
```

**Correct (uses transform for visual effect):**

```typescript
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
} from 'react-native-reanimated'

function ExpandingCard() {
  const scale = useSharedValue(1)

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scaleY: scale.value }],  // No layout recalculation
  }))

  const expand = () => {
    scale.value = withTiming(1.5)
  }

  return (
    <Animated.View style={[styles.card, animatedStyle]}>
      <CardContent />
    </Animated.View>
  )
}
// GPU-accelerated, no layout work
```

**When layout animation is unavoidable, use LayoutAnimation:**

```typescript
import { LayoutAnimation, UIManager, Platform } from 'react-native'

// Enable on Android
if (Platform.OS === 'android') {
  UIManager.setLayoutAnimationEnabledExperimental?.(true)
}

function ExpandingList() {
  const [expanded, setExpanded] = useState(false)

  const toggleExpand = () => {
    LayoutAnimation.configureNext(LayoutAnimation.Presets.easeInEaseOut)
    setExpanded(!expanded)
  }

  return (
    <View style={{ height: expanded ? 300 : 100 }}>
      <ListContent />
    </View>
  )
}
```

**Performance hierarchy (fastest to slowest):**
1. `opacity` - GPU compositing only
2. `transform` - GPU transform matrix
3. `backgroundColor` - repaint (no layout)
4. `width/height` - full layout + repaint

Reference: [Reanimated Performance Guide](https://docs.swmansion.com/react-native-reanimated/docs/guides/performance/)

### 7.4 Use Gesture Handler with Reanimated for Gesture-Driven Animations

**Impact: MEDIUM (2-5× smoother gesture response via native thread execution)**

Combine React Native Gesture Handler with Reanimated for gesture-driven animations that run entirely on the native thread, avoiding JS thread roundtrips.

**Incorrect (JS-based gesture handling):**

```typescript
import { PanResponder, Animated, View } from 'react-native'

function DraggableCard() {
  const pan = useRef(new Animated.ValueXY()).current

  const panResponder = useRef(
    PanResponder.create({
      onMoveShouldSetPanResponder: () => true,
      onPanResponderMove: Animated.event(
        [null, { dx: pan.x, dy: pan.y }],
        { useNativeDriver: false }  // Can't use native driver with PanResponder
      ),
      onPanResponderRelease: () => {
        Animated.spring(pan, {
          toValue: { x: 0, y: 0 },
          useNativeDriver: true,
        }).start()
      },
    })
  ).current

  return (
    <Animated.View
      {...panResponder.panHandlers}
      style={{ transform: pan.getTranslateTransform() }}
    >
      <CardContent />
    </Animated.View>
  )
}
// Gesture events cross JS bridge, causing lag
```

**Correct (native gesture handling with Reanimated):**

```typescript
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated'
import { Gesture, GestureDetector } from 'react-native-gesture-handler'

function DraggableCard() {
  const translateX = useSharedValue(0)
  const translateY = useSharedValue(0)

  const gesture = Gesture.Pan()
    .onUpdate((event) => {
      translateX.value = event.translationX
      translateY.value = event.translationY
    })
    .onEnd(() => {
      translateX.value = withSpring(0)
      translateY.value = withSpring(0)
    })

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: translateX.value },
      { translateY: translateY.value },
    ],
  }))

  return (
    <GestureDetector gesture={gesture}>
      <Animated.View style={animatedStyle}>
        <CardContent />
      </Animated.View>
    </GestureDetector>
  )
}
// Entire gesture-animation pipeline on UI thread
```

**Installation:**

```bash
npx expo install react-native-gesture-handler
```

**Wrap app with GestureHandlerRootView:**

```typescript
import { GestureHandlerRootView } from 'react-native-gesture-handler'

export default function App() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <RootNavigator />
    </GestureHandlerRootView>
  )
}
```

Reference: [Gesture Handler Documentation](https://docs.swmansion.com/react-native-gesture-handler/)

### 7.5 Use Reanimated for UI Thread Animations

**Impact: MEDIUM (consistent 60fps vs 30-45fps with JS thread animations)**

React Native Reanimated runs animation logic on the UI thread using worklets, avoiding JS thread bottlenecks and achieving consistent 60fps even during heavy JS work.

**Incorrect (Animated API blocks on JS thread):**

```typescript
import { Animated, Pressable } from 'react-native'
import { useRef } from 'react'

function AnimatedCard() {
  const scale = useRef(new Animated.Value(1)).current

  const handlePressIn = () => {
    Animated.spring(scale, {
      toValue: 0.95,
      useNativeDriver: true,
    }).start()
  }

  const handlePressOut = () => {
    Animated.spring(scale, {
      toValue: 1,
      useNativeDriver: true,
    }).start()
  }

  return (
    <Pressable onPressIn={handlePressIn} onPressOut={handlePressOut}>
      <Animated.View style={{ transform: [{ scale }] }}>
        <CardContent />
      </Animated.View>
    </Pressable>
  )
}
// Limited to transform and opacity with useNativeDriver
```

**Correct (Reanimated with worklets):**

```typescript
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated'
import { Pressable } from 'react-native'

function AnimatedCard() {
  const scale = useSharedValue(1)

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }))

  const handlePressIn = () => {
    scale.value = withSpring(0.95)
  }

  const handlePressOut = () => {
    scale.value = withSpring(1)
  }

  return (
    <Pressable onPressIn={handlePressIn} onPressOut={handlePressOut}>
      <Animated.View style={animatedStyle}>
        <CardContent />
      </Animated.View>
    </Pressable>
  )
}
```

**Installation:**

```bash
npx expo install react-native-reanimated
```

```javascript
// babel.config.js
module.exports = function (api) {
  api.cache(true)
  return {
    presets: ['babel-preset-expo'],
    plugins: ['react-native-reanimated/plugin'],  // Must be last
  }
}
```

**Reanimated advantages:**
- Animate any style property (height, color, borderRadius)
- Synchronous gesture-driven animations
- Shared values between components
- Layout animations

Reference: [React Native Reanimated Documentation](https://docs.swmansion.com/react-native-reanimated/)

---

## 8. Memory Management

**Impact: LOW-MEDIUM**

Memory leaks compound over time, eventually causing app crashes and degraded performance on lower-end devices.

### 8.1 Abort Fetch Requests on Component Unmount

**Impact: LOW-MEDIUM (prevents state updates on unmounted components)**

Use AbortController to cancel in-flight fetch requests when components unmount. This prevents memory leaks and "setState on unmounted component" warnings.

**Incorrect (fetch continues after unmount):**

```typescript
function UserProfile({ userId }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const loadUser = async () => {
      setLoading(true)
      const response = await fetch(`/api/users/${userId}`)
      const data = await response.json()
      setUser(data)  // May update unmounted component
      setLoading(false)
    }

    loadUser()
  }, [userId])

  if (loading) return <LoadingSpinner />
  return <ProfileCard user={user} />
}
// If user navigates away quickly, setState called on unmounted component
```

**Correct (aborts fetch on unmount):**

```typescript
function UserProfile({ userId }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const abortController = new AbortController()

    const loadUser = async () => {
      setLoading(true)
      try {
        const response = await fetch(`/api/users/${userId}`, {
          signal: abortController.signal,
        })
        const data = await response.json()
        setUser(data)
        setLoading(false)
      } catch (error) {
        if (error.name !== 'AbortError') {
          console.error('Fetch failed:', error)
          setLoading(false)
        }
        // Ignore AbortError - expected on unmount
      }
    }

    loadUser()

    return () => abortController.abort()
  }, [userId])

  if (loading) return <LoadingSpinner />
  return <ProfileCard user={user} />
}
```

**With TanStack Query (handles automatically):**

```typescript
import { useQuery } from '@tanstack/react-query'

function UserProfile({ userId }) {
  const { data: user, isLoading } = useQuery({
    queryKey: ['user', userId],
    queryFn: async ({ signal }) => {
      const response = await fetch(`/api/users/${userId}`, { signal })
      return response.json()
    },
  })

  if (isLoading) return <LoadingSpinner />
  return <ProfileCard user={user} />
}
// TanStack Query handles abort automatically
```

**Custom hook for fetch with abort:**

```typescript
function useFetch(url) {
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    const controller = new AbortController()
    setLoading(true)

    fetch(url, { signal: controller.signal })
      .then(res => res.json())
      .then(setData)
      .catch(err => {
        if (err.name !== 'AbortError') setError(err)
      })
      .finally(() => setLoading(false))

    return () => controller.abort()
  }, [url])

  return { data, loading, error }
}
```

Reference: [AbortController MDN](https://developer.mozilla.org/en-US/docs/Web/API/AbortController)

### 8.2 Avoid Closure-Based Memory Leaks in Callbacks

**Impact: LOW-MEDIUM (prevents retained references to unmounted component state)**

Closures in callbacks can retain references to component state and props, preventing garbage collection even after unmount. Use refs for values needed in long-lived callbacks.

**Incorrect (closure retains entire component scope):**

```typescript
function NotificationHandler({ userId, onNotification }) {
  const [notifications, setNotifications] = useState([])

  useEffect(() => {
    const handleNotification = (notification) => {
      // Closure captures entire component scope
      console.log(`User ${userId} received:`, notification)
      setNotifications(prev => [...prev, notification])
      onNotification(notification)
    }

    const subscription = NotificationService.subscribe(handleNotification)

    return () => subscription.unsubscribe()
  }, [userId, onNotification])  // Recreated on every userId change

  return <NotificationList notifications={notifications} />
}
```

**Correct (refs for stable callback values):**

```typescript
function NotificationHandler({ userId, onNotification }) {
  const [notifications, setNotifications] = useState([])
  const userIdRef = useRef(userId)
  const onNotificationRef = useRef(onNotification)

  // Keep refs updated
  useEffect(() => {
    userIdRef.current = userId
  }, [userId])

  useEffect(() => {
    onNotificationRef.current = onNotification
  }, [onNotification])

  useEffect(() => {
    const handleNotification = (notification) => {
      // Refs don't cause recreation, minimal closure
      console.log(`User ${userIdRef.current} received:`, notification)
      setNotifications(prev => [...prev, notification])
      onNotificationRef.current(notification)
    }

    const subscription = NotificationService.subscribe(handleNotification)

    return () => subscription.unsubscribe()
  }, [])  // Stable effect, never recreated

  return <NotificationList notifications={notifications} />
}
```

**useLatest hook pattern:**

```typescript
function useLatest(value) {
  const ref = useRef(value)
  useEffect(() => {
    ref.current = value
  }, [value])
  return ref
}

function NotificationHandler({ userId, onNotification }) {
  const userIdRef = useLatest(userId)
  const onNotificationRef = useLatest(onNotification)

  useEffect(() => {
    const handleNotification = (notification) => {
      console.log(`User ${userIdRef.current} received:`, notification)
      onNotificationRef.current(notification)
    }

    const subscription = NotificationService.subscribe(handleNotification)
    return () => subscription.unsubscribe()
  }, [])

  // ...
}
```

**When to use this pattern:**
- Event listeners that outlive renders
- WebSocket message handlers
- Push notification callbacks
- Background task callbacks

### 8.3 Clean Up Subscriptions and Timers in useEffect

**Impact: LOW-MEDIUM (prevents memory leaks from orphaned listeners and timers)**

Always return a cleanup function from useEffect when creating subscriptions, timers, or event listeners. Failing to clean up causes memory leaks that compound over time.

**Incorrect (no cleanup, memory leak):**

```typescript
function LocationTracker() {
  const [location, setLocation] = useState(null)

  useEffect(() => {
    // Subscription never removed on unmount
    Location.watchPositionAsync(
      { accuracy: Location.Accuracy.High },
      (newLocation) => setLocation(newLocation)
    )
  }, [])

  return <MapView location={location} />
}
// Location updates continue after component unmounts
```

**Correct (cleanup on unmount):**

```typescript
function LocationTracker() {
  const [location, setLocation] = useState(null)

  useEffect(() => {
    let subscription

    const startTracking = async () => {
      subscription = await Location.watchPositionAsync(
        { accuracy: Location.Accuracy.High },
        (newLocation) => setLocation(newLocation)
      )
    }

    startTracking()

    return () => {
      subscription?.remove()  // Clean up on unmount
    }
  }, [])

  return <MapView location={location} />
}
```

**Timer cleanup:**

```typescript
function AutoRefresh({ onRefresh }) {
  useEffect(() => {
    const intervalId = setInterval(() => {
      onRefresh()
    }, 30000)

    return () => clearInterval(intervalId)  // Clean up timer
  }, [onRefresh])

  return null
}
```

**Event listener cleanup:**

```typescript
function KeyboardAwareView({ children }) {
  const [keyboardHeight, setKeyboardHeight] = useState(0)

  useEffect(() => {
    const showSubscription = Keyboard.addListener('keyboardDidShow', (e) => {
      setKeyboardHeight(e.endCoordinates.height)
    })
    const hideSubscription = Keyboard.addListener('keyboardDidHide', () => {
      setKeyboardHeight(0)
    })

    return () => {
      showSubscription.remove()
      hideSubscription.remove()
    }
  }, [])

  return <View style={{ paddingBottom: keyboardHeight }}>{children}</View>
}
```

**Common cleanup needs:**
- WebSocket connections
- Location/sensor subscriptions
- Keyboard listeners
- App state listeners
- setInterval/setTimeout
- Notification listeners

Reference: [useEffect Cleanup Documentation](https://react.dev/learn/synchronizing-with-effects#step-3-add-cleanup-if-needed)

### 8.4 Profile Memory Usage with Development Tools

**Impact: LOW-MEDIUM (prevents 10-100MB memory leaks from reaching production)**

Use React Native DevTools, Flipper, and Hermes profiling to identify memory leaks and excessive allocations before they cause production crashes.

**Incorrect (no memory monitoring, leaks ship to production):**

```typescript
function App() {
  // No memory profiling setup
  // Memory leaks accumulate undetected
  // Users experience crashes after prolonged use
  return <RootNavigator />
}
```

**Correct (proactive memory monitoring):**

```typescript
import { useEffect } from 'react'

function App() {
  useMemoryMonitor()  // Development-only memory tracking
  return <RootNavigator />
}

function useMemoryMonitor() {
  useEffect(() => {
    if (__DEV__ && global.HermesInternal) {
      const interval = setInterval(() => {
        const stats = global.HermesInternal.getHeapStatistics()
        console.log('Memory:', Math.round(stats.heapSize / 1024 / 1024) + 'MB')
      }, 5000)
      return () => clearInterval(interval)
    }
  }, [])
}
```

**Setup React Native DevTools:**

```bash
# Open DevTools from Metro terminal
j  # Press 'j' to open React Native DevTools

# Or use the command
npx react-native doctor
```

**Enable Performance Monitor overlay:**

```typescript
import { PerformanceMonitor } from 'react-native'

// In development, enable performance overlay
if (__DEV__) {
  // Shake device or Cmd+D to open menu
  // Select "Show Performance Monitor"
}
```

**Profile with Hermes:**

```typescript
// Take a heap snapshot
const Hermes = global.HermesInternal

if (Hermes) {
  // Enable sampling profiler
  Hermes.enableSamplingProfiler()

  // Later, capture profile
  const profile = Hermes.stopSamplingProfiler()
  console.log('Heap stats:', Hermes.getHeapStatistics())
}
```

**Memory monitoring in CI:**

```typescript
// Add to your app for memory tracking
function useMemoryMonitor() {
  useEffect(() => {
    if (__DEV__) {
      const interval = setInterval(() => {
        if (global.HermesInternal) {
          const stats = global.HermesInternal.getHeapStatistics()
          console.log('Memory:', {
            used: Math.round(stats.heapSize / 1024 / 1024) + 'MB',
            allocated: Math.round(stats.allocatedBytes / 1024 / 1024) + 'MB',
          })
        }
      }, 5000)

      return () => clearInterval(interval)
    }
  }, [])
}
```

**What to look for:**
| Issue | Symptom | Tool |
|-------|---------|------|
| Memory leak | Heap grows over time | Hermes heap snapshot |
| Excessive re-renders | High JS frame time | React Profiler |
| Large objects | Spikes in allocation | Memory timeline |
| Retained views | View count grows | Flipper Layout Inspector |

**Flipper plugins for memory:**
- LeakCanary (Android) - automatic leak detection
- Memory plugin - heap visualization
- React DevTools - component memory

**Pre-release checklist:**
1. Navigate through all screens multiple times
2. Monitor memory for growth
3. Force garbage collection and check for retained objects
4. Test with limited memory (Android emulator settings)

Reference: [React Native DevTools](https://reactnative.dev/docs/react-native-devtools)

### 8.5 Release Heavy Resources When Not Needed

**Impact: LOW-MEDIUM (50-200MB memory freed when releasing camera/video/maps)**

Explicitly release camera, video players, maps, and other heavy native resources when components are hidden or backgrounded. These don't automatically garbage collect.

**Incorrect (camera stays active when hidden):**

```typescript
function CameraScreen() {
  const [hasPermission, setHasPermission] = useState(null)

  useEffect(() => {
    Camera.requestCameraPermissionsAsync().then(({ status }) => {
      setHasPermission(status === 'granted')
    })
  }, [])

  if (!hasPermission) return <PermissionRequest />

  return (
    <Camera style={styles.camera} type={Camera.Constants.Type.back}>
      <CameraOverlay />
    </Camera>
  )
}
// Camera continues running when navigating away
```

**Correct (release camera when not visible):**

```typescript
import { useFocusEffect } from '@react-navigation/native'

function CameraScreen() {
  const [hasPermission, setHasPermission] = useState(null)
  const [isFocused, setIsFocused] = useState(true)

  useEffect(() => {
    Camera.requestCameraPermissionsAsync().then(({ status }) => {
      setHasPermission(status === 'granted')
    })
  }, [])

  useFocusEffect(
    useCallback(() => {
      setIsFocused(true)
      return () => setIsFocused(false)  // Release when screen loses focus
    }, [])
  )

  if (!hasPermission) return <PermissionRequest />
  if (!isFocused) return <View style={styles.camera} />  // Placeholder

  return (
    <Camera style={styles.camera} type={Camera.Constants.Type.back}>
      <CameraOverlay />
    </Camera>
  )
}
```

**Video player resource management:**

```typescript
import { useVideoPlayer, VideoView } from 'expo-video'
import { useFocusEffect } from '@react-navigation/native'

function VideoScreen({ videoUrl }) {
  const player = useVideoPlayer(videoUrl)

  useFocusEffect(
    useCallback(() => {
      // Resume when focused
      player.play()

      return () => {
        // Pause and release when unfocused
        player.pause()
      }
    }, [player])
  )

  return <VideoView player={player} style={styles.video} />
}
```

**App state handling for background:**

```typescript
import { AppState } from 'react-native'

function MediaPlayer({ source }) {
  const playerRef = useRef(null)
  const appState = useRef(AppState.currentState)

  useEffect(() => {
    const subscription = AppState.addEventListener('change', (nextAppState) => {
      if (appState.current === 'active' && nextAppState.match(/inactive|background/)) {
        playerRef.current?.pause()
      }
      appState.current = nextAppState
    })

    return () => subscription.remove()
  }, [])

  return <Video ref={playerRef} source={source} />
}
```

**Heavy resources to manage:**
- Camera preview
- Video players
- Audio sessions
- Map views
- WebGL contexts
- Large image caches

Reference: [Expo Camera Documentation](https://docs.expo.dev/versions/latest/sdk/camera/)

---

## References

1. [https://reactnative.dev/docs/performance](https://reactnative.dev/docs/performance)
2. [https://docs.expo.dev](https://docs.expo.dev)
3. [https://expo.dev/blog/best-practices-for-reducing-lag-in-expo-apps](https://expo.dev/blog/best-practices-for-reducing-lag-in-expo-apps)
4. [https://www.callstack.com/ebooks/the-ultimate-guide-to-react-native-optimization](https://www.callstack.com/ebooks/the-ultimate-guide-to-react-native-optimization)
5. [https://docs.swmansion.com/react-native-reanimated/docs/guides/performance/](https://docs.swmansion.com/react-native-reanimated/docs/guides/performance/)
6. [https://shopify.github.io/flash-list/](https://shopify.github.io/flash-list/)
7. [https://reactnative.dev/blog/2024/10/23/the-new-architecture-is-here](https://reactnative.dev/blog/2024/10/23/the-new-architecture-is-here)