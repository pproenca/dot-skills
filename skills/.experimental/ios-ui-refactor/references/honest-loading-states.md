---
title: Show Real Progress, Not Indefinite Spinners
impact: HIGH
impactDescription: indefinite spinners provide zero information about wait time — determinate progress indicators reduce perceived wait time by 20-40% and eliminate "is it frozen?" support queries
tags: honest, loading, progress, rams-6, segall-brutal, feedback
---

## Show Real Progress, Not Indefinite Spinners

Rams insisted that design must not manipulate the consumer. An indefinite spinner that offers no information about duration or progress is dishonest — it says "something is happening" but withholds how long you'll wait. It manipulates the user into patience without offering the data needed to decide whether to wait or abandon the task. Segall's Think Brutal demands clarity: if you know the total, show a progress bar. If you know the steps, show which step you're on. If the operation is fast enough that the user won't notice, show no indicator at all. Only use an indefinite spinner when you genuinely cannot estimate progress — and even then, be honest about the expected duration with a label like "This may take a minute."

**Incorrect (every async operation shows the same indefinite spinner):**

```swift
struct DownloadView: View {
    @State private var isDownloading = false
    @State private var isProcessing = false

    var body: some View {
        VStack(spacing: 24) {
            if isDownloading {
                // Same spinner for a 50MB download — no progress info
                ProgressView()
                Text("Downloading...")
                    .foregroundStyle(.secondary)
            }

            if isProcessing {
                // Same spinner for a 3-step import — no step indication
                ProgressView()
                Text("Processing...")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
```

**Correct (determinate progress where possible, step indication where applicable):**

```swift
struct DownloadView: View {
    @State private var downloadProgress: Double = 0
    @State private var processingStep = 0
    private let totalSteps = 3
    private let stepLabels = ["Validating", "Importing", "Indexing"]

    var body: some View {
        VStack(spacing: 24) {
            // Determinate: user sees exactly how much remains
            VStack(spacing: 8) {
                ProgressView(value: downloadProgress)
                    .progressViewStyle(.linear)

                Text("\(Int(downloadProgress * 100))% downloaded")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }

            // Step-based: user knows where they are in the sequence
            VStack(spacing: 8) {
                ProgressView(value: Double(processingStep),
                             total: Double(totalSteps))
                    .progressViewStyle(.linear)

                Text("Step \(processingStep + 1) of \(totalSteps): \(stepLabels[processingStep])")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
```

**Honest loading indicators by situation:**
| Situation | Honest indicator |
|---|---|
| Known total bytes/items | Determinate ProgressView with percentage |
| Known step count | Step indicator "Step 2 of 4: Importing" |
| Unknown duration, fast (<2s) | No indicator — show result directly |
| Unknown duration, slow (2-10s) | Indefinite spinner with descriptive label |
| Unknown duration, very slow (10s+) | Indefinite spinner + "This may take a minute" |

**When NOT to apply:** Pull-to-refresh and inline loading indicators in lists where the system provides standard loading patterns. Brief operations under 1 second should show no loading indicator at all — the interface should simply transition from the current state to the result state without drawing attention to the gap.

Reference: [Progress Indicators - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/progress-indicators)
