---
title: Use Card Semantic Parts for Content Organization
impact: HIGH
impactDescription: improves scannability and consistent styling
tags: comp, card, composition, semantic, layout
---

## Use Card Semantic Parts for Content Organization

Card components provide Header, Title, Description, Content, and Footer parts for consistent structure. Using raw divs loses semantic meaning and styling consistency.

**Incorrect (raw divs inside card):**

```tsx
import { Card } from "@/components/ui/card"

function ProductCard({ product }) {
  return (
    <Card className="p-4">
      <div className="font-bold text-lg mb-2">{product.name}</div>
      <div className="text-gray-500 text-sm">{product.description}</div>
      <div className="mt-4">{product.price}</div>
      <div className="mt-4">
        <button>Add to Cart</button>
      </div>
    </Card>
  )
  // Inconsistent spacing, manual styling, no semantic meaning
}
```

**Correct (semantic card parts):**

```tsx
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"

function ProductCard({ product }) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>{product.name}</CardTitle>
        <CardDescription>{product.description}</CardDescription>
      </CardHeader>
      <CardContent>
        <p className="text-2xl font-bold">{product.price}</p>
      </CardContent>
      <CardFooter>
        <Button className="w-full">Add to Cart</Button>
      </CardFooter>
    </Card>
  )
}
```

**Benefits:**
- Consistent padding and spacing across all cards
- Theme-aware styling (uses CSS variables)
- Predictable structure for team members

Reference: [shadcn/ui Card](https://ui.shadcn.com/docs/components/card)
