---
title: Preserve Error Messages, Types, and Handling
impact: CRITICAL
impactDescription: Changed error behavior breaks error handling logic, monitoring alerts, and user-facing messages
tags: behave, errors, exceptions, error-handling
---

## Preserve Error Messages, Types, and Handling

Error behavior is part of your API contract. Changing exception types, error messages, or when errors are thrown breaks catch blocks, monitoring systems, and user expectations. Simplify error handling code only when the observable error behavior remains identical.

**Incorrect (changes exception type):**

```typescript
// Before: throws specific error type
function parseConfig(json: string): Config {
  try {
    return JSON.parse(json);
  } catch (e) {
    throw new ConfigParseError(`Invalid config: ${e.message}`);
  }
}

// After "simplification": throws generic error
function parseConfig(json: string): Config {
  return JSON.parse(json); // Now throws SyntaxError instead
}
// Breaks: catch (e) { if (e instanceof ConfigParseError) ... }
```

**Correct (preserves error type and message format):**

```typescript
function parseConfig(json: string): Config {
  try {
    return JSON.parse(json);
  } catch (e) {
    throw new ConfigParseError(`Invalid config: ${(e as Error).message}`);
  }
}
```

**Incorrect (changes error message):**

```python
# Before: specific error message
def validate_age(age: int) -> None:
    if age < 0:
        raise ValueError("Age cannot be negative")
    if age > 150:
        raise ValueError("Age cannot exceed 150")

# After "simplification": combined validation
def validate_age(age: int) -> None:
    if not 0 <= age <= 150:
        raise ValueError("Invalid age")  # Different message!
# Breaks: tests checking for specific error messages
```

**Correct (preserves original error messages):**

```python
def validate_age(age: int) -> None:
    if age < 0:
        raise ValueError("Age cannot be negative")
    if age > 150:
        raise ValueError("Age cannot exceed 150")
```

### When NOT to Apply

- When explicitly tasked with improving error messages
- When error messages contain sensitive information that should be removed
- When consolidating truly duplicate error paths (same message, same type)

### Benefits

- Catch blocks continue working correctly
- Monitoring and alerting rules remain valid
- User-facing error messages stay consistent
- Error documentation stays accurate
