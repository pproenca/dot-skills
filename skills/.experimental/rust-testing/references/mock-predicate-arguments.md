---
title: Use Predicates to Verify Mock Arguments
impact: MEDIUM
impactDescription: catches incorrect argument values
tags: mock, mockall, predicates, argument-validation
---

## Use Predicates to Verify Mock Arguments

Use `with()` predicates to verify mock methods receive correct arguments. Ignoring arguments can hide bugs where wrong data is passed.

**Incorrect (arguments ignored):**

```rust
#[test]
fn create_user_saves_correctly() {
    let mut mock_repo = MockRepository::new();

    mock_repo.expect_save()
        .returning(|_| Ok(()));  // Accepts any User, doesn't verify

    let service = UserService::new(mock_repo);
    service.create_user("alice@example.com", "Alice").unwrap();
    // Bug: email might be empty, name swapped - test still passes!
}
```

**Correct (arguments verified with predicates):**

```rust
use mockall::predicate::*;

#[test]
fn create_user_saves_with_correct_data() {
    let mut mock_repo = MockRepository::new();

    mock_repo.expect_save()
        .with(function(|user: &User| {
            user.email == "alice@example.com" && user.name == "Alice"
        }))
        .times(1)
        .returning(|_| Ok(()));

    let service = UserService::new(mock_repo);
    service.create_user("alice@example.com", "Alice").unwrap();
}

#[test]
fn update_user_saves_modified_data() {
    let mut mock_repo = MockRepository::new();

    // Verify specific field values
    mock_repo.expect_save()
        .withf(|user| {
            user.id == 42 &&
            user.name == "Updated Name" &&
            user.updated_at.is_some()
        })
        .times(1)
        .returning(|_| Ok(()));

    let service = UserService::new(mock_repo);
    service.update_user(42, "Updated Name").unwrap();
}
```

**Common predicates:**

```rust
use mockall::predicate::*;

.with(eq(42))                           // Exact equality
.with(ne(0))                            // Not equal
.with(lt(100))                          // Less than
.with(str::starts_with("user_"))        // String prefix
.with(str::contains("@"))               // String contains
.with(function(|x: &i32| *x > 0))       // Custom predicate
.with(always())                         // Any value (explicit)

// Multiple arguments
.with((eq(42), str::contains("test")))  // Tuple of predicates
```

**Alternative: withf for complex validation:**

```rust
mock.expect_send_email()
    .withf(|to, subject, body| {
        to == "admin@example.com" &&
        subject.contains("Alert") &&
        body.len() < 1000
    })
    .returning(|_, _, _| Ok(()));
```

Reference: [mockall - Matching Arguments](https://docs.rs/mockall/latest/mockall/#matching-arguments)
