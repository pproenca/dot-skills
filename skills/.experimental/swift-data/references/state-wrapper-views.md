---
title: Extract Wrapper Views for Dynamic Query State
impact: MEDIUM
impactDescription: enables dynamic @Query filtering with 0 manual refresh logic
tags: state, wrapper-view, dynamic-query, architecture
---

## Extract Wrapper Views for Dynamic Query State

When a `@Query` depends on user input (search text, filter selection), the `@State` driving that input must live in a parent view. This is because `@Query` is configured in the view's `init`, and `@State` values from the same view are not available at init time. Extract a wrapper view that holds the `@State` and passes it to a child view whose `init` constructs the `@Query` with the current filter value.

**Incorrect (single view with both @State and @Query — cannot pass state to Query init):**

```swift
@Equatable
struct MovieListScreen: View {
    @State private var searchText = ""
    // ERROR: Cannot use 'searchText' in @Query — @State is not
    // initialized when @Query property wrapper evaluates
    @Query(filter: #Predicate<Movie> { $0.title.contains(searchText) })
    private var movies: [Movie]

    var body: some View {
        List(movies) { movie in
            Text(movie.title)
        }
        .searchable(text: $searchText)
    }
}
```

**Correct (wrapper view holds @State, child view builds Query in init):**

```swift
// Wrapper: owns the search state
@Equatable
struct MovieListScreen: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            MovieList(titleFilter: searchText)
                .searchable(text: $searchText)
        }
    }
}

// Child: builds @Query from the filter parameter
@Equatable
struct MovieList: View {
    @Query private var movies: [Movie]

    init(titleFilter: String) {
        let predicate = #Predicate<Movie> { movie in
            titleFilter.isEmpty || movie.title.localizedStandardContains(titleFilter)
        }
        _movies = Query(filter: predicate, sort: \Movie.title)
    }

    var body: some View {
        List(movies) { movie in
            Text(movie.title)
        }
    }
}
```

**Benefits:**
- Clean separation of concerns: parent owns UI state, child owns data query
- The child view re-initializes with a new `@Query` whenever the filter changes
- Pattern scales to multiple filters (date range, category, sort order)

Reference: [Develop in Swift — Create, Update, and Delete Data](https://developer.apple.com/tutorials/develop-in-swift/create-update-and-delete-data)
