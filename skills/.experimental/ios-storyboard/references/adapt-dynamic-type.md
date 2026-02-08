---
title: Support Dynamic Type for All Text Labels
impact: MEDIUM
impactDescription: prevents App Store accessibility rejection
tags: adapt, dynamic-type, accessibility, font, text-style
---

## Support Dynamic Type for All Text Labels

Fixed font sizes ignore the user's preferred content size category set in iOS Settings, making the app unusable for visually impaired users. Apple requires Dynamic Type support for accessibility compliance, and apps that fail to scale text properly receive lower App Store accessibility ratings.

**Incorrect (hardcoded point sizes that never change with user preference):**

```xml
<label id="eventTitle" text="Concert Details">
    <fontDescription key="fontDescription" type="system" pointSize="17"/>
</label>

<label id="eventDate" text="March 15, 2025">
    <fontDescription key="fontDescription" type="system" pointSize="13"/>
</label>

<label id="eventVenue" text="Royal Albert Hall">
    <fontDescription key="fontDescription" type="system" pointSize="13"/>
</label>
```

**Correct (use text styles with adjustsFontForContentSizeCategory enabled):**

```xml
<label id="eventTitle" text="Concert Details"
       adjustsFontForContentSizeCategory="YES">
    <fontDescription key="fontDescription" style="UICTFontTextStyleHeadline"/>
</label>

<label id="eventDate" text="March 15, 2025"
       adjustsFontForContentSizeCategory="YES">
    <fontDescription key="fontDescription" style="UICTFontTextStyleSubheadline"/>
</label>

<!-- numberOfLines=0 ensures text wraps when scaled up -->
<label id="eventVenue" text="Royal Albert Hall"
       adjustsFontForContentSizeCategory="YES"
       numberOfLines="0">
    <fontDescription key="fontDescription" style="UICTFontTextStyleBody"/>
</label>
```

For custom fonts, set the style in code with `UIFontMetrics`:

```swift
// EventDetailViewController.swift
eventTitle.font = UIFontMetrics(forTextStyle: .headline)
    .scaledFont(for: UIFont(name: "Avenir-Heavy", size: 17)!)
eventTitle.adjustsFontForContentSizeCategory = true
```

**Benefits:**
- Text scales from Extra Small to Accessibility Extra Extra Extra Large (AX5) automatically
- Meets WCAG 2.1 AA text resizing requirements without custom zoom logic
- Setting `numberOfLines = 0` on labels prevents truncation at larger accessibility sizes
