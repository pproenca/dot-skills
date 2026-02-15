---
title: Present Modals Via Coordinator, Not Inline
impact: MEDIUM-HIGH
impactDescription: prevents modal presentation logic from coupling to view hierarchy
tags: nav, modal, sheet, fullscreen-cover, coordinator
---

## Present Modals Via Coordinator, Not Inline

Modal presentations (`sheet`, `fullScreenCover`, `alert`, `confirmationDialog`) must be driven by coordinator-owned state, not inline view state. The coordinator exposes observable modal state, and the root NavigationStack view binds `.sheet` to it. This keeps modal logic testable and allows coordinators to present modals from anywhere in the flow.

**Incorrect (inline modal state — untestable, scattered, cannot be triggered externally):**

```swift
struct OrderDetailView: View {
    let orderId: String
    @State var viewModel: OrderDetailViewModel

    // Modal state owned by the view — untestable
    @State private var showRefundSheet = false
    @State private var showCancelAlert = false
    @State private var showContactSheet = false

    var body: some View {
        VStack {
            Button("Request Refund") {
                showRefundSheet = true  // View controls presentation
            }
            Button("Cancel Order") {
                showCancelAlert = true
            }
            Button("Contact Support") {
                showContactSheet = true
            }
        }
        // Sheets scattered throughout the view hierarchy
        // Cannot be triggered from deep link, push notification, or coordinator
        .sheet(isPresented: $showRefundSheet) {
            RefundView(orderId: orderId)
        }
        .alert("Cancel Order?", isPresented: $showCancelAlert) {
            Button("Cancel Order", role: .destructive) {
                viewModel.cancelOrder()
            }
        }
        .sheet(isPresented: $showContactSheet) {
            ContactSupportView(orderId: orderId)
        }
    }
}
```

**Correct (coordinator owns modal state — testable, externally triggerable):**

```swift
// Modal routes as an enum — same pattern as navigation routes
enum OrderSheetRoute: Identifiable {
    case refund(orderId: String)
    case contactSupport(orderId: String)
    case shareOrder(orderId: String)

    var id: String {
        switch self {
        case .refund(let id): return "refund-\(id)"
        case .contactSupport(let id): return "contact-\(id)"
        case .shareOrder(let id): return "share-\(id)"
        }
    }
}

enum OrderAlertRoute: Identifiable {
    case cancelConfirmation(orderId: String)
    case deleteConfirmation(orderId: String)

    var id: String {
        switch self {
        case .cancelConfirmation(let id): return "cancel-\(id)"
        case .deleteConfirmation(let id): return "delete-\(id)"
        }
    }
}

// Coordinator owns all modal state
@Observable
final class OrderCoordinator {
    var path = NavigationPath()
    var presentedSheet: OrderSheetRoute?
    var presentedAlert: OrderAlertRoute?

    func presentRefund(orderId: String) {
        presentedSheet = .refund(orderId: orderId)
    }

    func presentCancelConfirmation(orderId: String) {
        presentedAlert = .cancelConfirmation(orderId: orderId)
    }

    func dismissSheet() {
        presentedSheet = nil
    }

    // Can be called from deep links, push notifications, etc.
    @ViewBuilder
    func sheetView(for route: OrderSheetRoute) -> some View {
        switch route {
        case .refund(let orderId):
            RefundView(orderId: orderId)
        case .contactSupport(let orderId):
            ContactSupportView(orderId: orderId)
        case .shareOrder(let orderId):
            ShareOrderView(orderId: orderId)
        }
    }
}

// Root view binds modals to coordinator state
struct OrderFlowView: View {
    @State private var coordinator = OrderCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            OrderListView()
                .navigationDestination(for: OrderRoute.self) { route in
                    coordinator.destinationView(for: route)
                }
        }
        // Sheets driven by coordinator — one binding point
        .sheet(item: $coordinator.presentedSheet) { route in
            coordinator.sheetView(for: route)
        }
        .environment(coordinator)
    }
}

// Views request modals via coordinator — no @State booleans
struct OrderDetailView: View {
    let orderId: String
    @Environment(OrderCoordinator.self) private var coordinator

    var body: some View {
        VStack {
            Button("Request Refund") {
                coordinator.presentRefund(orderId: orderId)
            }
            Button("Cancel Order") {
                coordinator.presentCancelConfirmation(orderId: orderId)
            }
        }
    }
}
```

Reference: [Advanced iOS App Architecture (4th Ed.)](https://www.kodeco.com/books/advanced-ios-app-architecture)
