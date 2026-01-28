---
title: Use Dynamic Imports for Large Features
impact: CRITICAL
impactDescription: 30-50% smaller initial bundle
tags: bundle, dynamic-import, code-splitting, lazy-loading, metro
---

## Use Dynamic Imports for Large Features

Load heavy features only when needed using dynamic imports. This keeps the initial bundle small and startup fast.

**Incorrect (all features in initial bundle):**

```tsx
// screens/Dashboard.tsx - everything imported upfront
import { LineChart } from 'victory-native'        // 100KB
import { PDFViewer } from 'react-native-pdf'      // 80KB
import { MarkdownEditor } from './MarkdownEditor' // 50KB

export default function Dashboard() {
  const [activeTab, setActiveTab] = useState('overview')

  return (
    <View>
      {activeTab === 'overview' && <Overview />}
      {activeTab === 'charts' && <LineChart />}      {/* Rarely used */}
      {activeTab === 'docs' && <PDFViewer />}        {/* Rarely used */}
      {activeTab === 'notes' && <MarkdownEditor />}  {/* Rarely used */}
    </View>
  )
}
// All 230KB loaded at startup
```

**Correct (dynamic imports for heavy features):**

```tsx
// screens/Dashboard.tsx - lazy load heavy components
import { Suspense, lazy, useState } from 'react'
import { ActivityIndicator, View } from 'react-native'

const LazyChart = lazy(() => import('./ChartSection'))
const LazyPDFViewer = lazy(() => import('./PDFSection'))
const LazyMarkdownEditor = lazy(() => import('./MarkdownSection'))

function LoadingFallback() {
  return <ActivityIndicator size="large" />
}

export default function Dashboard() {
  const [activeTab, setActiveTab] = useState('overview')

  return (
    <View>
      {activeTab === 'overview' && <Overview />}
      {activeTab === 'charts' && (
        <Suspense fallback={<LoadingFallback />}>
          <LazyChart />
        </Suspense>
      )}
      {activeTab === 'docs' && (
        <Suspense fallback={<LoadingFallback />}>
          <LazyPDFViewer />
        </Suspense>
      )}
      {activeTab === 'notes' && (
        <Suspense fallback={<LoadingFallback />}>
          <LazyMarkdownEditor />
        </Suspense>
      )}
    </View>
  )
}
// Only ~20KB loaded at startup, features load on demand
```

**With Expo Router (automatic code splitting):**

```tsx
// app/(tabs)/dashboard/index.tsx - loads immediately
export default function DashboardOverview() {
  return <Overview />
}

// app/(tabs)/dashboard/charts.tsx - loads on navigation
export default function ChartsScreen() {
  const { LineChart } = require('victory-native')
  return <LineChart />
}
```

**Features to dynamically import:**
- Charting libraries
- PDF viewers/generators
- Rich text editors
- Camera/video features
- Maps
- Admin-only screens

Reference: [React Lazy Documentation](https://react.dev/reference/react/lazy)
