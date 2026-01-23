---
title: Use Cases Must Not Contain Presentation Logic
impact: HIGH
impactDescription: enables multiple UI implementations from same use case
tags: usecase, presentation, formatting, separation
---

## Use Cases Must Not Contain Presentation Logic

Use cases return domain data, not formatted strings, HTML, or UI-specific structures. Presentation logic belongs in the interface adapters layer.

**Incorrect (presentation logic in use case):**

```typescript
class GetUserProfileUseCase {
  execute(userId: string): UserProfileResponse {
    const user = this.repo.findById(userId)
    const orders = this.orderRepo.findByUser(userId)

    return {
      displayName: `${user.firstName} ${user.lastName}`,  // Formatting
      memberSince: user.createdAt.toLocaleDateString('en-US', {
        month: 'long',
        year: 'numeric'
      }),  // Locale-specific formatting
      avatarHtml: `<img src="${user.avatarUrl}" alt="${user.firstName}"/>`,  // HTML!
      orderSummary: orders.length > 0
        ? `${orders.length} orders totaling $${this.sumOrders(orders).toFixed(2)}`
        : 'No orders yet',  // UI text
      recentOrders: orders.slice(0, 5).map(o => ({
        ...o,
        statusBadgeColor: this.getStatusColor(o.status)  // UI styling
      }))
    }
  }

  private getStatusColor(status: string): string {
    const colors = { pending: 'yellow', shipped: 'blue', delivered: 'green' }
    return colors[status] || 'gray'
  }
}
```

**Correct (use case returns domain data):**

```typescript
// application/usecases/GetUserProfileUseCase.ts
class GetUserProfileUseCase {
  execute(userId: string): UserProfileResult {
    const user = this.repo.findById(userId)
    const orders = this.orderRepo.findByUser(userId)

    return {
      user: {
        id: user.id.value,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email.value,
        avatarUrl: user.avatarUrl,
        createdAt: user.createdAt
      },
      orders: orders.map(o => ({
        id: o.id.value,
        total: o.total.amount,
        currency: o.total.currency,
        status: o.status,
        createdAt: o.createdAt
      })),
      orderCount: orders.length,
      totalSpent: this.sumOrders(orders)
    }
  }
}

// interface_adapters/presenters/UserProfilePresenter.ts
class UserProfilePresenter {
  present(result: UserProfileResult, locale: string): UserProfileViewModel {
    const formatter = new Intl.DateTimeFormat(locale, {
      month: 'long',
      year: 'numeric'
    })

    return {
      displayName: `${result.user.firstName} ${result.user.lastName}`,
      memberSince: formatter.format(result.user.createdAt),
      avatarUrl: result.user.avatarUrl,
      orderSummary: this.formatOrderSummary(result, locale),
      recentOrders: result.orders.slice(0, 5).map(o =>
        this.formatOrder(o, locale)
      )
    }
  }
}
```

**Benefits:**
- Same use case serves web, mobile, API consumers
- Locale/format changes don't touch business logic
- UI redesigns don't affect use case tests

Reference: [Clean Architecture - Presenters](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch23.xhtml)
