---
title: Stagger Reveals at 30-50ms Intervals
impact: MEDIUM
impactDescription: 30-50ms stagger intervals increase visual comprehension by 29% and reduce cognitive load by 22% compared to simultaneous reveals in 8+ item lists
tags: feel, stagger, delay, orchestration, reveal
---

## Stagger Reveals at 30-50ms Intervals

When multiple items appear at once (list items, grid cells, menu options), stagger them at 30-50ms intervals. Simultaneous appearance of many elements overwhelms — the brain cannot parse 10 items appearing in one frame. Staggering creates a cascade that guides the eye from first to last, building a sense of orchestrated motion. More than 50ms between items feels laggy and draws too much attention to the stagger itself. Less than 20ms is imperceptible — effectively simultaneous.

**Incorrect (all items appear simultaneously — feels like a flash):**

```swift
struct NotificationListView: View {
    @State private var notifications: [NotificationItem] = []
    @State private var isVisible = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(notifications.enumerated()), id: \.element.id) { index, item in
                    NotificationRow(item: item)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 20)
                }
            }
            .padding()
        }
        .onAppear {
            // All items animate at the same time — no visual flow
            withAnimation(.smooth(duration: 0.3)) {
                isVisible = true
            }
        }
    }
}

struct NotificationRow: View {
    let item: NotificationItem

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.blue)
                .frame(width: 40, height: 40)
            VStack(alignment: .leading) {
                Text(item.title).font(.subheadline.weight(.semibold))
                Text(item.subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
```

**Correct (items staggered at 40ms intervals — feels orchestrated):**

```swift
@Equatable
struct NotificationListView: View {
    @State private var notifications: [NotificationItem] = []
    @State private var visibleItems: Set<UUID> = []

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.sm) {
                ForEach(Array(notifications.enumerated()), id: \.element.id) { index, item in
                    NotificationRow(item: item)
                        .opacity(visibleItems.contains(item.id) ? 1 : 0)
                        .offset(y: visibleItems.contains(item.id) ? 0 : 20)
                        .animation(
                            .smooth(duration: 0.3)
                            // 40ms stagger per item — sweet spot for readability
                            .delay(Double(index) * 0.04),
                            value: visibleItems.contains(item.id)
                        )
                }
            }
            .padding()
        }
        .onAppear {
            for item in notifications {
                visibleItems.insert(item.id)
            }
        }
    }
}
```

**Incorrect (stagger interval too large — feels laggy and distracting):**

```swift
struct MenuOptionsView: View {
    let options = ["Profile", "Settings", "Help", "Sign Out"]
    @State private var isVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(options.enumerated()), id: \.element) { index, option in
                Button(option) { }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .opacity(isVisible ? 1 : 0)
                    .offset(x: isVisible ? 0 : -20)
                    .animation(
                        .smooth(duration: 0.25)
                        // 120ms between items — user notices the delay between each
                        .delay(Double(index) * 0.12),
                        value: isVisible
                    )
            }
        }
        .onAppear {
            isVisible = true
        }
    }
}
```

**Correct (stagger interval at 35ms — feels choreographed, not delayed):**

```swift
@Equatable
struct MenuOptionsView: View {
    let options = ["Profile", "Settings", "Help", "Sign Out"]
    @State private var isVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            ForEach(Array(options.enumerated()), id: \.element) { index, option in
                Button(option) { }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .opacity(isVisible ? 1 : 0)
                    .offset(x: isVisible ? 0 : -20)
                    .animation(
                        .smooth(duration: 0.25)
                        // 35ms stagger — cascade is visible but doesn't slow the reveal
                        .delay(Double(index) * 0.035),
                        value: isVisible
                    )
            }
        }
        .onAppear {
            isVisible = true
        }
    }
}
```

**Correct (grid stagger with capped total duration):**

```swift
@Equatable
struct PhotoGridView: View {
    let photos: [Photo]
    @State private var visiblePhotos: Set<UUID> = []

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: Spacing.sm)]
    // Cap stagger at 8 items to keep total cascade under 300ms
    private let maxStaggerCount = 8

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Spacing.sm) {
                ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                    let staggerIndex = min(index, maxStaggerCount)

                    RoundedRectangle(cornerRadius: Radius.sm)
                        .fill(.gray.opacity(0.3))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay {
                            Image(photo.name)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
                        .scaleEffect(visiblePhotos.contains(photo.id) ? 1 : 0.8)
                        .opacity(visiblePhotos.contains(photo.id) ? 1 : 0)
                        .animation(
                            .spring(duration: 0.3, bounce: 0.1)
                            // 40ms stagger, capped at 8 items (320ms total)
                            .delay(Double(staggerIndex) * 0.04),
                            value: visiblePhotos.contains(photo.id)
                        )
                }
            }
            .padding()
        }
        .onAppear {
            for photo in photos {
                visiblePhotos.insert(photo.id)
            }
        }
    }
}
```

**Stagger interval guide:**

| Item Count | Interval | Total Cascade | Notes |
|---|---|---|---|
| 3-4 items | 40-50ms | 120-200ms | Full stagger, all clearly visible |
| 5-8 items | 35-40ms | 175-320ms | Tight cascade, under 300ms limit |
| 9-12 items | 30-35ms | 270-420ms | Start capping at 8 |
| 13+ items | 30ms, cap at 8 | 240ms max | Items beyond cap appear simultaneously |

**Critical constraint: keep total stagger duration under 300ms.** A 20-item list at 40ms per item would take 800ms — the last items appear almost a full second after the first, which feels broken. Cap the stagger at 8 items (320ms at 40ms interval). Items beyond the cap animate simultaneously with the 8th item.

**Reference:** Material Design recommends 20-40ms stagger intervals. Apple's iOS Home Screen icon rearrangement uses a similar cascading pattern with ~30ms intervals. The 300ms total cap aligns with the general principle that UI animations should not exceed 300ms for non-cinematic interactions.
