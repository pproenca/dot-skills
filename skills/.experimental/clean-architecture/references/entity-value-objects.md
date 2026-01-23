---
title: Use Value Objects for Domain Concepts
impact: HIGH
impactDescription: eliminates primitive obsession, enforces constraints
tags: entity, value-objects, domain, types
---

## Use Value Objects for Domain Concepts

Replace primitive types with value objects that encapsulate validation and behavior. Value objects are immutable, compared by value, and self-validating.

**Incorrect (primitive obsession):**

```typescript
class Customer {
  constructor(
    public id: string,
    public email: string,
    public phone: string,
    public postalCode: string
  ) {}

  changeEmail(newEmail: string): void {
    // Validation scattered or missing
    if (!newEmail.includes('@')) {
      throw new Error('Invalid email')
    }
    this.email = newEmail
  }
}

// Callers can pass any string
const customer = new Customer('123', 'not-an-email', '123', 'invalid')
```

**Correct (value objects for domain concepts):**

```typescript
class Email {
  private constructor(private readonly value: string) {}

  static create(value: string): Email {
    if (!Email.isValid(value)) {
      throw new InvalidEmailError(value)
    }
    return new Email(value.toLowerCase())
  }

  private static isValid(value: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)
  }

  equals(other: Email): boolean {
    return this.value === other.value
  }

  toString(): string {
    return this.value
  }
}

class PhoneNumber {
  private constructor(
    private readonly countryCode: string,
    private readonly number: string
  ) {}

  static create(countryCode: string, number: string): PhoneNumber {
    // Validation and normalization
    return new PhoneNumber(countryCode, number.replace(/\D/g, ''))
  }
}

class Customer {
  constructor(
    public readonly id: CustomerId,
    private email: Email,
    private phone: PhoneNumber
  ) {}

  changeEmail(newEmail: Email): void {
    this.email = newEmail  // Already validated
  }
}

// Compile-time type safety + runtime validation
const customer = new Customer(
  CustomerId.create('123'),
  Email.create('user@example.com'),
  PhoneNumber.create('+1', '555-1234')
)
```

**Benefits:**
- Invalid values cannot exist in the system
- Domain concepts explicitly named in code
- Validation logic centralized and reusable
- Type system prevents mixing up string parameters

Reference: [Value Object Pattern](https://martinfowler.com/bliki/ValueObject.html)
