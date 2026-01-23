---
title: Gateways Hide External System Details
impact: MEDIUM
impactDescription: enables vendor switching, simplifies testing
tags: adapt, gateway, external, abstraction
---

## Gateways Hide External System Details

Database gateways, API gateways, and service gateways are polymorphic interfaces that hide external system details. The use case layer talks to abstractions; infrastructure implements them.

**Incorrect (use case knows external system details):**

```go
func (uc *ProcessRefundUseCase) Execute(orderId string) error {
    order := uc.db.QueryRow("SELECT * FROM orders WHERE id = $1", orderId)

    // Direct Stripe API knowledge in use case
    stripe.Key = os.Getenv("STRIPE_KEY")
    params := &stripe.RefundParams{
        PaymentIntent: stripe.String(order.PaymentIntentId),
        Amount:        stripe.Int64(order.Total),
    }
    _, err := refund.New(params)
    if err != nil {
        // Stripe-specific error handling
        if stripeErr, ok := err.(*stripe.Error); ok {
            if stripeErr.Code == stripe.ErrorCodeChargeAlreadyRefunded {
                return ErrAlreadyRefunded
            }
        }
        return err
    }

    uc.db.Exec("UPDATE orders SET status = 'refunded' WHERE id = $1", orderId)
    return nil
}
```

**Correct (gateway abstracts external system):**

```go
// application/ports/PaymentGateway.go
type PaymentGateway interface {
    Refund(paymentId string, amount Money) (RefundResult, error)
}

type RefundResult struct {
    RefundId string
    Status   RefundStatus
}

// application/ports/OrderRepository.go
type OrderRepository interface {
    FindById(id OrderId) (*Order, error)
    Save(order *Order) error
}

// application/usecases/ProcessRefundUseCase.go
type ProcessRefundUseCase struct {
    orders   OrderRepository
    payments PaymentGateway
}

func (uc *ProcessRefundUseCase) Execute(orderId string) error {
    order, err := uc.orders.FindById(OrderId(orderId))
    if err != nil {
        return err
    }

    result, err := uc.payments.Refund(order.PaymentId, order.Total)
    if err != nil {
        return err  // Gateway translates Stripe errors to domain errors
    }

    order.MarkRefunded(result.RefundId)
    return uc.orders.Save(order)
}

// infrastructure/StripePaymentGateway.go
type StripePaymentGateway struct {
    client *stripe.Client
}

func (g *StripePaymentGateway) Refund(paymentId string, amount Money) (RefundResult, error) {
    params := &stripe.RefundParams{
        PaymentIntent: stripe.String(paymentId),
        Amount:        stripe.Int64(amount.Cents()),
    }

    refund, err := g.client.Refunds.New(params)
    if err != nil {
        return RefundResult{}, g.translateError(err)
    }

    return RefundResult{
        RefundId: refund.ID,
        Status:   g.translateStatus(refund.Status),
    }, nil
}

func (g *StripePaymentGateway) translateError(err error) error {
    // Convert Stripe-specific errors to domain errors
    if stripeErr, ok := err.(*stripe.Error); ok {
        switch stripeErr.Code {
        case stripe.ErrorCodeChargeAlreadyRefunded:
            return ErrAlreadyRefunded
        }
    }
    return ErrPaymentFailed
}
```

**Benefits:**
- Switch from Stripe to Adyen without touching use cases
- Test use cases with mock gateways
- External API changes isolated to gateway implementation

Reference: [Clean Architecture - Database Gateways](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch22.xhtml)
