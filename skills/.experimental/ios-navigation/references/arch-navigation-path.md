---
title: Use NavigationPath for Heterogeneous Type-Erased Navigation
impact: HIGH
impactDescription: O(1) multi-type push onto single type-erased NavigationPath
tags: arch, swiftui, navigation-path, type-erasure, state-management, codable
---

## Use NavigationPath for Heterogeneous Type-Erased Navigation

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

NavigationPath is a type-erased container that can hold any Hashable values, making it suitable when a single NavigationStack must handle pushes from multiple unrelated data types. However, when all destinations share a common route enum, a typed array `[Route]` provides compile-time safety, direct subscript access, and straightforward Codable persistence without the indirection of NavigationPath's CodableRepresentation. Choose NavigationPath for heterogeneous stacks across module boundaries; choose a typed array when routes are centralized in a single enum.

**Incorrect (separate @State booleans simulating a navigation stack):**

```swift
// COST: Each destination needs its own boolean, no ordered stack
// Cannot determine back navigation order, pop-to-root requires resetting every flag
struct DashboardView: View {
    @State private var showTransactionDetail = false
    @State private var selectedTransaction: Transaction?
    @State private var showAccountSettings = false
    @State private var showTransferFlow = false
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
    func popToRoot() {
        showTransactionDetail = false
        showAccountSettings = false
        showTransferFlow = false
        selectedTransaction = nil
    }
}
```

**Correct (NavigationPath for heterogeneous stacks, typed array for single-enum routing):**

```swift
// Option A: NavigationPath for mixed Hashable types
@Equatable
struct DashboardView: View {
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                TransactionListView(onSelect: { path.append($0) })
                Button("Transfer") { path.append(TransferRequest()) }
            }
            .navigationDestination(for: Transaction.self) { TransactionDetailView(transaction: $0) }
            .navigationDestination(for: TransferRequest.self) { TransferFlowView(request: $0) }
        }
    }
    func popToRoot() { path = NavigationPath() }
    func saveState() -> Data? {
        guard let repr = path.codable else { return nil }
        return try? JSONEncoder().encode(repr)
    }
    func restoreState(from data: Data) {
        guard let repr = try? JSONDecoder().decode(NavigationPath.CodableRepresentation.self, from: data) else { return }
        path = NavigationPath(repr)
    }
}

// Option B: Typed [Route] array for single enum
@Equatable
struct DashboardView_TypedPath: View {
    @State private var path: [DashboardRoute] = []
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                TransactionListView(onSelect: { path.append(.transactionDetail($0.id)) })
                Button("Transfer") { path.append(.transferFlow(accountId: "default")) }
            }
            .navigationDestination(for: DashboardRoute.self) { route in
                switch route {
                case .transactionDetail(let id): TransactionDetailView(transactionId: id)
                case .transferFlow(let accountId): TransferFlowView(accountId: accountId)
                case .accountSettings(let section): AccountSectionView(section: section)
                case .beneficiaryList: BeneficiaryListView()
                }
            }
        }
    }
    func popToRoot() { path.removeAll() }
    func saveState() -> Data? { try? JSONEncoder().encode(path) }
}
```
