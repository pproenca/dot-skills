---
title: Use Stable, Unique Keys for Lists
impact: HIGH
impactDescription: prevents state bugs, enables efficient reconciliation
tags: render, keys, lists, reconciliation, performance
---

## Use Stable, Unique Keys for Lists

Incorrect keys cause state to persist incorrectly across items or force unnecessary re-renders. Use stable, unique identifiers.

**Code Smell Indicators:**
- Using array index as key
- Key warnings in console
- Form inputs losing values when list changes
- Animations not working correctly on list changes

**Incorrect (index keys cause bugs):**

```tsx
function TodoList({ todos, onToggle, onDelete }) {
  return (
    <ul>
      {todos.map((todo, index) => (
        // Index key: state gets out of sync when items reorder or delete
        <li key={index}>
          <input
            type="checkbox"
            checked={todo.completed}
            onChange={() => onToggle(todo.id)}
          />
          {todo.text}
          <button onClick={() => onDelete(todo.id)}>Delete</button>
        </li>
      ))}
    </ul>
  )
}

// Bug: Delete item 0, item 1's checkbox state moves to item 0
// Bug: Reorder items, checkbox states don't follow
```

**Incorrect (non-unique keys):**

```tsx
function CommentList({ comments }) {
  return (
    <ul>
      {comments.map(comment => (
        // userName is not unique - multiple comments from same user
        <li key={comment.userName}>
          {comment.text}
        </li>
      ))}
    </ul>
  )
}
```

**Correct (stable unique IDs):**

```tsx
function TodoList({ todos, onToggle, onDelete }) {
  return (
    <ul>
      {todos.map(todo => (
        // Use the item's unique ID
        <li key={todo.id}>
          <input
            type="checkbox"
            checked={todo.completed}
            onChange={() => onToggle(todo.id)}
          />
          {todo.text}
          <button onClick={() => onDelete(todo.id)}>Delete</button>
        </li>
      ))}
    </ul>
  )
}
```

**When index key is OK:**

```tsx
// Static list that never changes order, items never added/removed
function StaticNavigation() {
  const links = ['Home', 'About', 'Contact']  // Hardcoded, never changes

  return (
    <nav>
      {links.map((link, index) => (
        <a key={index} href={`/${link.toLowerCase()}`}>{link}</a>
      ))}
    </nav>
  )
}
```

**Generate IDs when needed:**

```tsx
import { nanoid } from 'nanoid'

function AddTodoForm({ onAdd }) {
  const [text, setText] = useState('')

  function handleSubmit(e) {
    e.preventDefault()
    onAdd({
      id: nanoid(),  // Generate unique ID when creating
      text,
      completed: false,
    })
    setText('')
  }

  return (
    <form onSubmit={handleSubmit}>
      <input value={text} onChange={e => setText(e.target.value)} />
      <button type="submit">Add</button>
    </form>
  )
}
```

**Compound keys for nested data:**

```tsx
function ThreadedComments({ threads }) {
  return (
    <div>
      {threads.map(thread => (
        <div key={thread.id}>
          <Comment comment={thread} />
          {thread.replies.map(reply => (
            // Combine parent + child for uniqueness within full tree
            <Comment key={`${thread.id}-${reply.id}`} comment={reply} indent />
          ))}
        </div>
      ))}
    </div>
  )
}
```

**Key checklist:**
```
Good key:
├── Unique among siblings
├── Stable (same item = same key across renders)
├── Derived from data (not generated during render)
└── Not array index (unless truly static list)
```

Reference: [Rendering Lists](https://react.dev/learn/rendering-lists#keeping-list-items-in-order-with-key)
