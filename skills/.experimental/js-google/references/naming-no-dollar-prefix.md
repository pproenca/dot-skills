---
title: Avoid Dollar Sign Prefix in Identifiers
impact: MEDIUM
impactDescription: prevents confusion with framework conventions
tags: naming, identifiers, dollar-sign, conventions
---

## Avoid Dollar Sign Prefix in Identifiers

Do not use `$` prefix in identifiers except when required by third-party frameworks (Angular, jQuery). Dollar signs create confusion with framework-specific conventions.

**Incorrect (arbitrary dollar signs):**

```javascript
class UserService {
  constructor() {
    this.$users = [];  // Looks like Angular service
    this.$cache = new Map();
  }

  $fetchUser(userId) {  // Confusing naming
    return this.$users.find(u => u.id === userId);
  }
}

const $element = document.getElementById('app');  // Looks like jQuery
const $data = { name: 'Alice' };
```

**Correct (no dollar signs):**

```javascript
class UserService {
  constructor() {
    this.users = [];
    this.cache = new Map();
  }

  fetchUser(userId) {
    return this.users.find(user => user.id === userId);
  }
}

const appElement = document.getElementById('app');
const userData = { name: 'Alice' };
```

**Exception (framework requirements):**

```javascript
// Angular dependency injection (required by framework)
class OrderComponent {
  constructor($http, $scope) {
    this.$http = $http;  // Framework convention
    this.$scope = $scope;
  }
}

// jQuery (if library is used)
const $modal = $('#modal');  // jQuery convention
```

Reference: [Google JavaScript Style Guide - Identifiers](https://google.github.io/styleguide/jsguide.html#naming-rules-common-to-all-identifiers)
