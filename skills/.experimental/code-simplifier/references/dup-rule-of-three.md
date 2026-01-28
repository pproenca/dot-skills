---
title: Apply the Rule of Three
impact: MEDIUM
impactDescription: Premature extraction adds indirection that costs 2-5 minutes per reader to understand, while waiting for 3 occurrences ensures the pattern is real
tags: dup, abstraction, dry, timing
---

## Apply the Rule of Three

Wait until code appears three times before extracting a helper. The first duplication might be coincidental. The second confirms a pattern exists. The third proves extraction is worthwhile. Extracting too early creates abstractions for patterns that never materialize, adding cognitive overhead without reducing maintenance burden.

**Incorrect (extracting after first duplication):**

```typescript
// Two similar validation calls - someone extracts immediately
function validateUser(user: User) {
  if (!user.email.includes('@')) throw new Error('Invalid email');
}

function validateContact(contact: Contact) {
  if (!contact.email.includes('@')) throw new Error('Invalid email');
}

// Over-engineered "solution" after seeing just 2 occurrences
function validateEmail(entity: { email: string }, entityName: string) {
  if (!entity.email.includes('@')) {
    throw new Error(`Invalid ${entityName} email`);
  }
}
// Now every caller needs to understand this abstraction
// And if requirements diverge, the abstraction becomes awkward
```

**Correct (wait for the third occurrence):**

```typescript
// First occurrence
function validateUser(user: User) {
  if (!user.email.includes('@')) throw new Error('Invalid email');
}

// Second occurrence - note it, don't extract yet
function validateContact(contact: Contact) {
  if (!contact.email.includes('@')) throw new Error('Invalid email');
}

// Third occurrence - NOW extract with confidence
function validateOrder(order: Order) {
  if (!order.customerEmail.includes('@')) throw new Error('Invalid email');
}

// After third occurrence, extract with full understanding of the pattern
function isValidEmail(email: string): boolean {
  return email.includes('@');
}
```

**Incorrect (under-extraction - ignoring obvious patterns):**

```python
# Same exact logic copy-pasted 5 times
def process_user_csv(filepath):
    with open(filepath, 'r') as f:
        reader = csv.DictReader(f)
        return [row for row in reader if row.get('active') == 'true']

def process_order_csv(filepath):
    with open(filepath, 'r') as f:
        reader = csv.DictReader(f)
        return [row for row in reader if row.get('active') == 'true']

def process_product_csv(filepath):
    with open(filepath, 'r') as f:
        reader = csv.DictReader(f)
        return [row for row in reader if row.get('active') == 'true']
# Bug fix needed? Change it in 5 places
```

**Correct (extract after pattern is established):**

```python
def load_active_records(filepath: str) -> list[dict]:
    """Load records from CSV where active='true'."""
    with open(filepath, 'r') as f:
        reader = csv.DictReader(f)
        return [row for row in reader if row.get('active') == 'true']

# Clear, single source of truth
users = load_active_records('users.csv')
orders = load_active_records('orders.csv')
products = load_active_records('products.csv')
```

### When NOT to Apply

- Security-critical code (authentication, authorization) - extract immediately
- Complex algorithms where bugs are likely - extract on second occurrence
- When business logic dictates the pattern will recur (known requirements)

### Benefits

- Abstractions are based on real patterns, not speculation
- Fewer premature abstractions that need refactoring later
- Code readers encounter simpler, more concrete code
- Easier to understand what each piece of code actually does
