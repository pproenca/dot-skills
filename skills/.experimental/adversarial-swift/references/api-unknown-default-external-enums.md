---
title: Use @unknown default when switching over enums from other modules
tags: api, enums, unknown-default, source-compatibility
---

## Use @unknown default when switching over enums from other modules

The wrong default is writing a plain `default:` when switching over an enum declared in an SDK, framework, or dependency. A regular `default` passively covers every case the library adds in the future, forever, with no diagnostic — the new case silently falls into the fallback branch. `@unknown default` handles the same cases at runtime but prompts the compiler to warn when the library introduces cases the switch does not list, so the handling code gets reviewed instead of silently absorbing them.

**Evidence of violation:** a `switch` over an enum declared outside the reviewed module (Foundation, UIKit, SwiftUI, a package dependency) whose fallback case is `default:` instead of `@unknown default:`. PASS when the fallback is `@unknown default:`, or when every case is listed explicitly with no fallback. N/A for switches over enums declared in the same module — the compiler already enforces exhaustiveness there, and `@unknown default` adds nothing.

**Incorrect (new library cases are absorbed silently, no warning ever fires):**

```swift
import Foundation

func displayName(for component: Calendar.Component) -> String {
    switch component {
    case .year: return "Year"
    case .month: return "Month"
    case .day: return "Day"
    default:
        return "Unknown Component"
    }
}
```

**Correct (compiler warns when Foundation adds a case this switch does not list):**

```swift
import Foundation

func displayName(for component: Calendar.Component) -> String {
    switch component {
    case .year: return "Year"
    case .month: return "Month"
    case .day: return "Day"
    @unknown default:
        return "Unknown Component"
    }
}
```

Reference: expert Swift reference (2025), “Explicitly handle potential future enum cases”
