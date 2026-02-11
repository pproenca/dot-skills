---
title: Use Progressive Disclosure for Dense Information
impact: CRITICAL
impactDescription: reduces first-screen cognitive load from 10+ data points to 5-7 chunks (Miller's Law) — prevents information overload that causes users to scroll past without engaging
tags: hier, progressive-disclosure, information-density, cognitive-load, navigation
---

## Use Progressive Disclosure for Dense Information

When a screen dumps all available data at once, users process none of it. Apple Health shows a single ring and a headline number — not 47 metrics. A principal designer identifies the 2-3 most important data points per context, surfaces those as the default view, and provides clear paths to drill deeper. Every piece of hidden information must be one tap away, never zero taps.

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

**Progressive disclosure patterns on iOS:**
- `NavigationLink` for detail screens (primary pattern)
- `DisclosureGroup` for inline expansion of secondary data
- `.sheet` for contextual detail without leaving the current flow
- Section headers with "Show More" buttons for lists

**When NOT to use:**
- Reference screens where users need to compare all values simultaneously (e.g., a stock ticker)
- Settings screens where each row is already a single value — these are already progressively disclosed via NavigationLink

Reference: [WWDC20 — Design for Intelligence](https://developer.apple.com/videos/play/wwdc2020/10086/), [Apple Health](https://developer.apple.com/health-fitness/) (summary ring pattern)
