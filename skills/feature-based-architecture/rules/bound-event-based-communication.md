---
title: Use Events for Cross-Feature Communication
impact: MEDIUM-HIGH
impactDescription: Decouples features at runtime; enables loose coupling without direct imports
tags: bound, events, communication, decoupling
---

## Use Events for Cross-Feature Communication

When features must communicate without direct dependencies, use an event-based approach. This keeps features loosely coupled while allowing them to react to each other's actions.

**Incorrect (direct coupling):**

```typescript
// src/features/order/hooks/useOrder.ts
import { clearCart } from '@/features/cart/stores/cartStore';
import { showNotification } from '@/features/notification/stores/notificationStore';
import { sendAnalytics } from '@/features/analytics/utils/analytics';

export function useOrder() {
  async function submitOrder(data: OrderData) {
    const order = await createOrder(data);

    // Directly calling into other features
    clearCart();
    showNotification({ type: 'success', message: 'Order placed!' });
    sendAnalytics('order_completed', { orderId: order.id });
  }
}
```

**Correct (event-based communication):**

```typescript
// src/shared/events/eventBus.ts
type EventMap = {
  'order:completed': { orderId: string; total: number };
  'order:failed': { error: string };
  'user:logged-in': { userId: string };
  'user:logged-out': void;
};

export const eventBus = createEventBus<EventMap>();

// src/features/order/hooks/useOrder.ts
import { eventBus } from '@/shared/events/eventBus';

export function useOrder() {
  async function submitOrder(data: OrderData) {
    const order = await createOrder(data);
    eventBus.emit('order:completed', { orderId: order.id, total: order.total });
  }
}

// src/features/cart/hooks/useCartSync.ts
import { eventBus } from '@/shared/events/eventBus';
import { useCartStore } from '../stores/cartStore';

export function useCartSync() {
  useEffect(() => {
    return eventBus.on('order:completed', () => {
      useCartStore.getState().clearCart();
    });
  }, []);
}

// src/features/notification/hooks/useOrderNotifications.ts
import { eventBus } from '@/shared/events/eventBus';

export function useOrderNotifications() {
  useEffect(() => {
    return eventBus.on('order:completed', ({ orderId }) => {
      showNotification({ type: 'success', message: `Order ${orderId} placed!` });
    });
  }, []);
}
```

**Benefits:**
- Order feature doesn't know about cart, notifications, or analytics
- New features can subscribe to events without modifying order
- Easy to test each feature in isolation

Reference: [Feature-Sliced Design](https://feature-sliced.design/)
