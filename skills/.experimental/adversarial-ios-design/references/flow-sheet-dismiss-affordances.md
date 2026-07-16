---
title: Give every sheet Cancel leading and Done trailing
tags: flow, sheets, toolbar, dismissal
---

## Give every sheet Cancel leading and Done trailing

The wrong default is a sheet with no toolbar dismiss buttons — swipe-down as the only exit — or a lone Done button with no way to abandon the task. The HIG fixes both the presence and the geometry: the Cancel button belongs on the leading edge of the top toolbar, Done on the trailing edge, and "If you provide a Done button, always pair it with a Cancel button" (or a Back button in a multi-view sheet) — never all three at once. SwiftUI's `.cancellationAction` and `.confirmationAction` placements produce exactly this layout, so the fix is a placement choice, not custom layout work.

**Evidence of violation:** any of these shapes, cited at the sheet's content — a `.sheet` whose root view declares no dismiss toolbar item at all (no `.cancellationAction`, `.confirmationAction`, `.topBarLeading`/`.topBarTrailing` dismiss button); a Done/commit button with no Cancel or Back sibling; Cancel placed with `.topBarTrailing` or Done placed with `.topBarLeading` (edges swapped); Cancel, Done, and Back all present in one toolbar. PASS: `.cancellationAction` + `.confirmationAction` items, or a Close button alone for read-only sheets — the reviewer cites the toolbar declarations. N/A: no sheets in the target.

**Incorrect (Done alone means abandoning the tag edit is impossible without committing):**

```swift
import SwiftUI

struct Tag: Identifiable, Equatable {
    let id = UUID()
    var label: String
}

struct TagEditorSheet: View {
    @Binding var entry: JournalEntry
    @State private var draftTags: [Tag] = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach($draftTags) { $tag in
                    TextField("Tag", text: $tag.label)
                }
            }
            .navigationTitle("Edit Tags")
            .task { draftTags = entry.tags }
            .toolbar {
                // ⚠️ Done with no Cancel — the only exits commit the edit
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        entry.tags = draftTags
                        dismiss()
                    }
                }
            }
        }
    }
}
```

**Correct (Cancel leading abandons, Done trailing commits):**

```swift
import SwiftUI

struct Tag: Identifiable, Equatable {
    let id = UUID()
    var label: String
}

struct TagEditorSheet: View {
    @Binding var entry: JournalEntry
    @State private var draftTags: [Tag] = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach($draftTags) { $tag in
                    TextField("Tag", text: $tag.label)
                }
            }
            .navigationTitle("Edit Tags")
            .task { draftTags = entry.tags }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        entry.tags = draftTags
                        dismiss()
                    }
                }
            }
        }
    }
}
```

Reference: [HIG — Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets), [HIG — Modality](https://developer.apple.com/design/human-interface-guidelines/modality)
