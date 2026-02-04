---
title: Use Development Builds Instead of Expo Go for Production Apps
impact: HIGH
impactDescription: enables custom native modules and full feature access
tags: setup, development-build, expo-go, native-modules
---

## Use Development Builds Instead of Expo Go for Production Apps

Expo Go is a sandbox for prototyping but cannot use custom native modules. Development builds are your own version of Expo Go with full native code access.

**Incorrect (relying on Expo Go for production app development):**

```bash
# Limited to Expo Go's bundled native modules
npx expo start
# Then scan QR code with Expo Go app
```

**Correct (create a development build):**

```bash
# Install expo-dev-client
npx expo install expo-dev-client

# Create development build for simulator
eas build --profile development --platform ios

# Or build locally
npx expo run:ios
npx expo run:android

# Start development server
npx expo start --dev-client
```

**When to switch from Expo Go:**

- Adding libraries with native code (e.g., `react-native-maps`)
- Customizing native configuration
- Testing push notifications
- Testing deep links and universal links
- Any production-bound project

Reference: [Expo Go vs Development Builds - Expo Documentation](https://docs.expo.dev/develop/development-builds/introduction/)
