---
title: Animate user-visible structural state changes
tags: motion, withanimation, transition, state-changes
---

## Animate user-visible structural state changes

The wrong default is mutating state so that views appear, disappear, resize, or reorder with no animation at all — content teleports into place, and the screen reads as a page refresh rather than a change the user caused. iOS communicates cause and effect through motion: the HIG asks for feedback motion that follows people's gestures and expectations, and SwiftUI's sanctioned mechanism is a `withAnimation` block around the mutation (or `.animation(_, value:)` / `.transition(_:)` on the affected views). A structural change that snaps is not a style choice; it is missing feedback.

**Evidence of violation:** a mutation site — a button action, `.onChange` handler, gesture callback, or task completion — that toggles a condition controlling `if`/`switch` view presence, inserts/removes/reorders a `ForEach` data source, or changes a layout-affecting value (frame, offset, alignment, visible detent content), where none of the following appears on any path to the render: `withAnimation { … }` around the mutation, `.animation(_, value:)` on an affected container keyed to that state, or `.transition(_:)` on the conditional view under an animated parent. Cite the mutation site. PASS: the mutation is wrapped in `withAnimation`, or the affected view carries `.animation(_, value:)` / `.transition(_:)` keyed to the mutated state — cite the animation mechanism. N/A: the only structural changes are navigation pushes, sheet or full-screen-cover presentations (the system animates those), or pure text-content changes that do not alter view structure — the reviewer must cite the system-animated or text-only nature of every change to claim this; absent that evidence, fail closed. N/A: the mutation path is guarded for Reduce Motion and deliberately skips animation — the guard must be cited.

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
