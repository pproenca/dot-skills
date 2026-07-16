---
title: Close switches over external enums with @unknown default
tags: enum, switch-exhaustiveness, library-evolution, unknown-default
---

## Close switches over external enums with @unknown default

The wrong default when switching over an enum from another module — Foundation, UIKit, a third-party SDK — is to match the cases of interest and close the switch with a bare `default:`. That clause silently swallows every case the library adds in a future version: the code keeps compiling, the new case falls into the generic branch, and nobody is ever told to review the handling. `@unknown default` keeps the same runtime fallback but makes the compiler emit a warning the moment the library's case list grows, so the gap gets a human decision instead of silence.

**Evidence of violation:** a `switch` over an enum declared outside the current module (the type arrives via an `import`) that matches at least one case individually and terminates with `default:` instead of `@unknown default:`. PASS: the switch ends with `@unknown default:`, or lists every case with no default at all (the compiler then enforces exhaustiveness directly). N/A: the enum is declared in the same module or target under review, the enum is `@frozen`, or the switch matches no individual cases (a pure default dispatch expresses "any value" intentionally).

**Incorrect (a bare default absorbs future Calendar.Component cases with no diagnostic):**

```swift
import Foundation

func displayName(for component: Calendar.Component) -> String {
    switch component {
    case .year:
        return "Year"
    case .month:
        return "Month"
    case .day:
        return "Day"
    default:
        return "Unknown Component"
    }
}
```

**Correct (the compiler warns when a new case appears, keeping the fallback reviewable):**

```swift
import Foundation

func displayName(for component: Calendar.Component) -> String {
    switch component {
    case .year:
        return "Year"
    case .month:
        return "Month"
    case .day:
        return "Day"
    // Explicitly handle other known cases...
    @unknown default:
        // Log and handle any unexpected cases gracefully
        print("A new Calendar.Component case has been introduced.")
        return "Unknown Component"
    }
}
```
