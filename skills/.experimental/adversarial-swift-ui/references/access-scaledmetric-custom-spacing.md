---
title: Scale custom spacing around text with ScaledMetric
tags: access, dynamic-type, scaledmetric, spacing
---

## Scale custom spacing around text with ScaledMetric

The wrong default when a design needs non-standard spacing is a fixed numeric literal in `spacing:` or `.padding(N)`. A static value holds its point size while the text around it grows with the user's Dynamic Type setting, so content that looked balanced at the default size becomes crowded and loses its intended structure at accessibility sizes. Prefer the system defaults first — bare `.padding()` and default stack spacing are already adaptive. When a custom value is genuinely required, back it with `@ScaledMetric` so the metric scales in proportion to the user's font size; `@ScaledMetric(relativeTo:)` ties the scaling to the specific text style the spacing accompanies.

**Evidence of violation:** a numeric literal passed to a stack's `spacing:` parameter or to `.padding(_:)` on a container whose children include `Text`, with no `@ScaledMetric` (plain or `relativeTo:`) property backing the value. PASS: `@ScaledMetric`-backed values; bare `.padding()` and default (omitted) stack spacing. N/A: literals in purely graphical, text-free contexts — icon insets, decorative shapes, image-only compositions — the reviewer must cite the text-free content to claim the carve-out; absent that evidence, fail closed. N/A: no custom spacing values in the target.

**Incorrect (fixed spacing turns cramped as Dynamic Type grows):**

```swift
import SwiftUI

struct Species {
    var scientificName = ""
    var description = ""
}

struct SpeciesInfoSection: View {
    let header: String
    let info: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(header).font(.headline)
            Text(info)
        }
    }
}

struct SpeciesDetailView: View {
    let species: Species

    var body: some View {
        ScrollView {
            // ⚠️ Fixed spacing may be too tight in larger font sizes
            VStack(alignment: .leading, spacing: 22) {
                SpeciesInfoSection(
                    header: "Scientific Name",
                    info: species.scientificName
                )

                SpeciesInfoSection(
                    header: "Description",
                    info: species.description
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
```

**Correct (spacing and padding scale alongside the content they separate):**

```swift
import SwiftUI

struct Species {
    var scientificName = ""
    var description = ""
}

struct SpeciesInfoSection: View {
    let header: String
    let info: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(header).font(.headline)
            Text(info)
        }
    }
}

struct SpeciesDetailView: View {
    let species: Species

    @ScaledMetric private var spacing = 22

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: spacing) {
                SpeciesInfoSection(
                    header: "Scientific Name",
                    info: species.scientificName
                )

                SpeciesInfoSection(
                    header: "Description",
                    info: species.description
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct Habitat {
    var name = ""
    var imageName = ""
}

struct HabitatCard: View {
    let habitat: Habitat

    @ScaledMetric private var padding = 12

    var body: some View {
        ZStack(alignment: .bottom) {
            Image(decorative: habitat.imageName)
                .resizable()
                .scaledToFit()
            Text(habitat.name)
                .padding(padding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial)
        }
        .clipShape(.rect(cornerRadius: 20))
    }
}
```
