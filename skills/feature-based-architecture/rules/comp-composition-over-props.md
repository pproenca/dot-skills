---
title: Prefer Composition Over Prop Drilling
impact: MEDIUM-HIGH
impactDescription: Eliminates prop drilling; enables flexible slot-based component design
tags: comp, composition, children, slots
---

## Prefer Composition Over Prop Drilling

When components need to render content from different features, use composition (children, render props, slots) instead of passing data down through multiple layers. This keeps components decoupled and flexible.

**Incorrect (prop drilling):**

```typescript
// Props must pass through every layer
function Page({ user, cart, notifications }) {
  return <Layout user={user} cart={cart} notifications={notifications} />;
}

function Layout({ user, cart, notifications }) {
  return (
    <div>
      <Header user={user} cart={cart} notifications={notifications} />
      <Content />
    </div>
  );
}

function Header({ user, cart, notifications }) {
  return (
    <header>
      <UserMenu user={user} />
      <CartIcon cart={cart} />
      <NotificationBell notifications={notifications} />
    </header>
  );
}
```

**Correct (composition with slots):**

```typescript
// Layout accepts composed children
interface LayoutProps {
  header: ReactNode;
  children: ReactNode;
}

function Layout({ header, children }: LayoutProps) {
  return (
    <div>
      <header>{header}</header>
      <main>{children}</main>
    </div>
  );
}

// Page composes features at the top level
function Page() {
  return (
    <Layout
      header={
        <>
          <UserMenu />      {/* Feature handles its own data */}
          <CartIcon />      {/* Feature handles its own data */}
          <NotificationBell /> {/* Feature handles its own data */}
        </>
      }
    >
      <MainContent />
    </Layout>
  );
}
```

**Render props for flexible rendering:**

```typescript
interface DataTableProps<T> {
  data: T[];
  renderRow: (item: T) => ReactNode;
  renderEmpty?: () => ReactNode;
}

function DataTable<T>({ data, renderRow, renderEmpty }: DataTableProps<T>) {
  if (data.length === 0) {
    return renderEmpty?.() ?? <EmptyState />;
  }
  return <table><tbody>{data.map(renderRow)}</tbody></table>;
}

// Usage - feature controls rendering
<DataTable
  data={users}
  renderRow={(user) => <UserRow user={user} />}
  renderEmpty={() => <NoUsersMessage />}
/>
```

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)
