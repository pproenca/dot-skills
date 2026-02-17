---
title: Use Zoom Transitions for Collection-to-Detail Navigation
impact: HIGH
impactDescription: eliminates spatial disorientation when navigating from grids or lists — users immediately understand where content came from
tags: enduring, zoom, navigation, collection, rams-7, edson-conviction, iOS18
---

## Use Zoom Transitions for Collection-to-Detail Navigation

When you tap a photo in a grid and it zooms open from exactly where your finger touched, your brain processes this as a physical act — you "opened" the photo. Standard push navigation from a grid cell breaks this spatial link and leaves the user momentarily disoriented: "where did this come from?" Zoom transitions anchor the detail view to the tapped cell, reflecting how human spatial cognition actually works. This is not a visual flourish — it is a reflection of how we perceive cause and effect on a touch surface, and it will remain valid for as long as people use their fingers to explore content.

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

**Exceptional (the creative leap) — navigation that feels spatial:**

```swift
struct ProjectGrid: View {
    let projects: [Project]
    @Namespace private var hero
    @State private var selectedProject: Project?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 160))],
                    spacing: 16
                ) {
                    ForEach(projects) { project in
                        NavigationLink(value: project) {
                            ProjectCard(project: project)
                                .matchedTransitionSource(
                                    id: project.id, in: hero
                                ) { source in
                                    source
                                        .clipShape(RoundedRectangle(
                                            cornerRadius: 20,
                                            style: .continuous))
                                        .shadow(
                                            color: .black.opacity(0.08),
                                            radius: 8, y: 4)
                                }
                        }
                    }
                }
                .padding()
            }
            .navigationDestination(for: Project.self) { project in
                ProjectDetailView(project: project)
                    .navigationTransition(.zoom(
                        sourceID: project.id, in: hero))
            }
        }
    }
}
```

The standard zoom transition already communicates origin, but the creative leap is shaping the transition itself — giving the source a continuous corner radius and a subtle shadow during the animation so the card feels like a physical object lifting off the grid and expanding to fill the screen. The siblings don't just sit there; they recede under the shadow as if the tapped card is rising above them in z-space. It stops feeling like a page navigation and starts feeling like you physically opened something. That moment of spatial conviction is what makes users instinctively swipe back instead of hunting for a back button — their hands already understand where they are.

**When NOT to apply:** Flat lists where items are text-only rows (standard push is appropriate for Settings-style drill-down), and tabs or top-level navigation switches where zoom implies spatial containment rather than lateral movement.

**Reference:** WWDC 2024 "Enhance your UI animations and transitions" — demonstrates `navigationTransition(.zoom)` as the recommended pattern for collection-to-detail flows.
