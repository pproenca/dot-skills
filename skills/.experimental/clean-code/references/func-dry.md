---
title: Do Not Repeat Yourself
impact: CRITICAL
impactDescription: prevents N× maintenance burden
tags: func, dry, duplication, abstraction
---

## Do Not Repeat Yourself

Duplication is the root of all evil in software. When an algorithm changes, you must change it in multiple places. When you fix a bug, you must remember to fix it everywhere.

**Incorrect (duplicated logic):**

```java
public void processNewEmployee(Employee employee) {
    if (employee.getName() == null || employee.getName().trim().isEmpty()) {
        throw new ValidationException("Name is required");
    }
    if (employee.getEmail() == null || !employee.getEmail().contains("@")) {
        throw new ValidationException("Valid email is required");
    }
    employeeRepository.save(employee);
    emailService.sendWelcome(employee.getEmail());
}

public void updateEmployee(Employee employee) {
    if (employee.getName() == null || employee.getName().trim().isEmpty()) {
        throw new ValidationException("Name is required");  // Duplicated
    }
    if (employee.getEmail() == null || !employee.getEmail().contains("@")) {
        throw new ValidationException("Valid email is required");  // Duplicated
    }
    employeeRepository.update(employee);
}
```

**Correct (extracted common logic):**

```java
public void processNewEmployee(Employee employee) {
    validateEmployee(employee);
    employeeRepository.save(employee);
    emailService.sendWelcome(employee.getEmail());
}

public void updateEmployee(Employee employee) {
    validateEmployee(employee);
    employeeRepository.update(employee);
}

private void validateEmployee(Employee employee) {
    requireNonEmpty(employee.getName(), "Name is required");
    requireValidEmail(employee.getEmail());
}

private void requireNonEmpty(String value, String message) {
    if (value == null || value.trim().isEmpty()) {
        throw new ValidationException(message);
    }
}
```

Every piece of knowledge must have a single, unambiguous, authoritative representation within a system.

Reference: [Clean Code, Chapter 3: Functions](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
