---
title: Extract Headless Components for Reusable Behavior
impact: HIGH
impactDescription: separates behavior from presentation, enables 5× more reuse scenarios
tags: comp, headless, hooks, behavior, reuse
---

## Extract Headless Components for Reusable Behavior

When multiple components share behavior but differ in appearance, extract a headless component that provides logic without rendering.

**Code Smell Indicators:**
- Similar state machines across different UIs
- Copy-pasted keyboard handlers
- Multiple modals with same open/close logic
- Tab components with same activation logic but different styles

**Incorrect (behavior locked to specific UI):**

```tsx
function Dropdown({ items, onSelect }) {
  const [isOpen, setIsOpen] = useState(false)
  const [highlightedIndex, setHighlightedIndex] = useState(0)
  const containerRef = useRef()

  // Keyboard navigation
  useEffect(() => {
    function handleKeyDown(e) {
      if (!isOpen) return
      switch (e.key) {
        case 'ArrowDown':
          setHighlightedIndex(i => Math.min(i + 1, items.length - 1))
          break
        case 'ArrowUp':
          setHighlightedIndex(i => Math.max(i - 1, 0))
          break
        case 'Enter':
          onSelect(items[highlightedIndex])
          setIsOpen(false)
          break
        case 'Escape':
          setIsOpen(false)
          break
      }
    }
    document.addEventListener('keydown', handleKeyDown)
    return () => document.removeEventListener('keydown', handleKeyDown)
  }, [isOpen, items, highlightedIndex, onSelect])

  // Click outside to close
  useEffect(() => {
    function handleClickOutside(e) {
      if (containerRef.current && !containerRef.current.contains(e.target)) {
        setIsOpen(false)
      }
    }
    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  // All this behavior is locked to this specific dropdown UI
  return (
    <div ref={containerRef} className="dropdown">
      <button onClick={() => setIsOpen(!isOpen)}>Toggle</button>
      {isOpen && (
        <ul className="dropdown-menu">
          {items.map((item, i) => (
            <li
              key={item.id}
              className={i === highlightedIndex ? 'highlighted' : ''}
              onClick={() => { onSelect(item); setIsOpen(false) }}
            >
              {item.label}
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
```

**Correct (headless hook provides behavior):**

```tsx
// Headless hook - behavior only, no rendering
function useListbox<T>({ items, onSelect }: { items: T[], onSelect: (item: T) => void }) {
  const [isOpen, setIsOpen] = useState(false)
  const [highlightedIndex, setHighlightedIndex] = useState(0)

  const open = () => setIsOpen(true)
  const close = () => setIsOpen(false)
  const toggle = () => setIsOpen(o => !o)

  const highlightNext = () => setHighlightedIndex(i => Math.min(i + 1, items.length - 1))
  const highlightPrev = () => setHighlightedIndex(i => Math.max(i - 1, 0))
  const selectHighlighted = () => {
    onSelect(items[highlightedIndex])
    close()
  }

  const getContainerProps = () => ({
    onKeyDown: (e: KeyboardEvent) => {
      if (!isOpen) return
      switch (e.key) {
        case 'ArrowDown': e.preventDefault(); highlightNext(); break
        case 'ArrowUp': e.preventDefault(); highlightPrev(); break
        case 'Enter': selectHighlighted(); break
        case 'Escape': close(); break
      }
    },
  })

  const getTriggerProps = () => ({
    onClick: toggle,
    'aria-expanded': isOpen,
    'aria-haspopup': 'listbox' as const,
  })

  const getOptionProps = (index: number) => ({
    role: 'option' as const,
    'aria-selected': index === highlightedIndex,
    onClick: () => { onSelect(items[index]); close() },
    onMouseEnter: () => setHighlightedIndex(index),
  })

  return {
    isOpen, highlightedIndex,
    open, close, toggle,
    getContainerProps, getTriggerProps, getOptionProps,
  }
}

// Now any UI can use the behavior
function Dropdown({ items, onSelect }) {
  const listbox = useListbox({ items, onSelect })

  return (
    <div {...listbox.getContainerProps()}>
      <button {...listbox.getTriggerProps()}>Toggle</button>
      {listbox.isOpen && (
        <ul role="listbox">
          {items.map((item, i) => (
            <li key={item.id} {...listbox.getOptionProps(i)}>{item.label}</li>
          ))}
        </ul>
      )}
    </div>
  )
}

function CommandPalette({ commands, onSelect }) {
  const listbox = useListbox({ items: commands, onSelect })
  // Completely different UI, same behavior!
  return (
    <dialog open={listbox.isOpen}>
      {commands.map((cmd, i) => (
        <button key={cmd.id} {...listbox.getOptionProps(i)}>
          <Icon name={cmd.icon} />
          <span>{cmd.name}</span>
          <kbd>{cmd.shortcut}</kbd>
        </button>
      ))}
    </dialog>
  )
}
```

**Pattern benefits:**
- Behavior tested once, reused everywhere
- UI can change without touching logic
- Accessibility built into the hook
- Different design systems can share behavior

Reference: [Headless UI Pattern](https://www.merrickchristensen.com/articles/headless-user-interface-components/)
