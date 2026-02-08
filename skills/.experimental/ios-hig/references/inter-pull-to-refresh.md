---
title: Support Pull-to-Refresh for Lists
impact: MEDIUM
impactDescription: enables manual refresh using familiar iOS gesture
tags: inter, pull-to-refresh, list, refresh
---

## Support Pull-to-Refresh for Lists

Implement pull-to-refresh for scrollable content that can be updated from a server. Use the system `.refreshable` modifier for consistent behavior.

**Incorrect (non-standard refresh):**

```swift
// Manual refresh button instead of pull
VStack {
    Button("Refresh") {
        loadData()
    }
    List(items) { item in
        ItemRow(item: item)
    }
}
// Users expect pull gesture

// Custom pull implementation that feels wrong
List {
    // content
}
.simultaneousGesture(
    DragGesture()
        .onEnded { _ in
            loadData() // No visual feedback, wrong timing
        }
)
```

**Correct (system pull-to-refresh):**

```swift
// SwiftUI refreshable
List(items) { item in
    ItemRow(item: item)
}
.refreshable {
    await loadData()
}

// With custom content
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}
.refreshable {
    await loadData()
}

// UIKit implementation
class ItemsViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(
            self,
            action: #selector(refresh),
            for: .valueChanged
        )
    }

    @objc func refresh() {
        loadData { [weak self] in
            self?.refreshControl?.endRefreshing()
        }
    }
}

// Combine with loading state
List {
    if isLoading && items.isEmpty {
        ProgressView()
    } else {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}
.refreshable {
    await loadData()
}
```

**Pull-to-refresh guidelines:**
- Only for server-refreshable content
- Use system implementation for consistent feel
- Show activity indicator during refresh
- Update content when complete
- Works with List, ScrollView
- Don't use for offline-only content

Reference: [Loading - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/loading)
