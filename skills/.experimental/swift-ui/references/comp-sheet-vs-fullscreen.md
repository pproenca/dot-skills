---
title: Choose Sheet vs FullScreenCover by Content Type
impact: HIGH
impactDescription: prevents confusing navigation mental model for users
tags: comp, sheet, fullscreencover, modal, presentation
---

## Choose Sheet vs FullScreenCover by Content Type

Sheets are for quick tasks that maintain context. Full-screen covers are for immersive flows that replace the current context entirely.

**Incorrect (sheet for immersive camera flow):**

```swift
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
```

**Correct (fullScreenCover for immersive flow):**

```swift
struct HomeView: View {
    @State private var showingCamera = false

    var body: some View {
        Button("Take Photo") { showingCamera = true }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView()  // Full screen for immersive experience
                // Requires explicit dismiss action
            }
    }
}
```

**Use sheet for quick contextual tasks:**

```swift
struct PhotosView: View {
    @State private var showingShareSheet = false

    var body: some View {
        Button("Share") { showingShareSheet = true }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(photo: selectedPhoto)
                    .presentationDetents([.medium, .large])
            }
    }
}
```

**Decision matrix:**

| Content Type | Presentation |
|--------------|--------------|
| Quick edit | Sheet (medium) |
| Share/export | Sheet |
| Filters/options | Sheet |
| Camera/scanner | FullScreenCover |
| Onboarding | FullScreenCover |
| Media player | FullScreenCover |
| Authentication | FullScreenCover |

Reference: [SwiftUI Presentations](https://www.swiftyplace.com/blog/presenting-views-in-swiftui-sheets-modals-popovers-alerts-and-navigation)
