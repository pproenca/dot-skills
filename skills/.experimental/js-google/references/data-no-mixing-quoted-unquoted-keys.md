---
title: Never Mix Quoted and Unquoted Object Keys
impact: MEDIUM
impactDescription: prevents compiler optimization issues
tags: data, objects, keys, style
---

## Never Mix Quoted and Unquoted Object Keys

Never mix quoted and unquoted property keys in the same object. Choose struct-style (unquoted) or dict-style (quoted) and use consistently.

**Incorrect (mixed key styles):**

```javascript
const config = {
  apiUrl: 'https://api.example.com',
  'api-key': 'secret123',  // Quoted
  timeout: 5000,
  'max-retries': 3,  // Quoted
};

const user = {
  name: 'Alice',
  'e-mail': 'alice@example.com',  // Mixing styles
  role: 'admin',
};
```

**Correct (struct-style, unquoted keys):**

```javascript
const config = {
  apiUrl: 'https://api.example.com',
  apiKey: 'secret123',
  timeout: 5000,
  maxRetries: 3,
};

const user = {
  name: 'Alice',
  email: 'alice@example.com',
  role: 'admin',
};
```

**Correct (dict-style, all quoted keys):**

```javascript
// Use when keys must contain special characters
const headers = {
  'Content-Type': 'application/json',
  'X-Api-Key': 'secret123',
  'Accept-Language': 'en-US',
};

// Or when keys are dynamic/external
const translations = {
  'en-US': 'Hello',
  'es-ES': 'Hola',
  'fr-FR': 'Bonjour',
};
```

**Why this matters:**
- Closure Compiler optimizes unquoted keys differently than quoted
- Mixing prevents consistent property access patterns
- Makes refactoring more error-prone

Reference: [Google JavaScript Style Guide - Object literals](https://google.github.io/styleguide/jsguide.html#features-objects-mixing-keys)
