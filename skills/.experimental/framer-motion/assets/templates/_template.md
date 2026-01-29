---
title: Rule Title Here
impact: MEDIUM
impactDescription: quantified impact (e.g., "2-10x improvement", "eliminates re-renders")
tags: category-prefix, technique, related-concept
---

## Rule Title Here

Brief explanation (1-3 sentences) of WHY this matters. Focus on performance implications and the cost of the incorrect approach.

**Incorrect (description of the problem/cost):**

```tsx
// Component showing the anti-pattern
function ExampleComponent() {
  // Comment on the problematic line explaining the cost
  const problematicValue = expensiveApproach();

  return (
    <motion.div animate={{ opacity: 1 }}>
      {/* Realistic component structure */}
    </motion.div>
  );
}
```

**Correct (description of the benefit/solution):**

```tsx
// Same component with the optimized approach
function ExampleComponent() {
  // Comment explaining the benefit
  const optimizedValue = efficientApproach();

  return (
    <motion.div animate={{ opacity: 1 }}>
      {/* Same structure, minimal diff from incorrect */}
    </motion.div>
  );
}
```

**When NOT to use this pattern:**
- Exception 1: When the simpler approach is sufficient
- Exception 2: When the optimization adds unnecessary complexity

Reference: [Framer Motion Documentation](https://motion.dev/docs)
