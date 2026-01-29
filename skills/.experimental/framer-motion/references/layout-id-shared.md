---
title: Use layoutId for Shared Element Transitions
impact: HIGH
impactDescription: 10× less code for cross-component transitions
tags: layout, layoutId, shared-element, transition
---

## Use layoutId for Shared Element Transitions

When an element should visually transition from one component to another (like a list item expanding to a modal), use matching `layoutId` props. Framer Motion automatically animates between the two positions using the FLIP technique.

**Incorrect (manual animation with opacity/scale):**

```tsx
function ProductGrid({ products, onSelect }: Props) {
  const [selected, setSelected] = useState<Product | null>(null);

  return (
    <>
      <div className="grid">
        {products.map((product) => (
          <motion.div
            key={product.id}
            className="product-card"
            onClick={() => setSelected(product)}
            animate={{ opacity: selected ? 0.5 : 1 }} // Fade effect, not smooth
          >
            <img src={product.image} alt={product.name} />
          </motion.div>
        ))}
      </div>
      <AnimatePresence>
        {selected && (
          <motion.div
            className="product-modal"
            initial={{ opacity: 0, scale: 0.8 }} // Abrupt appearance
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.8 }}
          >
            <img src={selected.image} alt={selected.name} />
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
```

**Correct (layoutId for automatic shared element transition):**

```tsx
function ProductGrid({ products, onSelect }: Props) {
  const [selected, setSelected] = useState<Product | null>(null);

  return (
    <>
      <div className="grid">
        {products.map((product) => (
          <motion.div
            key={product.id}
            layoutId={`product-${product.id}`} // Matching layoutId
            className="product-card"
            onClick={() => setSelected(product)}
          >
            <motion.img
              layoutId={`image-${product.id}`} // Image also transitions
              src={product.image}
              alt={product.name}
            />
          </motion.div>
        ))}
      </div>
      <AnimatePresence>
        {selected && (
          <motion.div
            layoutId={`product-${selected.id}`} // Same layoutId - animates between!
            className="product-modal"
          >
            <motion.img
              layoutId={`image-${selected.id}`}
              src={selected.image}
              alt={selected.name}
            />
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
```

**Key points:**
- Only one element with a given `layoutId` should be mounted at a time
- Wrap exiting elements in `AnimatePresence` for smooth exit transitions
- Nest multiple `layoutId` elements for complex shared transitions (card + image + title)
- Use `LayoutGroup` when `layoutId` elements are in different component trees

Reference: [Framer Motion - Shared Layout Animations](https://www.framer.com/motion/layout-animations/#shared-layout-animations)
