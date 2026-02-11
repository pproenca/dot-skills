---
title: Use SF Symbols Before Custom Icons
impact: MEDIUM-HIGH
impactDescription: SF Symbols are free, scale with Dynamic Type, support all rendering modes, and auto-adapt to weight — custom icons require 3 sizes x 2 appearance variants = 6 assets per icon
tags: asset, sf-symbols, icons, maintenance, scalability
---

## Use SF Symbols Before Custom Icons

Every custom icon asset is a maintenance liability: it needs @1x/@2x/@3x variants (or a PDF vector), light/dark variants, and manual weight matching to adjacent text. SF Symbols handle all of this automatically and match the system font weight of surrounding text. With 5,000+ symbols in SF Symbols 5, most common actions already have a high-quality glyph.

**Incorrect (custom PNG icons for common actions):**

```swift
// TabBarView.swift — custom assets for standard actions
struct TabBarView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image("tab-home")       // Custom PNG, doesn't scale with Dynamic Type
                    Text("Home")
                }
            SearchView()
                .tabItem {
                    Image("tab-search")     // Custom PNG, fixed weight
                    Text("Search")
                }
            ProfileView()
                .tabItem {
                    Image("tab-profile")    // Custom PNG, no weight adaptation
                    Text("Profile")
                }
        }
    }
}
```

**Correct (SF Symbols for standard actions, custom only for brand-specific):**

```swift
struct TabBarView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}

// Only use custom assets for brand-specific icons with no SF Symbol match
struct PartnerBadge: View {
    var body: some View {
        Image("brand-partner-badge")    // Unique brand mark, no system equivalent
            .renderingMode(.template)
            .foregroundStyle(.accentPrimary)
    }
}
```

Before requesting a custom icon from design, search the SF Symbols app (or `SFSymbolReference.com`) for a match. If no exact match exists, check if a related symbol with a custom rendering mode works. Only create a custom asset when no SF Symbol is even close.
