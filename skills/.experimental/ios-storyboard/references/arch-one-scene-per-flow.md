---
title: Limit Each Storyboard to a Single User Flow
impact: CRITICAL
impactDescription: reduces Xcode load time by 2-5x for large projects
tags: arch, storyboard, user-flow, performance
---

## Limit Each Storyboard to a Single User Flow

When unrelated flows share a storyboard, every developer editing any of those flows contends for the same file. Xcode must also parse and render every scene in the storyboard when opening it, even if you only need to edit one screen. Keeping each storyboard focused on a single user flow (login, checkout, onboarding) eliminates unnecessary parsing and keeps ownership boundaries clear.

**Incorrect (unrelated flows crammed into one storyboard):**

```xml
<!-- Main.storyboard — three unrelated flows in a single file -->
<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB"
          version="3.0" toolsVersion="21701" targetRuntime="AppleSDK"
          initialViewController="CheckoutCartVC">
    <scenes>
        <!-- Checkout flow -->
        <scene sceneID="checkout-cart"><!-- CheckoutCartViewController --></scene>
        <scene sceneID="checkout-shipping"><!-- ShippingAddressViewController --></scene>
        <scene sceneID="checkout-payment"><!-- PaymentMethodViewController --></scene>
        <scene sceneID="checkout-confirm"><!-- OrderConfirmationViewController --></scene>

        <!-- Settings flow — unrelated to checkout -->
        <scene sceneID="settings-main"><!-- SettingsViewController --></scene>
        <scene sceneID="settings-notifications"><!-- NotificationPrefsViewController --></scene>
        <scene sceneID="settings-privacy"><!-- PrivacySettingsViewController --></scene>

        <!-- Onboarding flow — unrelated to both -->
        <scene sceneID="onboarding-welcome"><!-- WelcomeViewController --></scene>
        <scene sceneID="onboarding-permissions"><!-- PermissionsViewController --></scene>
        <scene sceneID="onboarding-tutorial"><!-- TutorialViewController --></scene>
        <scene sceneID="onboarding-complete"><!-- CompletionViewController --></scene>
    </scenes>
</document>
```

**Correct (one storyboard per user flow):**

```xml
<!-- Checkout.storyboard — only checkout scenes -->
<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB"
          version="3.0" toolsVersion="21701" targetRuntime="AppleSDK"
          initialViewController="CheckoutCartVC">
    <scenes>
        <scene sceneID="checkout-cart"><!-- CheckoutCartViewController --></scene>
        <scene sceneID="checkout-shipping"><!-- ShippingAddressViewController --></scene>
        <scene sceneID="checkout-payment"><!-- PaymentMethodViewController --></scene>
        <scene sceneID="checkout-confirm"><!-- OrderConfirmationViewController --></scene>
    </scenes>
</document>
```

```xml
<!-- Settings.storyboard — only settings scenes -->
<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB"
          version="3.0" toolsVersion="21701" targetRuntime="AppleSDK"
          initialViewController="SettingsMainVC">
    <scenes>
        <scene sceneID="settings-main"><!-- SettingsViewController --></scene>
        <scene sceneID="settings-notifications"><!-- NotificationPrefsViewController --></scene>
        <scene sceneID="settings-privacy"><!-- PrivacySettingsViewController --></scene>
    </scenes>
</document>
```

```xml
<!-- Onboarding.storyboard — only onboarding scenes -->
<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB"
          version="3.0" toolsVersion="21701" targetRuntime="AppleSDK"
          initialViewController="OnboardingWelcomeVC">
    <scenes>
        <scene sceneID="onboarding-welcome"><!-- WelcomeViewController --></scene>
        <scene sceneID="onboarding-permissions"><!-- PermissionsViewController --></scene>
        <scene sceneID="onboarding-tutorial"><!-- TutorialViewController --></scene>
        <scene sceneID="onboarding-complete"><!-- CompletionViewController --></scene>
    </scenes>
</document>
```

**When NOT to use:**
- A trivial app with fewer than 5 screens total can use a single storyboard without significant cost. The overhead of splitting only pays off at scale (8+ screens or 2+ developers).
