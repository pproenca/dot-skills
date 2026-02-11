---
title: Use matchedGeometryEffect for Expand/Collapse Morphs
impact: HIGH
impactDescription: without shared geometry, expanding elements feel teleported — not transformed
tags: spatial, matchedGeometryEffect, morph, expand, namespace
---

## Use matchedGeometryEffect for Expand/Collapse Morphs

When a compact element — thumbnail, mini-player, card — expands into a detail view, the user expects a continuous spatial transformation. Their finger touched *this* element, and *this* element should grow into the detail. Without `matchedGeometryEffect`, SwiftUI has no way to interpolate position, size, and corner radius between the two states. The result is a hard cut or a generic slide — the element disappears in one place and appears in another, breaking the spatial link between action and result.

`matchedGeometryEffect` tells SwiftUI that two views across different layout branches represent the same logical element. SwiftUI interpolates the frame (position + size) between them during a state change, creating a smooth morph. The key is matching the outermost container first, then optionally matching sub-elements for richer transitions.

**Incorrect (slide transition — no spatial connection between collapsed and expanded):**

```swift
struct MiniPlayerView: View {
    @State private var isExpanded = false

    var body: some View {
        VStack {
            Spacer()

            if isExpanded {
                // Full player — slides up from bottom, no connection to mini-player
                VStack(spacing: 24) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.blue.gradient)
                        .frame(width: 280, height: 280)
                        .overlay {
                            Image(systemName: "music.note")
                                .font(.system(size: 60))
                                .foregroundStyle(.white)
                        }

                    VStack(spacing: 4) {
                        Text("Midnight City")
                            .font(.title2.bold())
                        Text("M83")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 40) {
                        Button(action: {}) {
                            Image(systemName: "backward.fill")
                                .font(.title2)
                        }
                        Button(action: {}) {
                            Image(systemName: "pause.fill")
                                .font(.title)
                        }
                        Button(action: {}) {
                            Image(systemName: "forward.fill")
                                .font(.title2)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
                // Slide from bottom — the expanded player has no spatial
                // relationship to the mini-player. It feels like a new screen.
                .transition(.move(edge: .bottom))
                .onTapGesture { isExpanded = false }
            } else {
                // Mini-player
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.blue.gradient)
                        .frame(width: 44, height: 44)
                        .overlay {
                            Image(systemName: "music.note")
                                .foregroundStyle(.white)
                        }

                    Text("Midnight City")
                        .font(.subheadline.weight(.medium))

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "pause.fill")
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .onTapGesture { isExpanded = true }
            }
        }
        .animation(.smooth(duration: 0.4), value: isExpanded)
    }
}
```

**Correct (matchedGeometryEffect morphs the mini-player into the full player):**

```swift
struct MiniPlayerView: View {
    @Namespace private var playerNamespace
    @State private var isExpanded = false

    var body: some View {
        VStack {
            Spacer()

            if isExpanded {
                // Full player — shares geometry with mini-player
                VStack(spacing: 24) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.blue.gradient)
                        .frame(width: 280, height: 280)
                        .overlay {
                            Image(systemName: "music.note")
                                .font(.system(size: 60))
                                .foregroundStyle(.white)
                        }
                        .matchedGeometryEffect(id: "artwork", in: playerNamespace)

                    VStack(spacing: 4) {
                        Text("Midnight City")
                            .font(.title2.bold())
                            .matchedGeometryEffect(id: "title", in: playerNamespace)
                        Text("M83")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 40) {
                        Button(action: {}) {
                            Image(systemName: "backward.fill")
                                .font(.title2)
                        }
                        Button(action: {}) {
                            Image(systemName: "pause.fill")
                                .font(.title)
                        }
                        .matchedGeometryEffect(id: "playPause", in: playerNamespace)
                        Button(action: {}) {
                            Image(systemName: "forward.fill")
                                .font(.title2)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
                .onTapGesture { isExpanded = false }
            } else {
                // Mini-player — shares geometry IDs with full player
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.blue.gradient)
                        .frame(width: 44, height: 44)
                        .overlay {
                            Image(systemName: "music.note")
                                .foregroundStyle(.white)
                        }
                        .matchedGeometryEffect(id: "artwork", in: playerNamespace)

                    Text("Midnight City")
                        .font(.subheadline.weight(.medium))
                        .matchedGeometryEffect(id: "title", in: playerNamespace)

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "pause.fill")
                    }
                    .matchedGeometryEffect(id: "playPause", in: playerNamespace)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .onTapGesture { isExpanded = true }
            }
        }
        .animation(.smooth(duration: 0.4), value: isExpanded)
    }
}
```

**Key principles for matchedGeometryEffect:**

- **Match the outermost container first.** The container's frame interpolation creates the morph — sub-elements refine it.
- **Use `isSource: true` on the currently visible state.** When both states exist simultaneously (e.g., overlay), set `isSource: true` on the one that should define the geometry.
- **Keep both states in the same parent.** The `@Namespace` must be owned by a common ancestor view, and the `if/else` branches must live inside that ancestor's body.
- **Separate IDs for independent elements.** Artwork, title, and controls each get their own ID so they interpolate independently rather than morphing as one blob.

**Reference:** WWDC 2021 session on `matchedGeometryEffect` and SwiftUI animation system.
