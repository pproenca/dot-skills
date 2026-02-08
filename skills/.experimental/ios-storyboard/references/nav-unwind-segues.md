---
title: Use Unwind Segues to Navigate Backward
impact: HIGH
impactDescription: prevents retain cycles and navigation stack corruption
tags: nav, unwind, memory-leak, navigation-stack
---

## Use Unwind Segues to Navigate Backward

Manually calling `dismiss(animated:)` or `popViewController(animated:)` bypasses the storyboard's navigation graph and can leave orphaned view controllers in memory. Unwind segues let UIKit properly tear down the navigation stack back to the target controller, releasing intermediate controllers and triggering the correct lifecycle callbacks.

**Incorrect (manual dismiss creates fragile navigation and potential memory leaks):**

```swift
// CheckoutConfirmationViewController.swift
@IBAction func returnToProductList(_ sender: UIButton) {
    // Pops only one level — breaks if an extra VC was pushed between
    navigationController?.popToRootViewController(animated: true)
}

@IBAction func dismissFlow(_ sender: UIButton) {
    // Dismisses only the presented VC, not the entire modal navigation stack
    dismiss(animated: true, completion: nil)
}
```

**Correct (define the unwind action on the DESTINATION controller, wire it in IB):**

```swift
// ProductListViewController.swift — the controller you're unwinding TO
@IBAction func unwindToProductList(_ segue: UIStoryboardSegue) {
    if let confirmationVC = segue.source as? CheckoutConfirmationViewController {
        completedOrderId = confirmationVC.orderId
    }
}
```

In Interface Builder, Control-drag from the CheckoutConfirmationViewController's trigger button to the **Exit** icon at the top of the scene, then select `unwindToProductList:`.

**When NOT to use:**
- Programmatic dismiss is acceptable for self-contained modal flows presented outside of storyboards (e.g., `UIImagePickerController`)

**Reference:**
- [Apple: Using Unwind Segues](https://developer.apple.com/documentation/uikit/resource_management/dismissing_a_view_controller_with_an_unwind_segue)
