---
title: Avoid Deeply Nested Stack Views Beyond Two Levels
impact: MEDIUM-HIGH
impactDescription: prevents layout calculation overhead in scroll views
tags: view, stack-view, nesting, performance
---

## Avoid Deeply Nested Stack Views Beyond Two Levels

Each level of stack view nesting adds a round of recursive `systemLayoutSizeFitting` calls during layout. Beyond two levels, the layout engine performs exponentially more constraint-solving passes, which causes visible frame drops when the hierarchy is embedded in a UIScrollView or UITableViewCell that recalculates layout during scrolling.

**Incorrect (4-level deep stack view nesting):**

```xml
<!-- Deeply nested stacks cause O(n^2) layout passes in scroll views -->
<stackView id="outer-stack" axis="vertical" spacing="16">
    <subviews>
        <stackView id="section-stack" axis="vertical" spacing="12">
            <subviews>
                <stackView id="row-stack" axis="horizontal" spacing="8">
                    <subviews>
                        <stackView id="icon-label-stack" axis="horizontal" spacing="4">
                            <subviews>
                                <imageView id="rating-icon" image="star.fill"/>
                                <label id="rating-label" text="4.8"/>
                            </subviews>
                        </stackView>
                        <label id="review-count" text="(2,341 reviews)"/>
                    </subviews>
                </stackView>
                <label id="description-label" text="Award-winning restaurant..."/>
            </subviews>
        </stackView>
        <label id="address-label" text="123 Main Street"/>
    </subviews>
</stackView>
```

**Correct (flattened to maximum 2 levels of nesting):**

```xml
<stackView id="outer-stack" axis="vertical" spacing="16">
    <subviews>
        <stackView id="rating-row" axis="horizontal" spacing="4">
            <subviews>
                <imageView id="rating-icon" image="star.fill"/>
                <label id="rating-label" text="4.8"/>
                <label id="review-count" text="(2,341 reviews)"/>
            </subviews>
        </stackView>
        <label id="description-label" text="Award-winning restaurant..."/>
        <label id="address-label" text="123 Main Street"/>
    </subviews>
</stackView>
```

**When NOT to use this rule:**

- Static layouts that are never embedded in scroll views or table cells can tolerate deeper nesting without visible performance impact. Measure with Instruments Time Profiler before flattening stable layouts.

Reference: [Optimizing Auto Layout](https://developer.apple.com/videos/play/wwdc2018/220/)
