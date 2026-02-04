---
title: Design Minimal Onboarding
impact: HIGH
impactDescription: gets users into app quickly while teaching essentials
tags: ux, onboarding, first-run, tutorial
---

## Design Minimal Onboarding

Onboarding should be brief and optional. Show only what users need to get started, and let them learn through use. Users want to use your app, not read about it.

**Incorrect (excessive onboarding):**

```swift
// Too many screens
PageView {
    OnboardingPage(title: "Welcome", description: "...")
    OnboardingPage(title: "Feature 1", description: "...")
    OnboardingPage(title: "Feature 2", description: "...")
    OnboardingPage(title: "Feature 3", description: "...")
    OnboardingPage(title: "Feature 4", description: "...")
}
// 5+ screens exhausts patience

// Can't skip
if !hasCompletedOnboarding {
    OnboardingView()
        .interactiveDismissDisabled() // Trapped
}

// Teaching obvious features
OnboardingPage(
    title: "Tap buttons",
    description: "Tap buttons to perform actions"
)
```

**Correct (minimal, valuable onboarding):**

```swift
// Quick start with 2-3 screens max
TabView {
    WelcomePage()
    KeyFeaturePage()
    GetStartedPage()
}
.tabViewStyle(.page)

// Always allow skip
VStack {
    TabView { /* onboarding pages */ }

    Button("Skip") {
        completeOnboarding()
    }
    .foregroundColor(.secondary)
}

// Or skip onboarding entirely - show empty state guidance
if items.isEmpty {
    ContentUnavailableView {
        Label("Start Your Collection", systemImage: "plus.circle")
    } description: {
        Text("Tap + to add your first item")
    } actions: {
        Button("Add First Item") { addItem() }
            .buttonStyle(.borderedProminent)
    }
}

// Contextual tooltips instead of upfront tour
.popover(isPresented: $showFeatureTip) {
    VStack {
        Text("New: Swipe to archive")
            .font(.headline)
        Text("Swipe left on any item to quickly archive it")
    }
    .padding()
}
```

**Onboarding principles:**
- Max 3 screens for initial onboarding
- Always offer skip option
- Show value, not features
- Use progressive disclosure
- Empty states teach by doing
- Remember "seen" state properly

Reference: [Onboarding - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/onboarding)
