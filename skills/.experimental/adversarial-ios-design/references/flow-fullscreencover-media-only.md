---
title: Reserve fullScreenCover for immersive media and multistep editing
tags: flow, modality, fullscreencover, sheets
---

## Reserve fullScreenCover for immersive media and multistep editing

The wrong default is reaching for `.fullScreenCover` because a task feels important — a goal form, a paywall-shaped info screen, a settings picker. A full-screen modal removes the sheet's visual reminder of the parent context and (by default) the swipe-to-dismiss escape, so it costs orientation and reversibility. The HIG scopes the full-screen style to a concrete enumeration: "presenting videos, photos, or camera views, or to support a multistep task like marking up a document or editing a photo." Everything below that bar is a sheet.

**Evidence of violation:** a `.fullScreenCover` whose content is a single `Form`, `List`, text-input task, confirmation, or informational screen — none of the enumerated uses (video playback, photo viewing, camera capture, document markup, photo/document editing, or another genuinely multistep editing flow). The reviewer cites the cover's content view. PASS: `.fullScreenCover` hosting camera/photo/video/markup or a multistep editor; `.sheet` for scoped tasks. N/A: no `.fullScreenCover` in the target. Carve-out: content that requires the full screen for another citable reason — an immersive game scene, a full-screen media canvas — the reviewer must cite that content; absent that evidence, fail closed.

**Incorrect (a two-field form loses its parent context and its swipe escape):**

```swift
import SwiftUI

struct WorkoutDashboardView: View {
    @State private var isEditingGoal = false
    @State private var weeklyGoal = WeeklyGoal()

    var body: some View {
        ScrollView {
            ActivitySummaryCard(goal: weeklyGoal)
        }
        // ⚠️ A simple form presented full screen — this is sheet-shaped work
        .fullScreenCover(isPresented: $isEditingGoal) {
            GoalForm(goal: $weeklyGoal)
        }
        .toolbar {
            Button("Edit Goal") { isEditingGoal = true }
        }
    }
}

struct GoalForm: View {
    @Binding var goal: WeeklyGoal
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Stepper("Workouts per week: \(goal.sessions)", value: $goal.sessions, in: 1...14)
                Stepper("Minutes per session: \(goal.minutes)", value: $goal.minutes, in: 10...120, step: 5)
            }
            .navigationTitle("Weekly Goal")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
```

**Correct (the sheet keeps the dashboard visible beneath the scoped task):**

```swift
import SwiftUI

struct WorkoutDashboardView: View {
    @State private var isEditingGoal = false
    @State private var weeklyGoal = WeeklyGoal()

    var body: some View {
        ScrollView {
            ActivitySummaryCard(goal: weeklyGoal)
        }
        .sheet(isPresented: $isEditingGoal) {
            GoalForm(goal: $weeklyGoal)
        }
        .toolbar {
            Button("Edit Goal") { isEditingGoal = true }
        }
    }
}
```

Reference: [HIG — Modality](https://developer.apple.com/design/human-interface-guidelines/modality), [HIG — Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets)
