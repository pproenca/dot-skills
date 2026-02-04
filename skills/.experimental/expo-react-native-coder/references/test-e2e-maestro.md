---
title: Use Maestro for E2E Testing
impact: MEDIUM
impactDescription: reduces E2E test setup time by 90%
tags: test, e2e, maestro, automation
---

## Use Maestro for E2E Testing

Use Maestro for end-to-end testing. It's recommended by Expo and integrates with EAS Workflows.

**Incorrect (Detox with complex native setup):**

```javascript
// detox.config.js - Requires native build configuration
module.exports = {
  testRunner: 'jest',
  runnerConfig: 'e2e/config.json',
  apps: {
    'ios.debug': {
      type: 'ios.app',
      binaryPath: 'ios/build/Build/Products/Debug-iphonesimulator/MyApp.app',
      build: 'xcodebuild -workspace ios/MyApp.xcworkspace -scheme MyApp...',
    },
  },
  // 50+ more lines of configuration needed
};
// Detox tests are flaky and hard to maintain
```

**Correct (Maestro with simple YAML):**

```bash
curl -Ls "https://get.maestro.mobile.dev" | bash
maestro --version
```

```yaml
# e2e/login.yaml
appId: com.company.myapp
---
- launchApp
- tapOn: "Email"
- inputText: "test@example.com"
- tapOn: "Password"
- inputText: "password123"
- tapOn: "Sign In"
- assertVisible: "Welcome"
```

```yaml
# e2e/create-post.yaml
appId: com.company.myapp
---
- launchApp
- runFlow: login.yaml
- tapOn: "Create"
- tapOn: "Title"
- inputText: "My Test Post"
- tapOn: "Submit"
- assertVisible: "My Test Post"
```

```bash
maestro test e2e/login.yaml
maestro test e2e/
```

Reference: [E2E tests with Maestro - Expo Documentation](https://docs.expo.dev/build-reference/e2e-tests/)
