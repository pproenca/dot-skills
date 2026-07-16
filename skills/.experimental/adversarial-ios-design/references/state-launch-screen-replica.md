---
title: Make the launch screen a chrome-only replica of the first screen
tags: state, launch-screen, info-plist, branding
---

## Make the launch screen a chrome-only replica of the first screen

The wrong default is either a logo splash or no launch screen at all. Both fail the same way: the launch screen's sole function is to make the app feel quick to launch by being nearly identical to the first real screen — a splash produces an unpleasant flash between branding and content, launch-screen text won't be localized, and a missing configuration jumps from black into the interface. The launch screen shows only the first screen's static chrome: the same background color in both appearances, and placeholder shapes where the first screen shows navigation or tab bars — no text, no logo, no advertising, unless the logo is a fixed part of the first screen itself.

**Evidence of violation:** a launch screen configuration (launch storyboard or `UILaunchScreen` Info.plist dictionary) containing text, a logo, or app-name imagery — cite the element; a launch background color that differs from the first screen's background in either light or dark appearance — cite both values; a first screen that shows navigation or tab bars while the launch screen configures no bar placeholders (`UINavigationBar`/`UITabBar` keys or storyboard equivalents); or no launch screen configured at all — the absence is FAIL, not N/A. PASS: a `UILaunchScreen` dictionary (or storyboard) reproducing only the first screen's chrome — matching background in both appearances, bar placeholders matching the first screen's bars, zero text or branding — the reviewer must cite the configuration keys against the first screen's source. N/A: a logo present on the launch screen that is a fixed part of the app's first screen — the reviewer must cite the logo in the first screen's body; absent that evidence, fail closed. N/A: the target contains no app-level configuration (a single-view diff with no project files).

**Incorrect (a branding splash that flashes before the real interface):**

```xml
<!-- Info.plist -->
<key>UILaunchScreen</key>
<dict>
    <!-- ⚠️ Logo and app name on the launch screen; background unrelated to the first screen -->
    <key>UIImageName</key>
    <string>MealboxWordmark</string>
    <key>UIColorName</key>
    <string>BrandOrange</string>
</dict>
```

**Correct (chrome-only replica — the launch frame the first screen fills in):**

```xml
<!-- Info.plist — first screen is a list under navigation chrome over SystemBackground -->
<key>UILaunchScreen</key>
<dict>
    <key>UIColorName</key>
    <string>LaunchBackground</string> <!-- matches the first screen's background, light + dark -->
    <key>UINavigationBar</key>
    <dict/>
</dict>
```

Reference: [HIG — Launching](https://developer.apple.com/design/human-interface-guidelines/launching)
