---
title: Extract Class from Large Class
impact: CRITICAL
impactDescription: improves testability and reduces cognitive load by 40-60%
tags: struct, extract-class, decomposition, large-class
---

## Extract Class from Large Class

When a class grows too large, it becomes difficult to understand and maintain. Extract cohesive groups of fields and methods into separate classes.

**Incorrect (class doing too much):**

```typescript
class Employee {
  name: string
  email: string
  phone: string
  street: string
  city: string
  state: string
  zipCode: string
  country: string

  getFullAddress(): string {
    return `${this.street}, ${this.city}, ${this.state} ${this.zipCode}, ${this.country}`
  }

  validateAddress(): boolean {
    return this.street.length > 0 && this.city.length > 0 && this.zipCode.length > 0
  }

  formatPhoneForDisplay(): string {
    return this.phone.replace(/(\d{3})(\d{3})(\d{4})/, '($1) $2-$3')
  }

  getContactInfo(): string {
    return `${this.email} | ${this.formatPhoneForDisplay()}`
  }
}
```

**Correct (extracted cohesive classes):**

```typescript
class Employee {
  name: string
  contact: ContactInfo
  address: Address

  getContactInfo(): string {
    return this.contact.format()
  }

  getFullAddress(): string {
    return this.address.format()
  }
}

class Address {
  constructor(
    public street: string,
    public city: string,
    public state: string,
    public zipCode: string,
    public country: string
  ) {}

  format(): string {
    return `${this.street}, ${this.city}, ${this.state} ${this.zipCode}, ${this.country}`
  }

  isValid(): boolean {
    return this.street.length > 0 && this.city.length > 0 && this.zipCode.length > 0
  }
}

class ContactInfo {
  constructor(
    public email: string,
    public phone: string
  ) {}

  format(): string {
    return `${this.email} | ${this.formatPhone()}`
  }

  private formatPhone(): string {
    return this.phone.replace(/(\d{3})(\d{3})(\d{4})/, '($1) $2-$3')
  }
}
```

**Signs you need to extract:**
- Groups of fields that are always used together
- Methods that operate on a subset of fields
- Fields with common prefixes (address_, contact_)

Reference: [Extract Class](https://refactoring.com/catalog/extractClass.html)
