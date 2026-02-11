---
title: Use Dynamic Imports for Heavy Libraries
impact: CRITICAL
impactDescription: reduces critical-path JS by 100-500KB
tags: bundle, dynamic-import, lazy-loading, libraries
---

## Use Dynamic Imports for Heavy Libraries

Large visualization, PDF, rich-text, and charting libraries add hundreds of kilobytes to the main bundle even when they render in a single feature. Dynamic `import()` defers these libraries to the moment the user actually needs them, keeping the critical rendering path lean.

**Incorrect (static imports load heavy libraries upfront):**

```tsx
import { Chart } from "chart.js/auto" // 180KB
import { jsPDF } from "jspdf" // 280KB
import MarkdownIt from "markdown-it" // 95KB

function OrderReport({ orders }: { orders: Order[] }) {
  const [showChart, setShowChart] = useState(false)

  const handleExportPDF = () => {
    const pdf = new jsPDF()
    pdf.text("Order Report", 10, 10)
    pdf.save("report.pdf")
  }

  return (
    <div>
      <button onClick={() => setShowChart(true)}>Show Chart</button>
      <button onClick={handleExportPDF}>Export PDF</button>
      {showChart && <Chart type="bar" data={formatChartData(orders)} />}
    </div>
  )
}
```

**Correct (dynamic imports load libraries on demand):**

```tsx
import { lazy, Suspense, useState } from "react"

const OrderChart = lazy(() => import("./OrderChart"))

function OrderReport({ orders }: { orders: Order[] }) {
  const [showChart, setShowChart] = useState(false)

  const handleExportPDF = async () => {
    const { jsPDF } = await import("jspdf") // 280KB loaded only when user clicks
    const pdf = new jsPDF()
    pdf.text("Order Report", 10, 10)
    pdf.save("report.pdf")
  }

  return (
    <div>
      <button onClick={() => setShowChart(true)}>Show Chart</button>
      <button onClick={handleExportPDF}>Export PDF</button>
      {showChart && (
        <Suspense fallback={<ChartSkeleton />}>
          <OrderChart orders={orders} />
        </Suspense>
      )}
    </div>
  )
}
```

Reference: [MDN — Dynamic import()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/import)
