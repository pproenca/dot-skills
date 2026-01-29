---
title: Use context to avoid prop drilling
impact: MEDIUM
impactDescription: Context passes data through the component tree without explicit props at each level
tags: [context, prop-drilling, global-state, theme]
---

# Use Context to Avoid Prop Drilling

When data needs to be accessible by many components at different nesting levels, Context provides it directly without passing through intermediate components.

## The Problem: Prop Drilling

```tsx
// Problem: Props passed through components that don't use them
function App() {
  const [theme, setTheme] = useState('light');

  return (
    <Layout theme={theme}>                    {/* Doesn't use theme */}
      <Sidebar theme={theme}>                  {/* Doesn't use theme */}
        <Navigation theme={theme}>             {/* Doesn't use theme */}
          <NavItem theme={theme}>Click</NavItem>  {/* Uses theme */}
        </Navigation>
      </Sidebar>
    </Layout>
  );
}
```

## The Solution: Context

```tsx
// Create context
const ThemeContext = createContext<Theme>('light');

// Provide at top
function App() {
  const [theme, setTheme] = useState<Theme>('light');

  return (
    <ThemeContext value={theme}>
      <Layout>
        <Sidebar>
          <Navigation>
            <NavItem>Click</NavItem>  {/* Gets theme from context */}
          </Navigation>
        </Sidebar>
      </Layout>
    </ThemeContext>
  );
}

// Consume where needed
function NavItem({ children }: { children: React.ReactNode }) {
  const theme = useContext(ThemeContext);

  return (
    <button className={theme === 'dark' ? 'btn-dark' : 'btn-light'}>
      {children}
    </button>
  );
}
```

## Common Use Cases

```tsx
// 1. Theme
const ThemeContext = createContext<'light' | 'dark'>('light');

// 2. Current user
const UserContext = createContext<User | null>(null);

// 3. Locale/i18n
const LocaleContext = createContext<Locale>('en-US');

// 4. Router
const RouterContext = createContext<Router>(defaultRouter);

// 5. Feature flags
const FeatureFlagContext = createContext<FeatureFlags>(defaultFlags);
```

## Before Context, Try Alternatives

```tsx
// 1. Just pass props if drilling is shallow
// 2-3 levels is often fine
<Parent data={data}>
  <Child data={data}>
    <Grandchild data={data} />
  </Child>
</Parent>

// 2. Use component composition
function App() {
  const user = useUser();

  return (
    <Layout>
      <Sidebar>
        {/* Pass the rendered component, not the data */}
        <UserAvatar user={user} />
      </Sidebar>
    </Layout>
  );
}

// 3. Consider if components should be reorganized
```

## Context Is Not Global State

```tsx
// Context provides dependency injection, not global state
// You can have multiple providers with different values

function App() {
  return (
    <ThemeContext value="light">
      <Header />
      <ThemeContext value="dark">
        {/* This section uses dark theme */}
        <Sidebar />
      </ThemeContext>
    </ThemeContext>
  );
}
```

## Key Principle

Context is for data that's needed by many components at different nesting levels. For data needed by one or few components, props are clearer. Don't use Context just to avoid a few levels of prop passing.
