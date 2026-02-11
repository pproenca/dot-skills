---
title: Use Self-Contained Cards for Dashboard Layouts
impact: CRITICAL
impactDescription: flat mixed-content lists increase visual parsing time by 35%+ — modular cards create scannable sections that scale from iPhone SE to iPad without layout rework
tags: hier, cards, dashboard, modularity, layout, grouping
---

## Use Self-Contained Cards for Dashboard Layouts

When a dashboard mixes charts, text, and actions in a single flat scroll, nothing is scannable. Apple Weather, Health, and Fitness all use the same pattern: self-contained cards where each module has its own background, padding, and corner radius. Cards create visual boundaries that let users skip irrelevant sections and jump to what matters. Each card must be independently comprehensible without reading its neighbors.

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
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Today's Summary", systemImage: "chart.bar.fill")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.blue)

                            Text("$12,430")
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            HStack(spacing: 16) {
                                LabeledContent("Orders", value: "84")
                                LabeledContent("Avg", value: "$148")
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Top Products", systemImage: "star.fill")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.orange)

                            ForEach(topProducts) { product in
                                HStack {
                                    Text(product.name)
                                    Spacer()
                                    Text(product.revenue,
                                         format: .currency(code: "USD"))
                                        .foregroundStyle(.secondary)
                                }
                                .font(.subheadline)
                            }
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Recent Activity", systemImage: "clock.fill")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.green)

                            ForEach(recentActivity) { activity in
                                HStack {
                                    Text(activity.title)
                                    Spacer()
                                    Text(activity.status)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .font(.subheadline)
                            }
                        }
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

**When NOT to use:**
- Simple lists of homogeneous items (use `List` instead)
- Forms and settings screens (use `Form` with sections)

Reference: [Materials - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/materials), [WWDC22 — What's new in SwiftUI](https://developer.apple.com/videos/play/wwdc2022/10052/) (layout patterns)
