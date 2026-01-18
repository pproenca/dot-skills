---
title: Use Object Literals Instead of Object Constructor
impact: MEDIUM
impactDescription: clearer syntax and avoids edge cases
tags: data, objects, literals, constructor
---

## Use Object Literals Instead of Object Constructor

Use object literal syntax `{}` instead of `new Object()`. The constructor form is verbose and has edge cases with single arguments.

**Incorrect (Object constructor):**

```javascript
const user = new Object();
user.name = 'Alice';
user.email = 'alice@example.com';
user.role = 'admin';

const config = new Object();
config.timeout = 5000;
config.retries = 3;

// Mixed styles
const order = new Object({
  id: 123,
  items: [],
});
```

**Correct (object literals):**

```javascript
const user = {
  name: 'Alice',
  email: 'alice@example.com',
  role: 'admin',
};

const config = {
  timeout: 5000,
  retries: 3,
};

const order = {
  id: 123,
  items: [],
};
```

**With shorthand properties:**

```javascript
const name = 'Alice';
const email = 'alice@example.com';
const role = 'admin';

// Shorthand property names
const user = { name, email, role };

// Method shorthand
const calculator = {
  add(a, b) {
    return a + b;
  },
  multiply(a, b) {
    return a * b;
  },
};
```

Reference: [Google JavaScript Style Guide - Object literals](https://google.github.io/styleguide/jsguide.html#features-objects-no-new-wrappers)
