---
title: Design List Cells with Standard Layouts
impact: HIGH
impactDescription: standard cell layouts reduce user comprehension time by 2-3× vs custom layouts — eliminates 30-50 lines of manual HStack/VStack per cell by leveraging built-in Label, LabeledContent, and NavigationLink patterns
tags: product, list, cells, edson-product-marketing, kocienda-demo, component
---

## Design List Cells with Standard Layouts

Edson's "the product is the marketing" means list cells ARE the product for many apps — the inbox, the settings screen, the search results. When cells follow Apple's standard patterns (leading icon, primary text, secondary text, trailing accessory), users understand the interface instantly because they've seen this pattern thousands of times in Mail, Settings, and Messages. Kocienda's demo culture valued interfaces that needed zero explanation; standard cell layouts are self-explanatory.

**Incorrect (non-standard layout — title below subtitle, accessories scattered):**

```swift
HStack {
    VStack {
        Text("Subtitle")
            .font(.caption)
        Text("Title")
            .font(.headline)
    }
    Spacer()
    Image(systemName: "star")
    Text("Detail")
}
```

**Correct (standard cell patterns):**

```swift
// Basic cell with navigation disclosure
List {
    ForEach(items) { item in
        NavigationLink(value: item) {
            Text(item.name)
        }
    }
}

// Subtitle cell
List {
    ForEach(items) { item in
        NavigationLink(value: item) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// Icon + text cell (Settings style)
List {
    ForEach(settings) { setting in
        Label(setting.name, systemImage: setting.icon)
    }
}

// Value cell (detail on trailing edge)
List {
    LabeledContent("Version", value: "2.1.0")
    LabeledContent("Build", value: "142")
}
```

**Standard cell anatomy:**
- **Leading:** Icon (SF Symbol or avatar, 28-40pt) or nothing
- **Primary text:** `.body` or `.headline`, one line
- **Secondary text:** `.subheadline` + `.secondary`, one line
- **Trailing:** Accessory (chevron, value, badge) or nothing

**When NOT to use standard cells:** Photo-centric feeds, card-based layouts, and dashboard widgets need custom designs. Standard cells are for lists of homogeneous data items.

Reference: [Lists and tables - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/lists-and-tables)
