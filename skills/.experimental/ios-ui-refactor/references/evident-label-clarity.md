---
title: Use Clear Labels Over Ambiguous Icons
impact: HIGH
impactDescription: unlabeled icons force trial-and-error discovery — users cannot tap what they cannot identify, and icon-only interfaces see significantly lower feature adoption than labeled ones
tags: evident, labels, icons, rams-4, segall-human, discoverability
---

## Use Clear Labels Over Ambiguous Icons

A tiny square with an arrow pointing up. Is that share? Export? Upload? You hesitate for just a moment — but that moment is a crack in your confidence. Multiply it across five unlabeled toolbar icons and the interface becomes a guessing game, each tap a small leap of faith. The frustration is quiet but real: the app is speaking in pictograms and expecting you to translate. Words dissolve that ambiguity instantly. A label beneath the icon turns a riddle into a statement. Apple's own tab bars always pair icons with text because even familiar glyphs carry just enough uncertainty to slow you down. Self-evident design speaks the user's language, not in symbols that demand interpretation.

**Incorrect (icon-only toolbar, no labels):**

```swift
struct DocumentToolbar: View {
    var body: some View {
        HStack(spacing: 24) {
            // What does each icon mean? Users must tap to find out.
            Button(action: {}) { Image(systemName: "doc.on.doc") }
            Button(action: {}) { Image(systemName: "arrow.uturn.backward") }
            Button(action: {}) { Image(systemName: "textformat.size") }
            Button(action: {}) { Image(systemName: "rectangle.and.pencil.and.ellipsis") }
            Button(action: {}) { Image(systemName: "ellipsis.circle") }
        }
        .font(.title3)
    }
}
```

**Correct (labels paired with icons, or at minimum, accessibility labels):**

```swift
struct DocumentToolbar: View {
    var body: some View {
        HStack(spacing: 16) {
            // Labels make every action instantly understandable
            Button(action: {}) {
                Label("Duplicate", systemImage: "doc.on.doc")
            }
            Button(action: {}) {
                Label("Undo", systemImage: "arrow.uturn.backward")
            }
            Button(action: {}) {
                Label("Format", systemImage: "textformat.size")
            }
            Menu {
                Button("Rename", systemImage: "pencil") {}
                Button("Move", systemImage: "folder") {}
                Button("Delete", role: .destructive) {}
            } label: {
                Label("More", systemImage: "ellipsis.circle")
            }
        }
        .labelStyle(.titleAndIcon)
        .font(.subheadline)
    }
}
```

**When to use labels with icons:**

```swift
// Tab bars: ALWAYS show labels
TabView {
    Text("Home").tabItem {
        Label("Home", systemImage: "house.fill")
    }
    Text("Search").tabItem {
        Label("Search", systemImage: "magnifyingglass")
    }
}

// Toolbars on iPad: show labels (.titleAndIcon)
// Toolbars on iPhone: icon-only acceptable BUT add accessibility labels
struct CompactToolbar: View {
    var body: some View {
        HStack {
            Button(action: {}) {
                Label("Duplicate", systemImage: "doc.on.doc")
            }
            .labelStyle(.iconOnly)
            .accessibilityLabel("Duplicate")
        }
    }
}

// Primary actions: always show labels
Button {
    // action
} label: {
    Label("Add to Cart", systemImage: "cart.fill")
        .frame(maxWidth: .infinity)
}
.buttonStyle(.borderedProminent)
```

**When NOT to apply:**
- Universal media controls (play/pause, skip, volume) where the icons are globally understood across all platforms and cultures
- iOS navigation bar items where space is extremely constrained — but still provide `.accessibilityLabel()`

**Benefits:**
- Reduces onboarding friction — users discover features immediately without trial-and-error
- Passes WCAG 2.5.3 (Label in Name) — accessibility users can navigate by spoken labels
- Survives icon redesigns — even if SF Symbols change, the text label remains constant

Reference: [Apple HIG — Labels](https://developer.apple.com/design/human-interface-guidelines/labels)
