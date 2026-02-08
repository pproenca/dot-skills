---
title: Validate Segue Conditions with shouldPerformSegue
impact: MEDIUM
impactDescription: prevents invalid navigation and data inconsistency
tags: nav, segue, validation, form
---

## Validate Segue Conditions with shouldPerformSegue

When a segue is wired directly to a button in Interface Builder, tapping the button fires the segue unconditionally. If the screen requires valid input before proceeding, the user lands on the next screen with incomplete or invalid data. Overriding `shouldPerformSegue(withIdentifier:sender:)` intercepts the transition and keeps the user on the current screen until all conditions are met.

**Incorrect (segue fires without validating required fields):**

```swift
// ShippingAddressViewController.swift
// Segue wired from "Continue" button directly to PaymentViewController in IB
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ProceedToPayment",
       let paymentVC = segue.destination as? PaymentViewController {
        // addressLine1 might be empty — PaymentVC receives invalid data
        paymentVC.shippingAddress = ShippingAddress(
            line1: addressLine1Field.text ?? "",
            city: cityField.text ?? "",
            postalCode: postalCodeField.text ?? ""
        )
    }
}
```

**Correct (validate before allowing the segue to proceed):**

```swift
// ShippingAddressViewController.swift
override func shouldPerformSegue(
    withIdentifier identifier: String,
    sender: Any?
) -> Bool {
    guard identifier == "ProceedToPayment" else { return true }

    let isValid = [addressLine1Field, cityField, postalCodeField]
        .allSatisfy { ($0.text ?? "").isEmpty == false }

    if !isValid {
        showValidationError("Please fill in all address fields.")
    }
    return isValid
}

override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ProceedToPayment",
       let paymentVC = segue.destination as? PaymentViewController {
        paymentVC.shippingAddress = ShippingAddress(
            line1: addressLine1Field.text!,
            city: cityField.text!,
            postalCode: postalCodeField.text!
        )
    }
}
```

**Benefits:**
- Validation logic stays in the source view controller instead of leaking into the destination
- The segue connection in Interface Builder remains intact, keeping the flow visible
- Works with any trigger (button, cell selection, gesture) without additional guard code
