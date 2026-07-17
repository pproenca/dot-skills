---
title: Animate user-visible structural state changes
tags: motion, withanimation, transition, state-changes
---

## Animate user-visible structural state changes

The wrong default is mutating state so that views appear, disappear, resize, or reorder with no animation at all — content teleports into place, and the screen reads as a page refresh rather than a change the user caused. iOS communicates cause and effect through motion: the HIG asks for feedback motion that follows people's gestures and expectations, and SwiftUI's sanctioned mechanism is a `withAnimation` block around the mutation (or `.animation(_, value:)` / `.transition(_:)` on the affected views). A structural change that snaps is not a style choice; it is missing feedback.

**Evidence of violation:** a filmstrip of the recorded interaction in which the structural change — views appearing, disappearing, resizing, or reordering — is complete between two adjacent tiles with no intermediate geometry: the content teleports. Cite the filmstrip tiles and the mutation site in code (button action, `.onChange` handler, gesture callback, task completion). Code alone cannot FAIL this rule: an unwrapped mutation — one that toggles `if`/`switch` view presence, inserts/removes/reorders a `ForEach` data source, or changes a layout-affecting value with no `withAnimation { … }`, `.animation(_, value:)`, or `.transition(_:)` on any path to the render — is a **candidate**; when no recording covers that interaction, report it as N/A with the reason "recording evidence unavailable — candidate at file:line", never FAIL. PASS: the filmstrip shows intermediate frames between initiation and settle, or every candidate mutation site carries one of the animation mechanisms — cite the tiles or the mechanism. N/A: the only structural changes are navigation pushes, sheet or full-screen-cover presentations (the system animates those), or pure text-content changes that do not alter view structure — the reviewer must cite the system-animated or text-only nature of every change to claim this; absent that evidence, fail closed. N/A: the mutation path is guarded for Reduce Motion and deliberately skips animation — the guard must be cited. The fix is one `withAnimation` at the cited mutation site — never a sweep of animation modifiers across the target.

**Incorrect (completed habits vanish with a snap, so the reorder reads as a glitch):**

```swift
import SwiftUI

struct Habit: Identifiable {
    let id = UUID()
    var name = ""
    var isDone = false
}

struct HabitListView: View {
    @State private var habits: [Habit]
    @State private var hidesCompleted = false

    init(habits: [Habit]) {
        self.habits = habits
    }

    var visibleHabits: [Habit] {
        hidesCompleted ? habits.filter { !$0.isDone } : habits
    }

    var body: some View {
        List {
            Toggle("Hide Completed", isOn: $hidesCompleted)
            ForEach(visibleHabits) { habit in
                Text(habit.name)
            }
        }
        .toolbar {
            Button("Mark All Done") {
                // ⚠️ Rows disappear with no animation — the list teleports
                for index in habits.indices {
                    habits[index].isDone = true
                }
            }
        }
    }
}
```

**Correct (the same mutation inside withAnimation lets rows slide out and the list settle):**

```swift
import SwiftUI

struct Habit: Identifiable {
    let id = UUID()
    var name = ""
    var isDone = false
}

struct HabitListView: View {
    @State private var habits: [Habit]
    @State private var hidesCompleted = false

    init(habits: [Habit]) {
        self.habits = habits
    }

    var visibleHabits: [Habit] {
        hidesCompleted ? habits.filter { !$0.isDone } : habits
    }

    var body: some View {
        List {
            Toggle("Hide Completed", isOn: $hidesCompleted.animation())
            ForEach(visibleHabits) { habit in
                Text(habit.name)
            }
        }
        .toolbar {
            Button("Mark All Done") {
                withAnimation {
                    for index in habits.indices {
                        habits[index].isDone = true
                    }
                }
            }
        }
    }
}
```

Reference: [Human Interface Guidelines — Motion](https://developer.apple.com/design/human-interface-guidelines/motion), [withAnimation(_:_:)](https://developer.apple.com/documentation/swiftui/withanimation(_:_:))
