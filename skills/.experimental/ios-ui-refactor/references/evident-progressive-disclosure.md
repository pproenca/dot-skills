---
title: Use Progressive Disclosure for Dense Information
impact: CRITICAL
impactDescription: reduces first-screen cognitive load from 10+ data points to 5-7 chunks (Miller's Law) — prevents information overload that causes users to scroll past without engaging
tags: evident, progressive-disclosure, rams-4, segall-human, cognitive-load
---

## Use Progressive Disclosure for Dense Information

Thirteen health metrics staring at you from one screen. Steps, HRV, blood oxygen, deep sleep, respiratory rate — all at the same volume, all demanding attention at once. The feeling is not "informed," it is overwhelmed. You glaze over, scroll past, engage with none of it. Now imagine landing on a single calm ring that tells you how your day is going, with a heart card and a sleep card below it — just enough to answer "am I okay?" If you want the deeper numbers, they're one tap away, waiting patiently in their own space. That calm completeness is progressive disclosure: not hiding information, but organizing it into layers of depth that the user controls, revealing the right detail at the right moment.

**Incorrect (all data visible at once, no prioritization):**

```swift
struct HealthDashboard: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                // Wall of undifferentiated metrics
                Text("Steps: 8,432")
                Text("Distance: 3.8 km")
                Text("Flights Climbed: 12")
                Text("Active Calories: 342 kcal")
                Text("Resting Calories: 1,650 kcal")
                Text("Heart Rate: 72 bpm")
                Text("HRV: 45 ms")
                Text("Blood Oxygen: 98%")
                Text("Sleep: 7h 23m")
                Text("Deep Sleep: 1h 45m")
                Text("REM Sleep: 2h 10m")
                Text("Respiratory Rate: 14 brpm")
                Text("Noise Level: 42 dB")
            }
            .font(.body)
            .padding()
        }
    }
}
```

**Correct (summary first, detail on demand):**

```swift
struct HealthDashboard: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Hero metric: the single most important number
                    ActivityRingSummary(
                        moveCalories: 342,
                        exerciseMinutes: 28,
                        standHours: 10
                    )

                    // Summary cards — one per conceptual group
                    NavigationLink {
                        HeartDetailView()
                    } label: {
                        SummaryCard(
                            title: "Heart",
                            headline: "72 BPM",
                            subtitle: "Resting average today",
                            systemImage: "heart.fill",
                            tint: .red
                        )
                    }

                    NavigationLink {
                        SleepDetailView()
                    } label: {
                        SummaryCard(
                            title: "Sleep",
                            headline: "7h 23m",
                            subtitle: "Last night",
                            systemImage: "bed.double.fill",
                            tint: .cyan
                        )
                    }

                    // Expandable section for secondary data
                    DisclosureGroup("More Health Data") {
                        LabeledContent("Blood Oxygen", value: "98%")
                        LabeledContent("Respiratory Rate", value: "14 brpm")
                        LabeledContent("Noise Level", value: "42 dB")
                    }
                    .padding()
                    .background(.quaternary.opacity(0.3),
                                in: RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
            .navigationTitle("Health")
        }
    }
}

// SummaryCard: title + headline + subtitle + icon with chevron,
// wrapped in .padding() + .background(.quaternary.opacity(0.3),
// in: RoundedRectangle(cornerRadius: 12))
```

**Exceptional (the creative leap) — disclosure as conversation:**

```swift
struct HeartSummaryCard: View {
    @State private var isExpanded = false
    @Namespace private var cardHero

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Always visible: the single calm answer
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .matchedGeometryEffect(
                        id: "icon", in: cardHero)
                Text("72 BPM")
                    .font(.title2.weight(.semibold))
                    .matchedGeometryEffect(
                        id: "headline", in: cardHero)
                Spacer()
            }

            if isExpanded {
                // The deeper answer — unfolds in place
                VStack(alignment: .leading, spacing: 8) {
                    LabeledContent("Resting Average", value: "68 BPM")
                    LabeledContent("Walking Average", value: "94 BPM")
                    LabeledContent("HRV", value: "45 ms")
                    LabeledContent("Range Today", value: "58–112 BPM")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Button {
                withAnimation(.snappy(duration: 0.35)) {
                    isExpanded.toggle()
                }
            } label: {
                Text(isExpanded ? "Show Less" : "Show Details")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .background(.quaternary.opacity(0.3),
                     in: RoundedRectangle(cornerRadius: 12))
    }
}
```

The difference between "expandable section" and "conversation" is how the reveal feels in motion. The `matchedGeometryEffect` keeps the heart icon and headline anchored in place while the detail rows materialize beneath them with a combined opacity-and-slide transition — the card doesn't jump or reflow, it *grows*. The `.snappy` spring gives the expansion a quick, confident feel, like the interface heard your question and is answering without hesitation. This transforms progressive disclosure from a mechanical show/hide into a dialogue: you asked, I'll tell you more, right here, at your pace.

**Progressive disclosure patterns on iOS:**
- `NavigationLink` for detail screens (primary pattern)
- `DisclosureGroup` for inline expansion of secondary data
- `.sheet` for contextual detail without leaving the current flow
- Section headers with "Show More" buttons for lists

**When NOT to apply:** Reference screens where users need to compare all values simultaneously (e.g., a stock ticker), and settings screens where each row is already a single value that is progressively disclosed via NavigationLink.

Reference: [WWDC20 — Design for Intelligence](https://developer.apple.com/videos/play/wwdc2020/10086/), [Apple Health](https://developer.apple.com/health-fitness/) (summary ring pattern)
