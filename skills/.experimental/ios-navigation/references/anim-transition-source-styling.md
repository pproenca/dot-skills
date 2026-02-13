---
title: Style Transition Sources with Shape and Background
impact: MEDIUM
impactDescription: saves 100+ lines of custom transition styling per hero animation
tags: anim, zoom, transition-source, styling, clip-shape
---

## Style Transition Sources with Shape and Background

The `.matchedTransitionSource` modifier accepts a configuration closure that controls how the source cell appears during the zoom animation. This is the correct place to apply `clipShape`, `background`, and `shadow` for the transition -- applying these directly to the `NavigationLink` or its content has no effect on the zoom animation, resulting in a raw rectangular morph that looks unfinished.

**Incorrect (styling on NavigationLink, ignored by zoom transition):**

```swift
// BAD: cornerRadius and shadow applied to the link content are not
// picked up by the zoom transition engine. The animation uses a
// plain rectangular clip, producing an unpolished morph effect.
struct PlaceListView: View {
    @Namespace private var zoomNamespace

    var body: some View {
        NavigationStack {
            List(places) { place in
                NavigationLink(value: place) {
                    PlaceRow(place: place)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 8)
                }
                .matchedTransitionSource(
                    id: place.id,
                    in: zoomNamespace
                )
                // cornerRadius and shadow above are NOT used by the
                // zoom transition -- the animation clips to a rectangle
            }
            .navigationDestination(for: Place.self) { place in
                PlaceDetailView(place: place)
                    .navigationTransition(
                        .zoom(sourceID: place.id, in: zoomNamespace)
                    )
            }
        }
    }
}
```

**Correct (styling via matchedTransitionSource configuration closure):**

```swift
struct PlaceListView: View {
    @Namespace private var zoomNamespace

    var body: some View {
        NavigationStack {
            List(places) { place in
                NavigationLink(value: place) {
                    PlaceRow(place: place)
                }
                .matchedTransitionSource(
                    id: place.id,
                    in: zoomNamespace
                ) { source in
                    source
                        .background(.fill.tertiary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 8, y: 4)
                }
            }
            .navigationDestination(for: Place.self) { place in
                PlaceDetailView(place: place)
                    .navigationTransition(
                        .zoom(sourceID: place.id, in: zoomNamespace)
                    )
            }
        }
    }
}
```
