---
title: Separate Container Logic from Presentational Components
impact: CRITICAL
impactDescription: enables independent testing and Storybook preview
tags: arch, container, presentational, testability, separation-of-concerns
---

## Separate Container Logic from Presentational Components

Components that mix data fetching, state management, and rendering are hard to test because tests must mock network calls just to verify visual output. Extracting data logic into a container hook lets the presentational component accept plain props, making it independently testable and previewable in Storybook.

**Incorrect (fetch + state + render fused in one component):**

```tsx
function InvoiceList() {
  const [invoices, setInvoices] = useState<Invoice[]>([]);
  const [sortField, setSortField] = useState<"date" | "amount">("date");
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    setIsLoading(true);
    fetchInvoices(sortField)
      .then(setInvoices)
      .finally(() => setIsLoading(false));
  }, [sortField]);

  // Testing the table layout requires mocking fetchInvoices
  if (isLoading) return <Skeleton rows={5} />;

  return (
    <table>
      <thead>
        <tr>
          <th onClick={() => setSortField("date")}>Date</th>
          <th onClick={() => setSortField("amount")}>Amount</th>
        </tr>
      </thead>
      <tbody>
        {invoices.map((inv) => (
          <tr key={inv.id}>
            <td>{inv.date.toLocaleDateString()}</td>
            <td>{formatCurrency(inv.amount)}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
```

**Correct (container hook + pure presentational component):**

```tsx
function useInvoiceList() {
  const [invoices, setInvoices] = useState<Invoice[]>([]);
  const [sortField, setSortField] = useState<"date" | "amount">("date");
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    setIsLoading(true);
    fetchInvoices(sortField)
      .then(setInvoices)
      .finally(() => setIsLoading(false));
  }, [sortField]);

  return { invoices, sortField, setSortField, isLoading };
}

// Pure presentational — testable with plain props, no mocks needed
function InvoiceTable({ invoices, sortField, onSortChange }: InvoiceTableProps) {
  return (
    <table>
      <thead>
        <tr>
          <th onClick={() => onSortChange("date")}>Date</th>
          <th onClick={() => onSortChange("amount")}>Amount</th>
        </tr>
      </thead>
      <tbody>
        {invoices.map((inv) => (
          <tr key={inv.id}>
            <td>{inv.date.toLocaleDateString()}</td>
            <td>{formatCurrency(inv.amount)}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

function InvoiceList() {
  const { invoices, sortField, setSortField, isLoading } = useInvoiceList();
  if (isLoading) return <Skeleton rows={5} />;
  return <InvoiceTable invoices={invoices} sortField={sortField} onSortChange={setSortField} />;
}
```

Reference: [React Docs - Reusing Logic with Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)
