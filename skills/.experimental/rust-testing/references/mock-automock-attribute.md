---
title: Use mockall automock for Complex Mocking
impact: CRITICAL
impactDescription: generates mock implementations automatically
tags: mock, mockall, automock, code-generation
---

## Use mockall automock for Complex Mocking

Use `#[automock]` from mockall to automatically generate mock implementations for traits. This eliminates boilerplate and provides expectation-based testing.

**Incorrect (manual mock implementation):**

```rust
// Tedious manual mock
pub trait Repository {
    fn find_by_id(&self, id: u64) -> Option<User>;
    fn save(&self, user: &User) -> Result<(), Error>;
    fn delete(&self, id: u64) -> Result<(), Error>;
    fn find_all(&self) -> Vec<User>;
}

struct MockRepository {
    find_by_id_result: Option<User>,
    save_called: std::cell::RefCell<bool>,
    // Need to track every method call manually...
}

impl Repository for MockRepository {
    fn find_by_id(&self, _id: u64) -> Option<User> {
        self.find_by_id_result.clone()
    }
    fn save(&self, _user: &User) -> Result<(), Error> {
        *self.save_called.borrow_mut() = true;
        Ok(())
    }
    // Repeat for every method...
}
```

**Correct (using mockall automock):**

```rust
use mockall::automock;

#[automock]
pub trait Repository {
    fn find_by_id(&self, id: u64) -> Option<User>;
    fn save(&self, user: &User) -> Result<(), Error>;
    fn delete(&self, id: u64) -> Result<(), Error>;
    fn find_all(&self) -> Vec<User>;
}

#[cfg(test)]
mod tests {
    use super::*;
    use mockall::predicate::*;

    #[test]
    fn update_user_saves_to_repository() {
        let mut mock = MockRepository::new();

        mock.expect_find_by_id()
            .with(eq(42))
            .times(1)
            .returning(|_| Some(User { id: 42, name: "Alice".into() }));

        mock.expect_save()
            .with(function(|u: &User| u.name == "Alice Updated"))
            .times(1)
            .returning(|_| Ok(()));

        let service = UserService::new(mock);
        service.update_user(42, "Alice Updated").unwrap();
    }

    #[test]
    fn delete_user_removes_from_repository() {
        let mut mock = MockRepository::new();

        mock.expect_delete()
            .with(eq(42))
            .times(1)
            .returning(|_| Ok(()));

        let service = UserService::new(mock);
        service.delete_user(42).unwrap();
    }
}
```

**Cargo.toml:**

```toml
[dev-dependencies]
mockall = "0.12"
```

**Key features:**
- `expect_*()` sets up expectations for method calls
- `with()` validates arguments using predicates
- `times()` verifies call count (exactly, at_least, at_most)
- `returning()` specifies the return value

Reference: [mockall crate documentation](https://docs.rs/mockall/latest/mockall/)
