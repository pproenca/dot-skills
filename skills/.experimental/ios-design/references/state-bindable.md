---
title: "Use @Bindable to Create Bindings from Observable Objects"
impact: HIGH
impactDescription: "eliminates manual state mirroring; creates direct bindings from @Observable"
tags: state, swiftui, bindable, observable, forms
---

## Use @Bindable to Create Bindings from Observable Objects

SwiftUI controls like `TextField` and `Toggle` require `Binding` values, but `@Observable` objects do not automatically expose `$property` syntax in views. `@Bindable` enables the `$` prefix on an observable instance so its properties can be passed directly to controls without manual state mirroring.

**Incorrect (manual state mirroring duplicates source of truth):**

```swift
@Observable
class Book {
    var title = ""
    var isFavorite = false
}

struct BookEditView: View {
    var book: Book
    @State private var draftTitle = "" // duplicated state, easily drifts
    @State private var draftIsFavorite = false

    var body: some View {
        Form {
            TextField("Title", text: $draftTitle)
            Toggle("Favorite", isOn: $draftIsFavorite)
            Button("Save") {
                book.title = draftTitle
                book.isFavorite = draftIsFavorite
            }
        }
        .onAppear {
            draftTitle = book.title
            draftIsFavorite = book.isFavorite
        }
    }
}
```

**Correct (@Bindable creates bindings directly from the observable model):**

```swift
@Observable
class Book {
    var title = ""
    var isFavorite = false
}

struct BookEditView: View {
    @Bindable var book: Book // enables $book.property bindings

    var body: some View {
        Form {
            TextField("Title", text: $book.title)
            Toggle("Favorite", isOn: $book.isFavorite)
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
