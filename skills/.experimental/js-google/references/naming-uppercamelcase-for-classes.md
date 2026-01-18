---
title: Use UpperCamelCase for Classes and Constructors
impact: HIGH
impactDescription: prevents new keyword misuse on non-constructors
tags: naming, classes, constructors, camelcase
---

## Use UpperCamelCase for Classes and Constructors

Classes, interfaces, records, and typedefs use UpperCamelCase (PascalCase). This visually distinguishes types that can be instantiated or used in type annotations.

**Incorrect (lowercase or mixed naming):**

```javascript
// Lowercase class name
class orderProcessor {
  constructor(config) {
    this.config = config;
  }
}

// Snake_case typedef
/** @typedef {{id: number, name: string}} */
let user_profile;

// Mixed naming
class HTTP_Client {
  fetch(url) {
    return globalThis.fetch(url);
  }
}
```

**Correct (UpperCamelCase for types):**

```javascript
class OrderProcessor {
  constructor(config) {
    this.config = config;
  }
}

/** @typedef {{id: number, name: string}} */
let UserProfile;

class HttpClient {
  fetch(url) {
    return globalThis.fetch(url);
  }
}

/** @interface */
class EventListener {
  /** @param {!Event} event */
  handleEvent(event) {}
}
```

**Camel case conversion rules:**
- `HTTP` becomes `Http` (not `HTTP`)
- `XMLParser` becomes `XmlParser`
- `IOStream` becomes `IoStream`

Reference: [Google JavaScript Style Guide - Class names](https://google.github.io/styleguide/jsguide.html#naming-class-names)
