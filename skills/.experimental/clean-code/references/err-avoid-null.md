---
title: Avoid Returning and Passing Null
impact: HIGH
impactDescription: eliminates NullPointerException risk
tags: err, null, optional, null-object
---

## Avoid Returning and Passing Null

Returning null creates work for callers and invites errors. One missing null check leads to NullPointerException. Throw exceptions, return empty collections, or use the Special Case / Null Object pattern.

**Incorrect (returning null):**

```java
public List<Employee> getEmployees() {
    if (thereAreNoEmployees) {
        return null;  // Caller must check for null
    }
    return employees;
}

// Every caller must do this
List<Employee> employees = getEmployees();
if (employees != null) {  // Easy to forget
    for (Employee e : employees) {
        pay(e);
    }
}

// Passing null
public double calculatePay(Employee employee, Money bonus) {
    // What if bonus is null?
}
calculatePay(employee, null);  // What does null mean?
```

**Correct (avoid null entirely):**

```java
// Return empty collection instead of null
public List<Employee> getEmployees() {
    if (thereAreNoEmployees) {
        return Collections.emptyList();
    }
    return employees;
}

// Clean caller code
for (Employee e : getEmployees()) {
    pay(e);
}

// Use Optional for truly optional values
public Optional<Employee> findById(Long id) {
    return Optional.ofNullable(employeeMap.get(id));
}

// Use Special Case object
public interface BillingPlan {
    Money getRate();
}

public class NullBillingPlan implements BillingPlan {
    public Money getRate() {
        return Money.ZERO;
    }
}

// Explicit parameters instead of null
public double calculatePay(Employee employee, Money bonus) { /* ... */ }
public double calculatePayWithoutBonus(Employee employee) { /* ... */ }
```

Reference: [Clean Code, Chapter 7: Error Handling](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
