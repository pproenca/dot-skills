---
title: {Rule Title}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {quantified impact — e.g., "eliminates 200ms perceived latency", "reduces animation bugs by 80%"}
tags: {prefix}, {technique}, {related-concepts}
---

## {Rule Title}

{1-3 sentences explaining WHY this matters. Focus on what goes wrong without this pattern and how the user perceives the difference. Be specific about the iOS animation system behavior.}

**Incorrect ({what's wrong — e.g., "linear easing for interactive element"}):**

```swift
{Bad code example — production-realistic SwiftUI view, not strawman}
{// Comments explaining the cost or broken behavior}
```

**Correct ({what's right — e.g., "spring with velocity preservation"}):**

```swift
{Good code example — minimal diff from incorrect}
{// Comments explaining the benefit}
```

{Optional sections as needed:}

**Alternative ({context — e.g., "view modifier form"}):**

```swift
{Alternative approach when applicable}
```

**When NOT to use this pattern:**
- {Exception 1}
- {Exception 2}

Reference: [{WWDC session or Apple docs title}]({URL})
