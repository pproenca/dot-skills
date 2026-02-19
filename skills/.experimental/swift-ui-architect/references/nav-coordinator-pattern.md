---
title: Every Feature Has a Coordinator Owning NavigationStack
impact: HIGH
impactDescription: centralizes navigation logic, enables deep linking, keeps views testable
tags: nav, coordinator, navigation-stack, feature, routing
---

## Every Feature Has a Coordinator Owning NavigationStack

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

Each feature module has a Coordinator (`@Observable` class) that owns a `NavigationPath` and manages all routing decisions. The coordinator is the ONLY object that can push/pop/present views. Views request navigation by calling coordinator methods — they never create NavigationLinks with destinations. This centralizes flow logic, enables deep linking, and makes navigation testable.

**Incorrect (navigation logic scattered across views — untestable, no deep linking):**

```swift
// Navigation decisions hardcoded in every view
// No central place to manage flow, test navigation, or handle deep links
struct OrderListView: View {
    @State var viewModel: OrderListViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.orders) { order in
                // Destination hardcoded in the view — cannot be tested or overridden
                NavigationLink(destination: OrderDetailView(orderId: order.id)) {
                    Text(order.title)
                }
            }
            .toolbar {
                Button("Settings") {
                    // Another navigation target — scattered across views
                }
            }
        }
    }
}

struct OrderDetailView: View {
    let orderId: String

    var body: some View {
        VStack {
            // More hardcoded navigation — 10+ views each with their own links
            NavigationLink(destination: TrackingView(orderId: orderId)) {
                Text("Track Order")
            }
            NavigationLink(destination: RefundView(orderId: orderId)) {
                Text("Request Refund")
            }
        }
    }
}
```

**Correct (coordinator owns all routing — centralized, testable, deep-linkable):**

```swift
// Route enum — every destination in one place
enum OrderRoute: Hashable {
    case list
    case detail(orderId: String)
    case tracking(orderId: String)
    case refund(orderId: String)
}

// Coordinator owns NavigationStack and all routing decisions
@Observable
final class OrderCoordinator {
    var path = NavigationPath()
    var presentedSheet: OrderSheetRoute?

    func navigate(to route: OrderRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func present(_ sheet: OrderSheetRoute) {
        presentedSheet = sheet
    }

    // Deep link support — resolve URL to route
    func handle(url: URL) -> Bool {
        guard let route = OrderRoute(url: url) else { return false }
        navigate(to: route)
        return true
    }
}

// Root view — NavigationStack bound to coordinator
struct OrderFlowView: View {
    @State private var coordinator = OrderCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            OrderListView()
                .navigationDestination(for: OrderRoute.self) { route in
                    // Coordinator controls which view maps to which route
                    // Views read coordinator from @Environment — injected below
                    switch route {
                    case .list:
                        OrderListView()
                    case .detail(let orderId):
                        OrderDetailView(orderId: orderId)
                    case .tracking(let orderId):
                        TrackingView(orderId: orderId)
                    case .refund(let orderId):
                        RefundView(orderId: orderId)
                    }
                }
        }
        .sheet(item: $coordinator.presentedSheet) { sheet in
            coordinator.sheetView(for: sheet)
        }
        .environment(coordinator)
    }
}

// Views read coordinator from @Environment — no parameter drilling
// @Environment properties are excluded from @Equatable comparison
struct OrderDetailView: View {
    let orderId: String
    @Environment(OrderCoordinator.self) private var coordinator

    var body: some View {
        VStack {
            Button("Track Order") {
                coordinator.navigate(to: .tracking(orderId: orderId))
            }
            Button("Request Refund") {
                coordinator.navigate(to: .refund(orderId: orderId))
            }
        }
    }
}
```

Reference: [Advanced iOS App Architecture (4th Ed.)](https://www.kodeco.com/books/advanced-ios-app-architecture)
