---
title: Return an opaque some type instead of spelling nested generic compositions
tags: api, opaque-types, generics, return-types
---

## Return an opaque some type instead of spelling nested generic compositions

The wrong default when a function's return value is built by composing generic wrappers is spelling the full nesting in the signature — `CustomizedEquipment<QualityCheckedEquipment<SoccerBall>>` — which couples every caller to the implementation's composition order, so any refactor of the pipeline is a source-breaking change. Reaching for existential `any P` instead trades that for boxing and dynamic dispatch. `some P` hides the composition behind the protocol, keeps static dispatch, and lets the body reorder wrappers freely.

**Evidence of violation:** a function signature whose return type is a generic type nested two or more levels deep at a module or library boundary, or a return type of `any P` where every `return` statement in the body yields the same concrete conforming type. PASS: composed returns are `some P`, or the concrete type is shallow and callers use its concrete API. N/A: callers verifiably need the concrete type's extra members, or different return paths produce different types (an opaque type requires one underlying type).

**Incorrect (the signature leaks the composition — reordering wrappers breaks callers):**

```swift
protocol Equipment {
    var description: String { get }
}

struct SoccerBall: Equipment {
    var description: String {
        "Soccer ball"
    }
}

struct CustomizedEquipment<T: Equipment>: Equipment {
    var baseEquipment: T
    var description: String {
        "Customized \(baseEquipment.description)"
    }
}

struct QualityCheckedEquipment<T: Equipment>: Equipment {
    var baseEquipment: T
    var description: String {
        "Quality checked \(baseEquipment.description)"
    }
}

func produceHighQualityCustomizedBall(
) -> CustomizedEquipment<QualityCheckedEquipment<SoccerBall>> {
    let qualityCheckedBall = QualityCheckedEquipment(
        baseEquipment: SoccerBall()
    )
    return CustomizedEquipment(baseEquipment: qualityCheckedBall)
}
```

**Correct (the opaque type hides the composition and keeps static dispatch):**

```swift
protocol Equipment {
    var description: String { get }
}

struct SoccerBall: Equipment {
    var description: String {
        "Soccer ball"
    }
}

struct CustomizedEquipment<T: Equipment>: Equipment {
    var baseEquipment: T
    var description: String {
        "Customized \(baseEquipment.description)"
    }
}

struct QualityCheckedEquipment<T: Equipment>: Equipment {
    var baseEquipment: T
    var description: String {
        "Quality checked \(baseEquipment.description)"
    }
}

func produceHighQualityCustomizedBall() -> some Equipment {
    let qualityCheckedBall = QualityCheckedEquipment(
        baseEquipment: SoccerBall()
    )
    return CustomizedEquipment(baseEquipment: qualityCheckedBall)
}
```
