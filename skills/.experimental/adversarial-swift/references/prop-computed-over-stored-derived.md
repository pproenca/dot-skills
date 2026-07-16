---
title: Derive related values with computed properties instead of parallel stored copies
tags: prop, computed-properties, invariants, synchronization
---

## Derive related values with computed properties instead of parallel stored copies

The wrong default is storing a derived value (a `diameter` next to its `radius`, a `total` next to its line items) as a second stored property and re-synchronizing it by hand at every write site. The copies drift the moment one write site forgets the companion update — a silent invariant break with no diagnostic anywhere. A computed property makes desynchronization structurally impossible: the derived value is recomputed from the single source of truth on every read, and a setter routes writes back to that source.

**Evidence of violation:** two or more stored properties in one type where one is a pure function of the other(s) — every assignment of it in the artifact recomputes it from its companions (the tell is paired assignments like `radius = r; diameter = r * 2` at each write site), with no independent writes anywhere. PASS: derived values are computed properties (with a setter when writes must flow back), or only one source-of-truth property is stored. N/A: the stored copy is a deliberate cache of an expensive derivation with explicit invalidation, or no property in the target is derivable from another.

**Incorrect (both values stored — one forgotten update desynchronizes them):**

```swift
class Circle {
    var radius: Double
    var diameter: Double

    init(radius: Double) {
        self.radius = radius
        self.diameter = radius * 2
    }

    func setRadius(_ newRadius: Double) {
        radius = newRadius
        diameter = newRadius * 2
    }

    func setDiameter(_ newDiameter: Double) {
        diameter = newDiameter
        // radius was not updated — area and circumference now disagree
    }

    var area: Double {
        return Double.pi * radius * radius
    }

    var circumference: Double {
        return Double.pi * diameter
    }
}
```

**Correct (one stored source of truth, the rest derived on demand):**

```swift
class Circle {
    var radius: Double

    init(radius: Double) {
        self.radius = radius
    }

    // Computed property for diameter with getter and setter
    var diameter: Double {
        get {
            return radius * 2
        }
        set(newDiameter) {
            radius = newDiameter / 2
        }
    }

    var area: Double {
        return Double.pi * radius * radius
    }

    var circumference: Double {
        return Double.pi * diameter
    }
}
```
