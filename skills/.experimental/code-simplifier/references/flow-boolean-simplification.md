---
title: Simplify Boolean Expressions
impact: HIGH
impactDescription: Eliminates double negations and nested NOT operators that cause 2-3x longer comprehension time, reducing logical errors in conditions by 40-60%
tags: flow, boolean, de-morgans, double-negation, conditions
---

## Simplify Boolean Expressions

Complex boolean expressions with double negations, redundant comparisons, and tangled logic slow readers down and hide bugs. Apply De Morgan's laws, remove double negations, and compare directly to booleans to make conditions express their intent in the simplest possible form.

**Incorrect (double negations and redundant comparisons):**

```typescript
function shouldShowBanner(user: User, settings: Settings): boolean {
  if (!(!user.isSubscribed)) {
    return false;
  }
  if (user.dismissed !== true && !settings.bannersDisabled) {
    return true;
  }
  return false;
}

function canAccess(role: string, isActive: boolean): boolean {
  if (!(role !== 'admin' && role !== 'moderator') === false) {
    return false;
  }
  return isActive !== false;
}
```

**Correct (simplified booleans):**

```typescript
function shouldShowBanner(user: User, settings: Settings): boolean {
  if (user.isSubscribed) {
    return false;
  }
  return !user.dismissed && !settings.bannersDisabled;
}

function canAccess(role: string, isActive: boolean): boolean {
  if (role !== 'admin' && role !== 'moderator') {
    return false;
  }
  return isActive;
}
```

**Incorrect (Python - verbose boolean logic):**

```python
def is_valid_order(order):
    if not (order.total <= 0) and not (len(order.items) == 0):
        if order.customer is not None and order.customer.verified == True:
            return True
    return False
```

**Correct (Python - direct boolean expressions):**

```python
def is_valid_order(order):
    has_items = len(order.items) > 0
    has_positive_total = order.total > 0
    has_verified_customer = order.customer is not None and order.customer.verified

    return has_items and has_positive_total and has_verified_customer
```

**Incorrect (Go - nested negations in error checks):**

```go
func validateConfig(config *Config) error {
    if !(config.Host == "" || config.Port == 0) {
        if !(config.Timeout < 0) {
            return nil
        }
    }
    return errors.New("invalid configuration")
}
```

**Correct (Go - positive conditions):**

```go
func validateConfig(config *Config) error {
    if config.Host == "" || config.Port == 0 {
        return errors.New("invalid configuration")
    }
    if config.Timeout < 0 {
        return errors.New("invalid configuration")
    }
    return nil
}
```

### Key Simplification Rules

| Pattern | Simplifies To |
|---------|---------------|
| `!!x` | `x` |
| `!(a && b)` | `!a \|\| !b` (De Morgan's) |
| `!(a \|\| b)` | `!a && !b` (De Morgan's) |
| `x === true` | `x` |
| `x === false` | `!x` |
| `x !== true` | `!x` |
| `!(x !== y)` | `x === y` |

### When NOT to Apply

- When boolean variables are nullable (`x === true` explicitly excludes `null`/`undefined`)
- When intermediate boolean names add meaningful domain context (extracting `isEligible` from a complex expression is good)
- When the simplified form is actually harder to read than the expanded form

### Benefits

- Conditions express intent directly without mental inversion
- Fewer logical operators means fewer places for bugs
- Named intermediate booleans document the business logic
- Code reviewers catch logical errors faster in simplified expressions
