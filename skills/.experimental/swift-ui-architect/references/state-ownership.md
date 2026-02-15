---
title: Use @State for Owned Data, Plain Property for Injected Data
impact: CRITICAL
impactDescription: prevents 100% of stale-copy bugs from misplaced @State ownership
tags: state, ownership, state-property, injection, lifecycle
---

## Use @State for Owned Data, Plain Property for Injected Data

`@State` creates and owns storage — the value survives view re-creation. Use `@State` ONLY in the view that creates the data (typically the ViewModel's owning view). Child views receiving data from parents use plain stored properties (`let`/`var`). Using `@State` for injected data creates a COPY that diverges from the source.

**Incorrect (child using @State for injected value — creates independent copy):**

```swift
struct ParentView: View {
    @State var username: String = "Pedro"

    var body: some View {
        VStack {
            Text("Parent: \(username)")
            // Passes current value, but child COPIES it into its own @State
            ChildView(username: username)
            Button("Update") { username = "Updated Pedro" }
        }
    }
}

struct ChildView: View {
    // BUG: @State creates an independent copy on first render
    // Parent's "Update" button changes will NEVER propagate here
    @State var username: String

    var body: some View {
        Text("Child: \(username)") // Shows stale "Pedro" forever
    }
}
```

**Correct (child using plain let — always reflects parent's current value):**

```swift
struct ParentView: View {
    @State var username: String = "Pedro"

    var body: some View {
        VStack {
            Text("Parent: \(username)")
            ChildView(username: username)
            Button("Update") { username = "Updated Pedro" }
        }
    }
}

struct ChildView: View {
    let username: String  // plain property — always reflects parent's value

    var body: some View {
        Text("Child: \(username)") // Updates when parent changes
    }
}
```

**Rule of thumb:**
- `@State` — view CREATES and OWNS this data
- `let` — view RECEIVES this data from a parent
- `@Binding` — view receives AND CAN MUTATE this data (see binding rule)

Reference: [Apple Documentation — Managing model data in your app](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)
