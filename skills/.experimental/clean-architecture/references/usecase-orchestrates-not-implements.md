---
title: Use Cases Orchestrate Entities Not Implement Business Rules
impact: HIGH
impactDescription: prevents rule duplication, maintains single source of truth
tags: usecase, orchestration, entities, delegation
---

## Use Cases Orchestrate Entities Not Implement Business Rules

Use cases coordinate the flow of data to and from entities. Business rules belong in entities; use cases should not duplicate or implement them.

**Incorrect (business rules in use case):**

```go
func (uc *ApplyDiscountUseCase) Execute(orderId string, code string) error {
    order := uc.repo.Find(orderId)
    discount := uc.discounts.Find(code)

    // Business rules implemented in use case
    if order.Status != "pending" {
        return errors.New("cannot apply discount to processed order")
    }

    if discount.ExpiresAt.Before(time.Now()) {
        return errors.New("discount expired")
    }

    if order.Total.LessThan(discount.MinimumOrder) {
        return errors.New("order total below minimum")
    }

    if discount.UsageCount >= discount.MaxUses {
        return errors.New("discount fully redeemed")
    }

    // Calculate discount - more business rules
    var discountAmount Money
    if discount.Type == "percentage" {
        discountAmount = order.Total.MultiplyBy(discount.Value / 100)
    } else {
        discountAmount = discount.Value
    }

    order.DiscountAmount = discountAmount
    order.Total = order.Total.Subtract(discountAmount)
    uc.repo.Save(order)
    return nil
}
```

**Correct (use case orchestrates, entities implement rules):**

```go
func (uc *ApplyDiscountUseCase) Execute(orderId string, code string) error {
    order := uc.repo.Find(orderId)
    discount := uc.discounts.Find(code)

    // Use case orchestrates the interaction
    if err := order.ApplyDiscount(discount); err != nil {
        return err
    }

    uc.repo.Save(order)
    return nil
}

// domain/entities/order.go
func (o *Order) ApplyDiscount(discount *Discount) error {
    if o.status != OrderStatusPending {
        return ErrOrderNotPending
    }

    if !discount.IsValidFor(o.total) {
        return discount.ValidationError(o.total)
    }

    o.discount = discount
    o.discountAmount = discount.CalculateFor(o.total)
    return nil
}

// domain/entities/discount.go
func (d *Discount) IsValidFor(orderTotal Money) bool {
    return !d.IsExpired() &&
           !d.IsFullyRedeemed() &&
           orderTotal.GreaterThanOrEqual(d.minimumOrder)
}

func (d *Discount) CalculateFor(total Money) Money {
    if d.discountType == PercentageDiscount {
        return total.MultiplyBy(d.value).DivideBy(100)
    }
    return d.value
}
```

**Benefits:**
- Business rules tested once in entity, not in every use case
- Rules cannot diverge between use cases
- Use case clearly shows workflow, not implementation details

Reference: [Clean Architecture - Use Cases](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
