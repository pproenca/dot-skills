---
title: Build Chart Data from ChartDataPoint Arrays, Not Raw Numbers
impact: MEDIUM-HIGH
impactDescription: enables per-point colour, native axis labels, and chart-type switching without restructuring data
tags: display, chart, dataPoint, swift-charts
---

## Build Chart Data from ChartDataPoint Arrays, Not Raw Numbers

`Chart` consumes a `ChartDataPoint[]` shaped as `{ x, y, color? }`. Building this structured representation up front lets the native Swift Charts pipeline produce native axes, legends, and gridlines — and gives you a per-point colour hook for highlighting outliers or category coding. Inlining raw numbers and recomputing labels yourself misses the native renderer's affordances entirely.

**Incorrect (parallel x/y arrays — no per-point colour, awkward label mapping):**

```tsx
import { Host, Chart } from '@expo/ui/swift-ui';

const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
const values = [82, 91, 73, 88, 95];

<Host matchContents>
  <Chart
    type="bar"
    data={values.map((y, i) => ({ x: labels[i], y }))}
  />
</Host>
```

**Correct (ChartDataPoint with colour highlighting the lowest day):**

```tsx
import { Host, Chart, type ChartDataPoint } from '@expo/ui/swift-ui';

const dailyEngagement: ChartDataPoint[] = [
  { x: 'Mon', y: 82 },
  { x: 'Tue', y: 91 },
  { x: 'Wed', y: 73, color: '#FF9500' },
  { x: 'Thu', y: 88 },
  { x: 'Fri', y: 95 },
];

<Host matchContents>
  <Chart type="bar" data={dailyEngagement} />
</Host>
```

Reference: [@expo/ui Chart source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/Chart/index.tsx)
