---
title: Narrow with the in Operator for Interface Unions
impact: HIGH
impactDescription: eliminates as casts with 1-line property checks
tags: narrow, in-operator, narrowing, unions
---

## Narrow with the in Operator for Interface Unions

The `in` operator narrows union types by checking for the presence of a property. This is simpler than writing a full type guard function and works well when discriminated unions lack a shared discriminant field.

**Incorrect (unsafe cast to access variant-specific properties):**

```typescript
interface EmailNotification {
  email: string
  subject: string
  body: string
}

interface SmsNotification {
  phone: string
  message: string
}

type Notification = EmailNotification | SmsNotification

function send(notification: Notification) {
  const email = (notification as EmailNotification).email // Unsafe cast
  if (email) {
    sendEmail(email, (notification as EmailNotification).subject)
  }
}
```

**Correct (in operator narrows safely):**

```typescript
interface EmailNotification {
  email: string
  subject: string
  body: string
}

interface SmsNotification {
  phone: string
  message: string
}

type Notification = EmailNotification | SmsNotification

function send(notification: Notification) {
  if ("email" in notification) {
    sendEmail(notification.email, notification.subject) // Narrowed to EmailNotification
  } else {
    sendSms(notification.phone, notification.message) // Narrowed to SmsNotification
  }
}
```

Reference: [TypeScript Handbook - The in operator narrowing](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#the-in-operator-narrowing)
