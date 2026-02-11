---
title: Avoid Object and Array Dependencies in Custom Hooks
impact: HIGH
impactDescription: prevents effect re-execution on every render
tags: hook, dependencies, referential-equality, primitives
---

## Avoid Object and Array Dependencies in Custom Hooks

Object and array literals in dependency arrays fail referential equality on every render, even when their contents are identical. The effect re-executes every render because `{} !== {}`. Extracting primitive values from objects or using stable references prevents phantom re-executions.

**Incorrect (object dep — effect fires every render):**

```tsx
interface MapViewport {
  latitude: number;
  longitude: number;
  zoom: number;
}

function useMapMarkers(viewport: MapViewport) {
  const [markers, setMarkers] = useState<Marker[]>([]);

  useEffect(() => {
    // Fires every render — viewport is a new object reference each time
    fetchMarkersInBounds(viewport).then(setMarkers);
  }, [viewport]);

  return markers;
}

function MapContainer() {
  const [viewport, setViewport] = useState<MapViewport>({ latitude: 51.5074, longitude: -0.1278, zoom: 12 });

  // Even when viewport values haven't changed, passing the object creates a new reference
  const markers = useMapMarkers(viewport);
  return <Map viewport={viewport} markers={markers} onMove={setViewport} />;
}
```

**Correct (primitive deps — effect fires only when values change):**

```tsx
function useMapMarkers(viewport: MapViewport) {
  const [markers, setMarkers] = useState<Marker[]>([]);
  const { latitude, longitude, zoom } = viewport;

  useEffect(() => {
    // Fires only when lat, lng, or zoom actually changes
    fetchMarkersInBounds({ latitude, longitude, zoom }).then(setMarkers);
  }, [latitude, longitude, zoom]);

  return markers;
}

function MapContainer() {
  const [viewport, setViewport] = useState<MapViewport>({ latitude: 51.5074, longitude: -0.1278, zoom: 12 });

  const markers = useMapMarkers(viewport);
  return <Map viewport={viewport} markers={markers} onMove={setViewport} />;
}
```

Reference: [React Docs - Removing Unnecessary Dependencies](https://react.dev/learn/removing-effect-dependencies)
