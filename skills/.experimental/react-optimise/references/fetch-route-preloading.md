---
title: Preload Data at Route Level Before Component Mounts
impact: HIGH
impactDescription: 200-1000ms eliminated by starting fetch before render
tags: fetch, preloading, router, loaders, latency
---

## Preload Data at Route Level Before Component Mounts

When data fetching starts inside a component's useEffect, the browser must download JavaScript, parse it, render the component, and only then begin the network request. Router-level loaders start fetching data as soon as the route matches, overlapping network time with component loading.

**Incorrect (fetch starts after component mounts — wasted render cycle):**

```tsx
import { useEffect, useState } from "react"
import { useParams } from "react-router-dom"

function PropertyListing() {
  const { propertyId } = useParams<{ propertyId: string }>()
  const [property, setProperty] = useState<Property | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // fetch starts AFTER mount — user sees spinner during network round trip
    fetchProperty(propertyId!).then((data) => {
      setProperty(data)
      setLoading(false)
    })
  }, [propertyId])

  if (loading) return <ListingSkeleton />

  return (
    <div>
      <PropertyHeader property={property!} />
      <PropertyGallery images={property!.images} />
      <PropertyDetails property={property!} />
    </div>
  )
}
```

**Correct (fetch starts at route match — overlaps with code loading):**

```tsx
import { useLoaderData, type LoaderFunctionArgs } from "react-router-dom"

export async function propertyLoader({ params }: LoaderFunctionArgs) {
  return fetchProperty(params.propertyId!) // starts immediately on navigation
}

function PropertyListing() {
  const property = useLoaderData() as Property

  return (
    <div>
      <PropertyHeader property={property} />
      <PropertyGallery images={property.images} />
      <PropertyDetails property={property} />
    </div>
  )
}

// Route configuration
const routes = [
  {
    path: "/properties/:propertyId",
    element: <PropertyListing />,
    loader: propertyLoader,
  },
]
```

Reference: [React Router — Data Loading](https://reactrouter.com/en/main/route/loader)
