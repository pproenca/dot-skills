---
title: Gate framework usage with canImport rather than os() checks
tags: api, conditional-compilation, canimport, cross-platform
---

## Gate framework usage with canImport rather than os() checks

The wrong default is gating a framework's import and usage behind platform checks — `#if os(iOS) || os(tvOS)` — which hardcodes today's platform matrix. When Apple ships the framework on a new platform, the os() chain silently keeps the feature disabled there until someone updates every check. `#if canImport(Framework)` asks the actual question — is this framework present? — so the code stays compatible as platforms evolve, without requiring updates.

**Evidence of violation:** an `#if os(...)` condition (possibly an OR-chain of platforms) whose guarded content is a framework `import` plus code using that framework, where the condition exists to track the framework's availability. PASS when the guard is `#if canImport(Framework)`. N/A when the `os()` check gates genuinely platform-specific behavior — a UI idiom, hardware capability, or platform-divergent API shape — rather than framework presence; the N/A claim must point at guarded content that is not framework-availability tracking.

**Incorrect (silently stays disabled when the framework reaches a new platform):**

```swift
#if os(iOS) || os(tvOS)
import CoreHaptics

class HapticFeedbackManager {
    func triggerHapticFeedback() {
        print("Haptic feedback triggered.")
    }
}
#else
class HapticFeedbackManager {
    func triggerHapticFeedback() {
        print("Haptics not available.")
    }
}
#endif
```

**Correct (tracks framework presence itself, no update needed as platforms evolve):**

```swift
#if canImport(CoreHaptics)
import CoreHaptics

class HapticFeedbackManager {
    func triggerHapticFeedback() {
        print("Haptic feedback triggered.")
    }
}
#else
class HapticFeedbackManager {
    func triggerHapticFeedback() {
        print("Haptics not available.")
    }
}
#endif
```

Reference: expert Swift reference (2025), “Tackle framework availability with compiler directives”
