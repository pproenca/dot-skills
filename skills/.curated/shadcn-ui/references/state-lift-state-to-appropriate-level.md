---
title: Lift State to the Appropriate Level
impact: LOW-MEDIUM
impactDescription: prevents prop drilling and enables component communication
tags: state, lifting, props, context, composition
---

## Lift State to the Appropriate Level

Lift shared state to the lowest common ancestor of components that need it. Don't lift higher than necessary (causes unnecessary re-renders) or leave too low (causes prop drilling).

**Incorrect (state too low, prop drilling):**

```tsx
function ProductPage() {
  return (
    <div className="grid grid-cols-2 gap-8">
      <ProductGallery />
      <ProductDetails />
    </div>
  )
}

function ProductGallery() {
  const [selectedImage, setSelectedImage] = useState(0)
  // selectedImage needed by ProductDetails for zoom feature
  // but state is isolated in ProductGallery
}

function ProductDetails() {
  // No way to access selectedImage without prop drilling
}
```

**Correct (state at common ancestor):**

```tsx
function ProductPage() {
  const [selectedImageIndex, setSelectedImageIndex] = useState(0)

  return (
    <div className="grid grid-cols-2 gap-8">
      <ProductGallery
        selectedIndex={selectedImageIndex}
        onSelectImage={setSelectedImageIndex}
      />
      <ProductDetails selectedImageIndex={selectedImageIndex} />
    </div>
  )
}

function ProductGallery({
  selectedIndex,
  onSelectImage,
}: {
  selectedIndex: number
  onSelectImage: (index: number) => void
}) {
  return (
    <div className="space-y-4">
      <div className="aspect-square">
        <img src={images[selectedIndex].src} alt="" />
      </div>
      <div className="flex gap-2">
        {images.map((image, index) => (
          <Button
            key={image.id}
            variant={index === selectedIndex ? "default" : "outline"}
            onClick={() => onSelectImage(index)}
          >
            <img src={image.thumbnail} alt="" className="h-12 w-12" />
          </Button>
        ))}
      </div>
    </div>
  )
}
```

**When to use Context instead:**

```tsx
// When prop drilling goes beyond 2-3 levels
const SelectedImageContext = createContext<{
  selectedIndex: number
  setSelectedIndex: (index: number) => void
} | null>(null)

function ProductPage() {
  const [selectedIndex, setSelectedIndex] = useState(0)

  return (
    <SelectedImageContext.Provider value={{ selectedIndex, setSelectedIndex }}>
      <div className="grid grid-cols-2 gap-8">
        <ProductGallery />
        <ProductDetails />
      </div>
    </SelectedImageContext.Provider>
  )
}
```

Reference: [Lifting State Up](https://react.dev/learn/sharing-state-between-components)
