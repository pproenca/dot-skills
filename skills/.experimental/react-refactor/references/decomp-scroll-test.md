---
title: Apply the Scroll Test to Identify Oversized Components
impact: HIGH
impactDescription: reduces component size to under 100 lines, 3× faster code review
tags: decomp, component-size, readability, extraction
---

## Apply the Scroll Test to Identify Oversized Components

If you must scroll to read a component from top to bottom, it contains multiple responsibilities that should be separate components. Large components accumulate unrelated state, making every change risky and every review slow.

**Incorrect (single component owns header, filters, table, and pagination):**

```tsx
function OrderDashboard() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [sortField, setSortField] = useState<keyof Order>("createdAt");
  const [currentPage, setCurrentPage] = useState(1);
  const [selectedOrders, setSelectedOrders] = useState<Set<string>>(new Set());
  const [isExporting, setIsExporting] = useState(false);

  const filteredOrders = orders.filter(
    (order) => order.customerName.toLowerCase().includes(searchQuery.toLowerCase())
  );
  const paginatedOrders = filteredOrders.slice(
    (currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE
  );

  async function handleExport() {
    setIsExporting(true);
    await exportOrdersCsv(orders.filter((o) => selectedOrders.has(o.id)));
    setIsExporting(false);
  }

  // 7 state variables, filtering, sorting, pagination, export — all in one component
  return (
    <div>
      <header>
        <h1>Orders</h1>
        <button onClick={handleExport} disabled={isExporting}>Export CSV</button>
      </header>
      <input value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} />
      <table>
        <thead>
          <tr>{COLUMNS.map((col) => (
            <th key={col} onClick={() => setSortField(col)}>{col}</th>
          ))}</tr>
        </thead>
        <tbody>
          {paginatedOrders.map((order) => (
            <tr key={order.id}>
              <td>{order.id}</td>
              <td>{order.customerName}</td>
              <td>{formatCurrency(order.total)}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <Pagination current={currentPage} total={filteredOrders.length} onChange={setCurrentPage} />
    </div>
  );
}
```

**Correct (each visual boundary becomes its own focused component):**

```tsx
function OrderDashboard() {
  const [orders] = useState<Order[]>([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [sortField, setSortField] = useState<keyof Order>("createdAt");
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("desc");
  const [currentPage, setCurrentPage] = useState(1);

  const filteredOrders = filterOrders(orders, searchQuery);
  const sortedOrders = sortOrders(filteredOrders, sortField, sortDirection);
  const totalPages = Math.ceil(filteredOrders.length / PAGE_SIZE);
  const paginatedOrders = paginate(sortedOrders, currentPage, PAGE_SIZE);

  return (
    <div>
      <OrderDashboardHeader orders={orders} />
      <OrderSearchBar query={searchQuery} onQueryChange={setSearchQuery} />
      <OrderTable
        orders={paginatedOrders}
        sortField={sortField}
        onSortChange={setSortField}
      />
      <Pagination
        currentPage={currentPage}
        totalPages={totalPages}
        onPageChange={setCurrentPage}
      />
    </div>
  );
}

function OrderDashboardHeader({ orders }: { orders: Order[] }) {
  const [isExporting, setIsExporting] = useState(false);

  async function handleExport() {
    setIsExporting(true);
    await exportOrdersCsv(orders);
    setIsExporting(false);
  }

  return (
    <header>
      <h1>Orders</h1>
      <button onClick={handleExport} disabled={isExporting}>
        {isExporting ? "Exporting..." : "Export CSV"}
      </button>
    </header>
  );
}
```

Reference: [Thinking in React](https://react.dev/learn/thinking-in-react)
