---
title: Understand event propagation and stopping
impact: MEDIUM
impactDescription: Events bubble up the tree by default; use stopPropagation to prevent parent handlers from firing
tags: [event, propagation, bubbling, stopPropagation, preventDefault]
---

# Understand Event Propagation and Stopping

Events in React bubble up the component tree, just like in the DOM. Understanding when to stop propagation or prevent default behavior is essential.

## Event Bubbling

```tsx
function Toolbar() {
  return (
    <div onClick={() => console.log('Toolbar clicked')}>
      <button onClick={() => console.log('Button clicked')}>
        Click me
      </button>
    </div>
  );
}

// Clicking the button logs:
// 1. "Button clicked"
// 2. "Toolbar clicked"
// Events bubble up from child to parent
```

## Stopping Propagation

```tsx
function Toolbar() {
  return (
    <div onClick={() => console.log('Toolbar clicked')}>
      <button onClick={(e) => {
        e.stopPropagation();  // Stop bubbling
        console.log('Button clicked');
      }}>
        Click me
      </button>
    </div>
  );
}

// Clicking the button logs:
// 1. "Button clicked"
// Parent handler doesn't fire
```

## Prevent Default Behavior

```tsx
function Form() {
  function handleSubmit(e: FormEvent) {
    e.preventDefault();  // Prevents page reload
    console.log('Submitting...');
  }

  return (
    <form onSubmit={handleSubmit}>
      <button type="submit">Submit</button>
    </form>
  );
}

function Link() {
  function handleClick(e: MouseEvent) {
    e.preventDefault();  // Prevents navigation
    console.log('Link clicked, but not navigating');
  }

  return (
    <a href="/page" onClick={handleClick}>
      Click me
    </a>
  );
}
```

## Practical Example: Modal

```tsx
function Modal({ onClose, children }: ModalProps) {
  return (
    // Clicking backdrop closes modal
    <div className="backdrop" onClick={onClose}>
      {/* Clicking content should NOT close modal */}
      <div className="content" onClick={e => e.stopPropagation()}>
        {children}
        <button onClick={onClose}>Close</button>
      </div>
    </div>
  );
}
```

## Capture Phase

```tsx
// Events can also be handled during capture phase (top-down)
function Parent() {
  return (
    <div
      onClickCapture={() => console.log('Parent capture')}
      onClick={() => console.log('Parent bubble')}
    >
      <button
        onClickCapture={() => console.log('Button capture')}
        onClick={() => console.log('Button bubble')}
      >
        Click
      </button>
    </div>
  );
}

// Order: Parent capture → Button capture → Button bubble → Parent bubble
```

## When to Stop Propagation

```tsx
// DO stop propagation when:
// - Child handles the event completely
// - Parent handler would conflict
// - Dropdown/modal should not trigger backdrop close

// DON'T stop propagation when:
// - You want analytics on parent to still fire
// - You want focus management on parent
// - Event delegation relies on bubbling
```

## Combined Example

```tsx
function Card({ onClick }: { onClick: () => void }) {
  function handleButtonClick(e: MouseEvent) {
    e.stopPropagation();  // Don't trigger card click
    console.log('Button action');
  }

  function handleLinkClick(e: MouseEvent) {
    e.preventDefault();   // Don't navigate
    e.stopPropagation();  // Don't trigger card click
    console.log('Link action');
  }

  return (
    <div className="card" onClick={onClick}>
      <h2>Card Title</h2>
      <button onClick={handleButtonClick}>Action</button>
      <a href="/details" onClick={handleLinkClick}>Details</a>
    </div>
  );
}
```

## Key Principle

Events bubble by default. Use `stopPropagation()` when you want to handle an event exclusively. Use `preventDefault()` to cancel browser default behavior. Use both when needed.
