---
title: Replace Boolean Sheet Triggers with Item Binding
impact: HIGH
impactDescription: eliminates stale data bugs when presenting sheets
tags: nav, sheet, item-binding, presentation, data-driven
---

## Replace Boolean Sheet Triggers with Item Binding

Using `.sheet(isPresented:)` alongside a separate `@State` property for the selected item creates two sources of truth that must be kept in sync. If the boolean becomes `true` before the item is assigned -- or the item is changed after the sheet is already presented -- the sheet displays stale or nil data. The `.sheet(item:)` overload presents the sheet when the binding becomes non-nil and passes the value directly into the content closure, guaranteeing the sheet always receives the correct item.

**Incorrect (boolean and item state kept separately):**

```swift
struct InvoiceListView: View {
    @State private var invoices: [Invoice] = []
    @State private var showDetail = false
    @State private var selectedInvoice: Invoice?

    var body: some View {
        List(invoices) { invoice in
            Button(invoice.title) {
                selectedInvoice = invoice
                showDetail = true
                // Race condition: showDetail can be true
                // before selectedInvoice is set on fast taps
            }
        }
        .sheet(isPresented: $showDetail) {
            // selectedInvoice may still be nil or stale
            if let invoice = selectedInvoice {
                InvoiceDetailView(invoice: invoice)
            }
        }
    }
}
```

**Correct (item binding as single source of truth):**

```swift
struct InvoiceListView: View {
    @State private var invoices: [Invoice] = []
    @State private var selectedInvoice: Invoice?

    var body: some View {
        List(invoices) { invoice in
            Button(invoice.title) {
                selectedInvoice = invoice
                // Sheet presents when selectedInvoice becomes non-nil
            }
        }
        .sheet(item: $selectedInvoice) { invoice in
            // invoice is guaranteed to be the correct, non-nil value
            InvoiceDetailView(invoice: invoice)
        }
    }
}
```

Reference: [sheet(item:onDismiss:content:)](https://developer.apple.com/documentation/swiftui/view/sheet(item:ondismiss:content:))
