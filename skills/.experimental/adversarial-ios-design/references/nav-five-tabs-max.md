---
title: Keep the iPhone tab bar to five tabs at most
tags: nav, tab-bar, overflow, more-tab
---

## Keep the iPhone tab bar to five tabs at most

The wrong default when an app grows is adding a sixth and seventh tab, which on iPhone produces an overflow "More" tab or truncated labels. The More tab makes the demoted sections harder to reach and notice — the exact opposite of what promoting them to a tab was supposed to achieve — and squeezed tabs shrink every hit target. Sections beyond five belong inside an existing tab's hierarchy, and on iPad inside `TabSection` sidebar groups.

**Evidence of violation:** more than five `Tab` (or `.tabItem`) entries visible at iPhone width in one `TabView` — count them, excluding a `Tab(role: .search)` (the system pins it separately) and entries confined to iPad-only `TabSection` sidebar groups. PASS: five or fewer countable tabs — cite the count; extra areas reachable through an in-tab hierarchy or `.tabViewStyle(.sidebarAdaptable)` sections on iPad. N/A: no `TabView` in the target.

**Incorrect (seven tabs force an overflow and bury two sections):**

```swift
import SwiftUI

struct LedgerRootView: View {
    var body: some View {
        // ⚠️ Seven tabs on iPhone — the last two collapse into a More tab
        TabView {
            Tab("Accounts", systemImage: "building.columns") { AccountListView() }
            Tab("Invoices", systemImage: "doc.text") { InvoiceListView() }
            Tab("Expenses", systemImage: "creditcard") { ExpenseListView() }
            Tab("Reports", systemImage: "chart.bar") { ReportListView() }
            Tab("Clients", systemImage: "person.2") { ClientListView() }
            Tab("Taxes", systemImage: "percent") { TaxSummaryView() }
            Tab("Settings", systemImage: "gearshape") { SettingsView() }
        }
    }
}
```

**Correct (five tabs; taxes live under Reports, settings under Accounts):**

```swift
import SwiftUI

struct LedgerRootView: View {
    var body: some View {
        TabView {
            Tab("Accounts", systemImage: "building.columns") {
                NavigationStack { AccountListView() }
            }
            Tab("Invoices", systemImage: "doc.text") {
                NavigationStack { InvoiceListView() }
            }
            Tab("Expenses", systemImage: "creditcard") {
                NavigationStack { ExpenseListView() }
            }
            Tab("Reports", systemImage: "chart.bar") {
                NavigationStack { ReportListView() }
            }
            Tab("Clients", systemImage: "person.2") {
                NavigationStack { ClientListView() }
            }
        }
    }
}
```

Reference: [HIG — Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars)
