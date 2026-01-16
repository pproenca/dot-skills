---
title: Inspect the Call Stack for Context
impact: MEDIUM-HIGH
impactDescription: reduces search space by 80-90%
tags: debug, call-stack, context, execution-path
---

## Inspect the Call Stack for Context

The call stack shows the chain of function calls that led to the current point. Inspect it to understand why a function was called with certain arguments and to identify incorrect callers.

**Incorrect (ignoring call stack):**

```javascript
function formatPrice(price) {
  // Bug: price is undefined
  return `$${price.toFixed(2)}`  // TypeError: Cannot read property 'toFixed' of undefined

  // Question: Why is price undefined?
  // Without call stack: Must search entire codebase for formatPrice calls
}
```

**Correct (using call stack to find the source):**

```javascript
function formatPrice(price) {
  // Breakpoint here, examine call stack:
  //
  // Call Stack:
  // > formatPrice(undefined)     <- Current: price is undefined
  //   renderOrderItem(item)      <- Called from here
  //   OrderList.render()         <- Called from here
  //   App.componentDidMount()    <- Root

  return `$${price.toFixed(2)}`
}

// Click on "renderOrderItem" in call stack:
function renderOrderItem(item) {
  // Now we can see the problem:
  const price = item.price        // item.price is undefined
  return formatPrice(price)
  // Root cause: item object is missing price property
}

// Click on "OrderList.render" in call stack:
function render() {
  return items.map(item => renderOrderItem(item))
  // Inspect 'items': Contains objects without 'price' field
  // Bug: API response schema changed, missing price field
}
```

**Call stack debugging tips:**
- Click frames to jump to that point in execution
- Examine local variables at each frame level
- Identify unexpected callers or call patterns
- Find where bad data originated

Reference: [Cornell CS312 - Debugging Techniques](https://www.cs.cornell.edu/courses/cs312/2006fa/lectures/lec26.html)
