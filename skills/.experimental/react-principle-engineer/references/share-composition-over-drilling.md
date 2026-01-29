---
title: Use composition to avoid prop drilling
impact: MEDIUM
impactDescription: Passing components as children or props can reduce the number of intermediate components that need to forward props
tags: [share, sharing, composition, drilling, children]
---

# Use Composition to Avoid Prop Drilling

Before reaching for Context, consider whether restructuring your components can eliminate prop drilling. Often, passing components (not just data) solves the problem more elegantly.

## Why This Matters

Composition:
- Reduces coupling between intermediate components
- Makes data flow more direct
- Avoids Context when it's not needed
- Keeps components focused on their job

**Incorrect (the problem):** Prop Drilling

```tsx
// Problem: Props drilled through components that don't use them
function App() {
  const [user, setUser] = useState<User | null>(null);

  return (
    <Layout user={user}>  {/* Layout doesn't use user */}
      <Content user={user}>  {/* Content doesn't use user */}
        <Header user={user}>  {/* Header doesn't use user */}
          <Avatar user={user} />  {/* Finally uses user! */}
        </Header>
      </Content>
    </Layout>
  );
}

function Layout({ user, children }: Props) {
  // Doesn't use user, just passes it through
  return <div className="layout">{children}</div>;
}

function Content({ user, children }: Props) {
  // Doesn't use user, just passes it through
  return <main>{children}</main>;
}

function Header({ user, children }: Props) {
  // Doesn't use user, just passes it through
  return <header>{children}</header>;
}
```

## Solution: Pass the Component

```tsx
// Solution: Pass the Avatar component directly
function App() {
  const [user, setUser] = useState<User | null>(null);

  return (
    <Layout>
      <Content>
        <Header
          avatar={<Avatar user={user} />}  // Pass component, not data
        />
      </Content>
    </Layout>
  );
}

function Layout({ children }: { children: React.ReactNode }) {
  return <div className="layout">{children}</div>;
}

function Content({ children }: { children: React.ReactNode }) {
  return <main>{children}</main>;
}

function Header({ avatar }: { avatar: React.ReactNode }) {
  return (
    <header>
      <nav>...</nav>
      {avatar}  {/* Just renders what it receives */}
    </header>
  );
}
```

## Using Children for Composition

```tsx
// Instead of passing data through, define the tree at the top

// Problem: Data passed down through the tree
function Page() {
  const theme = useTheme();
  return (
    <Layout theme={theme}>
      <Sidebar theme={theme}>
        <Button theme={theme}>Click</Button>
      </Sidebar>
    </Layout>
  );
}

// Solution: Use children to compose directly
function Page() {
  const theme = useTheme();

  return (
    <Layout>
      <Sidebar>
        <Button theme={theme}>Click</Button>  {/* Gets theme directly */}
      </Sidebar>
    </Layout>
  );
}

function Layout({ children }: { children: React.ReactNode }) {
  return <div className="layout">{children}</div>;
}

function Sidebar({ children }: { children: React.ReactNode }) {
  return <aside>{children}</aside>;
}
```

## Slot Pattern for Complex Layouts

```tsx
// Use "slot" props for flexible composition
interface PageLayoutProps {
  header: React.ReactNode;
  sidebar: React.ReactNode;
  content: React.ReactNode;
  footer?: React.ReactNode;
}

function PageLayout({ header, sidebar, content, footer }: PageLayoutProps) {
  return (
    <div className="page">
      <header>{header}</header>
      <div className="body">
        <aside>{sidebar}</aside>
        <main>{content}</main>
      </div>
      {footer && <footer>{footer}</footer>}
    </div>
  );
}

// Usage: components passed directly, no drilling
function App() {
  const [user, setUser] = useState<User | null>(null);

  return (
    <PageLayout
      header={<UserHeader user={user} />}
      sidebar={<Navigation user={user} />}
      content={<Dashboard user={user} />}
      footer={<Footer />}
    />
  );
}
```

## Render Props for Dynamic Composition

```tsx
// When child needs data from middle component
function MouseTracker({ children }: {
  children: (position: Position) => React.ReactNode
}) {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  return (
    <div onMouseMove={e => setPosition({ x: e.clientX, y: e.clientY })}>
      {children(position)}
    </div>
  );
}

// Parent decides what to render with the position
function App() {
  return (
    <MouseTracker>
      {position => (
        <div>
          Mouse is at ({position.x}, {position.y})
          <Cursor position={position} />
        </div>
      )}
    </MouseTracker>
  );
}
```

## When Composition Isn't Enough

Use Context when:
- Many components at different nesting levels need the same data
- Data changes frequently and affects deeply nested components
- Prop drilling would require changes to many intermediate components

```tsx
// Context is appropriate when:
// - Theme affects 50+ components at various depths
// - User auth status is needed throughout the app
// - Locale/language needs to be accessible everywhere
```

## Key Principle

Think about component structure before reaching for Context. Often, moving component instantiation higher in the tree and passing components (not just data) eliminates the need to drill props through middle layers.
