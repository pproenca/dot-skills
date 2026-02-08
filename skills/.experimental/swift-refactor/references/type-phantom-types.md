---
title: Use Phantom Types for Compile-Time State Machines
impact: LOW-MEDIUM
impactDescription: prevents calling methods in wrong order at compile time
tags: type, phantom, state-machine, compile-time, safety
---

## Use Phantom Types for Compile-Time State Machines

When a multi-step builder or workflow relies on runtime checks to enforce call ordering, nothing stops a caller from submitting a form before setting required fields -- the mistake only surfaces as a runtime crash or silent failure. Phantom type parameters encode valid state transitions directly in the type system so that calling methods out of order is a compile error, not a runtime surprise.

**Incorrect (runtime check allows submitting incomplete form):**

```swift
struct CheckoutForm {
    var shippingAddress: Address?
    var paymentMethod: PaymentMethod?

    mutating func setShipping(_ address: Address) {
        shippingAddress = address
    }

    mutating func setPayment(_ method: PaymentMethod) {
        paymentMethod = method
    }

    func submit() throws -> OrderConfirmation {
        guard let address = shippingAddress else {
            throw CheckoutError.missingShipping
        }
        guard let payment = paymentMethod else {
            throw CheckoutError.missingPayment
        }
        return try OrderService.place(address: address, payment: payment)
    }
}

// Compiles fine -- crashes at runtime
var form = CheckoutForm()
let confirmation = try form.submit()
```

**Correct (phantom types enforce required steps at compile time):**

```swift
enum Incomplete {}
enum HasShipping {}
enum Ready {}

struct CheckoutForm<State> {
    fileprivate let shippingAddress: Address?
    fileprivate let paymentMethod: PaymentMethod?
}

extension CheckoutForm where State == Incomplete {
    func withShipping(_ address: Address) -> CheckoutForm<HasShipping> {
        CheckoutForm<HasShipping>(shippingAddress: address, paymentMethod: nil)
    }
}

extension CheckoutForm where State == HasShipping {
    func withPayment(_ method: PaymentMethod) -> CheckoutForm<Ready> {
        CheckoutForm<Ready>(shippingAddress: shippingAddress, paymentMethod: method)
    }
}

extension CheckoutForm where State == Ready {
    func submit() throws -> OrderConfirmation {
        // Non-nil guaranteed by the type state transitions above
        try OrderService.place(address: shippingAddress!, payment: paymentMethod!)
    }
}

// Compile error: CheckoutForm<Incomplete> has no member 'submit'
let form = CheckoutForm<Incomplete>(shippingAddress: nil, paymentMethod: nil)
let confirmation = try form.submit()
```

Reserve phantom types for critical multi-step workflows where incorrect ordering has severe consequences (payment processing, data migration). For simple two-step flows, the added type ceremony outweighs the safety benefit.

Reference: [Phantom types in Swift](https://www.swiftbysundell.com/articles/phantom-types-in-swift/)
