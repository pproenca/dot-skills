---
title: Use Zoom Transitions for Collection-to-Detail Navigation
impact: HIGH
impactDescription: eliminates spatial disorientation when navigating from grids or lists — users immediately understand where content came from
tags: enduring, zoom, navigation, collection, rams-7, edson-conviction, iOS18
---

## Use Zoom Transitions for Collection-to-Detail Navigation

Rams' longevity comes from aligning with how humans naturally perceive space. Zoom transitions anchor the detail view to the tapped cell — this is not a trend but a reflection of spatial cognition that will remain valid for as long as humans use touch screens. Edson's conviction: commit to Apple's navigation transition system rather than building custom alternatives that will break with the next OS update.

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
