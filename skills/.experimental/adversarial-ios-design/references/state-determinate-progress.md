---
title: Use determinate progress for measurable work and drop vague labels
tags: state, progress, progressview, labels
---

## Use determinate progress for measurable work and drop vague labels

The wrong default is an indeterminate `ProgressView()` for every wait, often captioned `"Loading..."`. When the operation's extent is measurable — an upload with byte counts, an export with `fractionCompleted`, a pipeline with a known step count — an indeterminate spinner throws that information away and leaves the user unable to judge whether to wait; the HIG's direction is to use a determinate indicator when possible and to switch from indeterminate to determinate the moment the extent becomes known. Vague labels are a separate failure: the HIG names "loading" and "authenticating" as terms that seldom add value — a label earns its place only by saying what is happening and how much remains.

**Evidence of violation:** an operation with progress data available in the code (a `URLSession` upload/download task's `Progress`, a `fractionCompleted` observation, an enumerable step count over known work) rendered as an indeterminate `ProgressView()` — cite both the available progress source and the indeterminate indicator; or a progress indicator labeled with a vague literal — "Loading", "Please wait", "Authenticating", or equivalent — cite the string. PASS: `ProgressView(value:total:)` (or `ProgressView(_ progress:)`) bound to the real progress; labels absent or informative ("Uploading 3 of 12 photos"); an indeterminate indicator that switches to determinate once extent is known — the reviewer must cite the binding. N/A: the operation's extent is genuinely unmeasurable (an open-ended remote computation with no progress API) — the reviewer must cite the absence of any progress source; absent that evidence, fail closed. N/A: no progress indicators in the target.

**Incorrect (measurable work hidden behind a vague spinner):**

```swift
import SwiftUI

struct PhotoBackupView: View {
    let uploadedCount: Int
    let totalCount: Int
    let isUploading: Bool

    var body: some View {
        if isUploading {
            // ⚠️ Step counts exist, yet the indicator is indeterminate and vaguely labeled
            ProgressView("Loading...")
        }
    }
}
```

**Correct (the indicator reports real progress in the user's terms):**

```swift
import SwiftUI

struct PhotoBackupView: View {
    let uploadedCount: Int
    let totalCount: Int
    let isUploading: Bool

    var body: some View {
        if isUploading {
            ProgressView(value: Double(uploadedCount), total: Double(totalCount)) {
                Text("Uploading \(uploadedCount) of \(totalCount) photos")
            }
            .progressViewStyle(.linear)
        }
    }
}
```

Reference: [HIG — Progress indicators](https://developer.apple.com/design/human-interface-guidelines/progress-indicators)
