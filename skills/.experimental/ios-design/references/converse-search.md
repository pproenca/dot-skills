---
title: Integrate Search with the Searchable Modifier
impact: HIGH
impactDescription: saves 50-150 lines of custom search UI code — .searchable provides 5+ system behaviors for free (pull-to-reveal, Cmd+F shortcut, voice search, suggestions, cancel button) and matches the pattern 100% of iOS users already know
tags: converse, search, searchable, kocienda-demo, edson-conversation, discovery
---

## Integrate Search with the Searchable Modifier

Edson's conversation principle means search is a question the user asks the app — and the app should answer using the standard iOS search language that every user already understands. Kocienda's demo culture demanded that features work exactly as the user expects; `.searchable` provides the standard search bar placement, keyboard behavior, suggestions UI, and cancel button that users know from every Apple app.

**Incorrect (custom search field that misses system behavior):**

```swift
struct RecipeListView: View {
    @State private var searchText = ""

    var body: some View {
        VStack {
            // Custom search bar — misses pull-to-reveal, cancel button, suggestions
            TextField("Search recipes...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            List(filteredRecipes) { recipe in
                RecipeRow(recipe: recipe)
            }
        }
    }
}
```

**Correct (searchable modifier with standard behavior):**

```swift
struct RecipeListView: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List(filteredRecipes) { recipe in
                NavigationLink(value: recipe) {
                    RecipeRow(recipe: recipe)
                }
            }
            .searchable(text: $searchText, prompt: "Search recipes")
            .navigationTitle("Recipes")
        }
    }

    private var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return recipes
        }
        return recipes.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
}
```

**Search with suggestions:**

```swift
.searchable(text: $searchText) {
    ForEach(searchSuggestions) { suggestion in
        Text(suggestion.title)
            .searchCompletion(suggestion.title)
    }
}
```

**Search scopes for filtering categories:**

```swift
.searchable(text: $searchText)
.searchScopes($searchScope) {
    Text("All").tag(SearchScope.all)
    Text("Breakfast").tag(SearchScope.breakfast)
    Text("Dinner").tag(SearchScope.dinner)
    Text("Dessert").tag(SearchScope.dessert)
}
```

**When NOT to use searchable:** Screens where the content is small enough to scan visually (< 10 items), or where filtering is better served by a segmented control or picker.

Reference: [Search - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/search)
