---
title: Instrument Real User Monitoring with web-vitals
impact: HIGH
impactDescription: enables data-driven optimization targeting real bottlenecks
tags: cwv, rum, web-vitals, monitoring, metrics
---

## Instrument Real User Monitoring with web-vitals

Lab metrics from Lighthouse measure synthetic conditions that miss device diversity, network variance, and real user interaction patterns. Real User Monitoring (RUM) captures actual CWV scores from production users, revealing bottlenecks that lab tools cannot reproduce.

**Incorrect (no production metrics, relying only on lab tests):**

```tsx
// No performance monitoring in production
// Developers run Lighthouse locally and assume scores reflect real users

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/listings/:id" element={<ListingPage />} />
        <Route path="/account" element={<AccountPage />} />
      </Routes>
    </Router>
  )
}

// "Lighthouse says 95 — ship it"
// Real users on 3G Android devices experience 4s LCP and 800ms INP
```

**Correct (RUM captures real CWV scores per route):**

```tsx
import { onCLS, onINP, onLCP, onFCP, onTTFB, type Metric } from "web-vitals"

function reportWebVital(metric: Metric) {
  const payload = {
    name: metric.name,
    value: metric.value,
    rating: metric.rating, // "good" | "needs-improvement" | "poor"
    delta: metric.delta,
    id: metric.id,
    navigationType: metric.navigationType,
    route: window.location.pathname,
  }
  navigator.sendBeacon("/api/analytics/vitals", JSON.stringify(payload))
}

function initWebVitals() {
  onCLS(reportWebVital)
  onINP(reportWebVital)
  onLCP(reportWebVital)
  onFCP(reportWebVital)
  onTTFB(reportWebVital)
}

function App() {
  useEffect(() => {
    initWebVitals()
  }, [])

  return (
    <Router>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/listings/:id" element={<ListingPage />} />
        <Route path="/account" element={<AccountPage />} />
      </Routes>
    </Router>
  )
}
```

Reference: [web-vitals Library](https://github.com/GoogleChrome/web-vitals)
