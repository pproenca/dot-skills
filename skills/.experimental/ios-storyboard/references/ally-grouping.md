---
title: Group Related Elements for VoiceOver Navigation
impact: MEDIUM
impactDescription: reduces VoiceOver swipe count by 50-70%
tags: ally, grouping, voiceover, navigation
---

## Group Related Elements for VoiceOver Navigation

A card showing a product name, price, rating, and review count forces VoiceOver users to swipe through 4-5 separate elements. Grouping these into a single accessible container with a combined label reduces the swipe count and provides the full context in one announcement, matching how sighted users perceive the card as a single unit.

**Incorrect (5 separate accessible elements on a single card):**

```xml
<view id="product-card">
    <rect key="frame" x="16" y="100" width="343" height="120"/>
    <subviews>
        <imageView id="product-thumb" image="running-shoes">
            <accessibility key="accessibilityConfiguration" label="Running shoes"/>
        </imageView>
        <label id="product-name" text="Air Zoom Pegasus 40"/>
        <label id="product-price" text="$129.99"/>
        <imageView id="star-icon" image="star.fill">
            <accessibility key="accessibilityConfiguration" label="Rating"/>
        </imageView>
        <!-- VoiceOver: swipe, swipe, swipe, swipe to hear all info -->
        <label id="rating-text" text="4.6 (892 reviews)"/>
    </subviews>
</view>
```

**Correct (grouped container announced as a single element):**

```xml
<view id="product-card"
      shouldGroupAccessibilityChildren="YES">
    <rect key="frame" x="16" y="100" width="343" height="120"/>
    <accessibility key="accessibilityConfiguration"
                   isElement="YES"
                   label="Air Zoom Pegasus 40, $129.99, rated 4.6 out of 5, 892 reviews">
        <accessibilityTraits key="traits" button="YES"/>
    </accessibility>
    <subviews>
        <imageView id="product-thumb" image="running-shoes"/>
        <label id="product-name" text="Air Zoom Pegasus 40"/>
        <label id="product-price" text="$129.99"/>
        <imageView id="star-icon" image="star.fill"/>
        <label id="rating-text" text="4.6 (892 reviews)"/>
    </subviews>
</view>
```

For dynamic content where the label must be composed at runtime, set the combined label in code:

```swift
// ProductCardView.swift
override var accessibilityLabel: String? {
    get {
        return "\(product.name), \(product.formattedPrice), rated \(product.rating) out of 5, \(product.reviewCount) reviews"
    }
    set { }
}
```

Reference: [Grouping Accessibility Elements](https://developer.apple.com/documentation/objectivec/nsobject/1615143-shouldgroupaccessibilitychildren)
