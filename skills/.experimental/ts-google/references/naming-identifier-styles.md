---
title: Use Correct Identifier Naming Styles
impact: MEDIUM
impactDescription: improves code readability and consistency
tags: naming, identifiers, camelCase, PascalCase, style
---

## Use Correct Identifier Naming Styles

Follow consistent naming conventions based on identifier type. This improves readability and makes code intent clear.

**Naming conventions:**

| Style | Usage |
|-------|-------|
| `UpperCamelCase` | Classes, interfaces, types, enums, decorators, type parameters |
| `lowerCamelCase` | Variables, parameters, functions, methods, properties, module aliases |
| `CONSTANT_CASE` | Global constants, enum values, static readonly properties |

**Incorrect (wrong case for identifier type):**

```typescript
// Wrong case for type
interface user_data {
  user_name: string
}

// Wrong case for constant
const maxRetries = 3

// Wrong case for class
class userService {}

// Leading underscore for "private"
const _internalValue = 42
```

**Correct (proper case by identifier type):**

```typescript
// Interface - UpperCamelCase
interface UserData {
  userName: string
}

// Global constant - CONSTANT_CASE
const MAX_RETRIES = 3

// Class - UpperCamelCase
class UserService {}

// Variable - lowerCamelCase
const internalValue = 42

// Enum - UpperCamelCase with CONSTANT_CASE values
enum HttpStatus {
  OK = 200,
  NOT_FOUND = 404,
  INTERNAL_ERROR = 500,
}
```

**Treat acronyms as words:**

```typescript
// Correct
loadHttpUrl()
parseXmlDocument()
class HtmlParser {}

// Incorrect
loadHTTPURL()
parseXMLDocument()
class HTMLParser {}
```

Reference: [Google TypeScript Style Guide - Naming style](https://google.github.io/styleguide/tsguide.html#naming-style)
