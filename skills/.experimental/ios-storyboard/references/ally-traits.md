---
title: Assign Correct Accessibility Traits in Interface Builder
impact: MEDIUM
impactDescription: enables correct VoiceOver interaction behavior
tags: ally, traits, voiceover, interaction
---

## Assign Correct Accessibility Traits in Interface Builder

Accessibility traits tell VoiceOver how an element behaves: whether it is a button, a link, a header, or a static text label. When a custom UIView acts as a button but lacks the button trait, VoiceOver announces it as a generic element and does not tell the user they can activate it. Incorrect traits mislead users about what interactions are available.

**Incorrect (tappable custom view with no accessibility traits):**

```xml
<view id="plan-card" customClass="PlanSelectionCard" customModule="Subscription">
    <rect key="frame" x="16" y="200" width="343" height="120"/>
    <accessibility key="accessibilityConfiguration"
                   label="Premium Plan - $9.99/month">
        <!-- No traits: VoiceOver announces as static text, user doesn't know to tap -->
    </accessibility>
    <gestureRecognizers>
        <tapGestureRecognizer id="plan-tap"/>
    </gestureRecognizers>
</view>
```

**Correct (button trait tells VoiceOver this element is activatable):**

```xml
<view id="plan-card" customClass="PlanSelectionCard" customModule="Subscription">
    <rect key="frame" x="16" y="200" width="343" height="120"/>
    <accessibility key="accessibilityConfiguration"
                   label="Premium Plan - $9.99/month">
        <accessibilityTraits key="traits" button="YES"/>
    </accessibility>
    <gestureRecognizers>
        <tapGestureRecognizer id="plan-tap"/>
    </gestureRecognizers>
</view>
```

Common trait assignments:

| Element Behavior | Trait | VoiceOver Effect |
|---|---|---|
| Tappable view or custom control | `button` | "Double-tap to activate" |
| Section title | `header` | Rotor header navigation |
| Tappable URL or deep link | `link` | "Double-tap to open link" |
| Image with no action | `image` | Announces as image |
| Frequently updating content | `updatesFrequently` | VoiceOver polls for changes |

Reference: [UIAccessibilityTraits](https://developer.apple.com/documentation/uikit/uiaccessibilitytraits)
