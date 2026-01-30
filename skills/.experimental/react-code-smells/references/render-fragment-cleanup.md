---
title: Use Fragments to Avoid Wrapper Divs
impact: LOW-MEDIUM
impactDescription: cleaner DOM, prevents CSS layout issues
tags: render, fragments, wrapper-divs, dom, cleanup
---

## Use Fragments to Avoid Wrapper Divs

Extra wrapper divs pollute the DOM and can break CSS layouts. Use fragments when you need to return multiple elements.

**Code Smell Indicators:**
- Extra divs just to satisfy "single root" requirement
- CSS grid/flexbox issues from unexpected wrappers
- Deep DOM nesting without purpose
- Semantic issues from non-semantic wrappers

**Incorrect (unnecessary wrapper divs):**

```tsx
function UserInfo({ user }) {
  return (
    // Wrapper div only exists to return two elements
    <div>
      <dt>{user.name}</dt>
      <dd>{user.email}</dd>
    </div>
  )
}

// Breaks dl semantics
<dl>
  <UserInfo user={user1} />  {/* div breaks dt/dd relationship */}
  <UserInfo user={user2} />
</dl>
```

```tsx
function TableRow({ cells }) {
  return (
    <tr>
      {cells.map(cell => (
        // Wrapper div breaks table layout
        <div key={cell.id}>
          <td>{cell.value}</td>
          {cell.extra && <td>{cell.extra}</td>}
        </div>
      ))}
    </tr>
  )
}
```

**Correct (fragments):**

```tsx
function UserInfo({ user }) {
  return (
    // Fragment has no DOM representation
    <>
      <dt>{user.name}</dt>
      <dd>{user.email}</dd>
    </>
  )
}

// Proper dl structure maintained
<dl>
  <UserInfo user={user1} />
  <UserInfo user={user2} />
</dl>
```

```tsx
function TableCells({ cells }) {
  return (
    <>
      {cells.map(cell => (
        <Fragment key={cell.id}>
          <td>{cell.value}</td>
          {cell.extra && <td>{cell.extra}</td>}
        </Fragment>
      ))}
    </>
  )
}

// Table structure intact
<tr>
  <TableCells cells={rowCells} />
</tr>
```

**Fragment with key (for lists):**

```tsx
import { Fragment } from 'react'

function Glossary({ items }) {
  return (
    <dl>
      {items.map(item => (
        // Fragment accepts key prop
        <Fragment key={item.id}>
          <dt>{item.term}</dt>
          <dd>{item.definition}</dd>
        </Fragment>
      ))}
    </dl>
  )
}
```

**When wrappers ARE needed:**

```tsx
// Need a DOM element for:
// - CSS styling (flexbox item, grid item)
// - Event handling
// - Ref attachment
// - CSS-in-JS className

function Card({ children }) {
  return (
    <div className="card" onClick={handleClick}>  {/* Wrapper needed */}
      {children}
    </div>
  )
}
```

**Fragment patterns:**

| Pattern | Use Case |
|---------|----------|
| `<>...</>` | Simple multiple elements |
| `<Fragment>...</Fragment>` | When you need key prop |
| `<div>...</div>` | When you need styling/events/refs |

Reference: [Fragment](https://react.dev/reference/react/Fragment)
