---
title: Use Whitespace to Separate Conceptual Groups
impact: CRITICAL
impactDescription: uniform spacing between unrelated elements forces users to read every line to find group boundaries — Gestalt proximity grouping reduces visual parsing time by 20-30%
tags: hier, whitespace, spacing, gestalt, proximity, grouping
---

## Use Whitespace to Separate Conceptual Groups

When every element has the same spacing, the screen reads as one undifferentiated block. The Gestalt principle of proximity states that items closer together are perceived as related. A principal designer uses tight spacing (4-8pt) within conceptual groups and generous spacing (20-32pt) between them. This eliminates the need for dividers or backgrounds — whitespace alone communicates structure.

**Incorrect (uniform spacing between all elements):**

```swift
struct EventDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Every element has identical 12pt spacing
                // No way to tell which items belong together
                Text("WWDC25 Watch Party")
                    .font(.title2.bold())
                Text("June 9, 2025 at 10:00 AM")
                Text("Apple Park, Cupertino")
                Text("Hosted by Developer Relations")
                Text("Join us for the keynote livestream with snacks and networking.")
                Text("42 attending")
                Text("12 spots remaining")
                Button("RSVP") { }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}
```

**Correct (grouped spacing reflects information architecture):**

```swift
struct EventDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Group 1: Identity (tight 4pt internal spacing)
                VStack(alignment: .leading, spacing: 4) {
                    Text("WWDC25 Watch Party")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Hosted by Developer Relations")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // 24pt gap — signals new conceptual group

                // Group 2: Logistics (tight 6pt internal spacing)
                VStack(alignment: .leading, spacing: 6) {
                    Label("June 9, 2025 at 10:00 AM", systemImage: "calendar")
                    Label("Apple Park, Cupertino", systemImage: "mappin")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                // 24pt gap

                // Group 3: Description (standalone)
                Text("Join us for the keynote livestream with snacks and networking.")
                    .font(.body)

                // 24pt gap

                // Group 4: Attendance + action (tight 8pt)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("42 attending")
                        Spacer()
                        Text("12 spots remaining")
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)

                    Button("RSVP") { }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
    }
}
```

**Spacing ratios that create clear grouping:**

```swift
// Within a group:   4-8pt   (elements feel connected)
// Between groups:  20-32pt  (clear visual break)
// Ratio:           ~3:1 or higher between inter-group and intra-group

// SwiftUI pattern: nest VStacks with different spacing
VStack(spacing: 24) {          // inter-group: 24pt
    VStack(spacing: 4) { ... } // intra-group: 4pt
    VStack(spacing: 6) { ... } // intra-group: 6pt
    VStack(spacing: 8) { ... } // intra-group: 8pt
}

// Avoid: Divider() as a substitute for whitespace
// Dividers add visual noise — spacing alone is sufficient
// Exception: List rows where dividers are the system convention
```

**Benefits:**
- Eliminates Divider clutter — whitespace communicates the same grouping with less noise
- Works across Dynamic Type sizes because spacing scales proportionally
- Reduces view count compared to adding separator views

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout), [WWDC22 — Compose custom layouts with SwiftUI](https://developer.apple.com/videos/play/wwdc2022/10056/)
