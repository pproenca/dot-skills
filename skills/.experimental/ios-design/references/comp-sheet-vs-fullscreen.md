---
title: Choose Sheet vs FullScreenCover by Content Type
impact: HIGH
impactDescription: prevents confusing navigation mental model for users
tags: comp, sheet, fullscreencover, modal, presentation
---

## Choose Sheet vs FullScreenCover by Content Type

Sheets are for quick tasks that maintain context. Full-screen covers are for immersive flows that replace the current context entirely. Use sheets with presentation detents for resizable modals.

**Incorrect (wrong modal style):**

```swift
// Sheet for immersive camera flow
struct HomeView: View {
    @State private var showingCamera = false

    var body: some View {
        Button("Take Photo") { showingCamera = true }
            .sheet(isPresented: $showingCamera) {
                CameraView()  // Sheet for immersive camera feels wrong
                // User can accidentally dismiss by swiping
            }
    }
}

// Full screen for simple form
.fullScreenCover(isPresented: $showEdit) {
    EditProfileView() // Overkill for simple edit
}
```

**Correct (appropriate presentation styles):**

```swift
// Standard sheet for task
.sheet(isPresented: $showCompose) {
    NavigationStack {
        ComposeView()
            .navigationTitle("New Message")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showCompose = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") { send() }
                }
            }
    }
}

// Resizable sheet with detents
.sheet(isPresented: $showDetails) {
    DetailSheet()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}

// Full screen for immersive content
.fullScreenCover(isPresented: $showCamera) {
    CameraView()
}

// Prevent accidental dismiss for unsaved changes
.sheet(isPresented: $showEdit) {
    EditView()
        .interactiveDismissDisabled(hasUnsavedChanges)
}
```

**Decision matrix:**

| Content Type | Presentation |
|--------------|--------------|
| Quick edit | Sheet (medium) |
| Share/export | Sheet |
| Filters/options | Sheet |
| Forms, composition | Sheet (large) |
| Camera/scanner | FullScreenCover |
| Onboarding | FullScreenCover |
| Media player | FullScreenCover |
| Authentication | FullScreenCover |
| Inspector, details (iPad) | Popover |

Reference: [Sheets - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/sheets)
