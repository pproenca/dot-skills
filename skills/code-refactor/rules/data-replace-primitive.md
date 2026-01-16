---
title: Replace Primitive with Object
impact: MEDIUM
impactDescription: enables validation and domain-specific behavior
tags: data, primitive-obsession, value-object, domain-modeling
---

## Replace Primitive with Object

When primitives carry domain meaning beyond their raw value, wrap them in domain objects. This provides a home for validation and behavior.

**Incorrect (primitives scattered throughout):**

```typescript
function createUser(email: string, phone: string, zipCode: string): User {
  // Validation logic repeated everywhere emails are used
  if (!email.includes('@') || !email.includes('.')) {
    throw new Error('Invalid email')
  }
  // Phone validation repeated everywhere
  if (phone.replace(/\D/g, '').length !== 10) {
    throw new Error('Invalid phone')
  }
  // ZIP validation repeated
  if (!/^\d{5}(-\d{4})?$/.test(zipCode)) {
    throw new Error('Invalid ZIP')
  }

  return { email, phone, zipCode }
}

// Elsewhere, same validation repeated
function sendEmail(email: string, subject: string): void {
  if (!email.includes('@')) {  // Inconsistent validation
    throw new Error('Invalid email')
  }
  // ...
}
```

**Correct (domain objects with behavior):**

```typescript
class Email {
  private readonly value: string

  constructor(value: string) {
    if (!this.isValid(value)) {
      throw new Error(`Invalid email: ${value}`)
    }
    this.value = value.toLowerCase().trim()
  }

  private isValid(value: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)
  }

  toString(): string {
    return this.value
  }

  getDomain(): string {
    return this.value.split('@')[1]
  }
}

class PhoneNumber {
  private readonly digits: string

  constructor(value: string) {
    this.digits = value.replace(/\D/g, '')
    if (this.digits.length !== 10) {
      throw new Error(`Invalid phone number: ${value}`)
    }
  }

  format(): string {
    return `(${this.digits.slice(0, 3)}) ${this.digits.slice(3, 6)}-${this.digits.slice(6)}`
  }

  toString(): string {
    return this.digits
  }
}

class ZipCode {
  constructor(private readonly value: string) {
    if (!/^\d{5}(-\d{4})?$/.test(value)) {
      throw new Error(`Invalid ZIP code: ${value}`)
    }
  }

  toString(): string {
    return this.value
  }
}

// Usage is clean and validated by construction
function createUser(email: Email, phone: PhoneNumber, zipCode: ZipCode): User {
  return { email, phone, zipCode }  // Already validated
}

const user = createUser(
  new Email('user@example.com'),
  new PhoneNumber('123-456-7890'),
  new ZipCode('12345')
)
```

**Benefits:**
- Validation happens once, at construction
- Formatting and behavior lives with the data
- Type system prevents passing wrong primitives

Reference: [Replace Primitive with Object](https://refactoring.com/catalog/replacePrimitiveWithObject.html)
