---
title: Lazy Load Heavy Components
impact: LOW-MEDIUM
impactDescription: reduces initial memory footprint
tags: mem, lazy-loading, code-splitting, memory, performance
---

## Lazy Load Heavy Components

Heavy components that aren't immediately visible should load on demand to reduce initial memory usage.

**Incorrect (all components loaded upfront):**

```tsx
// All imported at module load time
import { Charts } from 'victory-native'        // 500KB
import { PDFView } from 'react-native-pdf'     // 400KB
import { VideoPlayer } from 'expo-av'          // 300KB
import { MapView } from 'react-native-maps'    // 600KB

function FeatureScreen({ activeTab }) {
  return (
    <View>
      <TabBar />
      {/* All components instantiated even if not shown */}
      {activeTab === 'charts' && <Charts />}
      {activeTab === 'pdf' && <PDFView />}
      {activeTab === 'video' && <VideoPlayer />}
      {activeTab === 'map' && <MapView />}
    </View>
  )
}
// 1.8MB loaded before user sees anything
```

**Correct (lazy load on demand):**

```tsx
import { Suspense, lazy, useState } from 'react'
import { ActivityIndicator } from 'react-native'

// Lazy imports - code split, loaded on demand
const LazyCharts = lazy(() => import('./ChartSection'))
const LazyPDFView = lazy(() => import('./PDFSection'))
const LazyVideoPlayer = lazy(() => import('./VideoSection'))
const LazyMapView = lazy(() => import('./MapSection'))

function FeatureScreen({ initialTab = 'charts' }) {
  const [activeTab, setActiveTab] = useState(initialTab)

  // Only render the active component
  const renderContent = () => {
    switch (activeTab) {
      case 'charts':
        return <LazyCharts />
      case 'pdf':
        return <LazyPDFView />
      case 'video':
        return <LazyVideoPlayer />
      case 'map':
        return <LazyMapView />
      default:
        return null
    }
  }

  return (
    <View style={{ flex: 1 }}>
      <TabBar activeTab={activeTab} onSelect={setActiveTab} />
      <Suspense fallback={<LoadingScreen />}>
        {renderContent()}
      </Suspense>
    </View>
  )
}
// Only active tab's code loaded into memory
```

**Preload before switching tabs:**

```tsx
function FeatureScreen() {
  const [activeTab, setActiveTab] = useState('charts')

  // Preload next tab on hover/long press
  const preloadTab = useCallback((tab: string) => {
    switch (tab) {
      case 'charts':
        import('./ChartSection')
        break
      case 'pdf':
        import('./PDFSection')
        break
      // ...
    }
  }, [])

  return (
    <View style={{ flex: 1 }}>
      <TabBar
        activeTab={activeTab}
        onSelect={setActiveTab}
        onHover={preloadTab}  // Preload on hover
      />
      <Suspense fallback={<LoadingScreen />}>
        <LazyContent tab={activeTab} />
      </Suspense>
    </View>
  )
}
```

**Unmount unused heavy components:**

```tsx
function VideoScreen() {
  const [isPlaying, setIsPlaying] = useState(false)

  return (
    <View>
      <TouchableOpacity onPress={() => setIsPlaying(true)}>
        {/* Show thumbnail until play */}
        <Image source={thumbnailUrl} style={styles.thumbnail} />
        <PlayButton />
      </TouchableOpacity>

      {/* Only mount video player when needed */}
      {isPlaying && (
        <VideoPlayer
          source={videoUrl}
          onEnd={() => setIsPlaying(false)}
        />
      )}
    </View>
  )
}
// Video player memory released when not playing
```

**Use InteractionManager for deferred loading:**

```tsx
import { InteractionManager } from 'react-native'

function HeavyScreen() {
  const [isReady, setIsReady] = useState(false)

  useEffect(() => {
    // Wait for navigation animation to complete
    const handle = InteractionManager.runAfterInteractions(() => {
      setIsReady(true)
    })

    return () => handle.cancel()
  }, [])

  if (!isReady) {
    return <SkeletonScreen />
  }

  return <HeavyContent />
}
// Smooth navigation, then load heavy content
```

**Memory-conscious conditional rendering:**

```tsx
function OptimizedScreen({ showAdvanced }) {
  // Completely unmount when not needed
  return (
    <View>
      <BasicContent />
      {showAdvanced ? (
        <Suspense fallback={<Spinner />}>
          <LazyAdvancedContent />
        </Suspense>
      ) : null}
    </View>
  )
}
// Advanced content memory freed when hidden
```

Reference: [React Lazy Documentation](https://react.dev/reference/react/lazy)
