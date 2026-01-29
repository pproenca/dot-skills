---
title: Animate viewBox for Smooth Zoom Effects
impact: LOW-MEDIUM
impactDescription: crisp zoom without scaling blur
tags: svg, viewbox, zoom, animation
---

## Animate viewBox for Smooth Zoom Effects

Animating the SVG `viewBox` attribute creates true zoom effects that maintain crisp vector quality at any zoom level. Using CSS `scale` transforms on SVG containers causes blurry edges and pixelation because it scales the rasterized output rather than the vector data.

**Incorrect (scale transform causes blur):**

```tsx
import { motion } from "framer-motion";

function ZoomableChart({ data }: ChartProps) {
  const [isZoomed, setIsZoomed] = useState(false);

  return (
    <motion.svg
      viewBox="0 0 400 300"
      width={400}
      height={300}
      animate={{ scale: isZoomed ? 2 : 1 }}  // Scales rasterized output, causes blur
      style={{ transformOrigin: "center" }}
      onClick={() => setIsZoomed(!isZoomed)}
    >
      <ChartContent data={data} />
    </motion.svg>
  );
}
```

**Correct (viewBox animation maintains vector quality):**

```tsx
import { motion } from "framer-motion";

function ZoomableChart({ data }: ChartProps) {
  const [isZoomed, setIsZoomed] = useState(false);

  return (
    <motion.svg
      width={400}
      height={300}
      animate={{
        viewBox: isZoomed ? "100 75 200 150" : "0 0 400 300",  // True vector zoom, always crisp
      }}
      transition={{ duration: 0.5 }}
      onClick={() => setIsZoomed(!isZoomed)}
    >
      <ChartContent data={data} />
    </motion.svg>
  );
}
```

Reference: [MDN - SVG viewBox](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/viewBox)
