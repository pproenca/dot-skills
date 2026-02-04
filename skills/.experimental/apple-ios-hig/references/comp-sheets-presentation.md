---
title: Use Sheets for Modal Tasks
impact: HIGH
impactDescription: provides appropriate modal context for focused tasks
tags: comp, sheets, modal, presentation
---

## Use Sheets for Modal Tasks

Use sheets for focused tasks that need modal presentation. Sheets slide up from the bottom and can be dismissed by swiping down. Reserve full-screen modals for immersive content.

**Incorrect (wrong modal style):**

```swift
// Full screen for simple form
.fullScreenCover(isPresented: $showEdit) {
    EditProfileView() // Overkill for simple edit
}

// No dismiss affordance
.sheet(isPresented: $showSettings) {
    SettingsView()
        .interactiveDismissDisabled() // Trapped user
}

// Alert for complex content
.alert("Edit Profile", isPresented: $showEdit) {
    TextField("Name", text: $name)
    // Alerts aren't for forms
}
```

**Correct (appropriate sheet usage):**

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

**When to use each:**
| Presentation | Use For |
|--------------|---------|
| Sheet (`.medium`) | Quick actions, filters |
| Sheet (`.large`) | Forms, composition |
| Full screen | Camera, media, immersive |
| Popover (iPad) | Inspector, details |

Reference: [Sheets - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/sheets)
