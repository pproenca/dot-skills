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

**When NOT to apply DRY:**
- **Coincidental duplication:** Two code blocks look similar but serve different purposes and will evolve independently. Extracting a shared function creates a false coupling that makes both harder to change later.
- **Premature abstraction:** If the code has only been duplicated once, wait. The third occurrence reveals the true abstraction. Premature extraction often produces awkward, over-parameterized helpers.
- **Cross-boundary duplication:** Sometimes duplication across microservices or bounded contexts is preferable to introducing a shared library that couples the services.

Reference: [Clean Code, Chapter 3: Functions](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
