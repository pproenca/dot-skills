---
title: Support Dark Mode from Day One
impact: CRITICAL
impactDescription: 82% of iPhone users have Dark Mode enabled at least part-time — shipping without Dark Mode support means broken visuals for the majority of your audience
tags: empathy, dark-mode, appearance, kocienda-empathy, edson-people, color
---

## Support Dark Mode from Day One

Kocienda describes how the iPhone team tested keyboard prototypes under every condition — walking, one-handed, in bright sunlight. Empathy meant understanding that the user wouldn't always be sitting at a desk with perfect lighting. Dark Mode is the same principle: the user reading your app in bed, in a dark theater, or in a car at night deserves the same quality experience as the person in a well-lit office. Edson's "design is about people" demands that you serve every context, not just the one you develop in.

**Incorrect (custom colors without Dark Mode variants):**

```swift
struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.title)
                .font(.headline)
                .foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.1))

            Text(recipe.description)
                .font(.subheadline)
                .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.5))
        }
        .padding()
        // Stark white in Dark Mode — blinds the user
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

**Correct (asset catalog colors with light and dark variants):**

```swift
struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(recipe.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

**Custom color Dark Mode checklist:**
1. Define every custom color in the asset catalog with "Any" and "Dark" appearances
2. Never use `Color(red:green:blue:)` for UI elements — always reference named colors
3. Use Xcode's "Appearance" toggle in previews to test both modes
4. Run the app with Dark Mode enabled before every PR

**When NOT to customize:** System colors (`.primary`, `.secondary`, `.accent`) already adapt. Only create custom named colors when your brand palette requires specific values beyond the system palette.

Reference: [Dark Mode - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/dark-mode)
