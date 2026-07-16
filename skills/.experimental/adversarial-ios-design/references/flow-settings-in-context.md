---
title: Keep task-scoped options in the task and out of Settings
tags: flow, settings, information-architecture, toolbar
---

## Keep task-scoped options in the task and out of Settings

The wrong default is a Settings tree as junk drawer: the library's sort order, a chart's date range, and a screen's show/hide toggles all filed under Settings, forcing the user to leave the task, hunt through a hierarchy, and come back. The HIG scopes settings tightly — "prefer letting people modify task-specific options without going to your settings area… make these options available in the screens they affect" — and bans redundancy with the system: "Respect people's systemwide settings and avoid including redundant versions of them in your custom settings area." An in-app Dark Mode toggle is the canonical redundancy: users who set it once wonder forever why the app ignores the system switch.

**Evidence of violation:** an option whose effect is scoped to a single screen (sort order, filter, view density, chart range) that is reachable only through a settings area — the affected screen exposes no control for it; or an in-app toggle duplicating a systemwide setting: appearance/dark mode, text size, Reduce Motion, Bold Text, haptics on/off. The reviewer cites the setting's declaration and the affected screen's toolbar. PASS: view-scoped options exposed on the screens they affect (a toolbar `Menu`, a segmented control); the custom settings area holding only general, infrequently changed options; system preferences read from the environment. N/A: the target has no settings surface and no view-scoped options.

**Incorrect (the sort lives two screens away from the list it sorts, beside a fake Dark Mode):**

```swift
import SwiftUI

struct ReadingSettingsView: View {
    @AppStorage("librarySort") private var librarySort = LibrarySort.recent
    @AppStorage("forceDarkMode") private var forceDarkMode = false

    var body: some View {
        Form {
            // ⚠️ Option scoped to the Library screen, reachable only here
            Picker("Sort Library By", selection: $librarySort) {
                ForEach(LibrarySort.allCases) { sort in
                    Text(sort.label).tag(sort)
                }
            }
            // ⚠️ Duplicates the systemwide appearance setting
            Toggle("Dark Mode", isOn: $forceDarkMode)
        }
        .navigationTitle("Settings")
    }
}
```

**Correct (the sort sits on the Library toolbar, appearance stays with the system):**

```swift
import SwiftUI

struct LibraryView: View {
    @AppStorage("librarySort") private var librarySort = LibrarySort.recent
    let books: [Book]

    var body: some View {
        List(books.sorted(by: librarySort)) { book in
            BookRow(book: book)
        }
        .navigationTitle("Library")
        .toolbar {
            Menu("Sort", systemImage: "arrow.up.arrow.down") {
                Picker("Sort Library By", selection: $librarySort) {
                    ForEach(LibrarySort.allCases) { sort in
                        Text(sort.label).tag(sort)
                    }
                }
            }
        }
    }
}
```

Reference: [HIG — Settings](https://developer.apple.com/design/human-interface-guidelines/settings)
