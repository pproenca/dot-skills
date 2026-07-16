---
title: Make new helper classes final or file-scoped to enable static dispatch
tags: api, final, access-control, dispatch
---

## Make new helper classes final or file-scoped to enable static dispatch

The wrong default when introducing a helper class is the bare `class Foo` — implicitly internal and non-final — which keeps every method call dynamically dispatched through the vtable even though nothing subclasses it. Marking the class `final`, `private`, or `fileprivate` lets the compiler devirtualize calls, inline bodies, and access fields directly; the bare form gives up those optimizations for an extensibility no one uses.

**Evidence of violation:** a `class` introduced by the reviewed change that is neither `final` nor `private`/`fileprivate` nor `open`, has no subclass anywhere in the reviewed file set, and carries no overridable-member design markers (no `open` members, no documentation describing subclassing). PASS: new classes are `final` (or file-scoped), or every non-final class has a visible subclass or inheritance-oriented design. N/A: classes declared `open` or documented for inheritance, classes subclassed anywhere in the artifact, base classes with a test double (a Mock/Spy/Stub subclass) visible in the file set, and pre-existing classes the change merely touches.

**Incorrect (implicitly internal and non-final — every call stays virtual):**

```swift
class VehicleManager {
    private var vehicleCount = 0

    func addVehicle() {
        vehicleCount += 1
    }
}

let manager = VehicleManager()

// Dynamically dispatched call through the vtable
manager.addVehicle()
```

**Correct (file-scoped visibility lets the compiler devirtualize):**

```swift
private class VehicleManager {
    private var vehicleCount = 0

    func addVehicle() {
        vehicleCount += 1
    }
}

private let manager = VehicleManager()

// Devirtualized call
manager.addVehicle()
```

**Alternative (public API that forbids subclassing):** declare the class `final` instead of restricting visibility — `final class VehicleManager` — when the type must stay visible outside the file but is not designed for inheritance.
