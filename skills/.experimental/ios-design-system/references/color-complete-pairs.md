---
title: Define Both Appearances for Every Custom Color
impact: CRITICAL
impactDescription: missing dark mode variant causes 100% of dark mode users to see broken contrast — the most common design system defect in production apps
tags: color, dark-mode, appearances, asset-catalog, accessibility
---

## Define Both Appearances for Every Custom Color

When a color set in the asset catalog has only an "Any Appearance" value and no "Dark" variant, iOS uses the light-mode value in dark mode verbatim. A white background stays white in dark mode. Dark text on a dark-mode background becomes invisible. This is the single most common visual defect in production iOS apps and it is entirely preventable: every custom color set MUST define both Any Appearance and Dark Appearance values at the moment it is created, with no exceptions.

**Incorrect (color set with only "Any Appearance"):**

```json
// backgroundSurface.colorset/Contents.json — MISSING DARK VARIANT
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "red" : "1.000",
          "green" : "1.000",
          "blue" : "1.000",
          "alpha" : "1.000"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : { "version" : 1, "author" : "xcode" }
}
// Result: White background in dark mode → unreadable text, blinding UI
```

**Correct (both appearances defined):**

```json
// backgroundSurface.colorset/Contents.json — COMPLETE
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "red" : "1.000",
          "green" : "1.000",
          "blue" : "1.000",
          "alpha" : "1.000"
        }
      },
      "idiom" : "universal"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "red" : "0.176",
          "green" : "0.176",
          "blue" : "0.184",
          "alpha" : "1.000"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : { "version" : 1, "author" : "xcode" }
}
```

**Enforcement with a PR checklist or automation:**

```swift
// Test that validates all color sets have dark variants
// Place in your test target

import XCTest

final class ColorAssetTests: XCTestCase {
    func testAllColorSetsHaveDarkVariant() throws {
        let catalogURL = Bundle.main.url(forResource: "Colors", withExtension: "xcassets")
        // Walk the catalog directory and parse each Contents.json
        // Assert that every color set contains an appearance entry with "value": "dark"

        let colorSetURLs = try FileManager.default
            .contentsOfDirectory(at: catalogURL!, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "colorset" }

        for colorSetURL in colorSetURLs {
            let contentsURL = colorSetURL.appendingPathComponent("Contents.json")
            let data = try Data(contentsOf: contentsURL)
            let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
            let colors = json["colors"] as! [[String: Any]]

            let hasDark = colors.contains { entry in
                guard let appearances = entry["appearances"] as? [[String: String]] else {
                    return false
                }
                return appearances.contains { $0["value"] == "dark" }
            }

            XCTAssertTrue(
                hasDark,
                "Color set '\(colorSetURL.lastPathComponent)' is missing a Dark appearance variant"
            )
        }
    }
}
```

**High Contrast variants (recommended for accessibility):**

```text
backgroundSurface.colorset/
├── Any Appearance              → #FFFFFF
├── Dark                        → #2C2C2E
├── High Contrast (Any)         → #FFFFFF   // Often same, but explicit
└── High Contrast (Dark)        → #000000   // Maximum contrast
```

Adding High Contrast variants earns the app better Accessibility Inspector scores and serves users with low vision. While optional, defining them at color creation time costs 30 seconds and prevents retrofitting later.

**Benefits:**
- Zero dark mode regressions: every color resolves correctly in both appearances from day one
- Automated test catches missing variants before they reach production
- High Contrast variants added at creation time are 10x cheaper than retrofitting after launch
- Accessibility audits pass without remediation

Reference: [Supporting Dark Mode — Apple Developer](https://developer.apple.com/documentation/uikit/appearance_customization/supporting_dark_mode_in_your_interface), [WWDC19 — Implementing Dark Mode on iOS](https://developer.apple.com/videos/play/wwdc2019/214/)
