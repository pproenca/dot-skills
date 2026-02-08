---
title: Set Correct Content Mode for UIImageView in Storyboard
impact: LOW-MEDIUM
impactDescription: prevents stretched or distorted images
tags: view, content-mode, image-view, aspect-ratio
---

## Set Correct Content Mode for UIImageView in Storyboard

The default content mode for UIImageView is `scaleToFill`, which stretches the image to match the view's frame regardless of aspect ratio. For photographs, icons, and user-uploaded content this produces visually distorted results. Choosing `scaleAspectFit` or `scaleAspectFill` preserves the original aspect ratio.

**Incorrect (default scaleToFill distorts non-square images):**

```xml
<imageView id="product-image" image="product-hero"
           contentMode="scaleToFill">
    <!-- 16:9 image stretched into a square frame -->
    <rect key="frame" x="0" y="0" width="375" height="375"/>
</imageView>
```

**Correct (scaleAspectFill preserves aspect ratio with clipping):**

```xml
<imageView id="product-image" image="product-hero"
           contentMode="scaleAspectFill" clipsToBounds="YES">
    <rect key="frame" x="0" y="0" width="375" height="375"/>
</imageView>
```

**Alternative:**

Use `scaleAspectFit` when the entire image must be visible without cropping (e.g., a document scan or diagram). The view will show letterbox/pillarbox bars if the aspect ratios do not match:

```xml
<imageView id="document-scan" image="receipt-photo"
           contentMode="scaleAspectFit">
    <rect key="frame" x="16" y="100" width="343" height="480"/>
</imageView>
```

| Content Mode | Behavior | Use Case |
|---|---|---|
| `scaleAspectFill` | Fills frame, clips overflow | Photos, avatars, hero images |
| `scaleAspectFit` | Fits inside frame, may letterbox | Documents, diagrams, logos |
| `scaleToFill` | Stretches to fill exactly | Gradient backgrounds, solid fills |

Reference: [UIView.ContentMode](https://developer.apple.com/documentation/uikit/uiview/contentmode)
