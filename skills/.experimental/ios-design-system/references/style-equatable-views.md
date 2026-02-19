---
title: Apply @Equatable to Every Design System View
impact: CRITICAL
impactDescription: Airbnb measured 15% scroll hitch reduction after enforcing @Equatable — non-diffable views re-evaluate body on every parent update
tags: style, equatable, diffing, performance, airbnb
---

## Apply @Equatable to Every Design System View

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

Design system components appear hundreds of times in a typical app — a `CardView` in a feed, a `Badge` in every list row. If these views are not diffable, SwiftUI's reflection-based diffing fails silently and re-evaluates every body on every parent state change. Airbnb mandates `@Equatable` on every view. For design system components that are instantiated most frequently, this is the single highest-impact performance optimization.

**Incorrect (no @Equatable — design system views force full re-evaluation):**

```swift
struct MetricCard: View {
    let title: String
    let value: String
    let trend: TrendDirection

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: Spacing.xxs) {
                Text(value)
                    .font(.title2.bold())
                Image(systemName: trend.iconName)
                    .foregroundStyle(trend.color)
            }
        }
        .padding(Spacing.md)
        .background(.backgroundSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }
}
// In a dashboard with 12 MetricCards, changing ONE card's value
// re-evaluates ALL 12 bodies because SwiftUI can't diff them
```

**Correct (@Equatable — only changed views re-evaluate):**

```swift
@Equatable
struct MetricCard: View {
    let title: String
    let value: String
    let trend: TrendDirection

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: Spacing.xxs) {
                Text(value)
                    .font(.title2.bold())
                Image(systemName: trend.iconName)
                    .foregroundStyle(trend.color)
            }
        }
        .padding(Spacing.md)
        .background(.backgroundSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }
}
// Now only the MetricCard whose value actually changed re-evaluates.
// The other 11 skip body evaluation entirely.
```

**For views with closure properties, use @SkipEquatable:**

```swift
@Equatable
struct ActionCard: View {
    let title: String
    let subtitle: String
    @SkipEquatable
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            .padding(Spacing.md)
            .background(.backgroundSurface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        }
        .buttonStyle(.plain)
    }
}
```

**Prerequisite:** The `@Equatable` macro requires the [`ordo-one/equatable`](https://github.com/ordo-one/equatable) SPM package. The open-source package uses `@EquatableIgnored` instead of `@SkipEquatable` (Airbnb's internal name). Alternatively, manually conform to `Equatable` and use the `.equatable()` modifier.

**Benefits:**
- 15% scroll hitch reduction measured at Airbnb after enforcing @Equatable
- Compile-time guarantee: adding a non-Equatable property without @SkipEquatable fails the build
- Design system components are the highest-leverage targets since they appear most frequently

Reference: [Airbnb — Understanding and Improving SwiftUI Performance](https://airbnb.tech/uncategorized/understanding-and-improving-swiftui-performance/), [ordo-one/equatable](https://github.com/ordo-one/equatable)
