---
title: Follow FIRST Principles
impact: MEDIUM
impactDescription: prevents test suite from becoming 10× slower over time
tags: test, first, fast, independent, repeatable
---

## Follow FIRST Principles

Clean tests follow FIRST: Fast, Independent, Repeatable, Self-Validating, and Timely. These properties ensure tests remain useful and maintainable.

**Incorrect (violating FIRST):**

```java
// Slow - depends on real database
@Test
public void testUserQuery() {
    Connection conn = DriverManager.getConnection(PROD_DB_URL);  // Slow!
    // ...
}

// Not Independent - tests depend on each other
private static User sharedUser;

@Test
public void test1CreateUser() {
    sharedUser = userService.create("bob");
}

@Test
public void test2UpdateUser() {
    sharedUser.setName("alice");  // Depends on test1 running first
}

// Not Repeatable - depends on external state
@Test
public void testPayment() {
    assertTrue(paymentGateway.charge(card, 100));  // Different result each time
}
```

**Correct (following FIRST):**

```java
// Fast - uses mocks, runs in milliseconds
@Test
public void queryShouldReturnMatchingUsers() {
    UserRepository repo = mock(UserRepository.class);
    when(repo.findByName("bob")).thenReturn(List.of(testUser));

    List<User> result = userService.query("bob");

    assertEquals(1, result.size());
}

// Independent - each test sets up its own state
@Test
public void createShouldReturnNewUser() {
    User user = userService.create("bob");
    assertEquals("bob", user.getName());
}

@Test
public void updateShouldModifyUserName() {
    User user = userService.create("bob");
    user.setName("alice");
    assertEquals("alice", user.getName());
}

// Repeatable - uses test doubles
@Test
public void chargeShouldReturnTrueOnSuccess() {
    PaymentGateway gateway = mock(PaymentGateway.class);
    when(gateway.charge(any(), eq(100))).thenReturn(true);

    assertTrue(paymentService.processPayment(100));
}
```

Reference: [Clean Code, Chapter 9: Unit Tests](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
