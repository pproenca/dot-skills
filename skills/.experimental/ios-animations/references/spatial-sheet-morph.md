---
title: Use matchedGeometryEffect for Sheet Presentations
impact: MEDIUM
impactDescription: sheets that emerge from their trigger feel connected; sheets from thin air feel like popups
tags: spatial, sheet, presentation, morph, trigger
---

## Use matchedGeometryEffect for Sheet Presentations

Standard `.sheet` presentations slide up from the bottom of the screen. This works for generic sheets, but when the sheet is triggered by tapping a specific card, list item, or button, the spatial disconnect is jarring: the user taps an element in the center of the screen, then content arrives from below with no visual connection to the trigger. The user's mental model says "I tapped this card to expand it" but the system says "here is a new panel from the bottom."

Combining `matchedGeometryEffect` with a `fullScreenCover` (or overlay) creates a morph effect: the tapped element appears to grow into the sheet. The card visually transforms into the sheet header, maintaining spatial continuity between the trigger and the presented content.

**Incorrect (standard .sheet — slides up from bottom, no connection to trigger):**

```swift
struct EventListView: View {
    @State private var selectedEvent: Event?
    let events: [Event]

    var body: some View {
        List(events) { event in
            EventCardView(event: event)
                .onTapGesture {
                    selectedEvent = event
                }
        }
        // Standard sheet: slides up from the bottom edge.
        // No spatial relationship to the tapped card.
        .sheet(item: $selectedEvent) { event in
            EventDetailSheet(event: event)
        }
    }
}

struct EventCardView: View {
    let event: Event

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(event.color.gradient)
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: event.icon)
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.headline)
                Text(event.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct EventDetailSheet: View {
    let event: Event

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(event.color.gradient)
                        .frame(height: 200)
                        .overlay {
                            Image(systemName: event.icon)
                                .font(.system(size: 48))
                                .foregroundStyle(.white)
                        }

                    Text(event.title)
                        .font(.title.bold())

                    Text(event.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("Event")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
```

**Correct (matchedGeometryEffect morphs the card into the detail overlay):**

```swift
struct EventListView: View {
    @Namespace private var eventNamespace
    @State private var selectedEvent: Event?
    let events: [Event]

    var body: some View {
        ZStack {
            List(events) { event in
                EventCardView(
                    event: event,
                    namespace: eventNamespace
                )
                .onTapGesture {
                    selectedEvent = event
                }
            }
            .opacity(selectedEvent == nil ? 1 : 0.3)

            // Full-screen overlay instead of .sheet — enables matchedGeometryEffect
            if let event = selectedEvent {
                EventExpandedView(
                    event: event,
                    namespace: eventNamespace,
                    onDismiss: { selectedEvent = nil }
                )
            }
        }
        .animation(.smooth(duration: 0.4), value: selectedEvent)
    }
}

struct EventCardView: View {
    let event: Event
    var namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(event.color.gradient)
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: event.icon)
                        .foregroundStyle(.white)
                }
                .matchedGeometryEffect(id: "\(event.id)-image", in: namespace)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.headline)
                    .matchedGeometryEffect(id: "\(event.id)-title", in: namespace)
                Text(event.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct EventExpandedView: View {
    let event: Event
    var namespace: Namespace.ID
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header morphs from the card — spatial connection maintained
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(event.color.gradient)
                    .frame(height: 200)
                    .overlay {
                        Image(systemName: event.icon)
                            .font(.system(size: 48))
                            .foregroundStyle(.white)
                    }
                    .matchedGeometryEffect(id: "\(event.id)-image", in: namespace)

                Text(event.title)
                    .font(.title.bold())
                    .matchedGeometryEffect(id: "\(event.id)-title", in: namespace)
            }
            .padding()

            // Content below the header fades in independently
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(event.description)
                        .font(.body)
                        .foregroundStyle(.secondary)

                    Button("Add to Calendar") {
                        // action
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .transition(.opacity.animation(.smooth.delay(0.12)))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
        .padding(8)
        .contentShape(Rectangle())
        .onTapGesture { onDismiss() }
    }
}
```

**Separating matched and independent content:**

The critical pattern is splitting the presented view into two zones:

1. **Matched header** — the elements that share IDs with the trigger card. These morph spatially.
2. **Independent body** — the content unique to the expanded state. This fades in with a slight delay, so it appears *after* the morph establishes the spatial context.

```swift
// Header: matched elements morph
VStack {
    Image(/* ... */)
        .matchedGeometryEffect(id: "\(item.id)-image", in: namespace)
    Text(item.title)
        .matchedGeometryEffect(id: "\(item.id)-title", in: namespace)
}

// Body: independent content fades in after the morph
ScrollView {
    Text(item.details)
}
.transition(.opacity.animation(.smooth.delay(0.12)))
```

**When to use this pattern vs. standard `.sheet`:**

| Scenario | Recommendation |
|---|---|
| Triggered by a specific card or item | Matched overlay morph |
| Generic "add new" action | Standard `.sheet` |
| Settings panel from nav bar | Standard `.sheet` |
| Expanding a dashboard widget | Matched overlay morph |
| System share sheet | Standard `.sheet` (system-managed) |

**Caveat:** This pattern replaces `.sheet` with a manual overlay, which means you lose the system-provided drag-to-dismiss gesture. You can add a custom `DragGesture` on the overlay to restore this, or use a dismiss button as shown above.
