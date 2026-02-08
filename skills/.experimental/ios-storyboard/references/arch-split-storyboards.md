---
title: Split Monolithic Storyboards into Feature Modules
impact: CRITICAL
impactDescription: eliminates 80%+ merge conflicts
tags: arch, storyboard, modularity, merge-conflicts
---

## Split Monolithic Storyboards into Feature Modules

A single Main.storyboard containing every screen in the app becomes unmergeable the moment two developers touch it simultaneously. Xcode serializes the entire scene graph into one XML file, so any concurrent edit produces hundreds of conflicting lines. Splitting by feature module isolates changes and cuts merge conflicts by 80% or more.

**Incorrect (monolithic storyboard with all scenes in one file):**

```xml
<!-- Main.storyboard — 18 scenes, edited by every developer on the team -->
<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB"
          version="3.0" toolsVersion="21701" targetRuntime="AppleSDK"
          propertyAccessControl="none" useAutolayout="YES"
          useTraitCollections="YES" useSafeAreas="YES"
          colorMatched="YES"
          initialViewController="LaunchScreenVC">
    <scenes>
        <!-- Login flow -->
        <scene sceneID="login-1"><!-- ... --></scene>
        <scene sceneID="login-2"><!-- ... --></scene>
        <scene sceneID="login-3"><!-- ... --></scene>
        <!-- Profile flow -->
        <scene sceneID="profile-1"><!-- ... --></scene>
        <scene sceneID="profile-2"><!-- ... --></scene>
        <scene sceneID="profile-3"><!-- ... --></scene>
        <!-- Settings flow -->
        <scene sceneID="settings-1"><!-- ... --></scene>
        <scene sceneID="settings-2"><!-- ... --></scene>
        <scene sceneID="settings-3"><!-- ... --></scene>
        <!-- Checkout flow -->
        <scene sceneID="checkout-1"><!-- ... --></scene>
        <scene sceneID="checkout-2"><!-- ... --></scene>
        <scene sceneID="checkout-3"><!-- ... --></scene>
        <scene sceneID="checkout-4"><!-- ... --></scene>
        <!-- Onboarding flow -->
        <scene sceneID="onboarding-1"><!-- ... --></scene>
        <scene sceneID="onboarding-2"><!-- ... --></scene>
        <scene sceneID="onboarding-3"><!-- ... --></scene>
        <scene sceneID="onboarding-4"><!-- ... --></scene>
        <scene sceneID="onboarding-5"><!-- ... --></scene>
    </scenes>
</document>
```

**Correct (separate storyboard per feature module):**

```xml
<!-- Login.storyboard — 3 scenes, owned by the auth team -->
<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB"
          version="3.0" toolsVersion="21701" targetRuntime="AppleSDK"
          propertyAccessControl="none" useAutolayout="YES"
          useTraitCollections="YES" useSafeAreas="YES"
          colorMatched="YES"
          initialViewController="LoginVC">
    <scenes>
        <scene sceneID="login-1"><!-- ... --></scene>
        <scene sceneID="login-2"><!-- ... --></scene>
        <scene sceneID="login-3"><!-- ... --></scene>
    </scenes>
</document>
```

```xml
<!-- Profile.storyboard — 3 scenes -->
<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB"
          version="3.0" toolsVersion="21701" targetRuntime="AppleSDK"
          propertyAccessControl="none" useAutolayout="YES"
          useTraitCollections="YES" useSafeAreas="YES"
          colorMatched="YES"
          initialViewController="ProfileVC">
    <scenes>
        <scene sceneID="profile-1"><!-- ... --></scene>
        <scene sceneID="profile-2"><!-- ... --></scene>
        <scene sceneID="profile-3"><!-- ... --></scene>
    </scenes>
</document>
```

```xml
<!-- Settings.storyboard — 3 scenes -->
<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB"
          version="3.0" toolsVersion="21701" targetRuntime="AppleSDK"
          propertyAccessControl="none" useAutolayout="YES"
          useTraitCollections="YES" useSafeAreas="YES"
          colorMatched="YES"
          initialViewController="SettingsVC">
    <scenes>
        <scene sceneID="settings-1"><!-- ... --></scene>
        <scene sceneID="settings-2"><!-- ... --></scene>
        <scene sceneID="settings-3"><!-- ... --></scene>
    </scenes>
</document>
```

**Benefits:**
- Each feature storyboard has 3-5 scenes max, making git diffs readable
- Developers working on different features never touch the same file
- Xcode opens and renders small storyboards instantly
- Feature teams can own their storyboard files via CODEOWNERS
