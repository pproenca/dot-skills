---
title: Place Actions in Toolbars Using Standard Placements
impact: HIGH
impactDescription: correct toolbar placement matches 95%+ of Apple's own apps — misplacement confuses users who expect consistent positions
tags: nav, toolbar, placement, actions, navigation-bar
---

## Place Actions in Toolbars Using Standard Placements

Toolbars organize actions in predictable positions. Use standard placements so users find controls where they expect them. Don't put primary actions in unexpected locations.

**Incorrect (actions in wrong positions):**

```swift
NavigationStack {
    ContentView()
        .toolbar {
            // Cancel in wrong position
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cancel") { dismiss() }
            }
            // Save in wrong position
            ToolbarItem(placement: .topBarLeading) {
                Button("Save") { save() }
            }
        }
}
```

**Correct (standard toolbar placements):**

```swift
NavigationStack {
    ContentView()
        .navigationTitle("New Item")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
            }
        }
}
```

**Standard placement conventions:**
| Placement | Usage | Position |
|-----------|-------|----------|
| `.cancellationAction` | Cancel, Close | Leading |
| `.confirmationAction` | Save, Done | Trailing |
| `.primaryAction` | Main action | Trailing |
| `.destructiveAction` | Delete | Varies |
| `.bottomBar` | Frequent actions | Bottom |
| `.keyboard` | Input helpers | Above keyboard |

Reference: [Toolbars - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/toolbars)
