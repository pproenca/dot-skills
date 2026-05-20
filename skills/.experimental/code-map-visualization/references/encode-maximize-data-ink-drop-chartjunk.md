---
title: Maximize Data-Ink and Drop Chartjunk
impact: HIGH
impactDescription: reduces non-data pixels competing with the map
tags: encode, data-ink, decluttering, tufte, chartjunk
---

## Maximize Data-Ink and Drop Chartjunk

Every pixel that is not encoding data competes with the pixels that are (Tufte's data-ink ratio). On a code map the cells are the data; heavy grid lines, drop shadows, gradient backgrounds, 3-D bevels, and decorative legends steal attention and, worse, add visual variation the eye reads as meaningful. Strip the non-data ink so the structure of the code stands out, not the frame around it.

**Incorrect (decoration competes with the cells):**

```typescript
ctx.shadowBlur = 12;                  // every cell drags a shadow -> visual noise
ctx.shadowColor = "rgba(0,0,0,.5)";
drawGrid(ctx, { lines: "heavy" });    // grid louder than the data
drawBeveledFrame(ctx);
```

**Correct (ink spent on data, not chrome):**

```typescript
ctx.shadowBlur = 0;
drawGrid(ctx, { lines: "hairline", color: "#eee" }); // present but recessive
drawCells(ctx, cells);                                // the cells are the figure
```

**When NOT to apply:**
- A subtle shadow or outline used *functionally* — to lift a selected cell off a busy basemap ([[color-control-contrast-against-basemap]]) — is data-ink, not chartjunk. The test is whether the ink carries information.

Reference: [Tufte, The Visual Display of Quantitative Information](https://www.edwardtufte.com/book/the-visual-display-of-quantitative-information/); [Munzner, Visualization Analysis & Design](https://www.cs.ubc.ca/~tmm/vadbook/)
