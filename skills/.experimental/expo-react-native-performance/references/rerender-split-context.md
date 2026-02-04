---
title: Split Context by Update Frequency
impact: HIGH
impactDescription: prevents cascading re-renders across app
tags: rerender, context, state-management, splitting
---

## Split Context by Update Frequency

A single context with frequently-changing values causes all consumers to re-render. Split context into separate providers based on update frequency to limit re-render scope.

**Incorrect (one context, all consumers re-render):**

```typescript
// contexts/AppContext.tsx
const AppContext = createContext<{
  user: User;
  theme: Theme;
  notifications: Notification[];  // Updates frequently
} | null>(null);

export function AppProvider({ children }: Props) {
  const [user, setUser] = useState<User | null>(null);
  const [theme, setTheme] = useState<Theme>('light');
  const [notifications, setNotifications] = useState<Notification[]>([]);

  return (
    <AppContext.Provider value={{ user, theme, notifications }}>
      {children}
    </AppContext.Provider>
  );
}
// Every component using user or theme re-renders on new notification
```

**Correct (split by update frequency):**

```typescript
// contexts/UserContext.tsx - rarely changes
const UserContext = createContext<User | null>(null);

// contexts/ThemeContext.tsx - rarely changes
const ThemeContext = createContext<Theme>('light');

// contexts/NotificationsContext.tsx - changes frequently
const NotificationsContext = createContext<Notification[]>([]);

// App.tsx
export function AppProvider({ children }: Props) {
  const [user, setUser] = useState<User | null>(null);
  const [theme, setTheme] = useState<Theme>('light');
  const [notifications, setNotifications] = useState<Notification[]>([]);

  return (
    <UserContext.Provider value={user}>
      <ThemeContext.Provider value={theme}>
        <NotificationsContext.Provider value={notifications}>
          {children}
        </NotificationsContext.Provider>
      </ThemeContext.Provider>
    </UserContext.Provider>
  );
}
// Only notification consumers re-render on new notification
```

**Alternative:** Use state management libraries like Zustand or Jotai that allow selective subscriptions.

Reference: [React Context](https://react.dev/learn/passing-data-deeply-with-context)
