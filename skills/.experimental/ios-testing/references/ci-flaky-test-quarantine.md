---
title: "Quarantine Flaky Tests Instead of Disabling Them"
impact: LOW-MEDIUM
impactDescription: "maintains coverage visibility while unblocking CI"
tags: ci, flaky, quarantine, reliability, tracking
---

## Quarantine Flaky Tests Instead of Disabling Them

Commenting out or deleting a flaky test eliminates coverage with no tracking mechanism to ensure someone fixes it. Quarantining with `.disabled` or `.enabled(if:)` traits in Swift Testing -- combined with a `.bug()` reference -- keeps the test visible in reports, documents the known issue, and lets CI pass without silently losing coverage.

**Incorrect (deleted coverage with no tracking):**

```swift
@Suite struct CheckoutFlowTests {
    // FIXME: flaky on CI, commented out for now
    // @Test func completesCheckoutWithApplePay() async throws {
    //     let checkout = CheckoutService(payment: MockPaymentGateway())
    //     let order = try await checkout.complete(method: .applePay)
    //     #expect(order.status == .confirmed)
    // }

    @Test func completesCheckoutWithCreditCard() async throws {
        let checkout = CheckoutService(payment: MockPaymentGateway())
        let order = try await checkout.complete(method: .creditCard)
        #expect(order.status == .confirmed) // Apple Pay path has zero coverage now
    }
}
```

**Correct (quarantined with bug reference, visible in test reports):**

```swift
@Suite struct CheckoutFlowTests {
    @Test(.disabled("Flaky due to async timing in payment callback"),
          .bug("https://jira.example.com/browse/PAY-1234")) // tracked in issue tracker
    func completesCheckoutWithApplePay() async throws {
        let checkout = CheckoutService(payment: MockPaymentGateway())
        let order = try await checkout.complete(method: .applePay)
        #expect(order.status == .confirmed) // test still compiles — catches build breaks
    }

    @Test func completesCheckoutWithCreditCard() async throws {
        let checkout = CheckoutService(payment: MockPaymentGateway())
        let order = try await checkout.complete(method: .creditCard)
        #expect(order.status == .confirmed)
    }
}
```
