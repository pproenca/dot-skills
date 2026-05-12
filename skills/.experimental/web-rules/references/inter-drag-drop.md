---
title: Provide a Keyboard-Accessible Alternative Whenever Drag Is Offered
impact: CRITICAL
impactDescription: WCAG 2.5.7 (AA in 2.2) requires drag operations to have a non-drag alternative; 100% of keyboard, motor-disabled, and screen-reader users cannot drag with a mouse
tags: inter, drag-drop, reorder, dnd-kit, accessibility, wcag-2-5-7
---

## Provide a Keyboard-Accessible Alternative Whenever Drag Is Offered

Drag-and-drop is fine, but never the only way to perform an action. Use `@dnd-kit/core` because it ships built-in keyboard support (Space to pick up, arrows to move, Space again to drop, Escape to cancel) and screen-reader live-region announcements. For simple reorder lists, also provide "Move up" / "Move down" buttons in a row's overflow menu.

**Incorrect (HTML5 native DnD — keyboard inaccessible, no fallback):**

```tsx
function SortableList({ items }: { items: Item[] }) {
  return (
    <ul>
      {items.map((item) => (
        <li
          key={item.id}
          draggable
          onDragStart={(e) => e.dataTransfer.setData('id', item.id)}
          onDrop={(e) => moveItem(e.dataTransfer.getData('id'), item.id)}
          onDragOver={(e) => e.preventDefault()}
        >
          {item.name}
        </li>
      ))}
    </ul>
  )
}
```

**Correct (@dnd-kit with keyboard sensor + visible drag handle + overflow alternative):**

```tsx
'use client'
import { DndContext, KeyboardSensor, PointerSensor, useSensor, useSensors } from '@dnd-kit/core'
import { SortableContext, useSortable, sortableKeyboardCoordinates, arrayMove } from '@dnd-kit/sortable'
import { CSS } from '@dnd-kit/utilities'
import { GripVertical } from 'lucide-react'

function SortableRow({ item, onMoveUp, onMoveDown }: {
  item: Item; onMoveUp: () => void; onMoveDown: () => void
}) {
  const { attributes, listeners, setNodeRef, transform, transition } = useSortable({ id: item.id })
  return (
    <li
      ref={setNodeRef}
      style={{ transform: CSS.Transform.toString(transform), transition }}
      className="flex items-center gap-2 p-2"
    >
      <button
        {...attributes}
        {...listeners}
        aria-label={`Reorder ${item.name}`}
        className="size-11 inline-flex items-center justify-center cursor-grab"
      >
        <GripVertical className="size-4" />
      </button>
      <span className="flex-1">{item.name}</span>
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button size="icon" variant="ghost" aria-label={`Actions for ${item.name}`}>
            <MoreHorizontal className="size-4" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent>
          <DropdownMenuItem onSelect={onMoveUp}>Move up</DropdownMenuItem>
          <DropdownMenuItem onSelect={onMoveDown}>Move down</DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </li>
  )
}

export function SortableList({ items, setItems }: { items: Item[]; setItems: (i: Item[]) => void }) {
  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor, { coordinateGetter: sortableKeyboardCoordinates }),
  )
  return (
    <DndContext
      sensors={sensors}
      onDragEnd={({ active, over }) => {
        if (over && active.id !== over.id) {
          const oldIndex = items.findIndex((i) => i.id === active.id)
          const newIndex = items.findIndex((i) => i.id === over.id)
          setItems(arrayMove(items, oldIndex, newIndex))
        }
      }}
    >
      <SortableContext items={items.map((i) => i.id)}>
        <ul>
          {items.map((item, i) => (
            <SortableRow
              key={item.id}
              item={item}
              onMoveUp={() => i > 0 && setItems(arrayMove(items, i, i - 1))}
              onMoveDown={() => i < items.length - 1 && setItems(arrayMove(items, i, i + 1))}
            />
          ))}
        </ul>
      </SortableContext>
    </DndContext>
  )
}
```

**Rule:**
- Always use a library (`@dnd-kit/core`, `react-aria` `useDrop`) — never raw HTML5 `draggable`
- Drag handle is a visible, focusable element with `aria-label`
- A keyboard-only path exists ("Move up" / "Move down" or arrow-key reorder)
- After drop, announce the new position via live region (dnd-kit does this automatically when `announcements` are configured)
- Persist the new order via Server Action; revalidate the route after success

Reference: [WCAG 2.5.7 Dragging Movements](https://www.w3.org/WAI/WCAG22/Understanding/dragging-movements.html) · [@dnd-kit accessibility](https://docs.dndkit.com/guides/accessibility)
