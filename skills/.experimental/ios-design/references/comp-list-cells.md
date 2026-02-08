---
title: Design List Cells with Standard Layouts
impact: HIGH
impactDescription: maintains consistency with system apps and user expectations
tags: comp, list, cells, tables
---

## Design List Cells with Standard Layouts

Use standard list cell layouts with leading icon/image, primary and secondary text, and trailing accessories. This matches user expectations from system apps.

**Incorrect (non-standard cell layouts):**

```swift
// Random arrangement
HStack {
    VStack {
        Text("Subtitle")
        Text("Title")
    }
    Spacer()
    Image(systemName: "star")
    Text("Detail")
}

// Too much content crammed in
HStack {
    Image("photo")
    VStack {
        Text("Title")
        Text("Subtitle")
        Text("Description")
        Text("More info")
    }
    VStack {
        Text("Status")
        Text("Date")
    }
    Image(systemName: "chevron.right")
}
```

**Correct (standard cell patterns):**

```swift
// Basic cell with accessory
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
            VStack(alignment: .leading) {
                Text(item.name)
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// Cell with icon
List {
    ForEach(settings) { setting in
        Label(setting.name, systemImage: setting.icon)
    }
}

// Cell with trailing detail
List {
    HStack {
        Text("Version")
        Spacer()
        Text("2.1.0")
            .foregroundColor(.secondary)
    }
}

// Cell with image
List {
    ForEach(contacts) { contact in
        HStack {
            contact.avatar
                .frame(width: 44, height: 44)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(contact.name)
                Text(contact.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
```

**Standard accessories:**
- Disclosure indicator (chevron): NavigationLink
- Detail button (i): More info
- Checkmark: Selection
- Switch: Toggle setting

Reference: [Lists and tables - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/lists-and-tables)
