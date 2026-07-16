---
title: Keep every text size at 11 points or larger
tags: type, minimum-size, legibility, font
---

## Keep every text size at 11 points or larger

The wrong default is shrinking tertiary text — legal lines, badge counts, axis labels — to 8–10 points because it fits and still reads on the author's simulator. Apple's floor for iOS text is 11 points: below it, text is illegible for a large share of users at normal viewing distance regardless of Dynamic Type settings. If content doesn't fit at 11, the fix is layout or wording, not a smaller font.

**Evidence of violation:** any font size literal below 11 on user-visible text — `.system(size: 9)`, `Font.custom(_, size: 10)`, `fixedSize: 10`, a `UIFont` constructed with a literal below 11 — cite the literal; also a `.minimumScaleFactor` whose arithmetic (base size × factor) lands below 11 on primary content. PASS: all size literals at 11 or above; the smallest ramp style in use is `.caption2` (11 points at the default setting). Whether a literal size ought to be a semantic style at all is the sibling architecture gate's concern, not this rule's — a literal of 11 or more passes here regardless of mechanism. N/A: no size literals and no styles below `.caption2` in the target.

**Incorrect (a 9-point disclosure nobody can read):**

```swift
import SwiftUI

struct SavingsRateFooter: View {
    let account: SavingsAccount

    var body: some View {
        Text("Rate is variable and subject to change. APY accurate as of \(account.rateDate, format: .dateTime.month().day().year()).")
            .font(.system(size: 9)) // ⚠️ below the 11pt floor
            .foregroundStyle(.secondary)
    }
}
```

**Correct (the smallest legible step of the ramp):**

```swift
import SwiftUI

struct SavingsRateFooter: View {
    let account: SavingsAccount

    var body: some View {
        Text("Rate is variable and subject to change. APY accurate as of \(account.rateDate, format: .dateTime.month().day().year()).")
            .font(.caption2)
            .foregroundStyle(.secondary)
    }
}
```

Reference: [Human Interface Guidelines — Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
