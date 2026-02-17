---
title: Show Real Progress, Not Indefinite Spinners
impact: HIGH
impactDescription: indefinite spinners provide zero information about wait time — determinate progress indicators make waits feel noticeably shorter and eliminate "is it frozen?" support queries
tags: honest, loading, progress, rams-6, segall-brutal, feedback
---

## Show Real Progress, Not Indefinite Spinners

Is it frozen? Did my payment go through? Should I close the app and start over? An indefinite spinner with no label and no progress is a tiny anxiety machine — it withholds the one thing the user needs to stay calm: information. Every second of ambiguity erodes trust. The spinner says "something is happening" but refuses to say what, how long, or whether it is still working at all. If you know the total bytes, show a progress bar. If you know the steps, show which step you are on. If the operation is fast enough that the user will not notice, show nothing — just cut straight to the result. Only reach for an indefinite spinner when you genuinely cannot estimate progress, and even then, be honest about the expected duration: a label like "This may take a minute" transforms a black box into a promise the user can hold you to.

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

**Exceptional (the creative leap) — progress that builds trust:**

```swift
struct FileDownloadView: View {
    @State private var progress: Double = 0.42
    @State private var bytesDownloaded: Int64 = 54_002_688
    @State private var totalBytes: Int64 = 128_974_848
    @State private var currentFile = "Beach_Sunset_4K.mov"
    @State private var estimatedSeconds = 34
    @State private var speed = "3.2 MB/s"

    var body: some View {
        VStack(spacing: 16) {
            // File identity — the user always knows WHAT is happening
            HStack(spacing: 12) {
                Image(systemName: "arrow.down.circle")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .symbolEffect(.pulse, options: .repeating)

                VStack(alignment: .leading, spacing: 2) {
                    Text(currentFile)
                        .font(.headline)
                    Text("\(formattedBytes(bytesDownloaded)) of \(formattedBytes(totalBytes))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                }

                Spacer()
            }

            // Progress — smooth, honest, alive
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .animation(.smooth, value: progress)

            // Context — answers "how long?" before the user asks
            HStack {
                Text(speed)
                Spacer()
                Text("About \(estimatedSeconds)s remaining")
            }
            .font(.caption)
            .foregroundStyle(.tertiary)
            .contentTransition(.numericText())
        }
        .padding()
        .background(.regularMaterial,
                     in: RoundedRectangle(cornerRadius: 16))
    }

    private func formattedBytes(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes,
                                  countStyle: .file)
    }
}
```

The pulsing symbol says "alive" without spinning in place. The file name says "I know what you asked for." The byte count and speed say "here is the proof." The estimated time says "I respect your schedule." Every piece of information answers a question the user would otherwise have to wonder about, and that absence of wondering is what trust feels like. The user can glance away and come back without losing context — the screen remembers on their behalf.

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
