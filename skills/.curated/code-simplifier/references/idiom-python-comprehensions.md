---
title: Use Comprehensions for Simple Transforms
impact: LOW-MEDIUM
impactDescription: Comprehensions are 10-30% faster and more readable for simple cases
tags: idiom, python, comprehensions, readability
---

## Use Comprehensions for Simple Transforms

Python comprehensions (list, dict, set, generator) are idiomatic for simple transformations and filtering. They're more concise and often faster than equivalent loops. However, complex comprehensions with multiple conditions or nested logic become unreadable—use regular loops instead.

**Incorrect (loop for simple transform):**

```python
# Verbose for a simple operation
result = []
for user in users:
    if user.is_active:
        result.append(user.email)

# Building dict inefficiently
lookup = {}
for item in items:
    lookup[item.id] = item.name
```

**Correct (comprehension for simple transform):**

```python
# Clear and Pythonic
result = [user.email for user in users if user.is_active]

# Dict comprehension
lookup = {item.id: item.name for item in items}

# Set comprehension for unique values
unique_categories = {product.category for product in products}

# Generator for memory efficiency with large data
total = sum(order.amount for order in orders if order.status == "completed")
```

**Incorrect (complex comprehension hurts readability):**

```python
# Too complex - multiple conditions and transformations
result = [
    transform_data(item.value)
    for category in categories
    for item in category.items
    if item.is_valid and item.value > threshold
    if not item.is_deleted
]
```

**Correct (loop for complex logic):**

```python
# Clear with explicit logic
result = []
for category in categories:
    for item in category.items:
        if not item.is_valid or item.is_deleted:
            continue
        if item.value <= threshold:
            continue
        result.append(transform_data(item.value))
```

### Guidelines

| Use Comprehensions | Use Loops |
|-------------------|-----------|
| Single filter + map | Multiple conditions |
| One level of nesting | Side effects needed |
| Fits on one line (~80 chars) | Complex transformations |
| Pure data transformation | Exception handling required |

### Walrus Operator in Comprehensions (Python 3.8+)

```python
# Avoid repeated computation
results = [y for x in data if (y := expensive_transform(x)) is not None]
```

### Benefits

- More readable for simple cases
- Often 10-30% faster than equivalent loops
- Generator expressions avoid building intermediate lists
- Clearly signals "this is a data transformation"
