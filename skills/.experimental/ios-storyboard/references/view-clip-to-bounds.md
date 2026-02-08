---
title: Enable Clip to Bounds for Views with Corner Radius
impact: LOW-MEDIUM
impactDescription: prevents visual overflow artifacts
tags: view, clip-to-bounds, corner-radius, rendering
---

## Enable Clip to Bounds for Views with Corner Radius

Setting `layer.cornerRadius` in a User Defined Runtime Attribute or via `@IBInspectable` rounds the background but does not clip subviews or the content of UIImageView. Without `clipsToBounds`, images and child views overflow the rounded corners, producing rectangular artifacts that break the intended design.

**Incorrect (cornerRadius without clipsToBounds):**

```xml
<view id="avatar-container" customClass="AvatarView">
    <rect key="frame" x="16" y="100" width="80" height="80"/>
    <subviews>
        <imageView id="avatar-image" image="profile-photo"
                   contentMode="scaleAspectFill">
            <rect key="frame" x="0" y="0" width="80" height="80"/>
        </imageView>
    </subviews>
    <userDefinedRuntimeAttributes>
        <!-- Image overflows the rounded corners -->
        <userDefinedRuntimeAttribute type="number" keyPath="layer.cornerRadius">
            <real key="value" value="40"/>
        </userDefinedRuntimeAttribute>
    </userDefinedRuntimeAttributes>
</view>
```

**Correct (clipsToBounds clips content to the rounded path):**

```xml
<view id="avatar-container" customClass="AvatarView" clipsToBounds="YES">
    <rect key="frame" x="16" y="100" width="80" height="80"/>
    <subviews>
        <imageView id="avatar-image" image="profile-photo"
                   contentMode="scaleAspectFill">
            <rect key="frame" x="0" y="0" width="80" height="80"/>
        </imageView>
    </subviews>
    <userDefinedRuntimeAttributes>
        <userDefinedRuntimeAttribute type="number" keyPath="layer.cornerRadius">
            <real key="value" value="40"/>
        </userDefinedRuntimeAttribute>
    </userDefinedRuntimeAttributes>
</view>
```

**When NOT to use:**

Avoid `clipsToBounds` on views that intentionally render shadows via `layer.shadowPath`, since clipping removes the shadow. In that case, use a separate container view for the shadow and an inner view with clipping for the corner radius.
