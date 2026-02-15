---
title: Never Use NavigationLink(destination:) — Use navigationDestination(for:)
impact: HIGH
impactDescription: NavigationLink(destination:) eagerly creates destination views and prevents coordinator routing
tags: nav, navigation-link, navigation-destination, lazy, routing
---

## Never Use NavigationLink(destination:) — Use navigationDestination(for:)

`NavigationLink(destination:)` is the legacy API that eagerly initializes the destination view and hardcodes the navigation target into the view itself. Use `NavigationLink(value:)` with `.navigationDestination(for:)` which lazily creates the destination and lets the coordinator control the mapping from route to view.

**Incorrect (NavigationLink(destination:) — eager init, hardcoded destination, no coordinator):**

```swift
struct OrderListView: View {
    @State var viewModel: OrderListViewModel

    var body: some View {
        // Legacy NavigationView — also deprecated
        NavigationView {
            List(viewModel.orders) { order in
                // destination: eagerly creates OrderDetailView for EVERY row
                // Even rows off-screen have their DetailView initialized
                NavigationLink(destination: OrderDetailView(
                    orderId: order.id,
                    // Hardcoded dependency — view decides its own destination
                    repository: OrderRepository(),
                    analytics: AnalyticsService.shared
                )) {
                    OrderRowView(order: order)
                }
            }
        }
    }
}

// Problems:
// 1. OrderDetailView created for ALL 100 rows immediately (eager init)
// 2. View hardcodes its destination — cannot be overridden by coordinator
// 3. Dependencies injected at the call site — not through DI system
// 4. Deep linking impossible — no route to push programmatically
// 5. Navigation logic scattered across every view
```

**Correct (NavigationLink(value:) + .navigationDestination — lazy, coordinator-routed):**

```swift
struct OrderListView: View {
    @State var viewModel: OrderListViewModel

    var body: some View {
        List(viewModel.orders) { order in
            // value: only pushes a Route enum value — no view creation
            // The actual destination is resolved lazily by .navigationDestination
            NavigationLink(value: OrderRoute.detail(orderId: order.id)) {
                OrderRowView(
                    title: order.title,
                    subtitle: order.formattedDate
                )
            }
        }
    }
}

// Coordinator owns the NavigationStack and destination mapping
struct OrderFlowView: View {
    @State private var coordinator = OrderCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            OrderListView()
                // Destination resolved LAZILY — only when navigated to
                // Coordinator controls the view factory
                .navigationDestination(for: OrderRoute.self) { route in
                    switch route {
                    case .list:
                        OrderListView()
                    case .detail(let orderId):
                        // View created on-demand, not eagerly
                        // Dependencies injected through Environment, not call site
                        OrderDetailView(orderId: orderId)
                    case .tracking(let orderId):
                        TrackingView(orderId: orderId)
                    case .refund(let orderId, let reason):
                        RefundView(orderId: orderId, reason: reason)
                    }
                }
        }
        .environment(coordinator)
    }
}

// Benefits:
// 1. Zero eager initialization — views created only when navigated to
// 2. Coordinator controls all destination mapping in one place
// 3. Programmatic navigation: coordinator.navigate(to: .detail(orderId: "123"))
// 4. Deep linking works: coordinator.handle(url: deepLinkURL)
// 5. Testable: verify coordinator.path contains expected routes
```

Reference: [Apple Documentation — NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack)
