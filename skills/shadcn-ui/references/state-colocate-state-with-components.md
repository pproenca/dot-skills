---
title: Colocate State with the Components That Use It
impact: LOW-MEDIUM
impactDescription: improves code organization and reduces unnecessary coupling
tags: state, colocation, organization, local-state, encapsulation
---

## Colocate State with the Components That Use It

Keep state as close as possible to where it's used. Don't put all state in a global store or lift it unnecessarily.

**Incorrect (all state in global store):**

```tsx
// store.ts
interface GlobalState {
  user: User | null
  theme: "light" | "dark"
  sidebarOpen: boolean
  accordionOpenItems: string[]
  selectedTabIndex: number
  searchQuery: string
  filterOptions: FilterOptions
  // UI state mixed with app state
}

function Sidebar() {
  const { sidebarOpen, accordionOpenItems, setSidebarOpen, setAccordionOpenItems } = useGlobalStore()
  // Component depends on global store for purely local UI state
}
```

**Correct (colocated local state):**

```tsx
function Sidebar() {
  // Local UI state - only this component cares
  const [accordionOpen, setAccordionOpen] = useState<string[]>(["nav"])

  return (
    <Accordion type="multiple" value={accordionOpen} onValueChange={setAccordionOpen}>
      <AccordionItem value="nav">
        <AccordionTrigger>Navigation</AccordionTrigger>
        <AccordionContent>
          <NavLinks />
        </AccordionContent>
      </AccordionItem>
      <AccordionItem value="settings">
        <AccordionTrigger>Settings</AccordionTrigger>
        <AccordionContent>
          <SettingsLinks />
        </AccordionContent>
      </AccordionItem>
    </Accordion>
  )
}

// Global store only for truly shared state
interface GlobalState {
  user: User | null
  theme: "light" | "dark"
  // Only app-level state that multiple components need
}
```

**State location decision tree:**

```tsx
// 1. Only used in one component? → useState in that component
function SearchInput() {
  const [query, setQuery] = useState("")
  // ...
}

// 2. Shared by siblings? → Lift to parent
function ProductPage() {
  const [selectedVariant, setSelectedVariant] = useState("default")
  return (
    <>
      <VariantSelector value={selectedVariant} onChange={setSelectedVariant} />
      <PriceDisplay variant={selectedVariant} />
    </>
  )
}

// 3. Needed across distant components? → Context or global store
const CartContext = createContext<CartState | null>(null)
function CartProvider({ children }) {
  const [items, setItems] = useState<CartItem[]>([])
  // Cart used by Header, ProductPage, Checkout, etc.
}

// 4. Server state (fetched data)? → React Query/SWR
function UserProfile() {
  const { data: user } = useQuery(["user"], fetchUser)
  // Server state managed separately from UI state
}
```

Reference: [Kent C. Dodds - Colocation](https://kentcdodds.com/blog/colocation)
