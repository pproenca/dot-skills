---
title: Pass Data via prepare(for:sender:) Instead of Direct Property Access
impact: HIGH
impactDescription: prevents tight coupling between view controllers
tags: nav, segue, data-passing, coupling
---

## Pass Data via prepare(for:sender:) Instead of Direct Property Access

Instantiating and configuring destination view controllers directly creates a hard dependency between the source and destination, making it impossible to reuse either controller independently. Using `prepare(for:sender:)` keeps data passing centralized in the segue lifecycle where Interface Builder can validate connections at build time.

**Incorrect (directly instantiating and setting properties bypasses the segue lifecycle):**

```swift
// OrderListViewController.swift
func showOrderDetail(for order: Order) {
    let storyboard = UIStoryboard(name: "Orders", bundle: nil)
    // Tightly couples this VC to the destination's concrete type and storyboard ID
    let detailVC = storyboard.instantiateViewController(
        withIdentifier: "OrderDetailViewController"
    ) as! OrderDetailViewController
    detailVC.order = order
    detailVC.delegate = self
    navigationController?.pushViewController(detailVC, animated: true)
}
```

**Correct (use prepare(for:sender:) to pass data through the segue):**

```swift
// OrderListViewController.swift
func showOrderDetail(for order: Order) {
    selectedOrder = order
    performSegue(withIdentifier: "ShowOrderDetail", sender: self)
}

override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowOrderDetail",
       let detailVC = segue.destination as? OrderDetailViewController {
        detailVC.order = selectedOrder
        detailVC.delegate = self
    }
}
```

**Benefits:**
- Navigation flow is visible in Interface Builder, making it auditable without reading code
- Destination view controller can be swapped in the storyboard without changing source code
- Segue identifier mismatches are caught early with runtime assertions
