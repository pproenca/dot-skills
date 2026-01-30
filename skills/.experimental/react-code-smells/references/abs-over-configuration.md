---
title: Prefer Composition Over Configuration
impact: HIGH
impactDescription: reduces component API surface by 60%, increases flexibility
tags: abs, composition, configuration, props-explosion, flexibility
---

## Prefer Composition Over Configuration

Components with many configuration props become rigid and hard to extend. Replace configuration with composition for flexibility.

**Code Smell Indicators:**
- Component has 15+ props
- Many boolean flags (showHeader, showFooter, withIcon)
- Props like `headerRenderer`, `footerRenderer`
- New feature requires new prop

**Incorrect (configuration-heavy):**

```tsx
interface DataTableProps {
  data: Row[]
  columns: Column[]
  // Configuration explosion
  sortable?: boolean
  filterable?: boolean
  paginated?: boolean
  pageSize?: number
  selectable?: boolean
  onSelectionChange?: (rows: Row[]) => void
  expandable?: boolean
  onExpand?: (row: Row) => void
  rowActions?: Action[]
  bulkActions?: Action[]
  emptyState?: React.ReactNode
  loadingState?: React.ReactNode
  headerRenderer?: () => React.ReactNode
  footerRenderer?: () => React.ReactNode
  rowClassName?: (row: Row) => string
  onRowClick?: (row: Row) => void
  stickyHeader?: boolean
  virtualized?: boolean
  // ... 20 more props
}

function DataTable(props: DataTableProps) {
  // 500 lines of conditional logic
}
```

**Correct (composition-based):**

```tsx
// Core table is simple
interface TableProps {
  children: React.ReactNode
}

function Table({ children }: TableProps) {
  return <table className="data-table">{children}</table>
}

// Features are composable
function TableHeader({ children }) {
  return <thead>{children}</thead>
}

function TableBody({ children }) {
  return <tbody>{children}</tbody>
}

function TableRow({ children, onClick, className }) {
  return <tr onClick={onClick} className={className}>{children}</tr>
}

function TableCell({ children }) {
  return <td>{children}</td>
}

// Sorting is a separate composable concern
function SortableHeader({ column, sortState, onSort, children }) {
  return (
    <th onClick={() => onSort(column)}>
      {children}
      {sortState.column === column && (
        <SortIcon direction={sortState.direction} />
      )}
    </th>
  )
}

// Selection is a separate composable concern
function useTableSelection(rows) {
  const [selected, setSelected] = useState(new Set())
  // ... selection logic
  return { selected, toggleRow, selectAll, clearSelection }
}

// Usage: compose exactly what you need
function ProductTable({ products }) {
  const [sort, setSort] = useState({ column: 'name', direction: 'asc' })
  const selection = useTableSelection(products)
  const sorted = useSorted(products, sort)
  const paged = usePagination(sorted, { pageSize: 20 })

  return (
    <div>
      <BulkActions selection={selection} />
      <Table>
        <TableHeader>
          <tr>
            <th><SelectAll {...selection} /></th>
            <SortableHeader column="name" sortState={sort} onSort={setSort}>
              Name
            </SortableHeader>
            <SortableHeader column="price" sortState={sort} onSort={setSort}>
              Price
            </SortableHeader>
            <th>Actions</th>
          </tr>
        </TableHeader>
        <TableBody>
          {paged.items.map(product => (
            <TableRow key={product.id}>
              <TableCell><Checkbox checked={selection.selected.has(product.id)} /></TableCell>
              <TableCell>{product.name}</TableCell>
              <TableCell><Price amount={product.price} /></TableCell>
              <TableCell><ProductActions product={product} /></TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
      <Pagination {...paged} />
    </div>
  )
}
```

**Benefits:**
- Add features without modifying Table
- Only pay for what you use
- Features can be tested independently
- Clear composition over hidden configuration

**When configuration is OK:**
- Small, finite set of variations (variant='primary' | 'secondary')
- Styling props (size, color)
- Behavior that doesn't affect structure

Reference: [Composition vs Configuration](https://kentcdodds.com/blog/inversion-of-control)
