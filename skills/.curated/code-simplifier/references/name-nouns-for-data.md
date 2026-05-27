---
title: Use Nouns for Data, Verbs for Actions
impact: MEDIUM-HIGH
impactDescription: Consistent noun/verb naming reduces misuse errors by making it immediately clear whether something stores data or performs an action
tags: name, conventions, semantics, functions, variables
---

## Use Nouns for Data, Verbs for Actions

Variables, constants, and properties represent data - name them with nouns or noun phrases. Functions and methods perform actions - name them with verbs or verb phrases. This grammatical consistency creates intuitive expectations about what code does, making it easier to read and harder to misuse.

**Incorrect (confused naming conventions):**

```typescript
// Bad: verb name for data
const getUser = { id: 1, name: 'Alice' };

// Bad: noun name for function
function user(id: number): User {
  return database.find(id);
}

// Bad: adjective for boolean action
function valid(input: string): boolean {
  return input.length > 0;
}

// Confusing usage
const result = user(getUser.id); // Which is the function?
```

**Correct (nouns for data, verbs for actions):**

```typescript
// Good: noun for data
const currentUser = { id: 1, name: 'Alice' };

// Good: verb for function
function fetchUser(id: number): User {
  return database.find(id);
}

// Good: verb for boolean-returning function
function isValid(input: string): boolean {
  return input.length > 0;
}

// Clear usage
const result = fetchUser(currentUser.id);
```

**Incorrect (Python - mixed conventions):**

```python
# Bad: function named like data
def order_total(order):
    return sum(item.price for item in order.items)

# Bad: data named like action
calculate_tax = 0.08
process_items = ['apple', 'banana']

# Confusing: is this calling a function or accessing data?
total = order_total  # Missing parentheses - but name suggests data
```

**Correct (Python - clear conventions):**

```python
# Good: verb phrase for function
def calculate_order_total(order):
    return sum(item.price for item in order.items)

# Good: nouns for data
tax_rate = 0.08
available_items = ['apple', 'banana']

# Clear: obviously a function call
total = calculate_order_total(cart)
```

**Incorrect (Go - unclear entity types):**

```go
// Bad: function looks like a type
func User(id int) *UserModel {
    return db.Find(id)
}

// Bad: variable looks like function
var fetchData = Response{Status: 200}
```

**Correct (Go - proper conventions):**

```go
// Good: function uses verb
func GetUser(id int) *UserModel {
    return db.Find(id)
}

// Good: variable uses noun
var apiResponse = Response{Status: 200}
```

### Common Patterns

| Entity Type | Convention | Examples |
|-------------|------------|----------|
| Variables | Noun/noun phrase | `user`, `orderItems`, `totalPrice` |
| Constants | Noun (often UPPER_CASE) | `MAX_RETRIES`, `DefaultTimeout` |
| Functions | Verb/verb phrase | `fetchUser`, `calculateTotal`, `validateInput` |
| Boolean functions | `is`, `has`, `can`, `should` | `isValid`, `hasPermission`, `canEdit` |
| Properties | Noun | `user.name`, `order.total` |

### When NOT to Apply

- Factory functions may use nouns when the pattern is conventional (e.g., `NewUser()` in Go)
- Builder pattern methods may chain noun-like names
- DSL or fluent APIs may prioritize readability over grammar

### Benefits

- Instantly distinguishes data from behavior
- Reduces cognitive load when reading code
- Prevents accidental misuse (calling data, accessing functions)
- Makes code structure predictable
