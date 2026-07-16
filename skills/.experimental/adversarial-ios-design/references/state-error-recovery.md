---
title: Design error states with a cause and a recovery action
tags: state, errors, retry, contentunavailableview
---

## Design error states with a cause and a recovery action

The wrong default in a load failure path is `catch { errorMessage = error.localizedDescription }` rendered as a bare red `Text`, or an `.alert` with a single OK button that dismisses into a blank screen. Both leave the user stranded: no statement of what went wrong in their terms, nothing to do about it, and any previously loaded content thrown away. The HIG's direction is to show when a command can't be carried out and help people understand why, and — when a process stalls — to provide feedback that helps people understand the problem and what they can do about it. A failure state for primary content is a designed view: an explanation that names a cause, a recovery action that re-invokes the work, and cached or partial content preserved where it exists.

**Evidence of violation:** a failure path for loading primary content that renders only a raw error string (`Text(error.localizedDescription)` or equivalent) with no action; or only an `.alert` whose sole button dismisses, leaving no in-place error view and no retry — cite the catch/render site. PASS: an in-place designed error state (e.g. `ContentUnavailableView` with a description that names the cause — offline, server unavailable) plus a recovery action (`Button("Retry")` re-invoking the load), with previously loaded content left visible where it exists — the reviewer must cite the view and the action. N/A: failures that cannot recur or be retried by the user (a one-shot migration) — the reviewer must cite why retry is meaningless; absent that evidence, fail closed. N/A: no fallible content load in the target.

**Incorrect (a raw error dump with nothing to do about it):**

```swift
import SwiftUI

struct PortfolioView: View {
    let holdings: [String]
    let loadError: Error?
    let reload: () async -> Void

    var body: some View {
        if let loadError {
            // ⚠️ Raw error text, no cause in user terms, no way to retry
            Text(loadError.localizedDescription)
                .foregroundStyle(.red)
        } else {
            List(holdings, id: \.self) { Text($0) }
        }
    }
}
```

**Correct (the failure explains itself and offers the way back):**

```swift
import SwiftUI

struct PortfolioView: View {
    let holdings: [String]
    let loadError: Error?
    let reload: () async -> Void

    var body: some View {
        if let loadError {
            ContentUnavailableView {
                Label("Quotes Unavailable", systemImage: "wifi.exclamationmark")
            } description: {
                Text("Prices couldn't be updated. Check your connection and try again.")
            } actions: {
                Button("Retry") {
                    Task { await reload() }
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            List(holdings, id: \.self) { Text($0) }
        }
    }
}
```

Reference: [HIG — Feedback](https://developer.apple.com/design/human-interface-guidelines/feedback), [HIG — Progress indicators](https://developer.apple.com/design/human-interface-guidelines/progress-indicators)
