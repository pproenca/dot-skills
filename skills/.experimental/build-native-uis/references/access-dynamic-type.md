---
title: Support Dynamic Type for All Text
impact: MEDIUM
impactDescription: 15-20% of users adjust text size, hardcoded fonts ignore their preference
tags: access, dynamic-type, font, text, typography
---

## Support Dynamic Type for All Text

Between 15 and 20 percent of users change their preferred text size in Settings. When you use hardcoded font sizes, your text stays fixed regardless of the user's preference, making your app difficult or impossible to read for those who need larger text.

**Incorrect (hardcoded font sizes ignore Dynamic Type):**

```swift
struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.title)
                .font(.system(size: 20, weight: .bold))
            Text(recipe.author)
                .font(.system(size: 14))
            Text(recipe.description)
                .font(.system(size: 16))
        }
        .padding()
    }
}
```

**Correct (semantic fonts that scale with Dynamic Type):**

```swift
struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.title)
                .font(.headline) // scales automatically with user's text size setting
            Text(recipe.author)
                .font(.subheadline)
            Text(recipe.description)
                .font(.body)
        }
        .padding()
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
