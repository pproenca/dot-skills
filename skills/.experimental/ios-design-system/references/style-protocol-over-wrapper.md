---
title: Use Style Protocols Instead of Wrapper Views for Styling
impact: HIGH
impactDescription: eliminates 1-3 wrapper nesting levels per component and prevents 100% of context-breaking bugs in menus, forms, and swipe actions
tags: style, protocol, ButtonStyle, composition, swiftui
---

## Use Style Protocols Instead of Wrapper Views for Styling

SwiftUI provides dedicated Style protocols for most controls: `ButtonStyle`, `ToggleStyle`, `LabelStyle`, `TextFieldStyle`, `GroupBoxStyle`, `ProgressViewStyle`, and more. These protocols integrate with SwiftUI's rendering pipeline and respect context — a `ButtonStyle` adapts to `.controlSize`, responds to `.disabled()`, and works correctly in menus, swipe actions, and forms. Wrapper views bypass all of this and create a parallel component system that doesn't compose.

**Incorrect (wrapper view that breaks context):**

```swift
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(AppTypography.headlinePrimary)
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(.accentPrimary)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        }
    }
}

// Problems:
// 1. Cannot be used in .swipeActions { } — SwiftUI expects raw Button
// 2. Ignores .controlSize — always the same size
// 3. Ignores .disabled() styling — stays fully opaque
// 4. Cannot use Button("Title", role: .destructive) — title is baked in
// 5. Cannot use Button with custom label views
```

**Correct (ButtonStyle that composes with SwiftUI):**

```swift
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.headlinePrimary)
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(isEnabled ? .accentPrimary : .fill.tertiary)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { .init() }
}

// Usage — works with ANY Button initializer:
Button("Submit", action: submit)
    .buttonStyle(.primary)

Button(action: submit) {
    Label("Submit", systemImage: "paperplane")
}
.buttonStyle(.primary)

// Respects modifiers:
Button("Submit", action: submit)
    .buttonStyle(.primary)
    .controlSize(.large) // Style can read this
    .disabled(isLoading)  // Style dims automatically
```

**When to use a View vs a Style:**

| Use a **View** when... | Use a **Style** when... |
|------------------------|------------------------|
| The component has its own state or data model | You're only changing the visual appearance |
| It wraps multiple controls into a compound component | The underlying control is a standard SwiftUI type |
| It manages layout of children | The control needs to work in SwiftUI context (forms, menus) |

```swift
// VIEW — compound component with its own data
struct SearchBar: View {
    @Binding var query: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search", text: $query)
            if !query.isEmpty {
                Button("Clear") { query = "" }
            }
        }
    }
}

// STYLE — visual treatment via ViewModifier (TextFieldStyle lacks public body method)
struct SearchFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            content
        }
        .padding(Spacing.sm)
        .background(.fill.quaternary)
        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
    }
}

extension View {
    func searchFieldStyle() -> some View { modifier(SearchFieldModifier()) }
}
```

Default to Style protocols. Only reach for wrapper Views when the component is genuinely compound.
