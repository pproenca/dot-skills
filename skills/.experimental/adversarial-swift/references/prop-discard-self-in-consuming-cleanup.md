---
title: End consuming cleanup methods with discard self
tags: prop, noncopyable, consuming, deinit
---

## End consuming cleanup methods with discard self

On a `~Copyable` type that owns cleanup in `deinit`, the wrong default is writing a `consuming` teardown method that performs the same cleanup and simply ends — `deinit` still runs when the consumed value's lifetime closes, so the resource is released twice (double close, double free, duplicate notification) with no compiler diagnostic. `discard self` at the end of the consuming method suppresses the `deinit` call for that path, making the method the single point of cleanup.

**Evidence of violation:** a `~Copyable` type declaring both a `deinit` containing cleanup logic and a `consuming` method with overlapping cleanup logic, where the consuming method does not end with `discard self`. All three shapes — the `deinit`, the `consuming` method, the missing `discard` — are syntactically checkable. When the stored properties are not trivially destroyable, `discard self` is not expressible; the double-cleanup shape still FAILs, and the fix is consolidating the cleanup in exactly one place. PASS: every consuming method that duplicates `deinit` cleanup ends in `discard self`, or cleanup exists in only one of the two places. N/A: the type has no `deinit`, has no `consuming` method, or the toolchain predates Swift 5.9 (`~Copyable`/`consuming`/`discard`).

**Incorrect (invalidate cleans up, then deinit cleans up again — double release):**

```swift
struct SingleUseTicket: ~Copyable {
    let ticketID: Int

    consuming func invalidate() {
        print("Ticket \(ticketID) invalidated.")
        // deinit still runs after this method — cleanup executes twice
    }

    deinit {
        print("Ticket \(ticketID) deinitialized.")
    }
}

func processTicket() {
    let ticket = SingleUseTicket(ticketID: 42)
    ticket.invalidate()
}
```

**Correct (discard self suppresses deinit on the consumed path):**

```swift
struct SingleUseTicket: ~Copyable {
    let ticketID: Int

    consuming func invalidate() {
        print("Ticket \(ticketID) invalidated.")
        discard self
    }

    deinit {
        print("Ticket \(ticketID) deinitialized.")
    }
}

func processTicket() {
    let ticket = SingleUseTicket(ticketID: 42)
    ticket.invalidate()
}
```
