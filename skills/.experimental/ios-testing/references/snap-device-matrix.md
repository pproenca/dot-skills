---
title: "Snapshot Across Device Sizes and Traits"
impact: MEDIUM
impactDescription: "4× visual coverage from single test function"
tags: snap, device-matrix, traits, dark-mode, dynamic-type
---

## Snapshot Across Device Sizes and Traits

A single-device snapshot misses constraint breakage on smaller screens, truncated labels on larger type sizes, and invisible text in dark mode. Parameterizing snapshots across a device matrix catches layout and theming regressions in one test function with no additional QA effort per configuration.

**Incorrect (only tests one device, misses SE/iPad/dark-mode breakage):**

```swift
import Testing
import SnapshotTesting
@testable import SettingsFeature

@Suite struct SettingsViewTests {
    @Test func settingsLayout() {
        let controller = SettingsViewController(viewModel: .stub())

        // Passes on iPhone 15 but clips text on SE and breaks in dark mode
        assertSnapshot(of: controller, as: .image(on: .iPhone13))
    }
}
```

**Correct (one function covers 4+ device and trait combinations):**

```swift
import Testing
import SnapshotTesting
@testable import SettingsFeature

enum DeviceVariant: String, CaseIterable, Sendable {
    case iPhoneSE, iPhone15, iPhone15Dark, iPad

    var config: ViewImageConfig {
        switch self {
        case .iPhoneSE: .iPhoneSe
        case .iPhone15, .iPhone15Dark: .iPhone13
        case .iPad: .iPadMini
        }
    }

    var traits: UITraitCollection {
        switch self {
        case .iPhone15Dark: UITraitCollection(userInterfaceStyle: .dark)
        default: UITraitCollection()
        }
    }
}

@Suite struct SettingsViewTests {
    @Test(arguments: DeviceVariant.allCases)
    func settingsLayout(variant: DeviceVariant) {
        let controller = SettingsViewController(viewModel: .stub())

        assertSnapshot(of: controller, as: .image(on: variant.config, traits: variant.traits), named: variant.rawValue) // each config produces its own reference image
    }
}
```
