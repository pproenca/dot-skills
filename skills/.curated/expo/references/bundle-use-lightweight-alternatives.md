---
title: Use Lightweight Library Alternatives
impact: HIGH
impactDescription: 50-200KB savings per replaced library
tags: bundle, dependencies, lightweight, alternatives
---

## Use Lightweight Library Alternatives

Replace heavy libraries with lightweight alternatives that provide the same functionality. Many popular libraries have smaller, more focused replacements.

**Incorrect (heavy libraries for simple tasks):**

```json
{
  "dependencies": {
    "moment": "^2.29.4",
    "lodash": "^4.17.21",
    "axios": "^1.6.0",
    "uuid": "^9.0.0"
  }
}
```

```typescript
import moment from 'moment'  // 232KB
import _ from 'lodash'  // 72KB
import axios from 'axios'  // 48KB
import { v4 as uuidv4 } from 'uuid'  // 12KB
```

**Correct (lightweight alternatives):**

```json
{
  "dependencies": {
    "date-fns": "^2.30.0",
    "ky": "^1.2.0"
  }
}
```

```typescript
import { format, parseISO } from 'date-fns'  // ~3KB per function
import ky from 'ky'  // 3KB

// Use built-in crypto for UUIDs
import * as Crypto from 'expo-crypto'
const uuid = Crypto.randomUUID()

// Use native array methods instead of lodash
const filtered = items.filter(x => x.active)
const mapped = items.map(x => x.name)
const unique = [...new Set(items)]
```

**Library replacements:**

| Heavy Library | Size | Alternative | Size |
|---------------|------|-------------|------|
| moment | 232KB | date-fns | ~3KB/fn |
| lodash | 72KB | Native methods | 0KB |
| axios | 48KB | ky or fetch | 3KB/0KB |
| uuid | 12KB | expo-crypto | built-in |
| classnames | 2KB | Template literals | 0KB |
| numeral | 33KB | Intl.NumberFormat | 0KB |

**Using native Intl APIs:**

```typescript
// Instead of numeral.js
const formatCurrency = (amount) =>
  new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(amount)

// Instead of moment for relative time
const formatRelative = (date) =>
  new Intl.RelativeTimeFormat('en', { numeric: 'auto' }).format(
    Math.round((date - Date.now()) / (1000 * 60 * 60 * 24)),
    'day'
  )
```

**When heavy libraries are justified:**
- Complex date manipulation (moment-timezone for timezone math)
- Deep cloning with circular refs (lodash.cloneDeep)
- HTTP interceptors and retry logic (axios)
