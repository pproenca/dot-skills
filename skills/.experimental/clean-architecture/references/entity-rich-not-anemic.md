---
title: Build Rich Domain Models Not Anemic Data Structures
impact: HIGH
impactDescription: centralizes business logic, prevents scattered rules
tags: entity, domain-model, anemic, behavior
---

## Build Rich Domain Models Not Anemic Data Structures

Entities should contain behavior, not just data. Anemic domain models push business logic into services, scattering rules and duplicating validation.

**Incorrect (anemic domain model):**

```java
// domain/entities/Subscription.java
public class Subscription {
    private String id;
    private String planId;
    private LocalDate startDate;
    private LocalDate endDate;
    private String status;

    // Only getters and setters - no behavior
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }
}

// application/services/SubscriptionService.java
public class SubscriptionService {
    public void cancel(Subscription sub) {
        if (!sub.getStatus().equals("active")) {
            throw new IllegalStateException("Cannot cancel");
        }
        sub.setStatus("cancelled");
        sub.setEndDate(LocalDate.now());
    }

    public void renew(Subscription sub, int months) {
        if (!sub.getStatus().equals("active")) {
            throw new IllegalStateException("Cannot renew");
        }
        sub.setEndDate(sub.getEndDate().plusMonths(months));
    }
    // Logic scattered across many services
}
```

**Correct (rich domain model):**

```java
// domain/entities/Subscription.java
public class Subscription {
    private final SubscriptionId id;
    private final PlanId planId;
    private final LocalDate startDate;
    private LocalDate endDate;
    private SubscriptionStatus status;

    public void cancel() {
        ensureActive();
        this.status = SubscriptionStatus.CANCELLED;
        this.endDate = LocalDate.now();
    }

    public void renew(Period extension) {
        ensureActive();
        if (extension.getMonths() < 1) {
            throw new InvalidExtensionPeriodException(extension);
        }
        this.endDate = this.endDate.plus(extension);
    }

    public boolean isExpired() {
        return LocalDate.now().isAfter(this.endDate);
    }

    public boolean canUpgradeTo(Plan newPlan) {
        return this.status == SubscriptionStatus.ACTIVE
            && newPlan.isUpgradeFrom(this.planId);
    }

    private void ensureActive() {
        if (this.status != SubscriptionStatus.ACTIVE) {
            throw new InactiveSubscriptionException(this.id);
        }
    }
}

// application/usecases/CancelSubscriptionUseCase.java
public class CancelSubscriptionUseCase {
    public void execute(SubscriptionId id) {
        Subscription sub = repository.findById(id);
        sub.cancel();  // Business logic in entity
        repository.save(sub);
    }
}
```

**Benefits:**
- Business rules live with the data they operate on
- Impossible to forget validation when manipulating data
- Entity documents its own capabilities and constraints

Reference: [Anemic Domain Model Anti-pattern](https://martinfowler.com/bliki/AnemicDomainModel.html)
