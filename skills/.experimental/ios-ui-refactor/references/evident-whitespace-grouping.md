---
title: Use Whitespace to Separate Conceptual Groups
impact: CRITICAL
impactDescription: uniform spacing between unrelated elements forces users to read every line to find group boundaries — Gestalt proximity grouping noticeably speeds up visual parsing and comprehension
tags: evident, whitespace, spacing, rams-4, segall-human, gestalt
---

## Use Whitespace to Separate Conceptual Groups

A wall of evenly spaced text feels like a run-on sentence — no pauses, no breathing room, every line blurring into the next. Your eye has nowhere to rest, so you skim without absorbing. Now picture the same content with gentle pauses between groups: the title and host sit together like a chapter heading, the date and location cluster like a sidebar, the action rises from its own clearing. Suddenly the screen has rhythm. Those silent gaps are doing real work — they create structure without adding a single element. The Gestalt principle of proximity is hardwired into human perception: things near each other belong together. Whitespace is not empty space; it is the punctuation of visual design.

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

**Exceptional (the creative leap) — spacing as visual rhythm:**

```swift
struct BookingConfirmation: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Tight opening — dense identity cluster (4pt)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Booking Confirmed")
                        .font(.title2.bold())
                    Text("Reservation #TH-4829")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Spacer().frame(height: 16) // Brief pause

                // Mid section — details breathe a little more (8pt)
                VStack(alignment: .leading, spacing: 8) {
                    Label("Mar 14 – Mar 21, 2025", systemImage: "calendar")
                    Label("Brighton, East Sussex", systemImage: "mappin")
                    Label("2 cats, 1 dog", systemImage: "pawprint")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Spacer().frame(height: 28) // Longer breath

                // Description — standalone, room to absorb
                Text("You'll be caring for Luna, Miso, and Barkley in a Victorian terrace five minutes from the sea.")
                    .font(.body)
                    .lineSpacing(4)

                Spacer().frame(height: 40) // Generous clearing

                // Action — rises from its own space, unhurried
                Button("View House Details") { }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }
}
```

The spacing tells a story the same way a musician uses rests between phrases. Tight at the top where identity needs to land quickly, then progressively more generous as the eye travels down — 4, 16, 8, 28, 40. By the time the user reaches the button, the generous clearing around it makes it feel like an invitation rather than a demand. The rhythm guides without pushing: each pause is a breath that lets the previous group settle before the next one begins.

**Benefits:**
- Eliminates Divider clutter — whitespace communicates the same grouping with less noise
- Works across Dynamic Type sizes because spacing scales proportionally
- Reduces view count compared to adding separator views

**When NOT to apply:** Dense data tables and spreadsheet-style views where uniform tight spacing is necessary to display maximum information and users expect to scan rows and columns without visual interruption.

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout), [WWDC22 — Compose custom layouts with SwiftUI](https://developer.apple.com/videos/play/wwdc2022/10056/)
