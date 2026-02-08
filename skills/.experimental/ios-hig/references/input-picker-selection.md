---
title: Use Picker for Single-Value Selection
impact: MEDIUM-HIGH
impactDescription: Picker adapts its style to context (wheel, menu, segmented) automatically
tags: input, picker, selection, forms, tag
---

## Use Picker for Single-Value Selection

Picker provides a platform-native selection control that automatically adapts its presentation style based on context -- appearing as a menu in a Form, a wheel in a sheet, or a segmented control when explicitly styled. Building custom selection buttons requires managing highlight state, accessibility labels, and visual feedback manually, and the result will not match the native look and feel.

**Incorrect (custom buttons for selection):**

```swift
struct CategoryPickerView: View {
    @State private var selectedCategory = "Work"
    let categories = ["Work", "Personal", "Shopping", "Health"]

    var body: some View {
        Form {
            ForEach(categories, id: \.self) { category in
                Button { // manual selection with custom highlight logic
                    selectedCategory = category
                } label: {
                    HStack {
                        Text(category)
                        Spacer()
                        if selectedCategory == category {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }
}
```

**Correct (using Picker with ForEach and tag):**

```swift
struct CategoryPickerView: View {
    @State private var selectedCategory = "Work"
    let categories = ["Work", "Personal", "Shopping", "Health"]

    var body: some View {
        Form {
            Picker("Category", selection: $selectedCategory) { // adapts style to context automatically
                ForEach(categories, id: \.self) { category in
                    Text(category).tag(category) // tag matches the selection binding type
                }
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
