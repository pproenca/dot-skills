---
title: Optimize iOS Text Rendering
impact: LOW-MEDIUM
impactDescription: faster text layout on iOS
tags: platform, ios, text, rendering
---

## Optimize iOS Text Rendering

iOS Text components can be expensive to render, especially with custom fonts or complex layouts. Use `allowFontScaling={false}` for fixed-size text and avoid unnecessary text nesting.

**Incorrect (nested Text, slow layout):**

```typescript
// components/PriceDisplay.tsx
export function PriceDisplay({ price, currency }: Props) {
  return (
    <View>
      <Text style={styles.price}>
        <Text style={styles.currency}>{currency}</Text>
        <Text style={styles.amount}>{price.toFixed(2)}</Text>
        <Text style={styles.decimal}>.{(price % 1).toFixed(2).slice(2)}</Text>
      </Text>
    </View>
  );
}
// Nested Text requires multiple layout passes
```

**Correct (flat structure, optimized):**

```typescript
// components/PriceDisplay.tsx
export function PriceDisplay({ price, currency }: Props) {
  const formattedPrice = `${currency}${price.toFixed(2)}`;

  return (
    <Text
      style={styles.price}
      allowFontScaling={false}  // Skip accessibility scaling calculation
      numberOfLines={1}         // Single line, skip line break calculation
    >
      {formattedPrice}
    </Text>
  );
}
// Single Text node, minimal layout calculation
```

**When to use `allowFontScaling={false}`:**
- Icons and logos
- Fixed-size UI elements
- Performance-critical list items

**Note:** Don't disable font scaling for body text—accessibility matters.

Reference: [Text Component](https://reactnative.dev/docs/text)
