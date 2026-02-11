---
title: Use PDF Vector or SVG for Custom Icons, Never Multiple PNGs
impact: MEDIUM-HIGH
impactDescription: a single PDF/SVG vector icon replaces 3 PNG sizes (@1x, @2x, @3x) and scales perfectly to any display — PNGs pixelate on newer displays and triple asset count
tags: asset, icons, vector, pdf, svg, format
---

## Use PDF Vector or SVG for Custom Icons, Never Multiple PNGs

A 30-icon set exported as PNGs produces 90 files (3 scales each). The same set as PDF vectors is 30 files that scale to any resolution — including future displays with higher pixel densities. Vectors also look crisp at non-standard sizes (e.g., when icons appear in Dynamic Type-scaled contexts).

**Incorrect (raster PNGs at multiple scales):**

```text
Icons.xcassets/
└── icon-bookmark.imageset/
    ├── Contents.json
    ├── icon-bookmark.png        // 24×24 @1x
    ├── icon-bookmark@2x.png     // 48×48 @2x
    └── icon-bookmark@3x.png     // 72×72 @3x
```

```json
// Contents.json — three raster entries
{
  "images": [
    { "filename": "icon-bookmark.png", "scale": "1x" },
    { "filename": "icon-bookmark@2x.png", "scale": "2x" },
    { "filename": "icon-bookmark@3x.png", "scale": "3x" }
  ]
}
```

**Correct (single PDF vector with Preserve Vector Data):**

```text
Icons.xcassets/
└── icon-bookmark.imageset/
    ├── Contents.json
    └── icon-bookmark.pdf        // Single vector file
```

```json
// Contents.json — single vector, preserves vector data, renders as template
{
  "images": [
    { "filename": "icon-bookmark.pdf", "idiom": "universal" }
  ],
  "properties": {
    "preserves-vector-representation": true,
    "template-rendering-intent": "template"
  }
}
```

```swift
// In SwiftUI — template rendering lets you tint freely
struct BookmarkButton: View {
    let isBookmarked: Bool

    var body: some View {
        Button(action: toggleBookmark) {
            Image("icon-bookmark")
                .foregroundStyle(isBookmarked ? .accentPrimary : .labelTertiary)
        }
    }
}
```

**Key Xcode settings for vector icons:**

| Setting | Value | Why |
|---------|-------|-----|
| Preserve Vector Data | Checked | Keeps sharp at any size, not just the base point size |
| Render As | Template Image | Allows `.foregroundStyle()` tinting |
| Scales | Single Scale | One vector file, no @2x/@3x needed |

SVG is also supported (Xcode 12+) and works identically to PDF. Choose whichever your design tool exports more cleanly. Figma exports SVG natively; Sketch historically exports cleaner PDFs.
