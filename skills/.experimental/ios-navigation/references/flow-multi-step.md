---
title: Use NavigationStack with Route Array for Multi-Step Flows
impact: HIGH
impactDescription: enables back navigation, skip steps, and pop-to-root in wizards
tags: flow, multi-step, wizard, onboarding, checkout
---

## Use NavigationStack with Route Array for Multi-Step Flows

Multi-step flows (onboarding, checkout, registration) should use NavigationStack with a typed route array. Each step pushes the next route onto the path. Pop-to-root clears the array. Sharing flow data via environment or an observable object keeps steps decoupled while maintaining a single source of truth for the wizard's collected state.

**Incorrect (boolean flags to show/hide each step):**

```swift
// BAD: Boolean-driven step visibility — no real back navigation,
// no ability to skip steps or pop-to-root cleanly
struct OnboardingFlow: View {
    @State private var showStep1 = true
    @State private var showStep2 = false
    @State private var showStep3 = false

    var body: some View {
        // Each step is toggled with booleans — back button doesn't
        // work, deep linking is impossible, state is fragile
        if showStep1 {
            NameEntryView(onNext: {
                showStep1 = false
                showStep2 = true
            })
        } else if showStep2 {
            PlanSelectionView(onNext: {
                showStep2 = false
                showStep3 = true
            })
        } else if showStep3 {
            ConfirmationView()
        }
    }
}
```

**Correct (NavigationStack with typed route enum):**

```swift
// GOOD: Each step is a route in a NavigationStack — back navigation,
// skip steps, and pop-to-root all work out of the box
enum OnboardingStep: Hashable {
    case name
    case plan
    case confirmation
}

// Observable object collects data across steps and holds the
// navigation path so child views can push without a binding.
@Observable
class OnboardingData {
    var name: String = ""
    var selectedPlan: Plan?
    var steps: [OnboardingStep] = []
}

struct OnboardingFlow: View {
    @State private var flowData = OnboardingData()

    var body: some View {
        @Bindable var flowData = flowData
        NavigationStack(path: $flowData.steps) {
            // First step is the root — no route needed
            NameEntryView()
                .navigationDestination(for: OnboardingStep.self) { step in
                    switch step {
                    case .name:
                        NameEntryView()
                    case .plan:
                        PlanSelectionView()
                    case .confirmation:
                        ConfirmationView(onComplete: {
                            // Pop-to-root clears the entire flow
                            flowData.steps.removeAll()
                        })
                    }
                }
        }
        // Shared flow data available to all steps via environment
        .environment(flowData)
    }
}

// Steps push the next route — they don't know about other steps.
// Access the shared OnboardingData from environment to push routes.
struct NameEntryView: View {
    @Environment(OnboardingData.self) private var data

    var body: some View {
        @Bindable var data = data
        Form {
            TextField("Name", text: $data.name)
            Button("Next") {
                data.steps.append(OnboardingStep.plan)
            }
        }
        .navigationTitle("Your Name")
    }
}
```
