---
title: Tint at most one prominent action per bar
tags: glass, tint, toolbars, emphasis
---

## Tint at most one prominent action per bar

The wrong default is brand-tinting every toolbar item so the bar "matches the identity." When every element is tinted, nothing reads as primary, and colored fills multiply against Liquid Glass until legibility over content collapses. Apple's grammar is one prominent action per bar — Done, Send, the single thing the screen exists for — with emphasis carried by the control's background, not its symbol or text, and every other item monochrome.

**Evidence of violation:** two or more items within one bar scope — a toolbar, a tab bar, or a floating action cluster — carrying prominence: `.buttonStyle(.glassProminent)`, `.borderedProminent`, or `.tint(` on the item itself; count the prominent items and cite each. Also a violation: emphasis applied to the symbol or text color (`.foregroundStyle(accent)` on a bar item's label) instead of the control background. PASS: at most one prominent tinted action per bar, placed on the trailing side, remaining items monochrome — cite the bar's item list. N/A: no bar or cluster in the target contains more than one action.

**Incorrect (three tinted items — no primary action, glass legibility gone):**

```swift
import SwiftUI

struct TicketDetailView: View {
    let ticket: EventTicket

    var body: some View {
        TicketSummary(ticket: ticket)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Share", systemImage: "square.and.arrow.up") { }
                        .tint(.purple) // ⚠️ tinted
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Favorite", systemImage: "heart") { }
                        .tint(.purple) // ⚠️ tinted
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Buy") { }
                        .buttonStyle(.glassProminent) // ⚠️ third prominent item in the same bar
                }
            }
    }
}
```

**Correct (one prominent trailing action; the rest monochrome):**

```swift
import SwiftUI

struct TicketDetailView: View {
    let ticket: EventTicket

    var body: some View {
        TicketSummary(ticket: ticket)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Share", systemImage: "square.and.arrow.up") { }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Favorite", systemImage: "heart") { }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Buy") { }
                        .buttonStyle(.glassProminent)
                }
            }
    }
}
```

Reference: [Human Interface Guidelines — Color](https://developer.apple.com/design/human-interface-guidelines/color), [Human Interface Guidelines — Toolbars](https://developer.apple.com/design/human-interface-guidelines/toolbars), [WWDC25 — Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)
