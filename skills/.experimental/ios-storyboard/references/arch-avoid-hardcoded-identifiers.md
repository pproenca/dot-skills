---
title: Avoid Hardcoded Storyboard and Cell Identifiers
impact: HIGH
impactDescription: prevents runtime crashes from typos
tags: arch, identifiers, type-safety, crash-prevention
---

## Avoid Hardcoded Storyboard and Cell Identifiers

String literals for storyboard names, view controller identifiers, and cell reuse identifiers are invisible to the compiler. A single typo causes a runtime crash instead of a build error. Centralizing identifiers in enums or structs catches mistakes at compile time and provides autocomplete.

**Incorrect (string literals scattered across the codebase):**

```swift
final class OrderHistoryViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(
            UINib(nibName: "OrderSummaryCell", bundle: nil),
            forCellReuseIdentifier: "OrderSummaryCell"
        )
    }

    func showOrderDetail(for order: Order) {
        let storyboard = UIStoryboard(name: "Orders", bundle: nil)
        // Typo: "OrderDetialVC" — crashes at runtime, no compiler warning
        let detailVC = storyboard.instantiateViewController(
            withIdentifier: "OrderDetialVC"
        ) as! OrderDetailViewController
        detailVC.order = order
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
        // Another copy of the string — must stay in sync manually
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "OrderSummaryCell", for: indexPath
        ) as! OrderSummaryCell
        return cell
    }
}
```

**Correct (centralized identifier constants):**

```swift
enum Storyboard: String {
    case orders = "Orders"
    case profile = "Profile"
    case settings = "Settings"

    var instance: UIStoryboard {
        UIStoryboard(name: rawValue, bundle: nil)
    }
}

enum ViewControllerID: String {
    case orderDetail = "OrderDetailVC"
    case orderHistory = "OrderHistoryVC"
    case profileMain = "ProfileMainVC"
}

enum CellID: String {
    case orderSummary = "OrderSummaryCell"
    case profileHeader = "ProfileHeaderCell"
}
```

```swift
final class OrderHistoryViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(
            UINib(nibName: CellID.orderSummary.rawValue, bundle: nil),
            forCellReuseIdentifier: CellID.orderSummary.rawValue
        )
    }

    func showOrderDetail(for order: Order) {
        let detailVC = Storyboard.orders.instance.instantiateViewController(
            withIdentifier: ViewControllerID.orderDetail.rawValue
        ) as! OrderDetailViewController
        detailVC.order = order
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CellID.orderSummary.rawValue, for: indexPath
        ) as! OrderSummaryCell
        return cell
    }
}
```

**Alternative (protocol-based approach for view controllers):**

```swift
protocol StoryboardInstantiable: UIViewController {
    static var storyboard: Storyboard { get }
    static var identifier: String { get }
}

extension StoryboardInstantiable {
    static var identifier: String { String(describing: self) }

    static func instantiate() -> Self {
        storyboard.instance.instantiateViewController(
            withIdentifier: identifier
        ) as! Self
    }
}

extension OrderDetailViewController: StoryboardInstantiable {
    static var storyboard: Storyboard { .orders }
}

// Usage — compile-time safe, no string literals at call site
let detailVC = OrderDetailViewController.instantiate()
```

Reference: [UIStoryboard](https://developer.apple.com/documentation/uikit/uistoryboard)
