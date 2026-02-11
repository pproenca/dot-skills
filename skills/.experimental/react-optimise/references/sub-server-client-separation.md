---
title: Separate Server State from Client State Management
impact: MEDIUM-HIGH
impactDescription: eliminates manual cache invalidation, reduces state management code by 40%
tags: sub, server-state, client-state, tanstack-query
---

## Separate Server State from Client State Management

Server state is asynchronous, cached, and owned by a remote source. Client state is synchronous, ephemeral, and owned by the browser. Mixing both in a single store forces manual cache invalidation, loading state tracking, and stale-while-revalidate logic that a dedicated server-state library handles automatically.

**Incorrect (manual cache management mixed with UI state):**

```tsx
interface AppState {
  products: Product[]
  isLoadingProducts: boolean
  productsError: string | null
  lastFetchedAt: number | null
  searchQuery: string
  selectedCategory: string
}

function useProductStore() {
  const [state, setState] = useState<AppState>({
    products: [],
    isLoadingProducts: false,
    productsError: null,
    lastFetchedAt: null,
    searchQuery: "",
    selectedCategory: "all",
  })

  const fetchProducts = async () => {
    setState((prev) => ({ ...prev, isLoadingProducts: true }))
    try {
      const products = await api.getProducts()
      setState((prev) => ({
        ...prev,
        products,
        isLoadingProducts: false,
        lastFetchedAt: Date.now(),
      }))
    } catch (error) {
      setState((prev) => ({
        ...prev,
        isLoadingProducts: false,
        productsError: (error as Error).message,
      }))
    }
  }

  // Must manually refetch after mutations
  const addProduct = async (product: NewProduct) => {
    await api.createProduct(product)
    await fetchProducts() // manual cache invalidation
  }

  return { ...state, fetchProducts, addProduct }
}
```

**Correct (dedicated server-state library + local UI state):**

```tsx
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"

function useProductCatalog() {
  const queryClient = useQueryClient()
  const [searchQuery, setSearchQuery] = useState("")
  const [selectedCategory, setSelectedCategory] = useState("all")

  const productsQuery = useQuery({
    queryKey: ["products"],
    queryFn: api.getProducts,
    staleTime: 30_000, // automatic background refetch after 30s
  })

  const addProductMutation = useMutation({
    mutationFn: api.createProduct,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["products"] })
    },
  })

  return {
    products: productsQuery.data ?? [],
    isLoading: productsQuery.isLoading,
    error: productsQuery.error,
    searchQuery,
    setSearchQuery,
    selectedCategory,
    setSelectedCategory,
    addProduct: addProductMutation.mutate,
  }
}
```

Reference: [TanStack Query — Comparison](https://tanstack.com/query/latest/docs/framework/react/comparison)
