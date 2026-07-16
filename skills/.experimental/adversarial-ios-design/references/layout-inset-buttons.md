---
title: Inset buttons from the display edges
tags: layout, buttons, margins, safe-areas
---

## Inset buttons from the display edges

The wrong default — imported from web and Android habits — is `.frame(maxWidth: .infinity)` on a call-to-action button with no horizontal inset, pinning it flush to both display edges. Buttons feel at home on iOS when they respect the system margins: an edge-to-edge slab of color fights the rounded display corners and reads as a foreign toolkit. Inset the button with horizontal padding, or, when a full-width bar is genuinely intended, align it to the safe areas with corners concentric to the display.

**Evidence of violation:** a `Button` (or tappable styled container) with `.frame(maxWidth: .infinity)` whose ancestor chain contains no horizontal inset — no `.padding` with a horizontal component at any level, and no inset-providing container (`List`, `Form`, `GroupBox`) between it and the screen edge; cite the chain. When the chain cannot be traced completely from the target, the leg is decided by a screenshot showing the control touching both display edges; with neither a traceable chain nor a screenshot, mark N/A with that reason. PASS: `.padding(.horizontal)` or an inset-providing container anywhere in the chain; a deliberate full-width bar whose safe-area alignment and display-concentric corners are citable in code — absent that evidence, fail closed. N/A: no `maxWidth: .infinity` tappables in the target.

**Incorrect (an edge-to-edge slab that ignores the system margins):**

```swift
import SwiftUI

struct TransferConfirmationView: View {
    let transfer: Transfer
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            TransferSummaryCard(transfer: transfer)
            Spacer()
            Button(action: onConfirm) {
                Text("Confirm Transfer")
                    .frame(maxWidth: .infinity) // ⚠️ flush to both display edges
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
```

**Correct (the same prominence, inset to the system margins):**

```swift
import SwiftUI

struct TransferConfirmationView: View {
    let transfer: Transfer
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            TransferSummaryCard(transfer: transfer)
            Spacer()
            Button(action: onConfirm) {
                Text("Confirm Transfer")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
        }
    }
}
```

Reference: [Human Interface Guidelines — Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
