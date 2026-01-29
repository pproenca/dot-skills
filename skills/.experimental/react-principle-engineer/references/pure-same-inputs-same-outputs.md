---
title: Same inputs must produce same outputs
impact: HIGH
impactDescription: Deterministic rendering enables caching, concurrent features, and predictable debugging
tags: [pure, rendering, determinism, predictability]
---

# Same Inputs Must Produce Same Outputs

Given the same props, state, and context, a component must always return the same JSX. This is the core contract that enables React's optimizations.

## Why This Matters

When components are deterministic:
- React can skip re-rendering unchanged components (`React.memo`)
- Concurrent rendering can safely interrupt and restart
- Server-side rendering produces consistent HTML
- Time-travel debugging works correctly
- Tests are reliable and reproducible

**Incorrect (anti-pattern):**

```tsx
// Problem: Output depends on external state (current time)
function WelcomeMessage({ name }: { name: string }) {
  const hour = new Date().getHours();

  // Different renders at different times produce different greetings
  // even with the same `name` prop
  if (hour < 12) {
    return <h1>Good morning, {name}!</h1>;
  } else if (hour < 18) {
    return <h1>Good afternoon, {name}!</h1>;
  } else {
    return <h1>Good evening, {name}!</h1>;
  }
}
```

**Correct (recommended):**

```tsx
// Solution: Time-dependent value comes from props/state
function WelcomeMessage({ name, currentHour }: {
  name: string;
  currentHour: number;
}) {
  if (currentHour < 12) {
    return <h1>Good morning, {name}!</h1>;
  } else if (currentHour < 18) {
    return <h1>Good afternoon, {name}!</h1>;
  } else {
    return <h1>Good evening, {name}!</h1>;
  }
}

// Parent manages the time state
function App() {
  const [currentHour, setCurrentHour] = useState(new Date().getHours());

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentHour(new Date().getHours());
    }, 60000);
    return () => clearInterval(interval);
  }, []);

  return <WelcomeMessage name="Alice" currentHour={currentHour} />;
}
```

**Incorrect (another anti-pattern):**

```tsx
// Problem: Using Math.random() during render
function RandomAvatar({ user }: { user: User }) {
  // Each render picks a different avatar!
  const avatarIndex = Math.floor(Math.random() * 10);
  return <img src={`/avatars/${avatarIndex}.png`} alt={user.name} />;
}
```

**Correct (alternative approach):**

```tsx
// Solution: Derive "random" value deterministically from props
function RandomAvatar({ user }: { user: User }) {
  // Same user always gets same avatar (hash the ID)
  const avatarIndex = Math.abs(hashCode(user.id)) % 10;
  return <img src={`/avatars/${avatarIndex}.png`} alt={user.name} />;
}

function hashCode(str: string): number {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    hash = (hash << 5) - hash + str.charCodeAt(i);
  }
  return hash;
}
```

**Incorrect (another anti-pattern):**

```tsx
// Problem: Reading from global/mutable state during render
let globalTheme = 'light';

function ThemedButton({ children }: { children: React.ReactNode }) {
  // If globalTheme changes, this component won't know to re-render
  return (
    <button className={globalTheme === 'dark' ? 'btn-dark' : 'btn-light'}>
      {children}
    </button>
  );
}
```

**Correct (alternative approach):**

```tsx
// Solution: Use context for global state
function ThemedButton({ children }: { children: React.ReactNode }) {
  const theme = useContext(ThemeContext);

  return (
    <button className={theme === 'dark' ? 'btn-dark' : 'btn-light'}>
      {children}
    </button>
  );
}
```

## Key Principle

Your component is a pure function: `props + state + context => JSX`. Any value that can change and affect the output must be part of those inputs, not read from external sources during render.
