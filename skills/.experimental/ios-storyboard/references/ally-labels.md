---
title: Set Accessibility Labels for All Interactive Elements
impact: MEDIUM
impactDescription: prevents VoiceOver from skipping interactive controls
tags: ally, accessibility-label, voiceover, interactive
---

## Set Accessibility Labels for All Interactive Elements

VoiceOver reads the `accessibilityLabel` to describe each element to users who cannot see the screen. Buttons with only an icon and no label are announced as "button" with no context. Form controls without labels force VoiceOver users to guess their purpose. Setting descriptive labels in Interface Builder's Identity Inspector ensures every interactive element is usable without sight.

**Incorrect (icon-only buttons with no accessibility labels):**

```xml
<button id="share-btn" buttonType="system">
    <rect key="frame" x="320" y="16" width="44" height="44"/>
    <state key="normal" image="square.and.arrow.up"/>
    <!-- VoiceOver announces: "button" — no indication of purpose -->
</button>
<button id="favorite-btn" buttonType="system">
    <rect key="frame" x="264" y="16" width="44" height="44"/>
    <state key="normal" image="heart"/>
</button>
```

**Correct (descriptive accessibility labels set in Interface Builder):**

```xml
<button id="share-btn" buttonType="system">
    <rect key="frame" x="320" y="16" width="44" height="44"/>
    <state key="normal" image="square.and.arrow.up"/>
    <accessibility key="accessibilityConfiguration" label="Share this article"/>
</button>
<button id="favorite-btn" buttonType="system">
    <rect key="frame" x="264" y="16" width="44" height="44"/>
    <state key="normal" image="heart"/>
    <accessibility key="accessibilityConfiguration" label="Add to favorites"/>
</button>
```

**Benefits:**

- VoiceOver announces "Share this article, button" and "Add to favorites, button"
- Labels should describe the action, not the icon ("Share this article" not "Arrow box icon")
- Buttons with text titles automatically use the title as the label and do not need an explicit override

Reference: [Accessibility Labels](https://developer.apple.com/documentation/objectivec/nsobject/1615181-accessibilitylabel)
