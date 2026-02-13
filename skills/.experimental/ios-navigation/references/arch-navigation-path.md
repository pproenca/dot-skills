---
title: Use NavigationPath for Heterogeneous Type-Erased Navigation
impact: HIGH
impactDescription: supports mixed route types while maintaining programmatic control
tags: arch, swiftui, navigation-path, type-erasure, state-management, codable
---

## Use NavigationPath for Heterogeneous Type-Erased Navigation

NavigationPath is a type-erased container that can hold any Hashable values, making it suitable when a single NavigationStack must handle pushes from multiple unrelated data types. However, when all destinations share a common route enum, a typed array `[Route]` provides compile-time safety, direct subscript access, and straightforward Codable persistence without the indirection of NavigationPath's CodableRepresentation. Choose NavigationPath for heterogeneous stacks across module boundaries; choose a typed array when routes are centralized in a single enum.

**Incorrect (separate @State booleans simulating a navigation stack):**

```swift
// COST: Each destination requires its own boolean and binding. There
// is no ordered stack — the system cannot determine back navigation
// order. Presenting two destinations simultaneously causes undefined
// UIKit behavior. Programmatic pop-to-root requires resetting every
// boolean manually. State restoration requires persisting N booleans
// plus their associated data independently.
struct DashboardView: View {
    @State private var showTransactionDetail = false
    @State private var selectedTransaction: Transaction?
    @State private var showAccountSettings = false
    @State private var showTransferFlow = false
    @State private var showBeneficiaryList = false
    @State private var showNotifications = false

    var body: some View {
        NavigationStack {
            VStack {
                TransactionListView(onSelect: { transaction in
                    selectedTransaction = transaction
                    showTransactionDetail = true
                })
                Button("Transfer") { showTransferFlow = true }
                Button("Settings") { showAccountSettings = true }
            }
            .navigationDestination(isPresented: $showTransactionDetail) {
                if let tx = selectedTransaction {
                    TransactionDetailView(transaction: tx)
                }
            }
            .navigationDestination(isPresented: $showTransferFlow) {
                TransferFlowView()
            }
            .navigationDestination(isPresented: $showAccountSettings) {
                AccountSettingsView()
            }
        }
    }

    // No way to pop to root without resetting every flag
    func popToRoot() {
        showTransactionDetail = false
        showAccountSettings = false
        showTransferFlow = false
        showBeneficiaryList = false
        showNotifications = false
        selectedTransaction = nil
    }
}
```

**Correct (NavigationPath for heterogeneous stacks, typed array for single-enum routing):**

```swift
// BENEFIT: NavigationPath supports mixed Hashable types for cross-module
// navigation. Typed [Route] array provides compile-time safety when all
// destinations share one enum. Both support programmatic push, pop,
// pop-to-root, and Codable state restoration.

// Option A: NavigationPath — use when pushing values of different types
// across module boundaries (e.g., feature modules that don't share a route enum).
struct DashboardView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                TransactionListView(onSelect: { transaction in
                    path.append(transaction) // Transaction: Hashable
                })
                Button("Transfer") {
                    path.append(TransferRequest()) // TransferRequest: Hashable
                }
            }
            .navigationDestination(for: Transaction.self) { transaction in
                TransactionDetailView(transaction: transaction)
            }
            .navigationDestination(for: TransferRequest.self) { request in
                TransferFlowView(request: request)
            }
            .navigationDestination(for: AccountSection.self) { section in
                AccountSectionView(section: section)
            }
        }
    }

    func popToRoot() { path = NavigationPath() }

    // State restoration with NavigationPath.CodableRepresentation
    func saveState() -> Data? {
        guard let representation = path.codable else { return nil }
        return try? JSONEncoder().encode(representation)
    }

    func restoreState(from data: Data) {
        guard let representation = try? JSONDecoder().decode(
            NavigationPath.CodableRepresentation.self, from: data
        ) else { return }
        path = NavigationPath(representation)
    }
}

// Option B: Typed [Route] array — use when all routes share a single enum.
// Provides direct array access, simpler Codable, and compile-time exhaustiveness.
struct DashboardView_TypedPath: View {
    @State private var path: [DashboardRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                TransactionListView(onSelect: { transaction in
                    path.append(.transactionDetail(transaction.id))
                })
                Button("Transfer") {
                    path.append(.transferFlow(accountId: "default"))
                }
            }
            .navigationDestination(for: DashboardRoute.self) { route in
                switch route {
                case .transactionDetail(let id):
                    TransactionDetailView(transactionId: id)
                case .transferFlow(let accountId):
                    TransferFlowView(accountId: accountId)
                case .accountSettings(let section):
                    AccountSectionView(section: section)
                case .beneficiaryList:
                    BeneficiaryListView()
                }
            }
        }
    }

    func popToRoot() { path.removeAll() }
    func pop() { path.removeLast() }
    func popTo(_ route: DashboardRoute) {
        guard let index = path.firstIndex(of: route) else { return }
        path.removeLast(path.count - index - 1)
    }

    // Direct Codable — no CodableRepresentation wrapper needed
    func saveState() -> Data? { try? JSONEncoder().encode(path) }
    func restoreState(from data: Data) {
        path = (try? JSONDecoder().decode([DashboardRoute].self, from: data)) ?? []
    }
}
```
