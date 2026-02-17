---
title: Use Self-Contained Cards for Dashboard Layouts
impact: CRITICAL
impactDescription: flat mixed-content lists increase visual parsing time by 35%+ — modular cards create scannable sections that scale from iPhone SE to iPad
tags: enduring, cards, dashboard, rams-7, edson-conviction, modularity
---

## Use Self-Contained Cards for Dashboard Layouts

Rams designed the Braun T3 radio with modular zones that are still referenced 65 years later. Cards are the digital equivalent — self-contained modules that feel complete on their own and compose into any arrangement. Apple's Weather, Health, and Fitness apps all bet on this pattern because it scales from iPhone SE to iPad. A flat list of mixed content forces the user to mentally group related data; cards do that grouping visually, creating scannable islands of meaning. Each card can be rearranged, added, or removed without breaking the whole — modularity that earns its keep at every screen size.

**Incorrect (flat list of heterogeneous data without visual boundaries):**

```swift
struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                // No visual grouping — everything runs together
                Text("Today's Summary")
                    .font(.headline)
                Text("Revenue: $12,430")
                Text("Orders: 84")
                Text("Avg Order: $148")

                Divider() // dividers are not grouping

                Text("Top Products")
                    .font(.headline)
                Text("1. Widget Pro — $3,200")
                Text("2. Gadget Air — $2,100")
                Text("3. Tool Kit — $1,800")

                Divider()

                Text("Recent Activity")
                    .font(.headline)
                Text("Order #1042 — Shipped")
                Text("Order #1041 — Processing")
                Text("Refund #87 — Completed")
            }
            .padding()
        }
    }
}
```

**Correct (modular cards with consistent treatment):**

```swift
struct DashboardView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    DashboardCard {
                        Label("Today's Summary", systemImage: "chart.bar.fill")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.blue)
                        Text("$12,430")
                            .font(.largeTitle.weight(.bold))
                        HStack(spacing: 16) {
                            LabeledContent("Orders", value: "84")
                            LabeledContent("Avg", value: "$148")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }

                    DashboardCard {
                        Label("Top Products", systemImage: "star.fill")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.orange)
                        // ... product rows
                    }

                    DashboardCard {
                        Label("Recent Activity", systemImage: "clock.fill")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.green)
                        // ... activity rows
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
}

// Reusable card container — consistent radius, padding, background
struct DashboardCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.regularMaterial,
                        in: RoundedRectangle(cornerRadius: 16))
    }
}
```

**Card design conventions on iOS:**
- Corner radius: 16pt (matches system cards in Weather, Health)
- Internal padding: 16pt (standard `.padding()`)
- Background: `.regularMaterial` or `.quaternary.opacity(0.3)` — never hard white/gray
- Card spacing: 16pt between cards, tighter within cards
- Each card has a label header with icon + tint for scannability

**When NOT to apply:** Simple lists of homogeneous items (use `List` instead) and forms or settings screens (use `Form` with sections).

Reference: [Materials - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/materials), [WWDC22 — What's new in SwiftUI](https://developer.apple.com/videos/play/wwdc2022/10052/) (layout patterns)
