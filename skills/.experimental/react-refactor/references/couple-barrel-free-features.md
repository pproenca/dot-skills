---
title: Use Barrel-Free Feature Modules for Clean Dependencies
impact: MEDIUM
impactDescription: 200-800ms build time reduction, effective tree shaking
tags: couple, barrel-files, tree-shaking, build-performance
---

## Use Barrel-Free Feature Modules for Clean Dependencies

Large barrel `index.ts` files that re-export everything from a feature force bundlers to parse every module in the directory, even when the consumer uses one export. This defeats tree shaking and inflates dev server startup. Replacing catch-all barrels with direct imports and type-only re-exports preserves clean APIs without the build cost.

**Incorrect (barrel re-exports everything — bundler parses entire feature):**

```tsx
// features/analytics/index.ts — barrel that re-exports 20+ modules
export { AnalyticsDashboard } from "./AnalyticsDashboard";
export { AnalyticsChart } from "./AnalyticsChart";
export { AnalyticsTable } from "./AnalyticsTable";
export { AnalyticsFilters } from "./AnalyticsFilters";
export { useAnalyticsQuery } from "./useAnalyticsQuery";
export { useAnalyticsExport } from "./useAnalyticsExport";
export { formatMetric } from "./formatMetric";
export { aggregateTimeSeries } from "./aggregateTimeSeries";
export { parseAnalyticsResponse } from "./parseAnalyticsResponse";
// ... 12 more exports

// Consumer only needs formatMetric, but bundler loads everything
import { formatMetric } from "@/features/analytics";

export function MetricBadge({ value }: { value: number }) {
  return <span className="badge">{formatMetric(value)}</span>;
}
```

**Correct (direct imports with type-only re-exports):**

```tsx
// features/analytics/index.ts — types only, no runtime re-exports
export type { AnalyticsEvent } from "./analytics.types";
export type { TimeSeriesPoint } from "./analytics.types";

// Consumer imports the specific module directly
import { formatMetric } from "@/features/analytics/formatMetric";

export function MetricBadge({ value }: { value: number }) {
  return <span className="badge">{formatMetric(value)}</span>;
}

// Page-level component imports what it needs directly
import { AnalyticsDashboard } from "@/features/analytics/AnalyticsDashboard";
import { AnalyticsFilters } from "@/features/analytics/AnalyticsFilters";

export function AnalyticsPage() {
  return (
    <div>
      <AnalyticsFilters />
      <AnalyticsDashboard />
    </div>
  );
}
// Bundler only parses the files actually imported — tree shaking works correctly
```

Reference: [Marvin Hagemeister - Speeding up the JavaScript ecosystem: The barrel file debacle](https://marvinh.dev/blog/speeding-up-javascript-ecosystem-part-7/)
