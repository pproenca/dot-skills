---
title: Update Accessibility Labels for Dynamic Content
impact: LOW-MEDIUM
impactDescription: prevents stale VoiceOver descriptions
tags: ally, dynamic-label, voiceover, state
---

## Update Accessibility Labels for Dynamic Content

Storyboards set accessibility labels at design time, but interactive controls like steppers, sliders, and toggle switches change their displayed value at runtime. If the accessibility label is never updated in code, VoiceOver announces the original static label regardless of the current state, leaving users unaware of what value they have selected.

**Incorrect (static label ignores runtime value changes):**

```swift
// CartItemCell.swift — configured in storyboard with label "Quantity stepper"
@IBOutlet weak var quantityStepper: UIStepper!
@IBOutlet weak var quantityLabel: UILabel!

@IBAction func stepperChanged(_ sender: UIStepper) {
    let quantity = Int(sender.value)
    quantityLabel.text = "\(quantity)"
    // VoiceOver still announces "Quantity stepper" regardless of value
}
```

**Correct (accessibility label and value updated on every change):**

```swift
// CartItemCell.swift
@IBOutlet weak var quantityStepper: UIStepper!
@IBOutlet weak var quantityLabel: UILabel!

@IBAction func stepperChanged(_ sender: UIStepper) {
    let quantity = Int(sender.value)
    quantityLabel.text = "\(quantity)"
    sender.accessibilityLabel = "Quantity"
    sender.accessibilityValue = "\(quantity) items"
    UIAccessibility.post(notification: .layoutChanged, argument: sender)
}
```

Use `accessibilityValue` for the changing portion and keep `accessibilityLabel` as the stable descriptor. VoiceOver announces both: "Quantity: 3 items, adjustable". Post a layout changed notification so VoiceOver re-reads the element immediately after the value changes.

**Benefits:**

- VoiceOver announces "Quantity: 3 items" instead of just "Quantity stepper"
- The `.layoutChanged` notification ensures the new value is read without requiring a manual swipe
- Separating label from value follows the UIAccessibility API contract

Reference: [accessibilityValue](https://developer.apple.com/documentation/objectivec/nsobject/1615181-accessibilitylabel)
