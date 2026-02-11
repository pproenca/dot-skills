---
title: Use Dependency Injection for External Services
impact: MEDIUM
impactDescription: enables testing without mocking modules, 3x faster test setup
tags: couple, dependency-injection, testability, decoupling
---

## Use Dependency Injection for External Services

Direct imports of API clients and external services weld a component to a specific implementation. Every test must mock the module system, and swapping providers requires editing component internals. Injecting services through props or context decouples components from infrastructure and makes tests trivial.

**Incorrect (hard import — coupled to specific HTTP client):**

```tsx
import { apiClient } from "@/lib/apiClient";

interface OrderSummaryProps {
  orderId: string;
}

// Component is untestable without jest.mock or equivalent module override
export function OrderSummary({ orderId }: OrderSummaryProps) {
  const [order, setOrder] = useState<Order | null>(null);

  useEffect(() => {
    apiClient.get(`/orders/${orderId}`).then(setOrder);
  }, [orderId]);

  if (!order) return <Skeleton />;
  return (
    <div>
      <h2>{order.vendor}</h2>
      <p>Total: ${order.total}</p>
    </div>
  );
}
```

**Correct (injected service — swappable and testable):**

```tsx
interface OrderService {
  getOrder: (orderId: string) => Promise<Order>;
}

const OrderServiceContext = createContext<OrderService | null>(null);

export function OrderServiceProvider({
  service,
  children,
}: {
  service: OrderService;
  children: React.ReactNode;
}) {
  return <OrderServiceContext value={service}>{children}</OrderServiceContext>;
}

export function OrderSummary({ orderId }: { orderId: string }) {
  const orderService = use(OrderServiceContext)!;
  const [order, setOrder] = useState<Order | null>(null);

  useEffect(() => {
    orderService.getOrder(orderId).then(setOrder);
  }, [orderId, orderService]);

  if (!order) return <Skeleton />;
  return (
    <div>
      <h2>{order.vendor}</h2>
      <p>Total: ${order.total}</p>
    </div>
  );
}

// Test — no module mocking needed
const fakeService: OrderService = {
  getOrder: async () => ({ id: "1", vendor: "Acme", total: 99 }),
};
render(
  <OrderServiceProvider service={fakeService}>
    <OrderSummary orderId="1" />
  </OrderServiceProvider>
);
```

Reference: [Kent C. Dodds - Inversion of Control](https://kentcdodds.com/blog/inversion-of-control)
