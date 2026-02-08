---
title: Migrate Alert to confirmationDialog API
impact: CRITICAL
impactDescription: fixes data-driven presentation, eliminates boolean state juggling
tags: api, alert, confirmation-dialog, deprecated, presentation
---

## Migrate Alert to confirmationDialog API

The legacy `Alert` struct was deprecated in iOS 15. Its boolean-based presentation forces manual state juggling and cannot bind contextual data to the alert. The modern `.alert(title:isPresented:presenting:actions:message:)` and `.confirmationDialog` modifiers accept an optional data parameter, so the alert only fires when data is non-nil and passes that data directly into the action closures.

**Incorrect (deprecated Alert struct with boolean state juggling):**

```swift
struct FileListView: View {
    @State private var showDeleteAlert = false
    @State private var fileToDelete: FileItem?

    var body: some View {
        List(files) { file in
            FileRow(file: file)
                .swipeActions {
                    Button("Delete") {
                        fileToDelete = file
                        showDeleteAlert = true
                    }
                }
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete File"),
                message: Text("Delete \(fileToDelete?.name ?? "")?"),
                primaryButton: .destructive(Text("Delete")) {
                    guard let file = fileToDelete else { return }
                    deleteFile(file)
                },
                secondaryButton: .cancel()
            )
        }
    }
}
```

**Correct (data-driven presentation, no boolean state):**

```swift
struct FileListView: View {
    @State private var fileToDelete: FileItem?

    var body: some View {
        List(files) { file in
            FileRow(file: file)
                .swipeActions {
                    Button("Delete") {
                        fileToDelete = file
                    }
                }
        }
        .alert(
            "Delete File",
            isPresented: Binding(
                get: { fileToDelete != nil },
                set: { if !$0 { fileToDelete = nil } }
            ),
            presenting: fileToDelete
        ) { file in
            Button("Delete", role: .destructive) {
                deleteFile(file)
            }
        } message: { file in
            Text("Delete \(file.name)?")
        }
    }
}
```

For destructive multi-option actions, use `.confirmationDialog` instead:

```swift
.confirmationDialog(
    "File Options",
    isPresented: $showOptions,
    presenting: selectedFile
) { file in
    Button("Move to Trash", role: .destructive) {
        trashFile(file)
    }
    Button("Archive") {
        archiveFile(file)
    }
} message: { file in
    Text("Choose an action for \(file.name)")
}
```

Reference: [alert(_:isPresented:presenting:actions:message:)](https://developer.apple.com/documentation/swiftui/view/alert(_:ispresented:presenting:actions:message:)-8584l)
