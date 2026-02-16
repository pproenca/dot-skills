---
title: Place Toolbar Items in the Correct Semantic Positions
impact: HIGH
impactDescription: toolbar items in wrong positions violate muscle memory from every other iOS app — users expect Cancel on the left and Done on the right, and reversing this causes 10-15% more wrong-button taps
tags: converse, toolbar, placement, kocienda-demo, edson-conversation, navigation
---

## Place Toolbar Items in the Correct Semantic Positions

Edson's conversation principle recognizes that toolbar placement is a language. Users have learned from thousands of iOS interactions that Cancel lives on the left and Done/Save lives on the right. This isn't a design preference — it's a protocol that Kocienda's team established and every Apple app reinforces. Placing actions in unexpected positions breaks the conversation's grammar.

**Incorrect (actions in wrong positions):**

```swift
struct ComposeView: View {
    var body: some View {
        Form { /* fields */ }
            .toolbar {
                // Done on the left, Cancel on the right — backwards
                ToolbarItem(placement: .topBarLeading) {
                    Button("Send") { send() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { cancel() }
                }
            }
    }
}
```

**Correct (semantic toolbar placements):**

```swift
struct ComposeView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form { /* fields */ }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") { send() }
                }
            }
    }
}
```

**Semantic placement guide:**
| Placement | Position | Usage |
|-----------|----------|-------|
| `.cancellationAction` | Leading | Cancel, Close |
| `.confirmationAction` | Trailing | Save, Done, Send |
| `.primaryAction` | Trailing (prominent) | Main action button |
| `.destructiveAction` | Varies | Delete (use sparingly) |
| `.navigationBarLeading` | Leading | Custom leading items |
| `.navigationBarTrailing` | Trailing | Custom trailing items |
| `.bottomBar` | Bottom toolbar | Secondary actions |
| `.keyboard` | Above keyboard | Input accessories |

**Bottom toolbar for multi-action screens:**

```swift
.toolbar {
    ToolbarItemGroup(placement: .bottomBar) {
        Button { archive() } label: {
            Image(systemName: "archivebox")
        }
        Spacer()
        Button { reply() } label: {
            Image(systemName: "arrowshape.turn.up.left")
        }
        Spacer()
        Button { delete() } label: {
            Image(systemName: "trash")
        }
    }
}
```

**When NOT to use toolbar:** For actions that are part of the content (like/favorite buttons, inline actions), place them in the view hierarchy, not the toolbar.

Reference: [Toolbars - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/toolbars)
