---
title: Use Guard Clauses for Preconditions
impact: HIGH
impactDescription: Guard clauses group all preconditions at function entry, reducing bug surface by 30-50% through fail-fast validation
tags: flow, guards, validation, preconditions, defensive-programming
---

## Use Guard Clauses for Preconditions

Guard clauses validate all preconditions at the function's entry point and exit immediately if validation fails. This pattern creates a clear contract: if execution passes the guards, all required conditions are met. Readers don't need to trace conditions through the entire function body.

**Incorrect (validations scattered throughout):**

```typescript
function sendNotification(user: User, message: string, channel: Channel): void {
  let result;

  if (user && user.email) {
    if (message && message.trim().length > 0) {
      const sanitized = sanitizeMessage(message);

      if (channel === 'email') {
        if (user.emailVerified) {
          result = emailService.send(user.email, sanitized);
        } else {
          console.log('Email not verified');
        }
      } else if (channel === 'sms') {
        if (user.phone) {
          if (user.phoneVerified) {
            result = smsService.send(user.phone, sanitized);
          } else {
            console.log('Phone not verified');
          }
        } else {
          console.log('No phone number');
        }
      }
    } else {
      console.log('Empty message');
    }
  } else {
    console.log('Invalid user');
  }

  return result;
}
```

**Correct (guard clauses at entry):**

```typescript
function sendNotification(user: User, message: string, channel: Channel): void {
  // Guard clauses - all preconditions checked upfront
  if (!user?.email) {
    throw new ValidationError('User must have an email address');
  }
  if (!message?.trim()) {
    throw new ValidationError('Message cannot be empty');
  }
  if (!['email', 'sms'].includes(channel)) {
    throw new ValidationError(`Invalid channel: ${channel}`);
  }

  const sanitized = sanitizeMessage(message);

  // Channel-specific guards
  if (channel === 'email') {
    if (!user.emailVerified) {
      throw new ValidationError('Email address not verified');
    }
    return emailService.send(user.email, sanitized);
  }

  if (channel === 'sms') {
    if (!user.phone) {
      throw new ValidationError('User must have a phone number for SMS');
    }
    if (!user.phoneVerified) {
      throw new ValidationError('Phone number not verified');
    }
    return smsService.send(user.phone, sanitized);
  }
}
```

**Incorrect (null checks interleaved with logic):**

```typescript
function calculateShipping(order: Order): number {
  let shipping = 0;

  if (order) {
    const items = order.items;
    if (items) {
      for (const item of items) {
        if (item && item.weight) {
          shipping += item.weight * RATE_PER_KG;
        }
      }
      if (order.address) {
        if (order.address.country !== 'US') {
          shipping *= INTERNATIONAL_MULTIPLIER;
        }
      }
    }
  }

  return shipping;
}
```

**Correct (guards enforce valid state):**

```typescript
function calculateShipping(order: Order): number {
  if (!order) {
    throw new Error('Order is required');
  }
  if (!order.items?.length) {
    throw new Error('Order must have items');
  }
  if (!order.address) {
    throw new Error('Order must have an address');
  }

  let shipping = 0;

  for (const item of order.items) {
    shipping += (item.weight ?? 0) * RATE_PER_KG;
  }

  if (order.address.country !== 'US') {
    shipping *= INTERNATIONAL_MULTIPLIER;
  }

  return shipping;
}
```

### Benefits

- Function contract is immediately visible
- Invalid states fail fast before causing side effects
- Core logic operates on guaranteed valid data
- Testing is simplified - guards can be tested independently
- Debugging is easier - failures point to specific validation

### When NOT to Apply

- When partial/graceful degradation is required (use defaults instead)
- In hot paths where exceptions are too expensive
- When building tolerant readers that handle malformed input
