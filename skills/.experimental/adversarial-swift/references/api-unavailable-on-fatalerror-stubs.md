---
title: Mark fatalError-only overrides unavailable so misuse fails at compile time
tags: api, availability, inheritance, fatalerror
---

## Mark fatalError-only overrides unavailable so misuse fails at compile time

The wrong default when a subclass inherits a member that must never be used — most commonly the Xcode fix-it stub `required init?(coder:) { fatalError("init(coder:) has not been implemented") }` — is leaving the trap as the only guard, so misuse compiles cleanly and crashes at runtime. Adding `@available(*, unavailable, message:)` to the same declaration turns the crash into a compile-time error carrying the explanation.

**Evidence of violation:** an `override` or `required` member whose body consists only of a `fatalError`/`preconditionFailure` trap (or a `super` call plus trap) and whose declaration lacks `@available(*, unavailable, ...)`. PASS: every trap-only inherited member carries the attribute, or no such stubs exist because the inherited members are genuinely implemented. N/A: the target declares no subclass overrides at all.

**Incorrect (the stub compiles at call sites and crashes at runtime):**

```swift
class Membership {
    func renew() {
        // Generic renewal process
    }
}

class LifetimeMembership: Membership {
    override func renew() {
        fatalError("Lifetime memberships do not require renewal.")
    }
}
```

**Correct (the attribute turns misuse into a compile-time error with a message):**

```swift
class Membership {
    func renew() {
        // Generic renewal process
    }
}

class LifetimeMembership: Membership {
    @available(
        *, unavailable,
        message: "Lifetime memberships do not require renewal."
    )
    override func renew() {
        super.renew()
    }
}
```

**Correct (the same pattern bans storyboard initialization of a code-only view):**

```swift
#if canImport(UIKit)
import UIKit

final class CustomView: UIView {
    @available(
        *, unavailable,
        message: """
        CustomView is not designed \
        to be initialized from a storyboard.
        """
    )
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(customParameter: [Int]) {
        // Custom initialization logic
        super.init(frame: .zero)
        // Additional setup using customParameter
    }
}
#endif
```
