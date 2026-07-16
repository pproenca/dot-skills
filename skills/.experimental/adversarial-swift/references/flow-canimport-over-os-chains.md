---
title: Gate framework-dependent code with canImport, not os() chains
tags: flow, conditional-compilation, canimport, cross-platform
---

## Gate framework-dependent code with canImport, not os() chains

The wrong default for code whose real dependency is a framework's presence is `#if os(iOS) || os(tvOS) ...` — a hand-maintained platform list. The list silently rots: when the framework arrives on a new platform (or the code moves to visionOS or Catalyst), the hand-listed chain excludes it or breaks the build. `#if canImport(Framework)` tracks the actual dependency automatically.

**Evidence of violation:** an `#if os(...)` condition (single or chained) whose guarded block's distinguishing content is an `import` of, or API usage from, one specific framework — the branch exists because the framework exists there, not because platform behavior differs. PASS: framework-presence branches use `#if canImport(...)`. N/A: the branch encodes genuine platform behavior differences (UI idiom, hardware capability, API divergence within a framework importable on both sides), or the target has no conditional compilation.

**Incorrect (hand-listed platforms — silently wrong when the framework's platform set changes):**

```swift
#if os(iOS) || os(macOS)
import CoreHaptics

class HapticFeedbackManager {
    func triggerHapticFeedback() {
        // CoreHaptics implementation
        print("Haptic feedback triggered.")
    }
}

#else

class HapticFeedbackManager {
    func triggerHapticFeedback() {
        // Non-CoreHaptics implementation or a simple message
        print("CoreHaptics not available. Feedback not triggered.")
    }
}

#endif
```

**Correct (the condition tracks the dependency itself):**

```swift
#if canImport(CoreHaptics)
import CoreHaptics

class HapticFeedbackManager {
    func triggerHapticFeedback() {
        // CoreHaptics implementation
        print("Haptic feedback triggered.")
    }
}

#else

class HapticFeedbackManager {
    func triggerHapticFeedback() {
        // Non-CoreHaptics implementation or a simple message
        print("CoreHaptics not available. Feedback not triggered.")
    }
}

#endif

let hapticManager = HapticFeedbackManager()
hapticManager.triggerHapticFeedback()
```
