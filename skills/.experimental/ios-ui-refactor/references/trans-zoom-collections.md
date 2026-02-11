---
title: Use Zoom Transitions for Collection-to-Detail Navigation
impact: HIGH
impactDescription: Eliminates spatial disorientation when navigating from grids or lists — users immediately understand where content came from and where it returns to
tags: trans, zoom, navigation, collection, grid, iOS18
---

## Use Zoom Transitions for Collection-to-Detail Navigation

When a user taps a photo thumbnail, card, or grid cell, the standard push transition (content slides in from the right) provides zero spatial connection between the tapped element and the detail view. The user loses track of which item they selected. iOS 18 introduces `navigationTransition(.zoom)` paired with `matchedTransitionSource`, which zooms the detail view directly out of the tapped cell — the same pattern Apple Photos uses for its grid-to-fullscreen transition.

**Incorrect (standard push from a grid cell with no spatial connection):**

```swift
struct PhotoGrid: View {
    let photos: [Photo]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 2) {
                    ForEach(photos) { photo in
                        // Standard push: detail slides in from the right,
                        // no visual link to the tapped thumbnail
                        NavigationLink(value: photo) {
                            AsyncImage(url: photo.thumbnailURL) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color(.systemGray5)
                            }
                            .frame(minHeight: 100)
                            .clipped()
                        }
                    }
                }
            }
            .navigationDestination(for: Photo.self) { photo in
                PhotoDetailView(photo: photo)
            }
        }
    }
}
```

**Correct (zoom transition anchored to the tapped cell):**

```swift
struct PhotoGrid: View {
    let photos: [Photo]
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 2) {
                    ForEach(photos) { photo in
                        NavigationLink(value: photo) {
                            AsyncImage(url: photo.thumbnailURL) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color(.systemGray5)
                            }
                            .frame(minHeight: 100)
                            .clipped()
                        }
                        // Mark this cell as the zoom origin
                        .matchedTransitionSource(id: photo.id, in: namespace)
                    }
                }
            }
            .navigationDestination(for: Photo.self) { photo in
                PhotoDetailView(photo: photo)
                    // Zoom the detail view out of the matched source
                    .navigationTransition(.zoom(sourceID: photo.id, in: namespace))
            }
        }
    }
}
```

**When NOT to use:**
- Flat lists where items are text-only rows (standard push is appropriate for Settings-style drill-down)
- Tabs or top-level navigation switches — zoom implies spatial containment, not lateral movement

**Reference:** WWDC 2024 "Enhance your UI animations and transitions" — demonstrates `navigationTransition(.zoom)` as the recommended pattern for collection-to-detail flows.
