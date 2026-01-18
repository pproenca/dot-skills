---
title: Follow Source File Structure Order
impact: HIGH
impactDescription: improves navigability and prevents declaration errors
tags: module, file-structure, organization, imports
---

## Follow Source File Structure Order

Source files must follow a consistent structure: license/copyright, file overview, imports, then implementation. Mixing these sections causes confusion and potential hoisting issues.

**Incorrect (mixed structure):**

```javascript
import { logger } from './utils/logger.js';

const MAX_RETRIES = 3;

import { fetchData } from './api/client.js';  // Import after code

/**
 * @fileoverview Handles data synchronization.
 */

export async function syncData(endpoint) {
  for (let i = 0; i < MAX_RETRIES; i++) {
    try {
      return await fetchData(endpoint);
    } catch (error) {
      logger.warn(`Retry ${i + 1} failed`);
    }
  }
}
```

**Correct (proper structure order):**

```javascript
/**
 * @fileoverview Handles data synchronization.
 */

import { fetchData } from './api/client.js';
import { logger } from './utils/logger.js';

const MAX_RETRIES = 3;

export async function syncData(endpoint) {
  for (let i = 0; i < MAX_RETRIES; i++) {
    try {
      return await fetchData(endpoint);
    } catch (error) {
      logger.warn(`Retry ${i + 1} failed`);
    }
  }
}
```

**Structure order:**
1. License/copyright (if applicable)
2. `@fileoverview` JSDoc
3. All import statements
4. Constants and implementation code

Reference: [Google JavaScript Style Guide - Source file structure](https://google.github.io/styleguide/jsguide.html#source-file-structure)
