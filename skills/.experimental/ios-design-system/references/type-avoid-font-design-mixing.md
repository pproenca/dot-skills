---
title: Use One Font Design Per App (Default, Rounded, Serif, or Monospaced)
impact: HIGH
impactDescription: mixing font designs (rounded titles with default body) creates visual dissonance — Apple uses a single design per app context
tags: type, font-design, consistency, visual-coherence
---

## Use One Font Design Per App (Default, Rounded, Serif, or Monospaced)

SwiftUI offers four font designs: `.default` (SF Pro), `.rounded` (SF Pro Rounded), `.serif` (New York), and `.monospaced` (SF Mono). Each has a distinct personality. Mixing them on the same screen — rounded for playful headers but default for body text — creates a visual identity crisis. Apple is strict about this: Freeform uses rounded throughout, Books uses serif for reading, and most apps stick to default.

**Incorrect (mixed font designs):**

```swift
struct DashboardView: View {
    var body: some View {
        VStack {
            // Rounded for the title — "playful" feel
            Text("Good Morning!")
                .font(.largeTitle.weight(.bold))
                .fontDesign(.rounded)

            // Default for body — back to "professional"
            Text("You have 5 tasks today")
                .font(.body)
            // ^^^ no .fontDesign, so it's .default

            // Serif for a quote — now we're literary?
            Text("\"The journey of a thousand miles...\"")
                .font(.callout)
                .fontDesign(.serif)

            // Three different visual personalities on one screen
        }
    }
}
```

**Correct (single font design applied globally):**

```swift
// Option A: Apply at the app root — every view inherits it
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .fontDesign(.rounded) // Entire app uses rounded
        }
    }
}

// All views automatically use SF Pro Rounded:
struct DashboardView: View {
    var body: some View {
        VStack {
            Text("Good Morning!")
                .font(.largeTitle.weight(.bold))

            Text("You have 5 tasks today")
                .font(.body)

            // Both use .rounded from the environment — no per-view overrides
        }
    }
}
```

**Acceptable exception — monospaced for code or data within a non-monospaced app:**

```swift
// App uses .default (SF Pro) everywhere, except code blocks
struct CodeSnippetView: View {
    let code: String

    var body: some View {
        ScrollView(.horizontal) {
            Text(code)
                .font(.body.monospaced()) // Exception: code content
                .padding(Spacing.md)
                .background(.fill.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
        }
    }
}

// Also acceptable: monospaced for tabular numbers in a default-design app
Text(price, format: .currency(code: "USD"))
    .monospacedDigit() // Aligns decimal points, not a design change
```

**Decision guide:**

| Font Design | Personality | Good For |
|-------------|------------|----------|
| `.default` | Professional, neutral | Most apps |
| `.rounded` | Friendly, approachable | Health, fitness, kids, casual apps |
| `.serif` | Literary, premium | Reading, editorial, luxury |
| `.monospaced` | Technical, precise | Developer tools, terminals |

Pick one. Apply it at the root. Move on.
