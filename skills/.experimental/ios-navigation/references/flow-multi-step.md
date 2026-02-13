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
// BAD: No real back navigation, no skip steps, no pop-to-root
struct OnboardingFlow: View {
    @State private var showStep1 = true
    @State private var showStep2 = false
    @State private var showStep3 = false
    var body: some View {
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
// GOOD: Back navigation, skip steps, and pop-to-root work out of the box
enum OnboardingStep: Hashable {
    case name, plan, confirmation
}

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
            NameEntryView()
                .navigationDestination(for: OnboardingStep.self) { step in
                    switch step {
                    case .name: NameEntryView()
                    case .plan: PlanSelectionView()
                    case .confirmation:
                        ConfirmationView(onComplete: { flowData.steps.removeAll() })
                    }
                }
        }
        .environment(flowData)
    }
}

struct NameEntryView: View {
    @Environment(OnboardingData.self) private var data
    var body: some View {
        @Bindable var data = data
        Form {
            TextField("Name", text: $data.name)
            Button("Next") { data.steps.append(.plan) }
        }
        .navigationTitle("Your Name")
    }
}
```
