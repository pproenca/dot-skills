---
title: Use Storyboard References for Cross-Module Navigation
impact: CRITICAL
impactDescription: eliminates cross-storyboard instantiation code
tags: arch, storyboard-reference, navigation, modularity
---

## Use Storyboard References for Cross-Module Navigation

Hardcoded storyboard instantiation in Swift creates tight coupling between feature modules. If the destination storyboard is renamed or restructured, every call site breaks silently at runtime. Storyboard references declared in Interface Builder let Xcode validate the connection at build time and keep navigation wiring inside the storyboard where it belongs.

**Incorrect (hardcoded storyboard instantiation in Swift):**

```swift
final class ProfileViewController: UIViewController {
    @IBAction func openSettingsTapped(_ sender: UIButton) {
        // Hardcoded storyboard name — crashes if renamed
        let settingsStoryboard = UIStoryboard(name: "Settings", bundle: nil)
        let settingsVC = settingsStoryboard.instantiateViewController(
            withIdentifier: "SettingsMainVC"
        )
        navigationController?.pushViewController(settingsVC, animated: true)
    }
}
```

```xml
<!-- Profile.storyboard — no reference to Settings, navigation is invisible to IB -->
<scene sceneID="profile-main">
    <objects>
        <viewController id="ProfileVC" sceneMemberID="viewController">
            <view key="view" contentMode="scaleToFill">
                <subviews>
                    <button opaque="NO" contentMode="scaleToFill"
                            title="Settings">
                        <connections>
                            <action selector="openSettingsTapped:"
                                    destination="ProfileVC" eventType="touchUpInside"/>
                        </connections>
                    </button>
                </subviews>
            </view>
        </viewController>
    </objects>
</scene>
```

**Correct (storyboard reference wired in Interface Builder):**

```xml
<!-- Profile.storyboard — navigation is visible and validated by Xcode -->
<scene sceneID="profile-main">
    <objects>
        <viewController id="ProfileVC" sceneMemberID="viewController">
            <connections>
                <segue destination="settingsRef"
                       kind="show" identifier="showSettings"/>
            </connections>
        </viewController>
    </objects>
</scene>

<!-- Storyboard reference — Xcode validates this at build time -->
<scene sceneID="settings-ref-scene">
    <objects>
        <storyboardReference id="settingsRef"
                             storyboardName="Settings"
                             referencedIdentifier="SettingsMainVC"/>
    </objects>
</scene>
```

```swift
final class ProfileViewController: UIViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSettings",
           let settingsVC = segue.destination as? SettingsViewController {
            settingsVC.userProfile = currentProfile
        }
    }
}
```

**Benefits:**
- Xcode warns at build time if the referenced storyboard or identifier is missing
- Navigation flow is visible in Interface Builder's canvas
- Feature modules only need to agree on entry-point identifiers, not internal structure
