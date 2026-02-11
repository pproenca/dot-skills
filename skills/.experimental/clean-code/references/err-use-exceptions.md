---
title: Separate Error Handling from Happy Path
impact: HIGH
impactDescription: reduces nested conditionals by 50-80% in exception-based languages
tags: err, exceptions, error-handling, separation, result-types
---

## Separate Error Handling from Happy Path

Error handling is important, but when it obscures logic, it's wrong. The core insight is separation: keep the happy path visible and error handling consolidated, regardless of which mechanism your language uses.

**Incorrect (error handling obscures business logic):**

```java
if (deletePage(page) == E_OK) {
    if (registry.deleteReference(page.name) == E_OK) {
        if (configKeys.deleteKey(page.name.makeKey()) == E_OK) {
            logger.log("page deleted");
        } else {
            logger.log("configKey not deleted");
        }
    } else {
        logger.log("deleteReference from registry failed");
    }
} else {
    logger.log("delete failed");
    return E_ERROR;
}
```

**Correct (Java/C#/Python — exceptions separate concerns):**

```java
public void delete(Page page) {
    try {
        deletePageAndAllReferences(page);
    } catch (PageDeletionException e) {
        logger.log(e.getMessage());
    }
}

private void deletePageAndAllReferences(Page page) throws PageDeletionException {
    deletePage(page);
    registry.deleteReference(page.name);
    configKeys.deleteKey(page.name.makeKey());
}
```

**Correct (Go — explicit error returns with early return):**

```go
func (s *Service) Delete(page Page) error {
    if err := s.deletePage(page); err != nil {
        return fmt.Errorf("deleting page: %w", err)
    }
    if err := s.registry.DeleteReference(page.Name); err != nil {
        return fmt.Errorf("deleting reference: %w", err)
    }
    if err := s.configKeys.DeleteKey(page.Name); err != nil {
        return fmt.Errorf("deleting config key: %w", err)
    }
    return nil
}
```

**Correct (Rust — Result type with ? operator):**

```rust
fn delete(&self, page: &Page) -> Result<(), DeletionError> {
    self.delete_page(page)?;
    self.registry.delete_reference(&page.name)?;
    self.config_keys.delete_key(&page.name)?;
    Ok(())
}
```

**The principle is language-agnostic:** separate error-handling logic from business logic. The mechanism differs:
- **Java/C#/Python:** try-catch with specific exception types
- **Go:** explicit error returns with early return pattern
- **Rust:** `Result<T, E>` with `?` operator
- **TypeScript/Kotlin:** `Result` types or exceptions depending on the domain

**When NOT to use exceptions:**
- In Go, Rust, or other languages designed around explicit error values — use their idiomatic patterns instead
- For expected business outcomes (e.g., "user not found") — consider returning `Optional` or a domain-specific result type rather than throwing
- In performance-critical hot paths where exception overhead matters

Reference: [Clean Code, Chapter 3: Functions](https://www.oreilly.com/library/view/clean-code-a/9780136083238/) and [Chapter 7: Error Handling](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
