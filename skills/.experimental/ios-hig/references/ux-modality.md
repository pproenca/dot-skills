---
title: Use Modality Appropriately
impact: HIGH
impactDescription: modal overuse traps users in flows — nested modals increase task abandonment by 30-50% compared to push navigation
tags: ux, modality, modal, sheets, interruption
---

## Use Modality Appropriately

Use modal presentations (sheets, alerts) only for focused tasks that require completion before continuing. Don't trap users in modal flows unnecessarily.

**Incorrect (modal overuse):**

```swift
// Modal for navigation
.sheet(isPresented: $showProfile) {
    ProfileView() // This should be pushed, not modal
}

// Modal within modal
.sheet(isPresented: $showForm) {
    FormView()
        .sheet(isPresented: $showPicker) {
            PickerView() // Nested modals confuse users
        }
}

// Modal for viewing content
.sheet(isPresented: $showArticle) {
    ArticleView(article: article) // Should be navigation
}

// No way to exit
.fullScreenCover(isPresented: $showOnboarding) {
    OnboardingView()
        .interactiveDismissDisabled(true)
}
```

**Correct (appropriate modality):**

```swift
// Modal for self-contained task
.sheet(isPresented: $showCompose) {
    NavigationStack {
        ComposeMessageView()
            .navigationTitle("New Message")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showCompose = false }
                }
            }
    }
}

// Navigation for viewing content
NavigationLink(value: article) {
    ArticleRow(article: article)
}
.navigationDestination(for: Article.self) { article in
    ArticleView(article: article)
}

// Sheet with detents for partial modal
.sheet(isPresented: $showFilter) {
    FilterView()
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
}

// Full screen only for immersive content
.fullScreenCover(isPresented: $showCamera) {
    CameraView(onCapture: { showCamera = false })
}
```

**When to use modality:**
| Scenario | Presentation |
|----------|--------------|
| View content | NavigationLink |
| Self-contained task | Sheet |
| Quick selection | Sheet (medium) |
| Camera/media capture | Full screen |
| Critical decision | Alert |

**Modal guidelines:**
- Task must be completable or cancellable
- Avoid nested modals (max 1 level)
- Provide clear exit (Cancel/Done/X)
- Warn before dismissing unsaved changes

Reference: [Modality - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/modality)
