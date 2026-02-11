---
title: Prefer Integration Tests for Component Verification
impact: MEDIUM
impactDescription: catches 40% more bugs than isolated unit tests
tags: safety, integration-tests, testing-strategy, confidence
---

## Prefer Integration Tests for Component Verification

Unit testing each component in isolation with mocked children and dependencies proves that individual pieces work, but misses the bugs that occur when pieces connect. Integration tests render the feature as the user experiences it, catching prop mismatches, context misconfiguration, and event propagation failures that isolated tests never see.

**Incorrect (isolated unit tests — each passes, feature broken):**

```tsx
// Each test passes independently but misses integration bugs

test("SearchInput calls onSearch with query", async () => {
  const onSearch = vi.fn();
  render(<SearchInput onSearch={onSearch} />);
  await userEvent.type(screen.getByRole("searchbox"), "laptop");
  await userEvent.click(screen.getByRole("button", { name: "Search" }));
  expect(onSearch).toHaveBeenCalledWith("laptop");
});

test("ProductGrid renders products", () => {
  const products = [{ id: "1", name: "Laptop", price: 999 }];
  render(<ProductGrid products={products} />);
  expect(screen.getByText("Laptop")).toBeInTheDocument();
});

test("FilterPanel calls onFilterChange", async () => {
  const onFilterChange = vi.fn();
  render(<FilterPanel onFilterChange={onFilterChange} />);
  await userEvent.click(screen.getByLabelText("In Stock"));
  expect(onFilterChange).toHaveBeenCalledWith({ inStock: true });
});

// Bug: SearchInput passes { query: "laptop" } but ProductGrid expects string
// Bug: FilterPanel resets search results — not caught by isolated tests
```

**Correct (integration test — feature tested as user experiences it):**

```tsx
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { http, HttpResponse } from "msw";
import { server } from "@/test/mswServer";

test("search and filter products end to end", async () => {
  server.use(
    http.get("/api/products", ({ request }) => {
      const url = new URL(request.url);
      const query = url.searchParams.get("q");
      const inStock = url.searchParams.get("inStock");
      const products = [
        { id: "1", name: "Laptop Pro", price: 999, inStock: true },
        { id: "2", name: "Laptop Air", price: 799, inStock: false },
      ].filter((p) =>
        (!query || p.name.toLowerCase().includes(query)) &&
        (!inStock || p.inStock)
      );
      return HttpResponse.json(products);
    }),
  );

  const user = userEvent.setup();
  render(<ProductSearchPage />);

  await user.type(screen.getByRole("searchbox"), "laptop");
  await user.click(screen.getByRole("button", { name: "Search" }));
  expect(await screen.findAllByRole("article")).toHaveLength(2);

  await user.click(screen.getByLabelText("In Stock"));
  expect(await screen.findAllByRole("article")).toHaveLength(1);
  expect(screen.getByText("Laptop Pro")).toBeInTheDocument();
});
```

Reference: [Kent C. Dodds - Write tests. Not too many. Mostly integration.](https://kentcdodds.com/blog/write-tests)
