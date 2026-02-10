---
title: Show Appropriate Loading Indicators
impact: HIGH
impactDescription: users abandon screens with no loading feedback after 3-5 seconds — appropriate indicators reduce perceived wait time by 40%
tags: feed, loading, progress, spinner
---

## Show Appropriate Loading Indicators

Always show loading state during async operations. Use progress indicators for known durations and activity indicators for unknown durations. Never leave users wondering.

**Incorrect (no loading feedback):**

```swift
// Button with no loading state
Button("Submit") {
    await submit() // User has no idea it's working
}

// Empty screen during load
if items.isEmpty {
    Text("No items") // Shown during load too
}

// Full-screen spinner for quick loads
if isLoading {
    ProgressView()
        .scaleEffect(2)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
// Overkill for sub-second operations
```

**Correct (appropriate loading feedback):**

```swift
// Button with loading state
Button {
    isSubmitting = true
    await submit()
    isSubmitting = false
} label: {
    if isSubmitting {
        ProgressView()
    } else {
        Text("Submit")
    }
}
.disabled(isSubmitting)

// List with loading, empty, and content states
Group {
    if isLoading {
        ProgressView("Loading items...")
    } else if items.isEmpty {
        ContentUnavailableView(
            "No Items",
            systemImage: "tray",
            description: Text("Items you add will appear here")
        )
    } else {
        List(items) { item in
            ItemRow(item: item)
        }
    }
}

// Progress bar for known duration
ProgressView(value: progress, total: 100) {
    Text("Uploading...")
} currentValueLabel: {
    Text("\(Int(progress))%")
}

// Inline loading for partial refresh
List {
    ForEach(items) { item in
        ItemRow(item: item)
    }
    if isLoadingMore {
        ProgressView()
            .frame(maxWidth: .infinity)
    }
}
```

**Loading indicator types:**
| Type | Usage |
|------|-------|
| Activity indicator | Unknown duration |
| Progress bar | Known progress |
| Skeleton/placeholder | Content shape known |
| Inline spinner | Partial updates |

Reference: [Progress indicators - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/progress-indicators)
