---
title: Interfaces Belong to Clients Not Implementers
impact: CRITICAL
impactDescription: enables true dependency inversion
tags: dep, interfaces, dependency-inversion, ownership
---

## Interfaces Belong to Clients Not Implementers

Interfaces should be defined in the layer that uses them, not the layer that implements them. The client owns the abstraction; the implementation adapts to it.

**Incorrect (interface defined next to implementation):**

```java
// infrastructure/persistence/UserRepository.java
public interface UserRepository {
    User findById(String id);
    void save(User user);
}

// infrastructure/persistence/PostgresUserRepository.java
public class PostgresUserRepository implements UserRepository {
    // Implementation
}

// application/usecases/CreateUserUseCase.java
import infrastructure.persistence.UserRepository;  // Use case imports from infrastructure!

public class CreateUserUseCase {
    private final UserRepository repository;
}
```

**Correct (interface defined where it's used):**

```java
// application/ports/output/UserRepository.java
public interface UserRepository {
    User findById(String id);
    void save(User user);
}

// application/usecases/CreateUserUseCase.java
import application.ports.output.UserRepository;  // Same layer import

public class CreateUserUseCase {
    private final UserRepository repository;  // No infrastructure dependency
}

// infrastructure/persistence/PostgresUserRepository.java
import application.ports.output.UserRepository;  // Infrastructure depends on application

public class PostgresUserRepository implements UserRepository {
    // Implementation adapts to the port
}
```

**Note:** This is the essence of the Dependency Inversion Principle. The high-level module defines what it needs; low-level modules conform to that contract.

Reference: [Clean Architecture - Chapter 11: DIP](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch11.xhtml)
