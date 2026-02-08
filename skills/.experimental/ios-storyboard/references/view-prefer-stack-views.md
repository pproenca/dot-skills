---
title: Use Stack Views Instead of Manual Constraints for Linear Layouts
impact: MEDIUM-HIGH
impactDescription: reduces constraint count by 60-80%
tags: view, stack-view, constraints, layout
---

## Use Stack Views Instead of Manual Constraints for Linear Layouts

Manually constraining views in a linear arrangement requires top-to-bottom or leading-to-trailing chains, spacing constants, and equal-width or equal-height constraints for every pair. A single UIStackView replaces all of that with one axis, distribution, and spacing value, making the layout declarative and far easier to modify when requirements change.

**Incorrect (12 individual constraints for 3 labels in a vertical list):**

```xml
<viewController id="profile-vc">
    <view key="view" id="root-view">
        <subviews>
            <label id="name-label" text="Jane Appleseed">
                <rect key="frame" x="16" y="100" width="343" height="21"/>
            </label>
            <label id="email-label" text="jane@example.com">
                <rect key="frame" x="16" y="129" width="343" height="21"/>
            </label>
            <label id="role-label" text="Senior Engineer">
                <rect key="frame" x="16" y="158" width="343" height="21"/>
            </label>
        </subviews>
        <constraints>
            <!-- 12 constraints to achieve a simple vertical list -->
            <constraint firstItem="name-label" firstAttribute="top"
                       secondItem="root-view" secondAttribute="top" constant="100"/>
            <constraint firstItem="name-label" firstAttribute="leading"
                       secondItem="root-view" secondAttribute="leading" constant="16"/>
            <constraint firstItem="name-label" firstAttribute="trailing"
                       secondItem="root-view" secondAttribute="trailing" constant="-16"/>
            <constraint firstItem="name-label" firstAttribute="height" constant="21"/>
            <constraint firstItem="email-label" firstAttribute="top"
                       secondItem="name-label" secondAttribute="bottom" constant="8"/>
            <constraint firstItem="email-label" firstAttribute="leading"
                       secondItem="root-view" secondAttribute="leading" constant="16"/>
            <constraint firstItem="email-label" firstAttribute="trailing"
                       secondItem="root-view" secondAttribute="trailing" constant="-16"/>
            <constraint firstItem="email-label" firstAttribute="height" constant="21"/>
            <constraint firstItem="role-label" firstAttribute="top"
                       secondItem="email-label" secondAttribute="bottom" constant="8"/>
            <constraint firstItem="role-label" firstAttribute="leading"
                       secondItem="root-view" secondAttribute="leading" constant="16"/>
            <constraint firstItem="role-label" firstAttribute="trailing"
                       secondItem="root-view" secondAttribute="trailing" constant="-16"/>
            <constraint firstItem="role-label" firstAttribute="height" constant="21"/>
        </constraints>
    </view>
</viewController>
```

**Correct (UIStackView with spacing replaces all inter-view constraints):**

```xml
<viewController id="profile-vc">
    <view key="view" id="root-view">
        <viewLayoutGuide key="safeArea" id="safe-area"/>
        <subviews>
            <stackView id="info-stack" axis="vertical" spacing="8">
                <rect key="frame" x="16" y="100" width="343" height="71"/>
                <subviews>
                    <label id="name-label" text="Jane Appleseed"/>
                    <label id="email-label" text="jane@example.com"/>
                    <label id="role-label" text="Senior Engineer"/>
                </subviews>
            </stackView>
        </subviews>
        <constraints>
            <!-- Only position the stack view itself -->
            <constraint firstItem="info-stack" firstAttribute="top"
                       secondItem="safe-area" secondAttribute="top" constant="100"/>
            <constraint firstItem="info-stack" firstAttribute="leading"
                       secondItem="safe-area" secondAttribute="leading" constant="16"/>
            <constraint firstItem="info-stack" firstAttribute="trailing"
                       secondItem="safe-area" secondAttribute="trailing"/>
        </constraints>
    </view>
</viewController>
```

**Benefits:**

- Adding or removing a label requires zero constraint changes
- Spacing adjustments are a single attribute edit instead of updating N constraints
- Stack views automatically handle hidden subviews by collapsing their space

Reference: [UIStackView](https://developer.apple.com/documentation/uikit/uistackview)
