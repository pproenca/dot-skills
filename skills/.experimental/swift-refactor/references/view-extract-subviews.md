---
title: Extract Subviews to Create Diffing Checkpoints
impact: HIGH
impactDescription: skips re-evaluation of unchanged branches, 2-5× body reduction
tags: view, subview, extraction, diffing, performance, composition
---

## Extract Subviews to Create Diffing Checkpoints

SwiftUI compares a subview's inputs before calling its body. When you extract a section into its own struct, SwiftUI can skip re-evaluating that entire branch if its inputs haven't changed. Keep each view body under 10 direct child nodes — extract aggressively to create maximum diffing checkpoints.

**Incorrect (monolithic body re-evaluates everything on any state change):**

```swift
struct EventDetailView: View {
    @State var viewModel: EventDetailViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: viewModel.coverImageURL) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: { Color.gray }
                    .frame(height: 240).clipped()
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.title).font(.title).bold().foregroundStyle(.white)
                        Text(viewModel.venue).font(.subheadline).foregroundStyle(.white.opacity(0.8))
                    }
                    .padding()
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text(viewModel.date, style: .date).font(.headline)
                        Text(viewModel.date, style: .time).font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(viewModel.isRSVPed ? "Going" : "RSVP") { viewModel.toggleRSVP() }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }
}
```

**Correct (subviews create diffing checkpoints — under 10 nodes per body):**

```swift
struct EventDetailView: View {
    @State var viewModel: EventDetailViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                EventCoverHeader(
                    title: viewModel.title,
                    venue: viewModel.venue,
                    coverImageURL: viewModel.coverImageURL
                )
                EventDateRow(
                    date: viewModel.date,
                    isRSVPed: viewModel.isRSVPed,
                    onToggleRSVP: viewModel.toggleRSVP
                )
                EventDescription(text: viewModel.description)
                AttendeesList(attendees: viewModel.attendees)
            }
        }
    }
}

struct EventCoverHeader: View {
    let title: String
    let venue: String
    let coverImageURL: URL?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: coverImageURL) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(height: 240)
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.title).bold().foregroundStyle(.white)
                Text(venue).font(.subheadline).foregroundStyle(.white.opacity(0.8))
            }
            .padding()
        }
    }
}
```

**Extraction guidelines:**
- Maximum 10 direct child nodes per body
- Each subview receives only the properties it needs — not entire models
- Extract when a section exceeds the 10-node threshold
- Group by semantic meaning (header, row, section), not arbitrary counts

Reference: [Demystify SwiftUI performance - WWDC23](https://developer.apple.com/videos/play/wwdc2023/10160/)
