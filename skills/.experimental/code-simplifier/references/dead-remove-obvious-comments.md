---
title: Remove Comments That State the Obvious
impact: MEDIUM
impactDescription: Redundant comments double reading time without adding information; they decay into lies as code evolves
tags: dead, comments, redundancy, self-documenting
---

## Remove Comments That State the Obvious

Comments that repeat what the code says add noise without value. They double the reading burden and inevitably drift out of sync with the code they describe. Well-named variables and functions are self-documenting; comments should add context the code cannot express.

**Incorrect (comments repeat the code):**

```typescript
// Import React
import React from 'react';

// User interface
interface User {
  id: string;      // The user's ID
  name: string;    // The user's name
  email: string;   // The user's email
  age: number;     // The user's age
}

// Function to get user by ID
function getUserById(id: string): User | null {
  // Find the user in the array
  const user = users.find(u => u.id === id);

  // If user is not found, return null
  if (!user) {
    return null;
  }

  // Return the user
  return user;
}

// Increment counter
counter++;

// Set loading to true
setLoading(true);

// Loop through items
for (const item of items) {
  // Process the item
  processItem(item);
}
```

**Correct (self-documenting code, no redundant comments):**

```typescript
import React from 'react';

interface User {
  id: string;
  name: string;
  email: string;
  age: number;
}

function getUserById(id: string): User | null {
  return users.find(u => u.id === id) ?? null;
}

counter++;
setLoading(true);

for (const item of items) {
  processItem(item);
}
```

**Incorrect (comments describe obvious logic):**

```python
def calculate_total(items):
    # Initialize total to zero
    total = 0

    # Loop through each item
    for item in items:
        # Add the item price to total
        total += item.price

        # If item has discount, subtract it
        if item.discount:
            total -= item.discount

    # Return the total
    return total
```

**Correct (code speaks for itself):**

```python
def calculate_total(items):
    total = 0
    for item in items:
        total += item.price
        if item.discount:
            total -= item.discount
    return total
```

**Incorrect (trivial getter/setter comments):**

```java
public class Product {
    private String name;
    private double price;

    /**
     * Gets the name.
     * @return the name
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the name.
     * @param name the name to set
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * Gets the price.
     * @return the price
     */
    public double getPrice() {
        return price;
    }
}
```

**Correct (skip trivial documentation):**

```java
public class Product {
    private String name;
    private double price;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public double getPrice() { return price; }
}
```

### What Makes a Comment Obvious?

- Restates the identifier name: `// the user's name` for `userName`
- Describes the language construct: `// loop through items` for a for loop
- Explains standard operations: `// return the result`
- Documents trivial getters/setters with no logic

### When NOT to Apply

- Regex patterns that need explanation
- Complex algorithms that benefit from step descriptions
- Non-obvious magic numbers or business rules
- Workarounds for known bugs or platform quirks
- Public API documentation (JSDoc, docstrings)

### Benefits

- 30-50% fewer comment lines without information loss
- Comments that remain are actually valuable
- Reduces maintenance burden of keeping comments in sync
- Forces better naming instead of relying on comments
- Faster code scanning without visual noise
