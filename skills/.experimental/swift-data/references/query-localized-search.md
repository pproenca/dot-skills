---
title: Use localizedStandardContains for Search
impact: MEDIUM
impactDescription: fixes 100% of missed search results from case/diacritic mismatch
tags: query, search, localization, predicate
---

## Use localizedStandardContains for Search

Using `.contains()` for search text matching is case-sensitive and breaks with accented characters. `localizedStandardContains` handles case, diacritics, and locale variations automatically — matching how users expect search to work on Apple platforms.

**Incorrect (case-sensitive, diacritic-sensitive matching):**

```swift
let predicate = #Predicate<Friend> { friend in
    // "café" won't match "Cafe", "CAFÉ" won't match "café"
    friend.name.contains(searchText)
}
```

**Correct (locale-aware, case-insensitive, diacritic-insensitive):**

```swift
let predicate = #Predicate<Friend> { friend in
    // Matches regardless of case or accents: "cafe" matches "Café", "CAFE", etc.
    friend.name.localizedStandardContains(searchText)
}
```

**Benefits:**
- Matches "cafe" to "Café", "CAFÉ", "café", and "Cafe"
- Follows the same search behavior as Spotlight, Mail, and other Apple apps
- Respects the user's locale settings for language-specific matching rules

Reference: [Develop in Swift — Create, Update, and Delete Data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
