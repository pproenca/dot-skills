---
title: Share Multiple Element IDs for Rich Hero Animations
impact: MEDIUM-HIGH
impactDescription: matching only the container creates a blob morph — matching sub-elements creates cinema
tags: spatial, hero, shared-element, multi-match, morph
---

## Share Multiple Element IDs for Rich Hero Animations

A single `matchedGeometryEffect` ID on the outer container produces a functional morph — but it looks like a blob transformation. Every sub-element (artwork, title, subtitle, controls) is trapped inside one interpolating rectangle, stretching and squashing as a single unit. The result is uncanny: text warps, icons distort, corners stretch non-uniformly.

Rich hero animations — like Apple Music's mini-to-full player, App Store's card-to-detail, or Photos' grid-to-fullscreen — match multiple sub-elements with independent IDs. Each element interpolates its own position and size independently, creating a choreographed transition where artwork grows, title repositions, and controls slide into place as separate, legible elements.

**Incorrect (single container ID — everything morphs as one blob):**

```swift
struct RecipeCardTransition: View {
    @Namespace private var heroNamespace
    @State private var selectedRecipe: Recipe?
    let recipes: [Recipe]

    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                    ForEach(recipes) { recipe in
                        // Only the outer container is matched — every child
                        // (image, title, subtitle) warps inside one rectangle
                        VStack(alignment: .leading, spacing: 8) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(recipe.color.gradient)
                                .frame(height: 120)
                                .overlay {
                                    Image(systemName: recipe.icon)
                                        .font(.largeTitle)
                                        .foregroundStyle(.white)
                                }

                            Text(recipe.title)
                                .font(.headline)

                            Text("\(recipe.duration) min")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        // Single ID on the whole card — blob morph
                        .matchedGeometryEffect(id: recipe.id, in: heroNamespace)
                        .onTapGesture {
                            selectedRecipe = recipe
                        }
                    }
                }
                .padding()
            }

            if let recipe = selectedRecipe {
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(recipe.color.gradient)
                        .frame(height: 300)
                        .overlay {
                            Image(systemName: recipe.icon)
                                .font(.system(size: 64))
                                .foregroundStyle(.white)
                        }

                    Text(recipe.title)
                        .font(.largeTitle.bold())

                    Text("\(recipe.duration) min")
                        .font(.body)
                        .foregroundStyle(.secondary)

                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.background)
                // Single ID — the entire detail morphs as one stretched rectangle
                .matchedGeometryEffect(id: recipe.id, in: heroNamespace)
                .onTapGesture { selectedRecipe = nil }
            }
        }
        .animation(.smooth(duration: 0.45), value: selectedRecipe)
    }
}
```

**Correct (multiple IDs — each sub-element interpolates independently):**

```swift
struct RecipeCardTransition: View {
    @Namespace private var heroNamespace
    @State private var selectedRecipe: Recipe?
    let recipes: [Recipe]

    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                    ForEach(recipes) { recipe in
                        VStack(alignment: .leading, spacing: 8) {
                            // Artwork: own ID — grows independently
                            RoundedRectangle(cornerRadius: 12)
                                .fill(recipe.color.gradient)
                                .frame(height: 120)
                                .overlay {
                                    Image(systemName: recipe.icon)
                                        .font(.largeTitle)
                                        .foregroundStyle(.white)
                                }
                                .matchedGeometryEffect(id: "\(recipe.id)-artwork", in: heroNamespace)

                            // Title: own ID — repositions without warping
                            Text(recipe.title)
                                .font(.headline)
                                .matchedGeometryEffect(id: "\(recipe.id)-title", in: heroNamespace)

                            // Duration: own ID — slides into new position
                            Text("\(recipe.duration) min")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .matchedGeometryEffect(id: "\(recipe.id)-duration", in: heroNamespace)
                        }
                        .onTapGesture {
                            selectedRecipe = recipe
                        }
                    }
                }
                .padding()
            }
            .opacity(selectedRecipe == nil ? 1 : 0)

            if let recipe = selectedRecipe {
                VStack(spacing: 16) {
                    // Artwork: same ID — interpolates from grid thumbnail to hero
                    RoundedRectangle(cornerRadius: 16)
                        .fill(recipe.color.gradient)
                        .frame(height: 300)
                        .overlay {
                            Image(systemName: recipe.icon)
                                .font(.system(size: 64))
                                .foregroundStyle(.white)
                        }
                        .matchedGeometryEffect(id: "\(recipe.id)-artwork", in: heroNamespace)

                    // Title: same ID — moves from card to detail position
                    Text(recipe.title)
                        .font(.largeTitle.bold())
                        .matchedGeometryEffect(id: "\(recipe.id)-title", in: heroNamespace)

                    // Duration: same ID — repositions independently
                    Text("\(recipe.duration) min")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .matchedGeometryEffect(id: "\(recipe.id)-duration", in: heroNamespace)

                    // Controls that only exist in the detail view — fade in
                    VStack(spacing: 12) {
                        Text("Preheat oven to 180C. Mix flour and sugar...")
                            .font(.body)
                            .foregroundStyle(.secondary)

                        Button("Start Cooking") {
                            // action
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .transition(.opacity.animation(.smooth.delay(0.15)))

                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.background)
                .onTapGesture { selectedRecipe = nil }
            }
        }
        .animation(.smooth(duration: 0.45), value: selectedRecipe)
    }
}
```

**Handling elements that should NOT morph:**

Not every element in the detail view has a counterpart in the collapsed state. Recipe instructions, action buttons, and secondary metadata appear only in the expanded view. These elements should use a `.transition(.opacity)` — ideally with a slight delay so they fade in *after* the spatial morph is underway. This creates a layered choreography: spatial elements morph first, then new content fades into its final position.

```swift
// Elements unique to the detail view fade in after the morph
VStack(spacing: 12) {
    Text("Step-by-step instructions...")
        .font(.body)
    Button("Start Cooking") {}
        .buttonStyle(.borderedProminent)
}
// Delay the fade so it starts after the morph is visually established
.transition(.opacity.animation(.smooth.delay(0.15)))
```

**ID naming conventions for multi-element heroes:**

| Element | ID pattern | Why |
|---|---|---|
| Artwork/image | `"\(item.id)-artwork"` | Primary visual anchor — most important to match |
| Title text | `"\(item.id)-title"` | Text repositioning is highly visible |
| Subtitle/metadata | `"\(item.id)-meta"` | Secondary but still spatial |
| Container background | `"\(item.id)-bg"` | Optional — useful if the background shape changes |

**Key principles:**

- **Match 2-4 elements maximum.** Beyond that, the choreography becomes chaotic rather than elegant. Apple Music matches artwork, title, and artist — not every button and slider.
- **Use `isSource: true` on the currently driving state** when both views coexist (e.g., in an overlay). The source state defines the geometry that the other state animates toward.
- **Font interpolation does not happen.** `matchedGeometryEffect` interpolates frames, not text styling. The font change between `.headline` and `.largeTitle.bold()` is a hard cut. This is acceptable because the position interpolation masks the font change.
