---
title: Give every primary content view a designed empty state
tags: state, empty-state, contentunavailableview, search
---

## Give every primary content view a designed empty state

The wrong default is binding a `List`, `ForEach`, or grid directly to a fetched or user-created collection and stopping there: when the collection is empty — a new user, a cleared filter, a search with no hits — the screen renders as a blank void under a navigation title, and the user cannot tell an empty account from a broken app. Every screen whose main content is such a collection needs an explicit empty branch that renders a designed view: `ContentUnavailableView` with a label and description (and a call-to-action where one exists), `ContentUnavailableView.search` for empty search results, or an equivalent designed view — Apple's own apps often show the visualization skeleton instead (an empty activity ring, chart axes with no data points), which satisfies this rule equally.

**Evidence of violation:** a screen whose primary content is a `List`/`ForEach`/`LazyVGrid` (or similar) over fetched or user-created data with no `isEmpty` branch (or equivalent `.overlay`/`switch` on a load-state enum) producing a designed empty view — the absence of the branch is FAIL, not N/A; a `.searchable` screen whose filtered results have no empty-results view; a tab section that renders nothing when its content is unavailable. PASS: `ContentUnavailableView { Label(...) } description: { ... }` (with an action where creation is possible), `ContentUnavailableView.search` for zero results, or a custom designed view with at least an explanation of why the content is absent — the reviewer must cite the branch and the view it produces. N/A: collections that are compile-time constant and can never be empty — the reviewer must cite the constant source; absent that evidence, fail closed. N/A: no collection-driven primary content in the target.

**Incorrect (an empty account renders as a blank screen indistinguishable from a failure):**

```swift
import SwiftUI

struct SavedWord: Identifiable {
    let id = UUID()
    var term = ""
    var translation = ""
}

struct SavedWordsView: View {
    let words: [SavedWord]

    var body: some View {
        // ⚠️ When `words` is empty this List renders nothing at all
        List(words) { word in
            LabeledContent(word.term, value: word.translation)
        }
        .navigationTitle("Saved Words")
    }
}
```

**Correct (the empty case explains itself and offers the next step):**

```swift
import SwiftUI

struct SavedWord: Identifiable {
    let id = UUID()
    var term = ""
    var translation = ""
}

struct SavedWordsView: View {
    let words: [SavedWord]
    let startLesson: () -> Void

    var body: some View {
        Group {
            if words.isEmpty {
                ContentUnavailableView {
                    Label("No Saved Words", systemImage: "character.book.closed")
                } description: {
                    Text("Words you save during lessons appear here.")
                } actions: {
                    Button("Start a Lesson", action: startLesson)
                        .buttonStyle(.borderedProminent)
                }
            } else {
                List(words) { word in
                    LabeledContent(word.term, value: word.translation)
                }
            }
        }
        .navigationTitle("Saved Words")
    }
}
```

Reference: [ContentUnavailableView](https://developer.apple.com/documentation/swiftui/contentunavailableview), [HIG — Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars)
