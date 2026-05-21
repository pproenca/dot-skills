```tsx
import {
  useState,
  useMemo,
  useTransition,
  useId,
  type ChangeEvent,
} from "react";

interface Product {
  id: number;
  name: string;
}

function generateProducts(count: number): Product[] {
  return Array.from({ length: count }, (_, i) => ({
    id: i + 1,
    name: `Product ${i + 1} – ${Math.random().toString(36).slice(2, 8)}`,
  }));
}

const ALL_PRODUCTS: Product[] = generateProducts(5_000);

export default function ProductSearch() {
  const inputId = useId();
  const [query, setQuery] = useState("");
  const [isPending, startTransition] = useTransition();
  const [deferredQuery, setDeferredQuery] = useState("");

  function handleChange(e: ChangeEvent<HTMLInputElement>) {
    const value = e.target.value;
    setQuery(value);
    startTransition(() => {
      setDeferredQuery(value);
    });
  }

  const filtered = useMemo(() => {
    const lower = deferredQuery.toLowerCase();
    return lower === ""
      ? ALL_PRODUCTS
      : ALL_PRODUCTS.filter((p) => p.name.toLowerCase().includes(lower));
  }, [deferredQuery]);

  return (
    <div>
      <label htmlFor={inputId}>Search products</label>
      <input
        id={inputId}
        type="search"
        value={query}
        onChange={handleChange}
        placeholder="Type to filter…"
        autoComplete="off"
      />
      {isPending && <span aria-live="polite"> Filtering…</span>}
      <p>{filtered.length} result(s)</p>
      <ul style={{ opacity: isPending ? 0.6 : 1 }}>
        {filtered.map((p) => (
          <li key={p.id}>{p.name}</li>
        ))}
      </ul>
    </div>
  );
}
```

The input stays responsive because `useTransition` marks the filtered-list state update as non-urgent: React commits the new `query` value immediately (keeping the caret and typed character visible), then applies the `deferredQuery` update — and the expensive `useMemo` filter — in a lower-priority render that can be interrupted if the user types again. `useMemo` avoids re-running the O(n) filter on every render unrelated to the query, and the stable `ALL_PRODUCTS` constant ensures the list is generated only once rather than on every component mount.
