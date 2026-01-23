---
title: Functions Should Do One Thing
impact: CRITICAL
impactDescription: enables understanding functions at a glance
tags: func, single-responsibility, cohesion, focus
---

## Functions Should Do One Thing

Functions should do one thing. They should do it well. They should do it only. If a function does multiple things, extract those things into separate functions.

**Incorrect (function does multiple things):**

```java
public void processEmployee(Employee employee) {
    // Validate employee
    if (employee.getName() == null || employee.getName().isEmpty()) {
        throw new IllegalArgumentException("Name required");
    }
    if (employee.getSalary() < 0) {
        throw new IllegalArgumentException("Salary cannot be negative");
    }

    // Calculate tax
    double tax = employee.getSalary() * 0.3;
    employee.setTax(tax);

    // Save to database
    Connection conn = getConnection();
    PreparedStatement stmt = conn.prepareStatement(
        "INSERT INTO employees VALUES (?, ?, ?)");
    stmt.setString(1, employee.getName());
    stmt.setDouble(2, employee.getSalary());
    stmt.setDouble(3, tax);
    stmt.execute();

    // Send email notification
    EmailService.send(employee.getEmail(), "Welcome!");
}
```

**Correct (each function does one thing):**

```java
public void processEmployee(Employee employee) {
    validateEmployee(employee);
    calculateTax(employee);
    saveEmployee(employee);
    sendWelcomeEmail(employee);
}

private void validateEmployee(Employee employee) {
    validateName(employee);
    validateSalary(employee);
}

private void calculateTax(Employee employee) {
    double tax = employee.getSalary() * TAX_RATE;
    employee.setTax(tax);
}

private void saveEmployee(Employee employee) {
    employeeRepository.save(employee);
}

private void sendWelcomeEmail(Employee employee) {
    emailService.sendWelcome(employee.getEmail());
}
```

**Test:** If you can extract another function from it with a name that is not merely a restatement of its implementation, the function is doing more than one thing.

Reference: [Clean Code, Chapter 3: Functions](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
