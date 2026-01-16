---
title: Use Custom Elements with Full Prop Support
impact: LOW-MEDIUM
impactDescription: enables seamless web component integration
tags: dom, custom-elements, web-components, interop
---

## Use Custom Elements with Full Prop Support

React 19 adds full support for custom elements, passing properties correctly instead of only attributes. Web components now work naturally with React.

**Incorrect (pre-React 19 workaround):**

```tsx
function MapWidget({ coordinates, onLocationSelect }: Props) {
  const mapRef = useRef<HTMLElement>(null)

  useEffect(() => {
    const map = mapRef.current
    if (map) {
      // Manual property setting
      (map as any).coordinates = coordinates;
      (map as any).addEventListener('locationselect', onLocationSelect)
    }
    return () => {
      (map as any)?.removeEventListener('locationselect', onLocationSelect)
    }
  }, [coordinates, onLocationSelect])

  return <custom-map ref={mapRef} />
}
```

**Correct (React 19 native support):**

```tsx
function MapWidget({ coordinates, onLocationSelect }: Props) {
  return (
    <custom-map
      coordinates={coordinates}           // Passed as property
      onlocationselect={onLocationSelect}  // Event handler attached
    />
  )
}
// React 19 automatically:
// - Passes complex objects as properties (not attributes)
// - Handles event listeners with on* naming
```

**With TypeScript:**

```tsx
// Declare custom element types
declare global {
  namespace JSX {
    interface IntrinsicElements {
      'custom-map': React.DetailedHTMLProps<
        React.HTMLAttributes<HTMLElement> & {
          coordinates: { lat: number; lng: number }
          onlocationselect?: (e: CustomEvent) => void
        },
        HTMLElement
      >
    }
  }
}

function MapWidget({ coordinates, onLocationSelect }: Props) {
  return (
    <custom-map
      coordinates={coordinates}
      onlocationselect={onLocationSelect}
    />
  )
}
```

Reference: [Custom Elements Support](https://react.dev/blog/2024/12/05/react-19#support-for-custom-elements)
