---
title: {Rule Title}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {Quantified impact}
tags: {category-prefix}, {technique}, {related-concepts}
---

## {Rule Title}

{1-3 sentences explaining WHY this matters. Focus on crash/corruption implications.}

**Incorrect ({description of the crash/bug}):**

```swift
{Dangerous code that will crash under specific conditions}
{// Comment on the KEY line explaining the cost}
```

**Proof Test (exposes the crash):**

```swift
{XCTest that FAILS with the incorrect code — proves the bug exists}
```

**Correct ({description of the fix}):**

```swift
{Safe code that makes the proof test pass}
{// Comment on the KEY line explaining the fix}
```
