---
title: Avoid Single-Use Helper Functions
impact: MEDIUM
impactDescription: Each unnecessary helper adds 30-60 seconds of navigation time and fragments code comprehension across multiple locations
tags: dup, helpers, abstraction, indirection
---

## Avoid Single-Use Helper Functions

Do not extract code into a helper function if it will only be called from one place. Single-use helpers fragment logic across multiple locations, forcing readers to jump between files or scroll to understand what should be a single coherent operation. The cure is worse than the disease - you trade local complexity for distributed complexity.

**Incorrect (single-use helper obscures logic):**

```typescript
// In userService.ts
async function createUser(data: UserInput): Promise<User> {
  const validated = await validateUserInput(data);
  const normalized = normalizeUserData(validated);
  const user = await saveUser(normalized);
  await sendWelcomeNotification(user);
  return user;
}

// In userHelpers.ts - only called once!
function normalizeUserData(data: ValidatedUserInput): NormalizedUser {
  return {
    email: data.email.toLowerCase().trim(),
    name: data.name.trim(),
    createdAt: new Date(),
  };
}
// Reader must now open another file to understand createUser
```

**Correct (inline single-use logic):**

```typescript
async function createUser(data: UserInput): Promise<User> {
  const validated = await validateUserInput(data);

  const normalized: NormalizedUser = {
    email: validated.email.toLowerCase().trim(),
    name: validated.name.trim(),
    createdAt: new Date(),
  };

  const user = await saveUser(normalized);
  await sendWelcomeNotification(user);
  return user;
}
// All logic visible in one place
```

**Incorrect (over-extraction for "cleanliness"):**

```python
class OrderProcessor:
    def process_order(self, order):
        self._validate_inventory(order)
        self._calculate_totals(order)
        self._apply_discounts(order)
        self._save_order(order)

    def _validate_inventory(self, order):
        # 3 lines of code, called only here
        for item in order.items:
            if item.quantity > self.inventory[item.sku]:
                raise InsufficientInventoryError(item.sku)

    def _calculate_totals(self, order):
        # 2 lines of code, called only here
        order.subtotal = sum(item.price * item.quantity for item in order.items)
        order.total = order.subtotal + order.shipping

    # ... more single-use private methods
# Class is now 150 lines but process_order reads like a mystery novel
```

**Correct (inline when logic is simple and single-use):**

```python
class OrderProcessor:
    def process_order(self, order):
        # Validate inventory
        for item in order.items:
            if item.quantity > self.inventory[item.sku]:
                raise InsufficientInventoryError(item.sku)

        # Calculate totals
        order.subtotal = sum(item.price * item.quantity for item in order.items)
        order.total = order.subtotal + order.shipping

        # Apply discounts (this IS complex - worth extracting)
        self._apply_discount_rules(order)

        self.repository.save(order)
# Comments provide structure; complex logic gets extracted
```

**Incorrect (extracting for testability when integration test suffices):**

```go
func ProcessPayment(order *Order) error {
    if err := validatePaymentDetails(order); err != nil {
        return err
    }
    return chargeCard(order)
}

// Extracted "for testability" but only called once
func validatePaymentDetails(order *Order) error {
    if order.Amount <= 0 {
        return errors.New("invalid amount")
    }
    if order.CardToken == "" {
        return errors.New("missing card token")
    }
    return nil
}
```

**Correct (test through the public interface):**

```go
func ProcessPayment(order *Order) error {
    if order.Amount <= 0 {
        return errors.New("invalid amount")
    }
    if order.CardToken == "" {
        return errors.New("missing card token")
    }
    return chargeCard(order)
}
// Test ProcessPayment with invalid inputs directly
```

### When Single-Use Helpers ARE Appropriate

- Function exceeds 50 lines and has clear logical sections
- Logic requires extensive comments that would benefit from a descriptive name
- Testing the helper in isolation provides significant value
- The helper encapsulates a complex algorithm that deserves its own tests

### Benefits

- Code flows linearly without jumping between locations
- Reduces file count and cognitive load
- Makes debugging easier - stack traces are shorter
- Faster code review - reviewers see complete logic in context
