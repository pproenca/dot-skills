---
title: Present All Modals Via Coordinator — Never Inline @State
impact: HIGH
impactDescription: centralizes modal logic, enables deep-link-triggered sheets, makes modal flows testable
tags: arch, coordinator, modal, sheet, fullscreen-cover
---

## Present All Modals Via Coordinator — Never Inline @State

Modal presentations (`sheet`, `fullScreenCover`, `alert`, `confirmationDialog`) must be driven by coordinator-owned state, not inline view `@State` booleans. The coordinator exposes observable modal state as `Identifiable` enums, and the root NavigationStack view binds `.sheet(item:)` to it. This keeps modal logic testable, allows coordinators to present modals from deep links or push notifications, and eliminates scattered `@State private var showX = false` across views.

**Incorrect (inline @State booleans for modals — untestable, scattered):**

```swift
@Equatable
struct OrderDetailView: View {
    let orderId: String
    // Modal state scattered across the view — untestable
    @State private var showRefundSheet = false
    @State private var showCancelAlert = false
    @State private var showContactSheet = false

    var body: some View {
        VStack {
            Button("Request Refund") { showRefundSheet = true }
            Button("Cancel Order") { showCancelAlert = true }
        }
        // Cannot be triggered from deep link or push notification
        .sheet(isPresented: $showRefundSheet) {
            RefundView(orderId: orderId)
        }
        .alert("Cancel Order?", isPresented: $showCancelAlert) {
            Button("Cancel Order", role: .destructive) { }
        }
    }
}
```

**Correct (coordinator owns all modal state — testable, externally triggerable):**

```swift
// Modal routes as Identifiable enums
enum OrderSheetRoute: Identifiable {
    case refund(orderId: String)
    case contactSupport(orderId: String)

    var id: String {
        switch self {
        case .refund(let id): "refund-\(id)"
        case .contactSupport(let id): "contact-\(id)"
        }
    }
}

@Observable @MainActor
final class OrderCoordinator {
    var path = NavigationPath()
    var presentedSheet: OrderSheetRoute?

    func presentRefund(orderId: String) {
        presentedSheet = .refund(orderId: orderId)
    }

    @ViewBuilder
    func sheetView(for route: OrderSheetRoute) -> some View {
        switch route {
        case .refund(let orderId):
            NavigationStack { RefundView(orderId: orderId) }
        case .contactSupport(let orderId):
            NavigationStack { ContactSupportView(orderId: orderId) }
        }
    }
}

// Root view binds modals to coordinator state — single binding point
@Equatable
struct OrderFlowView: View {
    @State private var coordinator = OrderCoordinator()

    var body: some View {
        @Bindable var coordinator = coordinator
        NavigationStack(path: $coordinator.path) {
            OrderListView()
                .navigationDestination(for: OrderRoute.self) { route in
                    coordinator.destinationView(for: route)
                }
        }
        .sheet(item: $coordinator.presentedSheet) { route in
            coordinator.sheetView(for: route)
        }
        .environment(coordinator)
    }
}

// Views request modals via coordinator — no @State booleans
@Equatable
struct OrderDetailView: View {
    let orderId: String
    @Environment(OrderCoordinator.self) private var coordinator

    var body: some View {
        VStack {
            Button("Request Refund") {
                coordinator.presentRefund(orderId: orderId)
            }
        }
    }
}
```

Reference: [Advanced iOS App Architecture (4th Ed.)](https://www.kodeco.com/books/advanced-ios-app-architecture)
