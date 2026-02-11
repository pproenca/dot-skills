---
title: Complete Component Extraction Without Half-Measures
impact: HIGH
impactDescription: enables independent testing and reuse of extracted component
tags: decomp, extraction, encapsulation, props
---

## Complete Component Extraction Without Half-Measures

Extracted components that still reach into their parent's state or internals provide no isolation benefit. They create the illusion of separation while keeping the coupling intact, making the code harder to understand than before extraction.

**Incorrect (extracted child still reads parent state directly via shared ref):**

```tsx
// Parent holds all state; child reaches back into parent's ref
const formStateRef = useRef<FormState>(null);

function InvoiceForm() {
  const [lineItems, setLineItems] = useState<LineItem[]>([]);
  const [discount, setDiscount] = useState(0);
  const [taxRate, setTaxRate] = useState(0.2);

  formStateRef.current = { lineItems, discount, taxRate };

  return (
    <div>
      <LineItemEditor />
      <InvoiceSummary />
    </div>
  );
}

function InvoiceSummary() {
  // Reaches into parent's ref — cannot be tested or reused independently
  const { lineItems, discount, taxRate } = formStateRef.current!;
  const subtotal = lineItems.reduce((sum, li) => sum + li.price * li.quantity, 0);
  const tax = subtotal * taxRate;
  const total = subtotal - discount + tax;

  return (
    <div>
      <span>Subtotal: {formatCurrency(subtotal)}</span>
      <span>Discount: -{formatCurrency(discount)}</span>
      <span>Tax: {formatCurrency(tax)}</span>
      <strong>Total: {formatCurrency(total)}</strong>
    </div>
  );
}
```

**Correct (extracted child receives all data through props):**

```tsx
function InvoiceForm() {
  const [lineItems, setLineItems] = useState<LineItem[]>([]);
  const [discount, setDiscount] = useState(0);
  const [taxRate, setTaxRate] = useState(0.2);

  return (
    <div>
      <LineItemEditor items={lineItems} onItemsChange={setLineItems} />
      <InvoiceSummary
        lineItems={lineItems}
        discount={discount}
        taxRate={taxRate}
      />
    </div>
  );
}

interface InvoiceSummaryProps {
  lineItems: LineItem[];
  discount: number;
  taxRate: number;
}

// Fully self-contained — testable with any props, reusable anywhere
function InvoiceSummary({ lineItems, discount, taxRate }: InvoiceSummaryProps) {
  const subtotal = lineItems.reduce((sum, li) => sum + li.price * li.quantity, 0);
  const tax = subtotal * taxRate;
  const total = subtotal - discount + tax;

  return (
    <div>
      <span>Subtotal: {formatCurrency(subtotal)}</span>
      <span>Discount: -{formatCurrency(discount)}</span>
      <span>Tax: {formatCurrency(tax)}</span>
      <strong>Total: {formatCurrency(total)}</strong>
    </div>
  );
}
```

Reference: [Passing Props to a Component](https://react.dev/learn/passing-props-to-a-component)
