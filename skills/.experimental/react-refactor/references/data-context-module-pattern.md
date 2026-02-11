---
title: Use Context Module Pattern for Action Colocation
impact: MEDIUM
impactDescription: reduces mutation surface to single file per context
tags: data, context-module, actions, colocation
---

## Use Context Module Pattern for Action Colocation

When actions that mutate shared state are scattered across consuming components, tracing data flow requires searching the entire codebase. Each consumer re-implements dispatch calls with its own payload shapes, creating subtle inconsistencies. Colocating actions alongside the context provider keeps all mutations in one file and exports named functions that encapsulate dispatch details.

**Incorrect (actions scattered across consumers — data flow untraceable):**

```tsx
// NotificationContext.tsx
const NotificationContext = createContext<{
  notifications: Notification[];
  dispatch: React.Dispatch<NotificationAction>;
} | null>(null);

export function NotificationProvider({ children }: { children: React.ReactNode }) {
  const [notifications, dispatch] = useReducer(notificationReducer, []);
  return (
    <NotificationContext value={{ notifications, dispatch }}>{children}</NotificationContext>
  );
}

// Header.tsx — consumer builds dispatch calls inline
function Header() {
  const { dispatch } = use(NotificationContext)!;
  const handleDismiss = (id: string) => {
    dispatch({ type: "DISMISS", payload: { id } });
  };
  // ...
}

// Sidebar.tsx — duplicates dispatch logic with different shape risk
function Sidebar() {
  const { dispatch } = use(NotificationContext)!;
  const addAlert = (message: string) => {
    dispatch({ type: "ADD", payload: { id: crypto.randomUUID(), message, level: "warning" } });
  };
  // ...
}
```

**Correct (context module pattern — actions colocated with provider):**

```tsx
// NotificationContext.tsx — actions live next to the reducer
const NotificationContext = createContext<{
  notifications: Notification[];
  dispatch: React.Dispatch<NotificationAction>;
} | null>(null);

export function NotificationProvider({ children }: { children: React.ReactNode }) {
  const [notifications, dispatch] = useReducer(notificationReducer, []);
  return (
    <NotificationContext value={{ notifications, dispatch }}>{children}</NotificationContext>
  );
}

// Named action creators — single source of truth for mutation shapes
export function dismissNotification(
  dispatch: React.Dispatch<NotificationAction>,
  id: string,
) {
  dispatch({ type: "DISMISS", payload: { id } });
}

export function addAlert(
  dispatch: React.Dispatch<NotificationAction>,
  message: string,
) {
  dispatch({ type: "ADD", payload: { id: crypto.randomUUID(), message, level: "warning" } });
}

// Header.tsx — consumes named action, no dispatch details leaked
import { dismissNotification } from "./NotificationContext";

function Header() {
  const { notifications, dispatch } = use(NotificationContext)!;
  return (
    <ul>
      {notifications.map((n) => (
        <li key={n.id}>
          {n.message}
          <button onClick={() => dismissNotification(dispatch, n.id)}>Dismiss</button>
        </li>
      ))}
    </ul>
  );
}
```

Reference: [Kent C. Dodds - The State Reducer Pattern with React Hooks](https://kentcdodds.com/blog/the-state-reducer-pattern-with-react-hooks)
