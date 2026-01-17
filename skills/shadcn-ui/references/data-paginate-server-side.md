---
title: Paginate Large Datasets Server-Side
impact: MEDIUM-HIGH
impactDescription: reduces initial payload by 90%+ for large datasets
tags: data, pagination, server-side, api, performance
---

## Paginate Large Datasets Server-Side

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
