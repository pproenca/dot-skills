---
title: Leverage Automatic Hardware Acceleration
impact: HIGH
impactDescription: 60fps during heavy JS vs 0fps when main thread blocked
tags: anim, hardware-acceleration, gpu, performance, main-thread
---

## Leverage Automatic Hardware Acceleration

Motion automatically hardware-accelerates transform and opacity animations, running them on the compositor thread. This means animations continue smoothly even when JavaScript is busy. Avoid patterns that force animations back to the main thread.

**Incorrect (blocking main thread during animation):**

```tsx
import { motion } from "framer-motion";
import { useState } from "react";

function SearchResults() {
  const [results, setResults] = useState([]);

  const handleSearch = async () => {
    // Heavy computation runs while trying to animate
    const data = await fetchResults();
    const processed = data.map(item => expensiveTransform(item));  // Blocks main thread
    setResults(processed);
  };

  return (
    <div>
      <button onClick={handleSearch}>Search</button>
      {results.map((item, i) => (
        <motion.div
          key={item.id}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          style={{ backgroundColor: item.color }}  // Dynamic style forces main thread
          transition={{ delay: i * 0.1 }}
        >
          {item.name}
        </motion.div>
      ))}
    </div>
  );
}
```

**Correct (keeping animations on compositor):**

```tsx
import { motion } from "framer-motion";
import { useState, useDeferredValue } from "react";

function SearchResults() {
  const [results, setResults] = useState([]);
  const deferredResults = useDeferredValue(results);

  const handleSearch = async () => {
    const data = await fetchResults();
    setResults(data);  // Set raw data, defer processing
  };

  return (
    <div>
      <button onClick={handleSearch}>Search</button>
      {deferredResults.map((item, i) => (
        <motion.div
          key={item.id}
          className={`result-card result-${item.type}`}  // CSS class instead of dynamic style
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: i * 0.1 }}
        >
          {item.name}
        </motion.div>
      ))}
    </div>
  );
}
```

**Hardware-accelerated by default:**
- `x`, `y`, `z`
- `scale`, `scaleX`, `scaleY`
- `rotate`, `rotateX`, `rotateY`, `rotateZ`
- `opacity`
- `filter`

**Tips for keeping animations smooth:**
1. Use CSS classes instead of dynamic inline styles
2. Defer heavy computations with `useDeferredValue` or `requestIdleCallback`
3. Use `useTransition` for non-urgent state updates
4. Avoid reading layout (offsetWidth, getBoundingClientRect) during animations

Reference: [Framer Motion - Hardware Acceleration](https://motion.dev/docs/react-animation#hardware-acceleration)
