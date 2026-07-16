---
title: Keep haptics off high-frequency and trivial triggers
tags: haptic, sensoryfeedback, overuse, triggers
---

## Keep haptics off high-frequency and trivial triggers

The wrong default in the other direction is `sensoryFeedback` bolted onto every interaction "for feel" — every button, every row tap, every scroll tick — producing haptic spam. Apple's guidance is that a haptic that feels just right occasionally becomes tiresome when it plays frequently, and that the best haptic experience is one people may not be conscious of but miss when it's turned off; in most apps, short haptics belong on discrete events. High-frequency haptics also train users to disable haptics app-wide, silencing the outcomes that deserve them.

**Evidence of violation:** a `.sensoryFeedback` modifier or feedback-generator call (`impactOccurred()`, `selectionChanged()`, `notificationOccurred(_:)`) whose trigger is one of these enumerated shapes: an ordinary navigation tap (pushing a screen, dismissing, switching tabs), every list-cell tap, a per-keystroke trigger (`onChange` of a `TextField`/`TextEditor` binding), a continuously-changing value (raw scroll offset, drag translation), or a timer tick. Cite the trigger binding — the trigger list is closed; shapes outside it do not fail this rule. PASS: haptics bound only to discrete, meaningful events — task outcomes, snap positions, selection value changes, threshold crossings — cite the trigger sites checked. N/A: the target contains no haptic feedback calls at all.

**Incorrect (a haptic per scroll tick — tiresome within seconds):**

```swift
import SwiftUI

struct ChapterScrollView: View {
    let chapters: [String]
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(chapters, id: \.self) { chapter in
                    Text(chapter).padding(.vertical, 4)
                }
            }
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { _, newOffset in
            scrollOffset = newOffset
        }
        // ⚠️ Trigger is a continuously-changing scroll offset — fires constantly
        .sensoryFeedback(.selection, trigger: scrollOffset)
    }
}
```

**Correct (the haptic marks a discrete event — reaching the final chapter):**

```swift
import SwiftUI

struct ChapterScrollView: View {
    let chapters: [String]
    @State private var reachedEnd = false

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(chapters, id: \.self) { chapter in
                    Text(chapter).padding(.vertical, 4)
                }
                Color.clear
                    .frame(height: 1)
                    .onAppear { reachedEnd = true }
            }
        }
        .sensoryFeedback(.success, trigger: reachedEnd) { _, newValue in
            newValue
        }
    }
}
```

Reference: [Human Interface Guidelines — Playing haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)
