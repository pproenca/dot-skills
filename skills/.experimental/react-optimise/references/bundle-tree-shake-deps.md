---
title: Configure Dependencies for Effective Tree Shaking
impact: CRITICAL
impactDescription: 50-90% dead code elimination in dependencies
tags: bundle, tree-shaking, esm, dependencies
---

## Configure Dependencies for Effective Tree Shaking

Tree shaking removes unused exports at build time, but only works when dependencies ship ESM (ES Modules) and declare `sideEffects: false`. CommonJS modules, barrel re-exports, and libraries without side-effect annotations force the bundler to include the entire package. Choosing ESM-native alternatives and configuring imports correctly recovers 50-90% of dead dependency code.

**Incorrect (CJS imports defeat tree shaking):**

```tsx
import _ from "lodash" // CJS — entire 72KB library included
import moment from "moment" // CJS — 67KB with all locales
import * as Icons from "react-icons/fa" // barrel import — all 1600 icons

function OrderConfirmation({ order }: { order: Order }) {
  const formattedDate = moment(order.createdAt).format("DD MMM YYYY")
  const total = _.sumBy(order.items, "price")

  return (
    <div>
      <Icons.FaCheckCircle />
      <p>Order placed on {formattedDate}</p>
      <p>Total: ${total.toFixed(2)}</p>
    </div>
  )
}
```

**Correct (ESM imports with tree-shakeable alternatives):**

```tsx
import { sumBy } from "lodash-es" // ESM — only sumBy is bundled
import { format } from "date-fns" // ESM with sideEffects: false
import { FaCheckCircle } from "react-icons/fa" // direct named import

function OrderConfirmation({ order }: { order: Order }) {
  const formattedDate = format(order.createdAt, "dd MMM yyyy")
  const total = sumBy(order.items, (orderItem) => orderItem.price)

  return (
    <div>
      <FaCheckCircle />
      <p>Order placed on {formattedDate}</p>
      <p>Total: ${total.toFixed(2)}</p>
    </div>
  )
}

// package.json — mark your own package as tree-shakeable
{
  "type": "module",
  "sideEffects": ["*.css"],
  "exports": {
    ".": { "import": "./dist/index.mjs", "require": "./dist/index.cjs" }
  }
}
```

Reference: [Webpack — Tree Shaking](https://webpack.js.org/guides/tree-shaking/)
