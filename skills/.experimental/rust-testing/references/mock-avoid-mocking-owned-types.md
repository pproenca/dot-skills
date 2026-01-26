---
title: Avoid Mocking Types You Own
impact: HIGH
impactDescription: prevents brittle tests that break on refactors
tags: mock, boundaries, coupling, refactoring
---

## Avoid Mocking Types You Own

Mock external dependencies (HTTP clients, databases) not internal types. Mocking internal types creates tight coupling between tests and implementation details.

**Incorrect (mocking internal type):**

```rust
// src/lib.rs
pub struct OrderCalculator;

impl OrderCalculator {
    pub fn calculate_total(&self, items: &[Item]) -> Decimal {
        items.iter().map(|i| i.price * i.quantity).sum()
    }
}

pub struct CheckoutService<C: Calculator> {
    calculator: C,
}

// tests/checkout_tests.rs
use mockall::automock;

#[automock]
trait Calculator {
    fn calculate_total(&self, items: &[Item]) -> Decimal;
}

#[test]
fn checkout_uses_calculator() {
    let mut mock = MockCalculator::new();
    mock.expect_calculate_total()
        .returning(|_| Decimal::new(100, 0));  // Mocking internal logic

    let service = CheckoutService::new(mock);
    // This test breaks if you refactor OrderCalculator!
}
```

**Correct (mock boundaries, test internal types directly):**

```rust
// src/lib.rs
pub struct OrderCalculator;

impl OrderCalculator {
    pub fn calculate_total(&self, items: &[Item]) -> Decimal {
        items.iter().map(|i| i.price * i.quantity).sum()
    }
}

#[async_trait]
pub trait PaymentGateway {
    async fn charge(&self, amount: Decimal) -> Result<PaymentId, Error>;
}

pub struct CheckoutService<P: PaymentGateway> {
    calculator: OrderCalculator,  // Owned type - use real implementation
    payment: P,                   // External dependency - mock this
}

#[cfg(test)]
mod tests {
    use super::*;

    // Test OrderCalculator directly - it's fast and deterministic
    #[test]
    fn calculate_total_sums_items() {
        let calculator = OrderCalculator;
        let items = vec![
            Item { price: dec!(10), quantity: 2 },
            Item { price: dec!(5), quantity: 3 },
        ];
        assert_eq!(calculator.calculate_total(&items), dec!(35));
    }

    // Only mock the external payment gateway
    struct MockPaymentGateway;

    #[async_trait]
    impl PaymentGateway for MockPaymentGateway {
        async fn charge(&self, _amount: Decimal) -> Result<PaymentId, Error> {
            Ok(PaymentId::new("mock-123"))
        }
    }

    #[tokio::test]
    async fn checkout_charges_correct_amount() {
        let service = CheckoutService::new(
            OrderCalculator,       // Real calculator
            MockPaymentGateway,    // Mock gateway
        );
        // Test integration between real components
    }
}
```

**When to mock:**

| Mock | Don't Mock |
|------|------------|
| HTTP clients | Pure functions |
| Databases | Data structures |
| File systems | Business logic |
| External APIs | Internal services |
| Time/randomness | Deterministic calculations |

Reference: [Test Doubles at Google](https://testing.googleblog.com/)
