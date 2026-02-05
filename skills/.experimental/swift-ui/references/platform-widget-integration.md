---
title: Design for Widget and Live Activity Integration
impact: MEDIUM
impactDescription: enables 40% more daily user touchpoints via home screen
tags: platform, widgets, live-activity, home-screen, extension
---

## Design for Widget and Live Activity Integration

Widgets and Live Activities extend your app beyond the main interface. Design shared components and data models that work across both.

**Incorrect (duplicate code for widget):**

```swift
// Main app
struct WorkoutProgressView: View {
    let workout: Workout

    var body: some View {
        VStack {
            Text("\(workout.elapsedTime.formatted())")
            Text("\(workout.caloriesBurned) cal")
        }
    }
}

// Widget - completely separate implementation
struct WorkoutWidgetView: View {
    let entry: WorkoutEntry

    var body: some View {
        // Duplicated layout logic
        // Different data model
        // Inconsistent appearance
        VStack {
            Text("\(entry.time)")
            Text("\(entry.calories)")
        }
    }
}
```

**Correct (shared components via App Group):**

```swift
// Shared framework
struct WorkoutProgress: Codable {
    let elapsedTime: TimeInterval
    let caloriesBurned: Int
}

struct WorkoutProgressView: View {
    let progress: WorkoutProgress
    @Environment(\.widgetFamily) var family  // nil in main app

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                CompactView(progress: progress)
            default:
                FullView(progress: progress)
            }
        }
    }
}

// Works in both app and widget
// Single source of truth for layout
```

**Share data via App Group:**

```swift
extension UserDefaults {
    static let shared = UserDefaults(suiteName: "group.com.app.fitness")!
}

// Main app writes
UserDefaults.shared.set(encoded, forKey: "workout")

// Widget reads
let workout = UserDefaults.shared.data(forKey: "workout")
```

**Updating widgets:**

```swift
// Refresh widget timeline
WidgetCenter.shared.reloadAllTimelines()
```

**Design considerations:**
- Widgets are read-only snapshots
- Use `.containerBackground()` for backgrounds
- Keep text concise - widgets are glanceable
- Deep link to relevant app sections

Reference: [Human Interface Guidelines - Widgets](https://developer.apple.com/design/human-interface-guidelines/widgets)
