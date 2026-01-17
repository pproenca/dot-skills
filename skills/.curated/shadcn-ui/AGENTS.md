# shadcn/ui

**Version 0.1.0**  
shadcn/ui Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive best practices guide for shadcn/ui applications, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (component architecture, accessibility preservation) to incremental (state management). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Component Architecture](#1-component-architecture) — **CRITICAL**
   - 1.1 [Extend Variants with Class Variance Authority](#11-extend-variants-with-class-variance-authority)
   - 1.2 [Forward Refs for Composable Components](#12-forward-refs-for-composable-components)
   - 1.3 [Isolate Component Variants from Base Styles](#13-isolate-component-variants-from-base-styles)
   - 1.4 [Preserve Radix Primitive Structure](#14-preserve-radix-primitive-structure)
   - 1.5 [Use asChild for Custom Trigger Elements](#15-use-aschild-for-custom-trigger-elements)
   - 1.6 [Use cn() for Safe Class Merging](#16-use-cn-for-safe-class-merging)
2. [Accessibility Preservation](#2-accessibility-preservation) — **CRITICAL**
   - 2.1 [Ensure Color Contrast Meets WCAG Standards](#21-ensure-color-contrast-meets-wcag-standards)
   - 2.2 [Maintain Focus Management in Modals](#22-maintain-focus-management-in-modals)
   - 2.3 [Preserve ARIA Attributes from Radix Primitives](#23-preserve-aria-attributes-from-radix-primitives)
   - 2.4 [Preserve Keyboard Navigation Patterns](#24-preserve-keyboard-navigation-patterns)
   - 2.5 [Provide Screen Reader Labels for Icon Buttons](#25-provide-screen-reader-labels-for-icon-buttons)
3. [Styling & Theming](#3-styling-theming) — **HIGH**
   - 3.1 [Apply Mobile-First Responsive Design](#31-apply-mobile-first-responsive-design)
   - 3.2 [Avoid !important Overrides](#32-avoid-important-overrides)
   - 3.3 [Extend Tailwind Theme for Custom Design Tokens](#33-extend-tailwind-theme-for-custom-design-tokens)
   - 3.4 [Support Dark Mode with CSS Variables](#34-support-dark-mode-with-css-variables)
   - 3.5 [Use Consistent Spacing Scale](#35-use-consistent-spacing-scale)
   - 3.6 [Use CSS Variables for Theme Colors](#36-use-css-variables-for-theme-colors)
4. [Form Patterns](#4-form-patterns) — **HIGH**
   - 4.1 [Handle Async Validation with Debouncing](#41-handle-async-validation-with-debouncing)
   - 4.2 [Reset Form State Correctly After Submission](#42-reset-form-state-correctly-after-submission)
   - 4.3 [Show Validation Errors at Appropriate Times](#43-show-validation-errors-at-appropriate-times)
   - 4.4 [Use React Hook Form with shadcn/ui Forms](#44-use-react-hook-form-with-shadcnui-forms)
   - 4.5 [Use Zod for Schema Validation](#45-use-zod-for-schema-validation)
5. [Data Display](#5-data-display) — **MEDIUM-HIGH**
   - 5.1 [Paginate Large Datasets Server-Side](#51-paginate-large-datasets-server-side)
   - 5.2 [Provide Actionable Empty States](#52-provide-actionable-empty-states)
   - 5.3 [Use Skeleton Components for Loading States](#53-use-skeleton-components-for-loading-states)
   - 5.4 [Use TanStack Table for Complex Data Tables](#54-use-tanstack-table-for-complex-data-tables)
   - 5.5 [Virtualize Large Lists and Tables](#55-virtualize-large-lists-and-tables)
6. [Component Composition](#6-component-composition) — **MEDIUM**
   - 6.1 [Combine Command with Popover for Searchable Selects](#61-combine-command-with-popover-for-searchable-selects)
   - 6.2 [Compose with Compound Component Patterns](#62-compose-with-compound-component-patterns)
   - 6.3 [Create Reusable Form Field Components](#63-create-reusable-form-field-components)
   - 6.4 [Nest Dialogs with Proper Focus Management](#64-nest-dialogs-with-proper-focus-management)
   - 6.5 [Use Drawer for Mobile Modal Interactions](#65-use-drawer-for-mobile-modal-interactions)
   - 6.6 [Use Slot Pattern for Flexible Content Areas](#66-use-slot-pattern-for-flexible-content-areas)
7. [Performance Optimization](#7-performance-optimization) — **MEDIUM**
   - 7.1 [Avoid Unnecessary Re-renders in Forms](#71-avoid-unnecessary-re-renders-in-forms)
   - 7.2 [Debounce Search and Filter Inputs](#72-debounce-search-and-filter-inputs)
   - 7.3 [Lazy Load Heavy Components](#73-lazy-load-heavy-components)
   - 7.4 [Memoize Expensive Component Renders](#74-memoize-expensive-component-renders)
   - 7.5 [Optimize Icon Imports from Lucide](#75-optimize-icon-imports-from-lucide)
8. [State Management](#8-state-management) — **LOW-MEDIUM**
   - 8.1 [Colocate State with the Components That Use It](#81-colocate-state-with-the-components-that-use-it)
   - 8.2 [Lift State to the Appropriate Level](#82-lift-state-to-the-appropriate-level)
   - 8.3 [Prefer Uncontrolled Components for Simple Inputs](#83-prefer-uncontrolled-components-for-simple-inputs)
   - 8.4 [Use Controlled State for Dialogs Triggered Externally](#84-use-controlled-state-for-dialogs-triggered-externally)

---

## 1. Component Architecture

**Impact: CRITICAL**

Proper component structure and Radix primitive usage is foundational - architectural mistakes cascade to every consumer and are costly to fix.

### 1.1 Extend Variants with Class Variance Authority

**Impact: CRITICAL (maintains type safety and design consistency)**

When adding new variants to shadcn/ui components, extend the existing CVA configuration rather than using conditional className logic. This maintains type safety and design system consistency.

**Incorrect (inline conditional classes):**

```tsx
function StatusBadge({ status }: { status: string }) {
  return (
    <Badge
      className={
        status === "success"
          ? "bg-green-500"
          : status === "warning"
            ? "bg-yellow-500"
            : status === "error"
              ? "bg-red-500"
              : ""
      }
    >
      {status}
    </Badge>
  )
}
// No type safety, classes can conflict with base Badge styles
```

**Correct (extended CVA configuration):**

```tsx
import { cva, type VariantProps } from "class-variance-authority"

const statusBadgeVariants = cva(
  "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold",
  {
    variants: {
      status: {
        success: "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300",
        warning: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300",
        error: "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300",
        info: "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300",
      },
    },
    defaultVariants: {
      status: "info",
    },
  }
)

interface StatusBadgeProps extends VariantProps<typeof statusBadgeVariants> {
  children: React.ReactNode
}

function StatusBadge({ status, children }: StatusBadgeProps) {
  return <span className={statusBadgeVariants({ status })}>{children}</span>
}
// Type-safe: status prop is typed as "success" | "warning" | "error" | "info"
```

Reference: [Class Variance Authority](https://cva.style/docs)

### 1.2 Forward Refs for Composable Components

**Impact: CRITICAL (enables integration with form libraries and focus management)**

Custom components wrapping shadcn/ui primitives must forward refs to enable form library integration, focus management, and imperative handles.

**Incorrect (ref not forwarded):**

```tsx
interface SearchInputProps {
  onSearch: (query: string) => void
}

function SearchInput({ onSearch }: SearchInputProps) {
  const [query, setQuery] = useState("")

  return (
    <Input
      value={query}
      onChange={(e) => setQuery(e.target.value)}
      onKeyDown={(e) => e.key === "Enter" && onSearch(query)}
    />
  )
}

// Parent cannot focus the input
function SearchForm() {
  const inputRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    inputRef.current?.focus() // null - ref not forwarded
  }, [])

  return <SearchInput ref={inputRef} onSearch={handleSearch} />
}
```

**Correct (ref forwarded to underlying element):**

```tsx
interface SearchInputProps {
  onSearch: (query: string) => void
}

const SearchInput = forwardRef<HTMLInputElement, SearchInputProps>(
  ({ onSearch }, ref) => {
    const [query, setQuery] = useState("")

    return (
      <Input
        ref={ref}
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        onKeyDown={(e) => e.key === "Enter" && onSearch(query)}
      />
    )
  }
)
SearchInput.displayName = "SearchInput"

// Parent can now focus the input
function SearchForm() {
  const inputRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    inputRef.current?.focus() // Works - ref forwarded to Input
  }, [])

  return <SearchInput ref={inputRef} onSearch={handleSearch} />
}
```

**Always forward refs when:**
- Wrapping form inputs (Input, Select, Textarea)
- Creating trigger components for modals/popovers
- Building components used with React Hook Form

Reference: [React forwardRef](https://react.dev/reference/react/forwardRef)

### 1.3 Isolate Component Variants from Base Styles

**Impact: CRITICAL (prevents style bleeding and maintains component reusability)**

Keep variant-specific styles separate from base component styles. Mixing them creates tightly coupled components that are difficult to extend or override.

**Incorrect (base and variant styles mixed):**

```tsx
function AlertBanner({
  type,
  children,
}: {
  type: "info" | "success" | "error"
  children: React.ReactNode
}) {
  return (
    <div
      className={`rounded-lg p-4 ${
        type === "info"
          ? "border-blue-200 bg-blue-50 text-blue-800"
          : type === "success"
            ? "border-green-200 bg-green-50 text-green-800"
            : "border-red-200 bg-red-50 text-red-800"
      }`}
    >
      {/* Border style missing from base, must be repeated in each variant */}
      {children}
    </div>
  )
}
```

**Correct (separated base and variant definitions):**

```tsx
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const alertVariants = cva(
  // Base styles applied to all variants
  "rounded-lg border p-4",
  {
    variants: {
      type: {
        // Only color-related styles in variants
        info: "border-blue-200 bg-blue-50 text-blue-800",
        success: "border-green-200 bg-green-50 text-green-800",
        error: "border-red-200 bg-red-50 text-red-800",
      },
    },
    defaultVariants: {
      type: "info",
    },
  }
)

interface AlertBannerProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof alertVariants> {}

function AlertBanner({ type, className, children, ...props }: AlertBannerProps) {
  return (
    <div className={cn(alertVariants({ type }), className)} {...props}>
      {children}
    </div>
  )
}
// Base styles (rounded-lg, border, p-4) guaranteed on all variants
```

**Benefits:**
- Base styles guaranteed on all variants
- Easy to add new variants without duplicating structure
- Clear separation enables easier maintenance

Reference: [CVA Documentation](https://cva.style/docs/getting-started/variants)

### 1.4 Preserve Radix Primitive Structure

**Impact: CRITICAL (maintains keyboard navigation and focus management)**

shadcn/ui components are built on Radix primitives with specific parent-child relationships. Breaking this structure disables keyboard navigation, focus trapping, and ARIA attributes.

**Incorrect (broken primitive hierarchy):**

```tsx
function CustomDialog({ children }: { children: React.ReactNode }) {
  const [open, setOpen] = useState(false)

  return (
    <>
      <button onClick={() => setOpen(true)}>Open</button>
      {open && (
        <div className="fixed inset-0 bg-black/50">
          <DialogContent>
            {/* DialogContent outside Dialog - focus trap broken */}
            {children}
          </DialogContent>
        </div>
      )}
    </>
  )
}
```

**Correct (preserved compound component structure):**

```tsx
function CustomDialog({ children }: { children: React.ReactNode }) {
  return (
    <Dialog>
      <DialogTrigger asChild>
        <button>Open</button>
      </DialogTrigger>
      <DialogContent>
        {/* Proper hierarchy: Dialog > DialogContent */}
        {children}
      </DialogContent>
    </Dialog>
  )
}
```

**Required hierarchies for common components:**
- `Dialog` → `DialogTrigger` + `DialogContent` → `DialogHeader/Footer`
- `DropdownMenu` → `DropdownMenuTrigger` + `DropdownMenuContent` → `DropdownMenuItem`
- `Tabs` → `TabsList` → `TabsTrigger` + `TabsContent`

Reference: [shadcn/ui Dialog](https://ui.shadcn.com/docs/components/dialog)

### 1.5 Use asChild for Custom Trigger Elements

**Impact: CRITICAL (preserves accessibility and event handling)**

When using custom elements as triggers for Radix-based components, use the `asChild` prop to merge behavior onto your custom element instead of wrapping it.

**Incorrect (nested button elements, broken a11y):**

```tsx
function UserMenu() {
  return (
    <DropdownMenu>
      <DropdownMenuTrigger>
        <Button variant="ghost">
          <UserIcon className="h-4 w-4" />
          Account
        </Button>
      </DropdownMenuTrigger>
      {/* Creates <button><button>...</button></button> - invalid HTML */}
      <DropdownMenuContent>
        <DropdownMenuItem>Profile</DropdownMenuItem>
        <DropdownMenuItem>Settings</DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
```

**Correct (single button element with merged props):**

```tsx
function UserMenu() {
  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost">
          <UserIcon className="h-4 w-4" />
          Account
        </Button>
      </DropdownMenuTrigger>
      {/* Renders single <button> with all Radix props merged */}
      <DropdownMenuContent>
        <DropdownMenuItem>Profile</DropdownMenuItem>
        <DropdownMenuItem>Settings</DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
```

**When to use asChild:**
- Trigger components (DialogTrigger, PopoverTrigger, DropdownMenuTrigger)
- When your custom component already renders a focusable element
- When you need to preserve your component's styling and props

Reference: [Radix UI Composition](https://www.radix-ui.com/primitives/docs/guides/composition)

### 1.6 Use cn() for Safe Class Merging

**Impact: CRITICAL (prevents Tailwind class conflicts)**

Always use the `cn()` utility (which wraps `clsx` and `tailwind-merge`) when combining classes. Direct string concatenation causes Tailwind class conflicts where later classes don't override earlier ones.

**Incorrect (string concatenation causes conflicts):**

```tsx
interface CardProps {
  className?: string
  variant?: "default" | "highlighted"
}

function Card({ className, variant }: CardProps) {
  const baseClasses = "rounded-lg border bg-card p-6"
  const variantClasses = variant === "highlighted" ? "bg-primary" : ""

  return (
    <div className={`${baseClasses} ${variantClasses} ${className}`}>
      {/* bg-card and bg-primary both in class string - unpredictable result */}
    </div>
  )
}
```

**Correct (cn() handles conflicts intelligently):**

```tsx
import { cn } from "@/lib/utils"

interface CardProps {
  className?: string
  variant?: "default" | "highlighted"
}

function Card({ className, variant }: CardProps) {
  return (
    <div
      className={cn(
        "rounded-lg border bg-card p-6",
        variant === "highlighted" && "bg-primary text-primary-foreground",
        className
      )}
    >
      {/* tailwind-merge ensures bg-primary overrides bg-card */}
    </div>
  )
}
```

**How cn() works:**
1. `clsx` handles conditional classes and arrays
2. `tailwind-merge` resolves conflicts (last wins for same property)
3. User's `className` prop always takes precedence (passed last)

Reference: [shadcn/ui Utilities](https://ui.shadcn.com/docs/installation/manual)

---

## 2. Accessibility Preservation

**Impact: CRITICAL**

shadcn/ui inherits WAI-ARIA compliance from Radix UI - breaking accessibility patterns excludes users and violates legal requirements.

### 2.1 Ensure Color Contrast Meets WCAG Standards

**Impact: CRITICAL (enables readability for low vision users)**

When customizing shadcn/ui theme colors, ensure text meets WCAG AA contrast ratios (4.5:1 for normal text, 3:1 for large text). The default theme is compliant; custom themes may not be.

**Incorrect (insufficient contrast ratio):**

```css
:root {
  --primary: 200 80% 70%;
  --primary-foreground: 200 80% 90%;
  /* Light blue on lighter blue = ~1.5:1 ratio - fails WCAG */
}

.dark {
  --muted: 220 10% 20%;
  --muted-foreground: 220 10% 40%;
  /* Dark gray on slightly lighter gray = ~2:1 ratio - fails WCAG */
}
```

**Correct (WCAG AA compliant contrast):**

```css
:root {
  --primary: 222.2 47.4% 11.2%;
  --primary-foreground: 210 40% 98%;
  /* Dark blue on near-white = ~12:1 ratio - passes WCAG AAA */
}

.dark {
  --muted: 217.2 32.6% 17.5%;
  --muted-foreground: 215 20.2% 65.1%;
  /* Dark slate on light gray = ~6:1 ratio - passes WCAG AA */
}
```

**Testing contrast:**

```tsx
// Use browser DevTools or tools like WebAIM Contrast Checker
// shadcn/ui default colors are pre-tested for WCAG AA

// When adding custom colors, verify each combination:
// - foreground on background
// - primary-foreground on primary
// - destructive-foreground on destructive
// - muted-foreground on muted
```

**WCAG requirements:**
- Normal text (< 18pt): 4.5:1 minimum
- Large text (≥ 18pt or 14pt bold): 3:1 minimum
- UI components and graphics: 3:1 minimum

Reference: [WCAG Contrast Requirements](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)

### 2.2 Maintain Focus Management in Modals

**Impact: CRITICAL (prevents 100% keyboard user navigation failure)**

Radix Dialog/Sheet components trap focus within the modal and return focus on close. Custom modal implementations must replicate this behavior for keyboard accessibility.

**Incorrect (focus escapes modal):**

```tsx
function CustomModal({
  open,
  onClose,
  children,
}: {
  open: boolean
  onClose: () => void
  children: React.ReactNode
}) {
  if (!open) return null

  return (
    <div className="fixed inset-0 bg-black/50" onClick={onClose}>
      <div className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-white p-6 rounded-lg">
        <button onClick={onClose}>Close</button>
        {children}
        {/* Tab key can focus elements behind modal */}
        {/* Escape key doesn't close modal */}
        {/* Focus not moved to modal on open */}
      </div>
    </div>
  )
}
```

**Correct (using shadcn/ui Dialog):**

```tsx
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogClose,
} from "@/components/ui/dialog"

function CustomModal({
  open,
  onOpenChange,
  title,
  children,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  title: string
  children: React.ReactNode
}) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
        </DialogHeader>
        {children}
        {/* Focus trapped within DialogContent */}
        {/* Escape key closes modal automatically */}
        {/* Focus returns to trigger on close */}
      </DialogContent>
    </Dialog>
  )
}
```

**Focus management behaviors:**
- Focus moves to first focusable element on open
- Tab cycles through modal content only
- Shift+Tab cycles backwards
- Escape closes and returns focus to trigger

Reference: [WAI-ARIA Dialog Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/)

### 2.3 Preserve ARIA Attributes from Radix Primitives

**Impact: CRITICAL (maintains screen reader compatibility)**

Radix primitives automatically manage ARIA attributes for accessibility. Overriding or omitting these attributes breaks screen reader functionality.

**Incorrect (ARIA attributes overridden):**

```tsx
function CustomAccordion({ items }: { items: AccordionItem[] }) {
  const [openIndex, setOpenIndex] = useState<number | null>(null)

  return (
    <div>
      {items.map((item, index) => (
        <div key={item.id}>
          <button
            onClick={() => setOpenIndex(openIndex === index ? null : index)}
          >
            {/* Missing aria-expanded, aria-controls */}
            {item.title}
          </button>
          {openIndex === index && (
            <div>
              {/* Missing aria-labelledby, role="region" */}
              {item.content}
            </div>
          )}
        </div>
      ))}
    </div>
  )
}
```

**Correct (using Radix primitives with automatic ARIA):**

```tsx
import {
  Accordion,
  AccordionContent,
  AccordionItem as AccordionItemComponent,
  AccordionTrigger,
} from "@/components/ui/accordion"

function CustomAccordion({ items }: { items: AccordionItem[] }) {
  return (
    <Accordion type="single" collapsible>
      {items.map((item) => (
        <AccordionItemComponent key={item.id} value={item.id}>
          <AccordionTrigger>
            {/* Radix adds aria-expanded, aria-controls automatically */}
            {item.title}
          </AccordionTrigger>
          <AccordionContent>
            {/* Radix adds aria-labelledby, role="region" automatically */}
            {item.content}
          </AccordionContent>
        </AccordionItemComponent>
      ))}
    </Accordion>
  )
}
```

**ARIA attributes managed by Radix:**
- `aria-expanded` on triggers (Accordion, Collapsible, Dialog)
- `aria-controls` / `aria-labelledby` for content relationships
- `role` attributes (dialog, menu, tablist, etc.)
- `aria-selected` / `aria-checked` for selection states

Reference: [Radix Accessibility](https://www.radix-ui.com/primitives/docs/overview/accessibility)

### 2.4 Preserve Keyboard Navigation Patterns

**Impact: CRITICAL (enables non-mouse users to navigate components)**

Radix components implement WAI-ARIA keyboard navigation patterns. Custom styling or structure changes must not break these patterns.

**Incorrect (keyboard navigation broken):**

```tsx
function CustomTabs({ tabs }: { tabs: TabData[] }) {
  const [activeTab, setActiveTab] = useState(0)

  return (
    <div>
      <div className="flex gap-2">
        {tabs.map((tab, index) => (
          <div
            key={tab.id}
            onClick={() => setActiveTab(index)}
            className={activeTab === index ? "border-b-2" : ""}
          >
            {/* div is not focusable, arrow keys don't work */}
            {tab.label}
          </div>
        ))}
      </div>
      <div>{tabs[activeTab].content}</div>
    </div>
  )
}
```

**Correct (shadcn/ui Tabs with full keyboard support):**

```tsx
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs"

function CustomTabs({ tabs }: { tabs: TabData[] }) {
  return (
    <Tabs defaultValue={tabs[0].id}>
      <TabsList>
        {tabs.map((tab) => (
          <TabsTrigger key={tab.id} value={tab.id}>
            {/* Left/Right arrows navigate tabs */}
            {/* Home/End jump to first/last tab */}
            {/* Enter/Space selects tab */}
            {tab.label}
          </TabsTrigger>
        ))}
      </TabsList>
      {tabs.map((tab) => (
        <TabsContent key={tab.id} value={tab.id}>
          {tab.content}
        </TabsContent>
      ))}
    </Tabs>
  )
}
```

**Keyboard patterns by component:**
- **Tabs**: Left/Right arrows, Home/End
- **Menu/Dropdown**: Up/Down arrows, Enter to select
- **Accordion**: Up/Down arrows, Enter to toggle
- **Combobox**: Up/Down arrows, Enter to select, Escape to close

Reference: [WAI-ARIA Patterns](https://www.w3.org/WAI/ARIA/apg/patterns/)

### 2.5 Provide Screen Reader Labels for Icon Buttons

**Impact: CRITICAL (enables navigation for visually impaired users)**

Icon-only buttons must have accessible labels. Without them, screen readers announce "button" with no context about the action.

**Incorrect (icon button without accessible name):**

```tsx
function ThemeToggle() {
  const { theme, setTheme } = useTheme()

  return (
    <Button
      variant="outline"
      size="icon"
      onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
    >
      <SunIcon className="h-4 w-4 dark:hidden" />
      <MoonIcon className="h-4 w-4 hidden dark:block" />
      {/* Screen reader announces: "button" - no context */}
    </Button>
  )
}
```

**Correct (sr-only text provides context):**

```tsx
function ThemeToggle() {
  const { theme, setTheme } = useTheme()

  return (
    <Button
      variant="outline"
      size="icon"
      onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
    >
      <SunIcon className="h-4 w-4 dark:hidden" />
      <MoonIcon className="h-4 w-4 hidden dark:block" />
      <span className="sr-only">Toggle theme</span>
      {/* Screen reader announces: "Toggle theme, button" */}
    </Button>
  )
}
```

**Alternative (using aria-label):**

```tsx
function CloseButton({ onClose }: { onClose: () => void }) {
  return (
    <Button
      variant="ghost"
      size="icon"
      onClick={onClose}
      aria-label="Close dialog"
    >
      <XIcon className="h-4 w-4" />
    </Button>
  )
}
```

**Use sr-only when:**
- The label is longer or more descriptive
- Multiple icons need different labels in the same context
- You want visible fallback if CSS fails

Reference: [Tailwind Screen Reader](https://tailwindcss.com/docs/screen-readers)

---

## 3. Styling & Theming

**Impact: HIGH**

Consistent Tailwind and CSS variable usage ensures visual coherence and maintainable theming across the entire application.

### 3.1 Apply Mobile-First Responsive Design

**Impact: HIGH (prevents mobile usability failures on 50%+ of traffic)**

Build components mobile-first, then add responsive modifiers for larger screens. This matches Tailwind's design philosophy and ensures mobile usability.

**Incorrect (desktop-first, mobile as afterthought):**

```tsx
function DataTable({ data }: { data: TableRow[] }) {
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead className="w-[200px]">Name</TableHead>
          <TableHead className="w-[150px]">Status</TableHead>
          <TableHead className="w-[200px]">Email</TableHead>
          <TableHead className="text-right w-[100px]">Amount</TableHead>
          {/* All columns visible - table overflows on mobile */}
        </TableRow>
      </TableHeader>
      {/* ... */}
    </Table>
  )
}
```

**Correct (mobile-first with progressive enhancement):**

```tsx
function DataTable({ data }: { data: TableRow[] }) {
  return (
    <div className="w-full overflow-auto">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead className="min-w-[120px]">Name</TableHead>
            <TableHead className="hidden sm:table-cell">Status</TableHead>
            <TableHead className="hidden md:table-cell">Email</TableHead>
            <TableHead className="text-right">Amount</TableHead>
            {/* Secondary columns hidden on mobile, revealed at breakpoints */}
          </TableRow>
        </TableHeader>
        <TableBody>
          {data.map((row) => (
            <TableRow key={row.id}>
              <TableCell className="font-medium">{row.name}</TableCell>
              <TableCell className="hidden sm:table-cell">
                <Badge variant={row.status === "active" ? "default" : "secondary"}>
                  {row.status}
                </Badge>
              </TableCell>
              <TableCell className="hidden md:table-cell">{row.email}</TableCell>
              <TableCell className="text-right">${row.amount}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  )
}
```

**Responsive patterns:**
- `hidden sm:block` - Hidden on mobile, visible at 640px+
- `flex-col md:flex-row` - Stack on mobile, row on desktop
- `grid-cols-1 lg:grid-cols-3` - Single column to multi-column
- `text-sm md:text-base` - Smaller text on mobile

Reference: [Tailwind Responsive Design](https://tailwindcss.com/docs/responsive-design)

### 3.2 Avoid !important Overrides

**Impact: HIGH (maintains style specificity and component customization)**

Never use `!important` to override shadcn/ui styles. It breaks the cascade and prevents component consumers from customizing styles.

**Incorrect (using !important):**

```tsx
function BrandButton({ children }: { children: React.ReactNode }) {
  return (
    <Button className="!bg-brand-500 !text-white !hover:bg-brand-600">
      {/* !important prevents any further customization */}
      {children}
    </Button>
  )
}

// Consumer cannot override
function Page() {
  return (
    <BrandButton className="bg-red-500">
      {/* bg-red-500 ignored due to !important */}
      Click me
    </BrandButton>
  )
}
```

**Correct (proper specificity with cn()):**

```tsx
import { cn } from "@/lib/utils"

function BrandButton({
  className,
  children,
}: {
  className?: string
  children: React.ReactNode
}) {
  return (
    <Button
      className={cn(
        "bg-brand-500 text-white hover:bg-brand-600",
        className
      )}
    >
      {/* User className passed last, can override defaults */}
      {children}
    </Button>
  )
}

// Consumer can customize
function Page() {
  return (
    <BrandButton className="bg-red-500 hover:bg-red-600">
      {/* Works - className overrides defaults via cn() */}
      Click me
    </BrandButton>
  )
}
```

**If styles aren't applying:**
1. Check class order in `cn()` - later classes win
2. Verify Tailwind config includes your custom colors
3. Use browser DevTools to inspect computed styles

Reference: [Tailwind Important Modifier](https://tailwindcss.com/docs/configuration#important-modifier)

### 3.3 Extend Tailwind Theme for Custom Design Tokens

**Impact: HIGH (maintains design system consistency)**

Add brand colors and custom design tokens by extending the Tailwind theme rather than using arbitrary values. This creates reusable tokens and enables autocomplete.

**Incorrect (arbitrary values scattered):**

```tsx
function BrandedCard() {
  return (
    <Card className="bg-[#1a365d] border-[#2a4a7f]">
      <CardHeader>
        <CardTitle className="text-[#e2e8f0]">
          {/* Arbitrary values: no autocomplete, hard to maintain */}
          Dashboard
        </CardTitle>
      </CardHeader>
      <CardContent>
        <p className="text-[#a0aec0]">Welcome to your dashboard</p>
      </CardContent>
    </Card>
  )
}
```

**Correct (extended Tailwind theme):**

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        brand: {
          50: "#e6f0ff",
          100: "#b3d1ff",
          500: "#1a365d",
          600: "#153050",
          700: "#102540",
          foreground: "#e2e8f0",
          muted: "#a0aec0",
        },
      },
    },
  },
}
```

```tsx
function BrandedCard() {
  return (
    <Card className="bg-brand-500 border-brand-600">
      <CardHeader>
        <CardTitle className="text-brand-foreground">
          {/* Autocomplete works, single source of truth */}
          Dashboard
        </CardTitle>
      </CardHeader>
      <CardContent>
        <p className="text-brand-muted">Welcome to your dashboard</p>
      </CardContent>
    </Card>
  )
}
```

**Benefits of theme extension:**
- IDE autocomplete for all custom values
- Single source of truth for brand colors
- Easy global updates when brand changes
- Works with opacity modifiers (bg-brand-500/50)

Reference: [Tailwind Theme Extension](https://tailwindcss.com/docs/theme#extending-the-default-theme)

### 3.4 Support Dark Mode with CSS Variables

**Impact: HIGH (provides user preference compliance and reduces eye strain)**

Use the shadcn/ui dark mode pattern with CSS variables. Define both light and dark values; components automatically adapt.

**Incorrect (hardcoded mode-specific styles):**

```tsx
function NotificationCard({ message }: { message: string }) {
  return (
    <Card className="bg-white text-gray-900 border-gray-200">
      {/* No dark mode support - harsh white in dark environments */}
      <CardContent className="p-4">
        <p className="text-gray-600">{message}</p>
      </CardContent>
    </Card>
  )
}
```

**Correct (CSS variables with dark mode support):**

```css
/* globals.css */
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;
  }
}
```

```tsx
function NotificationCard({ message }: { message: string }) {
  return (
    <Card className="bg-card text-card-foreground border-border">
      {/* Automatically adapts to light/dark mode */}
      <CardContent className="p-4">
        <p className="text-muted-foreground">{message}</p>
      </CardContent>
    </Card>
  )
}
```

**Theme toggle implementation:**

```tsx
import { useTheme } from "next-themes"

function ThemeToggle() {
  const { theme, setTheme } = useTheme()

  return (
    <Button variant="outline" size="icon" onClick={() => setTheme(theme === "dark" ? "light" : "dark")}>
      <SunIcon className="h-4 w-4 rotate-0 scale-100 dark:-rotate-90 dark:scale-0" />
      <MoonIcon className="absolute h-4 w-4 rotate-90 scale-0 dark:rotate-0 dark:scale-100" />
      <span className="sr-only">Toggle theme</span>
    </Button>
  )
}
```

Reference: [shadcn/ui Dark Mode](https://ui.shadcn.com/docs/dark-mode)

### 3.5 Use Consistent Spacing Scale

**Impact: HIGH (creates visual rhythm and reduces design inconsistency)**

Use Tailwind's spacing scale consistently rather than mixing arbitrary values. Consistent spacing creates visual rhythm and professional appearance.

**Incorrect (inconsistent spacing):**

```tsx
function ProfileCard({ user }: { user: User }) {
  return (
    <Card className="p-5">
      <CardHeader className="pb-3">
        <div className="flex gap-[14px] items-center">
          {/* Mixing scales: p-5, pb-3, gap-[14px], mt-[10px] */}
          <Avatar className="h-12 w-12" />
          <div>
            <CardTitle className="mb-[6px]">{user.name}</CardTitle>
            <p className="text-muted-foreground mt-[10px]">{user.email}</p>
          </div>
        </div>
      </CardHeader>
    </Card>
  )
}
```

**Correct (consistent Tailwind spacing):**

```tsx
function ProfileCard({ user }: { user: User }) {
  return (
    <Card className="p-6">
      <CardHeader className="pb-4">
        <div className="flex gap-4 items-center">
          {/* Consistent scale: p-6, pb-4, gap-4, space-y-1 */}
          <Avatar className="h-12 w-12" />
          <div className="space-y-1">
            <CardTitle>{user.name}</CardTitle>
            <p className="text-muted-foreground">{user.email}</p>
          </div>
        </div>
      </CardHeader>
    </Card>
  )
}
```

**Tailwind spacing scale reference:**
- `1` = 0.25rem (4px)
- `2` = 0.5rem (8px)
- `4` = 1rem (16px)
- `6` = 1.5rem (24px)
- `8` = 2rem (32px)

**Guidelines:**
- Component padding: `p-4` or `p-6`
- Element gaps: `gap-2`, `gap-4`, or `gap-6`
- Section margins: `mt-8`, `mb-12`
- Use `space-y-*` and `space-x-*` for consistent child spacing

Reference: [Tailwind Spacing](https://tailwindcss.com/docs/customizing-spacing)

### 3.6 Use CSS Variables for Theme Colors

**Impact: HIGH (enables runtime theme switching and consistency)**

Reference theme colors via CSS variables (--primary, --background, etc.) rather than hardcoded Tailwind colors. This enables theme switching and maintains design consistency.

**Incorrect (hardcoded colors break theming):**

```tsx
function StatusCard({ status }: { status: "active" | "inactive" }) {
  return (
    <Card className="bg-white dark:bg-gray-800 border-gray-200">
      <CardHeader>
        <CardTitle className={status === "active" ? "text-green-600" : "text-gray-500"}>
          {/* Hardcoded colors don't adapt to theme changes */}
          Status: {status}
        </CardTitle>
      </CardHeader>
    </Card>
  )
}
```

**Correct (CSS variables adapt to theme):**

```tsx
function StatusCard({ status }: { status: "active" | "inactive" }) {
  return (
    <Card className="bg-card border-border">
      <CardHeader>
        <CardTitle
          className={status === "active" ? "text-primary" : "text-muted-foreground"}
        >
          {/* Colors automatically update with theme */}
          Status: {status}
        </CardTitle>
      </CardHeader>
    </Card>
  )
}
```

**shadcn/ui CSS variable naming:**
- `bg-background`, `text-foreground` - Base colors
- `bg-card`, `text-card-foreground` - Card surfaces
- `bg-primary`, `text-primary-foreground` - Primary actions
- `bg-muted`, `text-muted-foreground` - Subdued elements
- `bg-destructive`, `text-destructive` - Destructive actions
- `border-border`, `ring-ring` - Borders and focus rings

Reference: [shadcn/ui Theming](https://ui.shadcn.com/docs/theming)

---

## 4. Form Patterns

**Impact: HIGH**

Forms are critical UX touchpoints - proper React Hook Form and Zod integration ensures data integrity and user experience.

### 4.1 Handle Async Validation with Debouncing

**Impact: HIGH (prevents excessive API calls during validation)**

When validating against an API (username availability, email uniqueness), debounce the validation to prevent excessive network requests.

**Incorrect (API call on every keystroke):**

```tsx
const schema = z.object({
  username: z.string().min(3).refine(
    async (username) => {
      // Called on EVERY keystroke - floods server
      const response = await fetch(`/api/check-username?u=${username}`)
      return response.ok
    },
    { message: "Username already taken" }
  ),
})

function UsernameForm() {
  const form = useForm({
    resolver: zodResolver(schema),
    mode: "onChange", // Triggers validation constantly
  })

  return <Form {...form}>{/* ... */}</Form>
}
```

**Correct (debounced async validation):**

```tsx
import { useDebouncedCallback } from "use-debounce"

const baseSchema = z.object({
  username: z.string().min(3, "Username must be at least 3 characters"),
})

type FormValues = z.infer<typeof baseSchema>

function UsernameForm() {
  const [usernameError, setUsernameError] = useState<string | null>(null)
  const [isChecking, setIsChecking] = useState(false)

  const form = useForm<FormValues>({
    resolver: zodResolver(baseSchema),
    mode: "onBlur",
  })

  const checkUsername = useDebouncedCallback(async (username: string) => {
    if (username.length < 3) return

    setIsChecking(true)
    try {
      const response = await fetch(`/api/check-username?u=${username}`)
      if (!response.ok) {
        setUsernameError("Username already taken")
        form.setError("username", { message: "Username already taken" })
      } else {
        setUsernameError(null)
      }
    } finally {
      setIsChecking(false)
    }
  }, 500) // 500ms debounce

  return (
    <Form {...form}>
      <FormField
        control={form.control}
        name="username"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Username</FormLabel>
            <FormControl>
              <div className="relative">
                <Input
                  {...field}
                  onChange={(e) => {
                    field.onChange(e)
                    checkUsername(e.target.value)
                  }}
                />
                {isChecking && (
                  <Loader2 className="absolute right-3 top-3 h-4 w-4 animate-spin" />
                )}
              </div>
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
    </Form>
  )
}
```

Reference: [use-debounce](https://github.com/xnimorz/use-debounce)

### 4.2 Reset Form State Correctly After Submission

**Impact: HIGH (prevents stale data and submission errors)**

After successful form submission, reset the form state to prevent stale data, duplicate submissions, and confusion about form status.

**Incorrect (form not reset after submission):**

```tsx
function ContactForm() {
  const form = useForm<ContactFormValues>({
    resolver: zodResolver(contactSchema),
  })

  const onSubmit = async (data: ContactFormValues) => {
    await submitContact(data)
    toast.success("Message sent!")
    // Form still shows old data
    // User might accidentally resubmit
  }

  return <Form {...form}>{/* ... */}</Form>
}
```

**Correct (form reset with proper state management):**

```tsx
function ContactForm() {
  const form = useForm<ContactFormValues>({
    resolver: zodResolver(contactSchema),
    defaultValues: {
      name: "",
      email: "",
      message: "",
    },
  })

  const onSubmit = async (data: ContactFormValues) => {
    try {
      await submitContact(data)
      toast.success("Message sent!")
      form.reset() // Resets to defaultValues and clears errors
    } catch (error) {
      toast.error("Failed to send message")
      // Keep form data so user can retry
    }
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)}>
        {/* Form fields */}
        <Button type="submit" disabled={form.formState.isSubmitting}>
          {form.formState.isSubmitting ? "Sending..." : "Send Message"}
        </Button>
      </form>
    </Form>
  )
}
```

**Reset patterns:**
- `form.reset()` - Reset to defaultValues
- `form.reset(newValues)` - Reset to specific values
- `form.resetField("email")` - Reset single field
- `form.clearErrors()` - Clear errors without resetting values

**For edit forms (reset to fetched data):**

```tsx
const { data: user } = useQuery(["user", userId], fetchUser)

const form = useForm<UserFormValues>({
  resolver: zodResolver(userSchema),
})

useEffect(() => {
  if (user) {
    form.reset(user) // Reset to fetched data when available
  }
}, [user, form])
```

Reference: [React Hook Form reset](https://react-hook-form.com/docs/useform/reset)

### 4.3 Show Validation Errors at Appropriate Times

**Impact: HIGH (improves user experience and reduces frustration)**

Show validation errors on blur or submit, not on every keystroke. Immediate validation frustrates users typing valid input.

**Incorrect (errors shown while typing):**

```tsx
const form = useForm<FormValues>({
  resolver: zodResolver(schema),
  mode: "onChange", // Validates on every keystroke
})

// User types "t" - sees "Email must be valid" immediately
// User types "te" - still sees error
// User types "test@" - still sees error
// Frustrating experience during normal typing
```

**Correct (errors shown on blur or submit):**

```tsx
const form = useForm<FormValues>({
  resolver: zodResolver(schema),
  mode: "onBlur", // Validates when field loses focus
  reValidateMode: "onChange", // Re-validates on change after first error
})

// User types entire email without interruption
// Error only shown when they leave the field
// Once error shown, it updates as they fix it
```

**Alternative (validate on submit only):**

```tsx
const form = useForm<FormValues>({
  resolver: zodResolver(schema),
  mode: "onSubmit", // Only validates on form submission
})

// Good for short forms where user submits quickly
// Shows all errors at once after submit attempt
```

**Validation mode guidelines:**
- `onBlur` - Recommended for most forms
- `onChange` - Only for real-time feedback (passwords)
- `onSubmit` - Short forms or wizards
- `reValidateMode: "onChange"` - Always pair with onBlur for instant feedback during correction

Reference: [React Hook Form Validation](https://react-hook-form.com/docs/useform#mode)

### 4.4 Use React Hook Form with shadcn/ui Forms

**Impact: HIGH (eliminates re-renders and provides validation)**

shadcn/ui's Form components are designed for React Hook Form integration. Using controlled state with useState causes re-renders on every keystroke.

**Incorrect (controlled state causes re-renders):**

```tsx
function LoginForm() {
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [errors, setErrors] = useState<Record<string, string>>({})

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    // Manual validation logic...
    // Re-renders entire form on every keystroke
  }

  return (
    <form onSubmit={handleSubmit}>
      <Input
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Email"
      />
      {errors.email && <p className="text-red-500">{errors.email}</p>}
      <Input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />
      <Button type="submit">Login</Button>
    </form>
  )
}
```

**Correct (React Hook Form with shadcn/ui):**

```tsx
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form"

const loginSchema = z.object({
  email: z.string().email("Invalid email address"),
  password: z.string().min(8, "Password must be at least 8 characters"),
})

type LoginFormValues = z.infer<typeof loginSchema>

function LoginForm() {
  const form = useForm<LoginFormValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: { email: "", password: "" },
  })

  const onSubmit = (data: LoginFormValues) => {
    // Validated data, no re-renders during typing
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input placeholder="email@example.com" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="password"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Password</FormLabel>
              <FormControl>
                <Input type="password" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit">Login</Button>
      </form>
    </Form>
  )
}
```

Reference: [shadcn/ui Forms](https://ui.shadcn.com/docs/components/form)

### 4.5 Use Zod for Schema Validation

**Impact: HIGH (eliminates runtime type errors with full TS inference)**

Define form schemas with Zod for type-safe validation. Zod integrates with React Hook Form via `@hookform/resolvers` and provides TypeScript type inference.

**Incorrect (manual validation without schema):**

```tsx
function RegistrationForm() {
  const form = useForm()

  const onSubmit = (data: any) => {
    // Manual validation - no type safety
    if (!data.email || !data.email.includes("@")) {
      form.setError("email", { message: "Invalid email" })
      return
    }
    if (!data.age || data.age < 18) {
      form.setError("age", { message: "Must be 18 or older" })
      return
    }
    // data is typed as 'any' - no autocomplete
  }

  return <form onSubmit={form.handleSubmit(onSubmit)}>{/* ... */}</form>
}
```

**Correct (Zod schema with type inference):**

```tsx
import { z } from "zod"
import { zodResolver } from "@hookform/resolvers/zod"

const registrationSchema = z.object({
  email: z.string().email("Please enter a valid email"),
  username: z
    .string()
    .min(3, "Username must be at least 3 characters")
    .max(20, "Username must be at most 20 characters")
    .regex(/^[a-zA-Z0-9_]+$/, "Only letters, numbers, and underscores"),
  age: z.coerce
    .number()
    .min(18, "You must be at least 18 years old")
    .max(120, "Please enter a valid age"),
  website: z.string().url("Please enter a valid URL").optional().or(z.literal("")),
})

type RegistrationFormValues = z.infer<typeof registrationSchema>
// TypeScript knows: { email: string; username: string; age: number; website?: string }

function RegistrationForm() {
  const form = useForm<RegistrationFormValues>({
    resolver: zodResolver(registrationSchema),
    defaultValues: {
      email: "",
      username: "",
      age: undefined,
      website: "",
    },
  })

  const onSubmit = (data: RegistrationFormValues) => {
    // data is fully typed with validation passed
    console.log(data.email) // TypeScript knows this is a valid email string
  }

  return <Form {...form}>{/* ... */}</Form>
}
```

**Common Zod patterns:**
- `z.coerce.number()` - Converts string input to number
- `.optional().or(z.literal(""))` - Allow empty string for optional fields
- `.refine()` - Custom validation logic
- `.transform()` - Transform values after validation

Reference: [Zod Documentation](https://zod.dev/)

---

## 5. Data Display

**Impact: MEDIUM-HIGH**

Tables, lists, and data visualization patterns affect how users interact with large datasets and complex information.

### 5.1 Paginate Large Datasets Server-Side

**Impact: MEDIUM-HIGH (reduces initial payload by 90%+ for large datasets)**

For datasets over 100 items, implement server-side pagination. Client-side pagination requires loading all data upfront, bloating the initial payload.

**Incorrect (client-side pagination):**

```tsx
function ProductTable() {
  const { data: products } = useQuery(["products"], () =>
    fetch("/api/products").then((r) => r.json())
  )
  // Fetches ALL 10,000 products on mount

  const [page, setPage] = useState(0)
  const pageSize = 10
  const paginatedProducts = products?.slice(page * pageSize, (page + 1) * pageSize)

  return (
    <>
      <Table>{/* render paginatedProducts */}</Table>
      <Pagination>{/* ... */}</Pagination>
    </>
  )
}
```

**Correct (server-side pagination):**

```tsx
function ProductTable() {
  const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 10 })

  const { data, isLoading } = useQuery(
    ["products", pagination],
    () =>
      fetch(
        `/api/products?page=${pagination.pageIndex}&limit=${pagination.pageSize}`
      ).then((r) => r.json()),
    { keepPreviousData: true } // Smooth transitions between pages
  )
  // Fetches only 10 products per page

  const table = useReactTable({
    data: data?.products ?? [],
    columns,
    pageCount: data?.totalPages ?? -1,
    state: { pagination },
    onPaginationChange: setPagination,
    manualPagination: true, // Tell TanStack Table pagination is server-side
    getCoreRowModel: getCoreRowModel(),
  })

  return (
    <>
      <Table>
        <TableBody>
          {table.getRowModel().rows.map((row) => (
            <TableRow key={row.id}>
              {row.getVisibleCells().map((cell) => (
                <TableCell key={cell.id}>
                  {flexRender(cell.column.columnDef.cell, cell.getContext())}
                </TableCell>
              ))}
            </TableRow>
          ))}
        </TableBody>
      </Table>
      <div className="flex items-center justify-between py-4">
        <p className="text-sm text-muted-foreground">
          Page {pagination.pageIndex + 1} of {data?.totalPages}
        </p>
        <div className="flex gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => table.previousPage()}
            disabled={!table.getCanPreviousPage()}
          >
            Previous
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={() => table.nextPage()}
            disabled={!table.getCanNextPage()}
          >
            Next
          </Button>
        </div>
      </div>
    </>
  )
}
```

Reference: [TanStack Table Pagination](https://tanstack.com/table/latest/docs/guide/pagination)

### 5.2 Provide Actionable Empty States

**Impact: MEDIUM-HIGH (increases user action rate by 2-4×)**

When displaying empty data (no results, no items), provide context and clear actions rather than just "No data".

**Incorrect (unhelpful empty state):**

```tsx
function TaskList({ tasks }: { tasks: Task[] }) {
  if (tasks.length === 0) {
    return <p className="text-muted-foreground p-4">No tasks found.</p>
    // User doesn't know why or what to do next
  }

  return <ul>{/* render tasks */}</ul>
}
```

**Correct (actionable empty state):**

```tsx
import { Plus, Search, Filter } from "lucide-react"

function TaskList({
  tasks,
  searchQuery,
  filter,
  onCreateTask,
  onClearFilters,
}: TaskListProps) {
  if (tasks.length === 0) {
    // Different empty states based on context
    if (searchQuery) {
      return (
        <div className="flex flex-col items-center justify-center p-12 text-center">
          <Search className="h-12 w-12 text-muted-foreground mb-4" />
          <h3 className="text-lg font-medium">No results for "{searchQuery}"</h3>
          <p className="text-muted-foreground mt-1 mb-4">
            Try adjusting your search or filters
          </p>
          <Button variant="outline" onClick={onClearFilters}>
            Clear filters
          </Button>
        </div>
      )
    }

    if (filter !== "all") {
      return (
        <div className="flex flex-col items-center justify-center p-12 text-center">
          <Filter className="h-12 w-12 text-muted-foreground mb-4" />
          <h3 className="text-lg font-medium">No {filter} tasks</h3>
          <p className="text-muted-foreground mt-1 mb-4">
            Tasks marked as {filter} will appear here
          </p>
          <Button variant="outline" onClick={() => onClearFilters()}>
            View all tasks
          </Button>
        </div>
      )
    }

    // Fresh start - no tasks yet
    return (
      <div className="flex flex-col items-center justify-center p-12 text-center border-2 border-dashed rounded-lg">
        <Plus className="h-12 w-12 text-muted-foreground mb-4" />
        <h3 className="text-lg font-medium">No tasks yet</h3>
        <p className="text-muted-foreground mt-1 mb-4 max-w-sm">
          Get started by creating your first task to track your work
        </p>
        <Button onClick={onCreateTask}>
          <Plus className="h-4 w-4 mr-2" />
          Create task
        </Button>
      </div>
    )
  }

  return <ul>{/* render tasks */}</ul>
}
```

**Empty state guidelines:**
- Use relevant icons to visually communicate the state
- Explain why the list is empty (search, filter, fresh start)
- Provide a clear primary action
- Keep copy concise and helpful

Reference: [Empty States Design Patterns](https://www.nngroup.com/articles/empty-state-interface-design/)

### 5.3 Use Skeleton Components for Loading States

**Impact: MEDIUM-HIGH (reduces perceived load time and prevents layout shift)**

Use shadcn/ui Skeleton components to show content placeholders during data loading. This prevents layout shifts and reduces perceived load time.

**Incorrect (spinner or empty state):**

```tsx
function UserProfile({ userId }: { userId: string }) {
  const { data: user, isLoading } = useQuery(["user", userId], fetchUser)

  if (isLoading) {
    return (
      <div className="flex justify-center p-8">
        <Loader2 className="h-8 w-8 animate-spin" />
        {/* Content jumps when data loads - layout shift */}
      </div>
    )
  }

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center gap-4">
          <Avatar className="h-16 w-16">
            <AvatarImage src={user.avatar} />
          </Avatar>
          <div>
            <CardTitle>{user.name}</CardTitle>
            <p className="text-muted-foreground">{user.email}</p>
          </div>
        </div>
      </CardHeader>
    </Card>
  )
}
```

**Correct (skeleton matching final layout):**

```tsx
import { Skeleton } from "@/components/ui/skeleton"

function UserProfileSkeleton() {
  return (
    <Card>
      <CardHeader>
        <div className="flex items-center gap-4">
          <Skeleton className="h-16 w-16 rounded-full" />
          <div className="space-y-2">
            <Skeleton className="h-5 w-32" />
            <Skeleton className="h-4 w-48" />
          </div>
        </div>
      </CardHeader>
    </Card>
  )
}

function UserProfile({ userId }: { userId: string }) {
  const { data: user, isLoading } = useQuery(["user", userId], fetchUser)

  if (isLoading) {
    return <UserProfileSkeleton />
    // Same dimensions as loaded content - no layout shift
  }

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center gap-4">
          <Avatar className="h-16 w-16">
            <AvatarImage src={user.avatar} />
          </Avatar>
          <div>
            <CardTitle>{user.name}</CardTitle>
            <p className="text-muted-foreground">{user.email}</p>
          </div>
        </div>
      </CardHeader>
    </Card>
  )
}
```

**Skeleton best practices:**
- Match skeleton dimensions to final content exactly
- Use `animate-pulse` (default) for subtle loading indication
- Group related skeletons to show content hierarchy
- Create reusable skeleton components for repeated patterns

Reference: [shadcn/ui Skeleton](https://ui.shadcn.com/docs/components/skeleton)

### 5.4 Use TanStack Table for Complex Data Tables

**Impact: MEDIUM-HIGH (eliminates 200-500 lines of manual table logic)**

For tables requiring sorting, filtering, or pagination, use TanStack Table with shadcn/ui's Table component. Manual implementations are error-prone and lack features.

**Incorrect (manual sorting implementation):**

```tsx
function UserTable({ users }: { users: User[] }) {
  const [sortField, setSortField] = useState<keyof User>("name")
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("asc")

  const sortedUsers = [...users].sort((a, b) => {
    // Manual sorting - breaks for nested fields, dates, null values
    const aVal = a[sortField]
    const bVal = b[sortField]
    return sortDirection === "asc"
      ? aVal > bVal ? 1 : -1
      : aVal < bVal ? 1 : -1
  })

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead onClick={() => setSortField("name")}>Name</TableHead>
          {/* Missing sort indicators, accessibility */}
        </TableRow>
      </TableHeader>
      {/* ... */}
    </Table>
  )
}
```

**Correct (TanStack Table integration):**

```tsx
import {
  useReactTable,
  getCoreRowModel,
  getSortedRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  flexRender,
  type ColumnDef,
  type SortingState,
} from "@tanstack/react-table"

const columns: ColumnDef<User>[] = [
  {
    accessorKey: "name",
    header: ({ column }) => (
      <Button
        variant="ghost"
        onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
      >
        Name
        <ArrowUpDown className="ml-2 h-4 w-4" />
      </Button>
    ),
  },
  {
    accessorKey: "email",
    header: "Email",
  },
  {
    accessorKey: "status",
    header: "Status",
    cell: ({ row }) => <Badge>{row.getValue("status")}</Badge>,
  },
]

function UserTable({ users }: { users: User[] }) {
  const [sorting, setSorting] = useState<SortingState>([])

  const table = useReactTable({
    data: users,
    columns,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    onSortingChange: setSorting,
    state: { sorting },
  })

  return (
    <Table>
      <TableHeader>
        {table.getHeaderGroups().map((headerGroup) => (
          <TableRow key={headerGroup.id}>
            {headerGroup.headers.map((header) => (
              <TableHead key={header.id}>
                {flexRender(header.column.columnDef.header, header.getContext())}
              </TableHead>
            ))}
          </TableRow>
        ))}
      </TableHeader>
      <TableBody>
        {table.getRowModel().rows.map((row) => (
          <TableRow key={row.id}>
            {row.getVisibleCells().map((cell) => (
              <TableCell key={cell.id}>
                {flexRender(cell.column.columnDef.cell, cell.getContext())}
              </TableCell>
            ))}
          </TableRow>
        ))}
      </TableBody>
    </Table>
  )
}
```

Reference: [shadcn/ui Data Table](https://ui.shadcn.com/docs/components/data-table)

### 5.5 Virtualize Large Lists and Tables

**Impact: MEDIUM-HIGH (10-100× rendering performance for large lists)**

For lists or tables with 100+ items, use virtualization to render only visible rows. Rendering all rows causes memory bloat and janky scrolling.

**Incorrect (rendering all rows):**

```tsx
function LogViewer({ logs }: { logs: LogEntry[] }) {
  return (
    <div className="h-[600px] overflow-auto">
      {logs.map((log) => (
        <div key={log.id} className="p-2 border-b">
          {/* Renders 10,000 DOM nodes for 10,000 logs */}
          <span className="text-muted-foreground">{log.timestamp}</span>
          <span className="ml-2">{log.message}</span>
        </div>
      ))}
    </div>
  )
}
```

**Correct (virtualized with TanStack Virtual):**

```tsx
import { useVirtualizer } from "@tanstack/react-virtual"

function LogViewer({ logs }: { logs: LogEntry[] }) {
  const parentRef = useRef<HTMLDivElement>(null)

  const virtualizer = useVirtualizer({
    count: logs.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 40, // Estimated row height in pixels
    overscan: 5, // Render 5 extra rows above/below viewport
  })

  return (
    <div ref={parentRef} className="h-[600px] overflow-auto">
      <div
        style={{
          height: `${virtualizer.getTotalSize()}px`,
          position: "relative",
        }}
      >
        {virtualizer.getVirtualItems().map((virtualRow) => {
          const log = logs[virtualRow.index]
          return (
            <div
              key={virtualRow.key}
              className="absolute w-full p-2 border-b"
              style={{
                height: `${virtualRow.size}px`,
                transform: `translateY(${virtualRow.start}px)`,
              }}
            >
              {/* Only ~20 DOM nodes rendered at any time */}
              <span className="text-muted-foreground">{log.timestamp}</span>
              <span className="ml-2">{log.message}</span>
            </div>
          )
        })}
      </div>
    </div>
  )
}
```

**When to virtualize:**
- Lists with 100+ items
- Tables with 50+ rows and complex cells
- Log viewers, chat histories, infinite scroll
- Any scrollable list causing jank

Reference: [TanStack Virtual](https://tanstack.com/virtual/latest)

---

## 6. Component Composition

**Impact: MEDIUM**

Combining shadcn/ui primitives using compound component patterns maximizes reusability and maintains API consistency.

### 6.1 Combine Command with Popover for Searchable Selects

**Impact: MEDIUM (reduces selection time by 3-5× for long lists)**

For searchable dropdown selection (combobox pattern), combine Command with Popover. Command provides search and keyboard navigation; Popover provides positioning.

**Incorrect (native select with no search):**

```tsx
function CountrySelect({ value, onChange }: CountrySelectProps) {
  return (
    <Select value={value} onValueChange={onChange}>
      <SelectTrigger>
        <SelectValue placeholder="Select country" />
      </SelectTrigger>
      <SelectContent>
        {countries.map((country) => (
          <SelectItem key={country.code} value={country.code}>
            {country.name}
          </SelectItem>
        ))}
        {/* 200+ countries with no way to search - poor UX */}
      </SelectContent>
    </Select>
  )
}
```

**Correct (Command + Popover combobox):**

```tsx
import { Check, ChevronsUpDown } from "lucide-react"
import { cn } from "@/lib/utils"
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"

function CountrySelect({ value, onChange }: CountrySelectProps) {
  const [open, setOpen] = useState(false)
  const selectedCountry = countries.find((c) => c.code === value)

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button
          variant="outline"
          role="combobox"
          aria-expanded={open}
          className="w-full justify-between"
        >
          {selectedCountry?.name ?? "Select country..."}
          <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-full p-0">
        <Command>
          <CommandInput placeholder="Search countries..." />
          <CommandList>
            <CommandEmpty>No country found.</CommandEmpty>
            <CommandGroup>
              {countries.map((country) => (
                <CommandItem
                  key={country.code}
                  value={country.name}
                  onSelect={() => {
                    onChange(country.code)
                    setOpen(false)
                  }}
                >
                  <Check
                    className={cn(
                      "mr-2 h-4 w-4",
                      value === country.code ? "opacity-100" : "opacity-0"
                    )}
                  />
                  {country.name}
                </CommandItem>
              ))}
            </CommandGroup>
          </CommandList>
        </Command>
      </PopoverContent>
    </Popover>
  )
}
```

**Combobox features:**
- Type to filter (CommandInput)
- Arrow keys to navigate
- Enter to select
- Escape to close
- Accessible role="combobox" with aria-expanded

Reference: [shadcn/ui Combobox](https://ui.shadcn.com/docs/components/combobox)

### 6.2 Compose with Compound Component Patterns

**Impact: MEDIUM (reduces prop count by 60-80% vs monolithic components)**

Build custom components using compound component patterns like shadcn/ui. This creates flexible, composable APIs that fit naturally with existing components.

**Incorrect (monolithic component with many props):**

```tsx
interface SettingsCardProps {
  title: string
  description: string
  icon: LucideIcon
  switchLabel: string
  switchChecked: boolean
  onSwitchChange: (checked: boolean) => void
  badge?: string
  footer?: React.ReactNode
}

function SettingsCard({
  title,
  description,
  icon: Icon,
  switchLabel,
  switchChecked,
  onSwitchChange,
  badge,
  footer,
}: SettingsCardProps) {
  // Rigid API - hard to customize layout or add new elements
  return (
    <Card>
      <CardHeader>
        <Icon className="h-5 w-5" />
        <CardTitle>{title}</CardTitle>
        {badge && <Badge>{badge}</Badge>}
      </CardHeader>
      <CardContent>
        <p>{description}</p>
        <Switch checked={switchChecked} onCheckedChange={onSwitchChange} />
      </CardContent>
      {footer && <CardFooter>{footer}</CardFooter>}
    </Card>
  )
}
```

**Correct (compound component pattern):**

```tsx
const SettingsCardContext = createContext<{ disabled?: boolean }>({})

function SettingsCard({ children, disabled }: { children: React.ReactNode; disabled?: boolean }) {
  return (
    <SettingsCardContext.Provider value={{ disabled }}>
      <Card className={cn(disabled && "opacity-50")}>{children}</Card>
    </SettingsCardContext.Provider>
  )
}

function SettingsCardHeader({ children }: { children: React.ReactNode }) {
  return <CardHeader className="flex flex-row items-center gap-4">{children}</CardHeader>
}

function SettingsCardIcon({ icon: Icon }: { icon: LucideIcon }) {
  return <Icon className="h-5 w-5 text-muted-foreground" />
}

function SettingsCardTitle({ children }: { children: React.ReactNode }) {
  return <CardTitle className="text-base">{children}</CardTitle>
}

function SettingsCardContent({ children }: { children: React.ReactNode }) {
  return <CardContent>{children}</CardContent>
}

function SettingsCardAction({ children }: { children: React.ReactNode }) {
  const { disabled } = useContext(SettingsCardContext)
  return <div className={cn(disabled && "pointer-events-none")}>{children}</div>
}

// Usage - flexible composition
<SettingsCard>
  <SettingsCardHeader>
    <SettingsCardIcon icon={Bell} />
    <SettingsCardTitle>Notifications</SettingsCardTitle>
    <Badge>Beta</Badge>
  </SettingsCardHeader>
  <SettingsCardContent>
    <p className="text-muted-foreground">Receive alerts for important updates</p>
  </SettingsCardContent>
  <SettingsCardAction>
    <Switch checked={enabled} onCheckedChange={setEnabled} />
  </SettingsCardAction>
</SettingsCard>
```

Reference: [Compound Components Pattern](https://www.patterns.dev/react/compound-pattern/)

### 6.3 Create Reusable Form Field Components

**Impact: MEDIUM (reduces boilerplate and ensures consistency)**

Extract common form field patterns into reusable components to reduce boilerplate and maintain consistency across forms.

**Incorrect (repeated form field boilerplate):**

```tsx
function UserForm() {
  const form = useForm<UserFormValues>({
    resolver: zodResolver(userSchema),
  })

  return (
    <Form {...form}>
      <FormField
        control={form.control}
        name="firstName"
        render={({ field }) => (
          <FormItem>
            <FormLabel>First Name</FormLabel>
            <FormControl>
              <Input placeholder="Enter first name" {...field} />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={form.control}
        name="lastName"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Last Name</FormLabel>
            <FormControl>
              <Input placeholder="Enter last name" {...field} />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      {/* 10 more fields with identical structure... */}
    </Form>
  )
}
```

**Correct (reusable field components):**

```tsx
// components/form/text-field.tsx
interface TextFieldProps<T extends FieldValues> {
  control: Control<T>
  name: Path<T>
  label: string
  placeholder?: string
  description?: string
  type?: "text" | "email" | "password"
}

function TextField<T extends FieldValues>({
  control,
  name,
  label,
  placeholder,
  description,
  type = "text",
}: TextFieldProps<T>) {
  return (
    <FormField
      control={control}
      name={name}
      render={({ field }) => (
        <FormItem>
          <FormLabel>{label}</FormLabel>
          <FormControl>
            <Input type={type} placeholder={placeholder} {...field} />
          </FormControl>
          {description && <FormDescription>{description}</FormDescription>}
          <FormMessage />
        </FormItem>
      )}
    />
  )
}

// components/form/select-field.tsx
interface SelectFieldProps<T extends FieldValues> {
  control: Control<T>
  name: Path<T>
  label: string
  placeholder?: string
  options: { value: string; label: string }[]
}

function SelectField<T extends FieldValues>({
  control,
  name,
  label,
  placeholder,
  options,
}: SelectFieldProps<T>) {
  return (
    <FormField
      control={control}
      name={name}
      render={({ field }) => (
        <FormItem>
          <FormLabel>{label}</FormLabel>
          <Select onValueChange={field.onChange} defaultValue={field.value}>
            <FormControl>
              <SelectTrigger>
                <SelectValue placeholder={placeholder} />
              </SelectTrigger>
            </FormControl>
            <SelectContent>
              {options.map((option) => (
                <SelectItem key={option.value} value={option.value}>
                  {option.label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          <FormMessage />
        </FormItem>
      )}
    />
  )
}

// Usage - clean and consistent
function UserForm() {
  const form = useForm<UserFormValues>({ resolver: zodResolver(userSchema) })

  return (
    <Form {...form}>
      <TextField control={form.control} name="firstName" label="First Name" />
      <TextField control={form.control} name="lastName" label="Last Name" />
      <TextField control={form.control} name="email" label="Email" type="email" />
      <SelectField
        control={form.control}
        name="role"
        label="Role"
        options={roleOptions}
      />
    </Form>
  )
}
```

Reference: [React Hook Form with TypeScript](https://react-hook-form.com/ts)

### 6.4 Nest Dialogs with Proper Focus Management

**Impact: MEDIUM (maintains focus trap hierarchy in nested modals)**

When opening a dialog from within another dialog (e.g., confirmation from settings), manage focus correctly to prevent trapping issues.

**Incorrect (nested Dialog loses focus context):**

```tsx
function SettingsDialog() {
  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button>Settings</Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Settings</DialogTitle>
        </DialogHeader>
        <div className="space-y-4">
          {/* Settings content */}
          <Dialog>
            <DialogTrigger asChild>
              <Button variant="destructive">Delete Account</Button>
            </DialogTrigger>
            <DialogContent>
              {/* Inner dialog - focus management may break */}
              <DialogTitle>Confirm Delete</DialogTitle>
            </DialogContent>
          </Dialog>
        </div>
      </DialogContent>
    </Dialog>
  )
}
```

**Correct (AlertDialog for confirmations):**

```tsx
function SettingsDialog() {
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false)

  return (
    <>
      <Dialog>
        <DialogTrigger asChild>
          <Button>Settings</Button>
        </DialogTrigger>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Settings</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            {/* Settings content */}
            <Button variant="destructive" onClick={() => setShowDeleteConfirm(true)}>
              Delete Account
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      <AlertDialog open={showDeleteConfirm} onOpenChange={setShowDeleteConfirm}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Account?</AlertDialogTitle>
            <AlertDialogDescription>
              This action cannot be undone. Your data will be permanently deleted.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleDelete}>Delete</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  )
}
```

**Alternative (DropdownMenu with modal={false}):**

```tsx
<DropdownMenu modal={false}>
  {/* When modal={false}, dropdown won't steal focus from parent dialog */}
  <DropdownMenuTrigger asChild>
    <Button variant="outline">Options</Button>
  </DropdownMenuTrigger>
  <DropdownMenuContent>
    <DropdownMenuItem onSelect={() => setShowDeleteConfirm(true)}>
      Delete
    </DropdownMenuItem>
  </DropdownMenuContent>
</DropdownMenu>
```

**Guidelines:**
- Use AlertDialog for confirmations (designed for this pattern)
- Set `modal={false}` on DropdownMenu inside Dialogs
- Manage nested dialog state in parent component

Reference: [shadcn/ui AlertDialog](https://ui.shadcn.com/docs/components/alert-dialog)

### 6.5 Use Drawer for Mobile Modal Interactions

**Impact: MEDIUM (reduces touch distance by 40-60% on mobile)**

On mobile devices, use Drawer (bottom sheet) instead of Dialog for better thumb reachability. Detect device type and render the appropriate component.

**Incorrect (Dialog on all devices):**

```tsx
function ConfirmDelete({ onConfirm }: { onConfirm: () => void }) {
  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button variant="destructive">Delete</Button>
      </DialogTrigger>
      <DialogContent>
        {/* Center-screen dialog is hard to reach on mobile */}
        <DialogHeader>
          <DialogTitle>Are you sure?</DialogTitle>
          <DialogDescription>This action cannot be undone.</DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button variant="outline">Cancel</Button>
          <Button variant="destructive" onClick={onConfirm}>Delete</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
```

**Correct (responsive Dialog/Drawer):**

```tsx
import { useMediaQuery } from "@/hooks/use-media-query"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
  DialogTrigger,
} from "@/components/ui/dialog"
import {
  Drawer,
  DrawerContent,
  DrawerHeader,
  DrawerTitle,
  DrawerDescription,
  DrawerFooter,
  DrawerTrigger,
} from "@/components/ui/drawer"

function ConfirmDelete({ onConfirm }: { onConfirm: () => void }) {
  const [open, setOpen] = useState(false)
  const isDesktop = useMediaQuery("(min-width: 768px)")

  const content = (
    <>
      <p className="text-muted-foreground">This action cannot be undone.</p>
      <div className="flex gap-2 mt-4">
        <Button variant="outline" onClick={() => setOpen(false)} className="flex-1">
          Cancel
        </Button>
        <Button variant="destructive" onClick={onConfirm} className="flex-1">
          Delete
        </Button>
      </div>
    </>
  )

  if (isDesktop) {
    return (
      <Dialog open={open} onOpenChange={setOpen}>
        <DialogTrigger asChild>
          <Button variant="destructive">Delete</Button>
        </DialogTrigger>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Are you sure?</DialogTitle>
          </DialogHeader>
          {content}
        </DialogContent>
      </Dialog>
    )
  }

  return (
    <Drawer open={open} onOpenChange={setOpen}>
      <DrawerTrigger asChild>
        <Button variant="destructive">Delete</Button>
      </DrawerTrigger>
      <DrawerContent>
        <DrawerHeader>
          <DrawerTitle>Are you sure?</DrawerTitle>
        </DrawerHeader>
        <div className="px-4 pb-4">{content}</div>
      </DrawerContent>
    </Drawer>
  )
}
```

**useMediaQuery hook:**

```tsx
function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(false)

  useEffect(() => {
    const media = window.matchMedia(query)
    setMatches(media.matches)
    const listener = (e: MediaQueryListEvent) => setMatches(e.matches)
    media.addEventListener("change", listener)
    return () => media.removeEventListener("change", listener)
  }, [query])

  return matches
}
```

Reference: [shadcn/ui Drawer](https://ui.shadcn.com/docs/components/drawer)

### 6.6 Use Slot Pattern for Flexible Content Areas

**Impact: MEDIUM (enables custom content injection without prop explosion)**

For components with multiple content areas (header, footer, actions), use named slot patterns instead of render props or excessive boolean props.

**Incorrect (render props and booleans):**

```tsx
interface NotificationProps {
  title: string
  message: string
  showIcon?: boolean
  icon?: React.ReactNode
  showDismiss?: boolean
  onDismiss?: () => void
  showAction?: boolean
  actionLabel?: string
  onAction?: () => void
  renderFooter?: () => React.ReactNode
}

function Notification({
  title,
  message,
  showIcon,
  icon,
  showDismiss,
  onDismiss,
  showAction,
  actionLabel,
  onAction,
  renderFooter,
}: NotificationProps) {
  // Props explosion - hard to extend, confusing API
  return (
    <div className="rounded-lg border p-4">
      {showIcon && icon}
      <div>
        <h4>{title}</h4>
        <p>{message}</p>
      </div>
      {showDismiss && <button onClick={onDismiss}>×</button>}
      {showAction && <button onClick={onAction}>{actionLabel}</button>}
      {renderFooter?.()}
    </div>
  )
}
```

**Correct (slot-based composition):**

```tsx
interface NotificationProps {
  children: React.ReactNode
  className?: string
}

function Notification({ children, className }: NotificationProps) {
  return (
    <div className={cn("rounded-lg border p-4", className)}>
      {children}
    </div>
  )
}

function NotificationIcon({ children }: { children: React.ReactNode }) {
  return <div className="flex-shrink-0">{children}</div>
}

function NotificationContent({ children }: { children: React.ReactNode }) {
  return <div className="flex-1 ml-3">{children}</div>
}

function NotificationTitle({ children }: { children: React.ReactNode }) {
  return <h4 className="font-medium">{children}</h4>
}

function NotificationDescription({ children }: { children: React.ReactNode }) {
  return <p className="text-sm text-muted-foreground mt-1">{children}</p>
}

function NotificationActions({ children }: { children: React.ReactNode }) {
  return <div className="flex gap-2 mt-3">{children}</div>
}

function NotificationDismiss({ onDismiss }: { onDismiss: () => void }) {
  return (
    <Button variant="ghost" size="icon" onClick={onDismiss} className="absolute top-2 right-2">
      <X className="h-4 w-4" />
      <span className="sr-only">Dismiss</span>
    </Button>
  )
}

// Usage - compose exactly what you need
<Notification className="relative">
  <NotificationIcon>
    <CheckCircle className="h-5 w-5 text-green-500" />
  </NotificationIcon>
  <NotificationContent>
    <NotificationTitle>Success!</NotificationTitle>
    <NotificationDescription>Your changes have been saved.</NotificationDescription>
    <NotificationActions>
      <Button size="sm">View</Button>
      <Button size="sm" variant="outline">Undo</Button>
    </NotificationActions>
  </NotificationContent>
  <NotificationDismiss onDismiss={() => setVisible(false)} />
</Notification>
```

Reference: [Composition vs Inheritance](https://react.dev/learn/passing-props-to-a-component)

---

## 7. Performance Optimization

**Impact: MEDIUM**

Bundle size management, lazy loading, and render optimization ensure fast load times and smooth interactions.

### 7.1 Avoid Unnecessary Re-renders in Forms

**Impact: MEDIUM (prevents full form re-render on every keystroke)**

Isolate frequently updating form state to prevent entire form re-renders. Watch specific fields instead of the entire form state.

**Incorrect (watching entire form state):**

```tsx
function CheckoutForm() {
  const form = useForm<CheckoutFormValues>()
  const values = form.watch() // Re-renders entire form on ANY field change

  const total = calculateTotal(values.items, values.coupon)

  return (
    <Form {...form}>
      {/* All 20 form fields re-render on every keystroke */}
      <FormField name="name" control={form.control} render={...} />
      <FormField name="email" control={form.control} render={...} />
      <FormField name="address" control={form.control} render={...} />
      {/* ... 17 more fields */}
      <div>Total: ${total}</div>
    </Form>
  )
}
```

**Correct (isolated watch with useWatch):**

```tsx
function CheckoutForm() {
  const form = useForm<CheckoutFormValues>()

  return (
    <Form {...form}>
      <FormField name="name" control={form.control} render={...} />
      <FormField name="email" control={form.control} render={...} />
      <FormField name="address" control={form.control} render={...} />
      {/* Fields don't re-render when unrelated fields change */}

      {/* Isolated component for reactive total */}
      <OrderTotal control={form.control} />
    </Form>
  )
}

function OrderTotal({ control }: { control: Control<CheckoutFormValues> }) {
  // Only this component re-renders when items or coupon change
  const items = useWatch({ control, name: "items" })
  const coupon = useWatch({ control, name: "coupon" })

  const total = calculateTotal(items, coupon)

  return <div className="text-lg font-bold">Total: ${total}</div>
}
```

**Alternative (watch specific fields at form level):**

```tsx
function CheckoutForm() {
  const form = useForm<CheckoutFormValues>()

  // Only watch specific fields needed for calculations
  const [items, coupon] = form.watch(["items", "coupon"])
  // Still causes re-renders but only for these 2 fields

  return (
    <Form {...form}>
      {/* ... */}
    </Form>
  )
}
```

**Best practices:**
- Use `useWatch` in isolated child components
- Watch specific field names, not entire form
- Use `useFormState` for submission/validation state
- Use `useController` for complex controlled components

Reference: [React Hook Form useWatch](https://react-hook-form.com/docs/usewatch)

### 7.2 Debounce Search and Filter Inputs

**Impact: MEDIUM (reduces API calls by 80-90% during typing)**

Debounce search inputs to prevent API calls on every keystroke. Users type 3-5 characters per second; calling the API each time overwhelms the server and UI.

**Incorrect (API call on every keystroke):**

```tsx
function SearchUsers() {
  const [query, setQuery] = useState("")
  const { data, isLoading } = useQuery(
    ["users", query],
    () => searchUsers(query),
    { enabled: query.length > 0 }
  )
  // User types "john" = 4 API calls in < 1 second

  return (
    <div className="space-y-4">
      <Input
        placeholder="Search users..."
        value={query}
        onChange={(e) => setQuery(e.target.value)}
      />
      {isLoading && <Skeleton className="h-20" />}
      {/* Results flicker between each keystroke */}
    </div>
  )
}
```

**Correct (debounced search):**

```tsx
import { useDebouncedValue } from "@/hooks/use-debounced-value"

function SearchUsers() {
  const [query, setQuery] = useState("")
  const debouncedQuery = useDebouncedValue(query, 300) // 300ms delay

  const { data, isLoading } = useQuery(
    ["users", debouncedQuery],
    () => searchUsers(debouncedQuery),
    { enabled: debouncedQuery.length > 0 }
  )
  // User types "john" = 1 API call after they stop typing

  return (
    <div className="space-y-4">
      <Input
        placeholder="Search users..."
        value={query}
        onChange={(e) => setQuery(e.target.value)}
      />
      {isLoading && <Skeleton className="h-20" />}
      {/* Stable results, no flickering */}
    </div>
  )
}
```

**useDebouncedValue hook:**

```tsx
function useDebouncedValue<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value)

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay)
    return () => clearTimeout(timer)
  }, [value, delay])

  return debouncedValue
}
```

**Recommended delays:**
- Search inputs: 300-500ms
- Autocomplete: 150-300ms
- Filter updates: 200-400ms
- Form field validation: 500ms

Reference: [use-debounce](https://github.com/xnimorz/use-debounce)

### 7.3 Lazy Load Heavy Components

**Impact: MEDIUM (reduces initial bundle by 30-50%)**

Use dynamic imports for heavy components (charts, editors, modals with complex content) to reduce initial bundle size and improve Time to Interactive.

**Incorrect (all components in initial bundle):**

```tsx
import { DataChart } from "@/components/data-chart" // 150KB
import { RichTextEditor } from "@/components/rich-text-editor" // 200KB
import { CodeEditor } from "@/components/code-editor" // 300KB

function Dashboard() {
  const [showChart, setShowChart] = useState(false)
  const [showEditor, setShowEditor] = useState(false)

  return (
    <div>
      {/* All 650KB loaded even if never used */}
      {showChart && <DataChart data={chartData} />}
      {showEditor && <RichTextEditor />}
    </div>
  )
}
```

**Correct (lazy loaded with Suspense):**

```tsx
import dynamic from "next/dynamic"
import { Skeleton } from "@/components/ui/skeleton"

const DataChart = dynamic(() => import("@/components/data-chart"), {
  loading: () => <Skeleton className="h-[400px] w-full" />,
})

const RichTextEditor = dynamic(() => import("@/components/rich-text-editor"), {
  loading: () => <Skeleton className="h-[300px] w-full" />,
  ssr: false, // Disable SSR for browser-only components
})

const CodeEditor = dynamic(() => import("@/components/code-editor"), {
  loading: () => <Skeleton className="h-[400px] w-full" />,
  ssr: false,
})

function Dashboard() {
  const [showChart, setShowChart] = useState(false)
  const [showEditor, setShowEditor] = useState(false)

  return (
    <div>
      {/* Components loaded only when rendered */}
      {showChart && <DataChart data={chartData} />}
      {showEditor && <RichTextEditor />}
    </div>
  )
}
```

**For React without Next.js:**

```tsx
import { lazy, Suspense } from "react"
import { Skeleton } from "@/components/ui/skeleton"

const DataChart = lazy(() => import("@/components/data-chart"))

function Dashboard() {
  return (
    <Suspense fallback={<Skeleton className="h-[400px] w-full" />}>
      <DataChart data={chartData} />
    </Suspense>
  )
}
```

**When to lazy load:**
- Components over 50KB
- Components not visible on initial render
- Components behind user interaction (modals, tabs)
- Heavy third-party integrations (charts, maps, editors)

Reference: [Next.js Dynamic Imports](https://nextjs.org/docs/pages/building-your-application/optimizing/lazy-loading)

### 7.4 Memoize Expensive Component Renders

**Impact: MEDIUM (prevents unnecessary re-renders in lists and data displays)**

Use `React.memo` for list items and expensive components to prevent re-renders when parent state changes but props remain the same.

**Incorrect (re-renders all rows on any change):**

```tsx
function DataTable({ data, onRowSelect }: DataTableProps) {
  const [selectedId, setSelectedId] = useState<string | null>(null)

  return (
    <Table>
      <TableBody>
        {data.map((row) => (
          <TableRow key={row.id} onClick={() => onRowSelect(row.id)}>
            {/* All 100 rows re-render when selectedId changes */}
            <TableCell>{row.name}</TableCell>
            <TableCell>{row.email}</TableCell>
            <TableCell>
              <Badge variant={row.status === "active" ? "default" : "secondary"}>
                {row.status}
              </Badge>
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  )
}
```

**Correct (memoized row component):**

```tsx
const DataTableRow = memo(function DataTableRow({
  row,
  onSelect,
}: {
  row: DataRow
  onSelect: (id: string) => void
}) {
  return (
    <TableRow onClick={() => onSelect(row.id)}>
      <TableCell>{row.name}</TableCell>
      <TableCell>{row.email}</TableCell>
      <TableCell>
        <Badge variant={row.status === "active" ? "default" : "secondary"}>
          {row.status}
        </Badge>
      </TableCell>
    </TableRow>
  )
})

function DataTable({ data, onRowSelect }: DataTableProps) {
  const [selectedId, setSelectedId] = useState<string | null>(null)

  // Stable callback reference
  const handleSelect = useCallback((id: string) => {
    setSelectedId(id)
    onRowSelect(id)
  }, [onRowSelect])

  return (
    <Table>
      <TableBody>
        {data.map((row) => (
          <DataTableRow key={row.id} row={row} onSelect={handleSelect} />
          // Only rows with changed props re-render
        ))}
      </TableBody>
    </Table>
  )
}
```

**Memoization guidelines:**
- Use `memo` for list items rendered 10+ times
- Use `useCallback` for handlers passed to memoized children
- Use `useMemo` for expensive computations
- Don't memoize everything - measure first

Reference: [React memo](https://react.dev/reference/react/memo)

### 7.5 Optimize Icon Imports from Lucide

**Impact: MEDIUM (reduces bundle by 200-500KB with direct imports)**

Import Lucide icons directly from their paths or use Next.js optimizePackageImports to avoid loading the entire icon library.

**Incorrect (barrel import loads all icons):**

```tsx
import { Check, X, Menu, Settings, User, Bell } from "lucide-react"
// In dev mode: loads 1,500+ icons, adds ~2.8s to startup
// In production: tree-shaking may not fully eliminate unused icons
```

**Correct (direct imports):**

```tsx
import Check from "lucide-react/dist/esm/icons/check"
import X from "lucide-react/dist/esm/icons/x"
import Menu from "lucide-react/dist/esm/icons/menu"
import Settings from "lucide-react/dist/esm/icons/settings"
import User from "lucide-react/dist/esm/icons/user"
import Bell from "lucide-react/dist/esm/icons/bell"
// Loads only 6 icons (~2KB each)
```

**Alternative (Next.js 13.5+ optimizePackageImports):**

```js
// next.config.js
module.exports = {
  experimental: {
    optimizePackageImports: ["lucide-react"],
  },
}
```

```tsx
// Now barrel imports are automatically optimized
import { Check, X, Menu, Settings, User, Bell } from "lucide-react"
// Next.js transforms this to direct imports at build time
```

**Creating an icon wrapper for consistency:**

```tsx
// components/icons.tsx
export { default as CheckIcon } from "lucide-react/dist/esm/icons/check"
export { default as XIcon } from "lucide-react/dist/esm/icons/x"
export { default as MenuIcon } from "lucide-react/dist/esm/icons/menu"
export { default as SettingsIcon } from "lucide-react/dist/esm/icons/settings"
// Centralized icon exports with consistent naming
```

Reference: [Vercel Package Import Optimization](https://vercel.com/blog/how-we-optimized-package-imports-in-next-js)

---

## 8. State Management

**Impact: LOW-MEDIUM**

Controlled vs uncontrolled patterns and state lifting decisions affect component predictability and debugging.

### 8.1 Colocate State with the Components That Use It

**Impact: LOW-MEDIUM (improves code organization and reduces unnecessary coupling)**

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

### 8.2 Lift State to the Appropriate Level

**Impact: LOW-MEDIUM (prevents prop drilling and enables component communication)**

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

### 8.3 Prefer Uncontrolled Components for Simple Inputs

**Impact: LOW-MEDIUM (reduces state management overhead for simple cases)**

For inputs that don't need real-time value access (search forms, quick filters), use uncontrolled components with refs or form data to reduce state overhead.

**Incorrect (controlled state for simple search):**

```tsx
function SimpleSearch({ onSearch }: { onSearch: (query: string) => void }) {
  const [query, setQuery] = useState("")

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    onSearch(query)
  }

  return (
    <form onSubmit={handleSubmit}>
      <Input
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search..."
      />
      {/* Re-renders component on every keystroke */}
      <Button type="submit">Search</Button>
    </form>
  )
}
```

**Correct (uncontrolled with form data):**

```tsx
function SimpleSearch({ onSearch }: { onSearch: (query: string) => void }) {
  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)
    const query = formData.get("query") as string
    onSearch(query)
  }

  return (
    <form onSubmit={handleSubmit}>
      <Input name="query" placeholder="Search..." />
      {/* No re-renders during typing */}
      <Button type="submit">Search</Button>
    </form>
  )
}
```

**Alternative (useRef for imperative access):**

```tsx
function QuickFilter({ onFilter }: { onFilter: (value: string) => void }) {
  const inputRef = useRef<HTMLInputElement>(null)

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Enter") {
      onFilter(inputRef.current?.value ?? "")
    }
  }

  return (
    <Input
      ref={inputRef}
      placeholder="Filter..."
      onKeyDown={handleKeyDown}
    />
  )
}
```

**Use controlled state when:**
- You need real-time validation feedback
- The value is used elsewhere in the UI (character count, preview)
- You need to programmatically change the value
- Using React Hook Form (which handles this efficiently)

**Use uncontrolled when:**
- Value only needed on submit
- Simple forms with no real-time requirements
- Performance is critical in large forms

Reference: [React Uncontrolled Components](https://react.dev/learn/sharing-state-between-components#controlled-and-uncontrolled-components)

### 8.4 Use Controlled State for Dialogs Triggered Externally

**Impact: LOW-MEDIUM (enables programmatic dialog control from parent components)**

When dialogs need to be opened from parent components or through programmatic events, use controlled state (`open`/`onOpenChange` props) instead of relying on the internal trigger.

**Incorrect (uncontrolled dialog, hard to open programmatically):**

```tsx
function UserRow({ user }: { user: User }) {
  return (
    <TableRow>
      <TableCell>{user.name}</TableCell>
      <TableCell>
        <Dialog>
          <DialogTrigger asChild>
            <Button size="sm">Edit</Button>
          </DialogTrigger>
          <DialogContent>
            <EditUserForm user={user} />
          </DialogContent>
        </Dialog>
        {/* Cannot open this dialog from parent table component */}
      </TableCell>
    </TableRow>
  )
}

function UsersTable() {
  const handleBulkEdit = () => {
    // No way to programmatically open edit dialog for selected users
  }
}
```

**Correct (controlled dialog state):**

```tsx
function UserRow({
  user,
  editOpen,
  onEditOpenChange,
}: {
  user: User
  editOpen: boolean
  onEditOpenChange: (open: boolean) => void
}) {
  return (
    <TableRow>
      <TableCell>{user.name}</TableCell>
      <TableCell>
        <Button size="sm" onClick={() => onEditOpenChange(true)}>
          Edit
        </Button>
        <Dialog open={editOpen} onOpenChange={onEditOpenChange}>
          <DialogContent>
            <EditUserForm user={user} onSuccess={() => onEditOpenChange(false)} />
          </DialogContent>
        </Dialog>
      </TableCell>
    </TableRow>
  )
}

function UsersTable({ users }: { users: User[] }) {
  const [editingUserId, setEditingUserId] = useState<string | null>(null)

  const handleBulkEdit = (userId: string) => {
    setEditingUserId(userId) // Programmatically open dialog
  }

  return (
    <Table>
      <TableBody>
        {users.map((user) => (
          <UserRow
            key={user.id}
            user={user}
            editOpen={editingUserId === user.id}
            onEditOpenChange={(open) => setEditingUserId(open ? user.id : null)}
          />
        ))}
      </TableBody>
    </Table>
  )
}
```

**Alternative (dialog state in parent, dialog content separate):**

```tsx
function UsersTable({ users }: { users: User[] }) {
  const [editingUser, setEditingUser] = useState<User | null>(null)

  return (
    <>
      <Table>
        <TableBody>
          {users.map((user) => (
            <TableRow key={user.id}>
              <TableCell>{user.name}</TableCell>
              <TableCell>
                <Button size="sm" onClick={() => setEditingUser(user)}>
                  Edit
                </Button>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>

      <Dialog open={!!editingUser} onOpenChange={(open) => !open && setEditingUser(null)}>
        <DialogContent>
          {editingUser && <EditUserForm user={editingUser} />}
        </DialogContent>
      </Dialog>
    </>
  )
}
```

Reference: [Radix Dialog Controlled](https://www.radix-ui.com/primitives/docs/components/dialog#api-reference)

---

## References

1. [https://ui.shadcn.com/](https://ui.shadcn.com/)
2. [https://www.radix-ui.com/primitives/docs/overview/accessibility](https://www.radix-ui.com/primitives/docs/overview/accessibility)
3. [https://vercel.com/academy/shadcn-ui](https://vercel.com/academy/shadcn-ui)
4. [https://react-hook-form.com/](https://react-hook-form.com/)
5. [https://tailwindcss.com/](https://tailwindcss.com/)
6. [https://cva.style/docs](https://cva.style/docs)
7. [https://tanstack.com/table/latest](https://tanstack.com/table/latest)
8. [https://tanstack.com/virtual/latest](https://tanstack.com/virtual/latest)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |