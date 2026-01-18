---
title: Use Single Quotes for String Literals
impact: LOW
impactDescription: maintains consistency across codebase
tags: format, strings, quotes, style
---

## Use Single Quotes for String Literals

Use single quotes (`'`) for ordinary string literals. Use template literals (backticks) for strings requiring interpolation or multiple lines.

**Incorrect (double quotes or inconsistent):**

```javascript
const name = "Alice";
const greeting = "Hello, " + name + "!";

const message = 'Welcome to the "Admin" panel';
const mixed = "Some use double" + ' and some use single';
```

**Correct (single quotes):**

```javascript
const name = 'Alice';
const greeting = 'Hello, ' + name + '!';

// Use template literals for interpolation
const greetingTemplate = `Hello, ${name}!`;

// Escape inner quotes or use template literal
const message = 'Welcome to the "Admin" panel';
const altMessage = `Welcome to the "Admin" panel`;
```

**Template literals for complex strings:**

```javascript
// Multi-line strings
const html = `
  <div class="user-card">
    <h2>${user.name}</h2>
    <p>${user.email}</p>
  </div>
`;

// Complex interpolation
const summary = `Order #${order.id}: ${order.items.length} items, $${order.total.toFixed(2)}`;
```

**When double quotes are acceptable:**
- JSON strings (required by spec)
- Strings containing many single quotes

Reference: [Google JavaScript Style Guide - String literals](https://google.github.io/styleguide/jsguide.html#features-strings)
