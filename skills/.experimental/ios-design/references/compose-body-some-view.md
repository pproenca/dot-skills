---
title: Return some View from Body, Never Concrete Types
impact: HIGH
impactDescription: eliminates 100% of body-signature breaking changes — concrete types force O(n) cascading fixes across all dependents per layout tweak, opaque `some View` reduces that to O(1) with zero downstream recompilation
tags: compose, body, opaque-type, kocienda-creative-selection, view
---

## Return some View from Body, Never Concrete Types

Kocienda's creative selection means building pieces that can be freely recombined. When a view's body returns `some View`, the concrete type is hidden behind an opaque wrapper — you can change from `VStack` to `HStack` to `ZStack` without breaking any dependent code. This is the compositional freedom that makes iterative refinement possible. Concrete return types lock the implementation, turning every layout experiment into a refactoring exercise.

**Incorrect (concrete return type locks implementation):**

```swift
struct ProfileSection: View {
    // Returning concrete type exposes implementation detail
    var body: VStack<TupleView<(Text, Text)>> {
        VStack {
            Text("John Appleseed")
            Text("iOS Engineer")
        }
    }
}
```

**Correct (opaque return type enables free iteration):**

```swift
struct ProfileSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("John Appleseed")
                .font(.headline)

            Text("iOS Engineer")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
```

**This also applies to extracted helper methods:**

```swift
struct EventDetailView: View {
    let event: Event

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection
                descriptionSection
                locationSection
            }
            .padding()
        }
    }

    // Computed properties also use some View
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.title)
                .font(.title.bold())
            Text(event.date.formatted(date: .long, time: .shortened))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var descriptionSection: some View {
        Text(event.description)
            .font(.body)
    }

    private var locationSection: some View {
        Label(event.location, systemImage: "mappin.circle.fill")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}
```

**When concrete types are acceptable:** Generic container views that accept `Content: View` as a generic parameter (like `DashboardCard<Content: View>`) expose the generic type intentionally to enable type-safe composition.

Reference: [View fundamentals - Apple Documentation](https://developer.apple.com/documentation/swiftui/view-fundamentals)
