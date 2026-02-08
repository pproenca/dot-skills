---
title: Test with TestFlight Before Release
impact: LOW
impactDescription: real device testing, gather beta feedback, catch issues before App Store
tags: dist, distribution, testflight, beta, testing
---

## Test with TestFlight Before Release

TestFlight lets you distribute beta builds to testers before App Store release. Upload builds from Xcode, invite testers, and collect crash reports and feedback.

**Incorrect (skipping beta testing):**

```swift
// Don't ship directly to App Store without testing
// Problems you'll miss:
// - Device-specific crashes
// - Network edge cases
// - User flow confusion
// - Accessibility issues
// - Battery/performance problems on older devices
```

**TestFlight workflow:**

1. **Archive your app:**
   - Product > Archive in Xcode
   - Validate the archive

2. **Upload to App Store Connect:**
   - Distribute App > App Store Connect
   - Upload completes in Organizer

3. **Configure TestFlight:**
   - Set What to Test notes
   - Add internal testers (up to 100)
   - Add external testers (up to 10,000)

4. **Testers receive:**
   - Email invitation
   - Install via TestFlight app
   - Submit feedback and crash reports

**Code considerations:**

```swift
// Detect TestFlight vs App Store
#if DEBUG
let isTestFlight = false
#else
let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
#endif

// Show beta features only in TestFlight
if isTestFlight {
    Text("Beta Feature")
}

// Provide feedback mechanism
Button("Send Feedback") {
    // Open feedback form or email
}
```

**TestFlight benefits:**
- Test on real devices and networks
- Automatic crash reporting
- Built-in feedback screenshots
- 90-day build expiration
- No App Review for internal testers

Reference: [Develop in Swift Tutorials - Test your beta app](https://developer.apple.com/tutorials/develop-in-swift/test-your-beta-app)
