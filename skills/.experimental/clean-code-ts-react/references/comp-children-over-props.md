---
title: Compose with Children Over Configuration Props
impact: MEDIUM-HIGH
impactDescription: inverts variation from props-explosion to caller composition
tags: comp, composition, children, compound-components
---

## Compose with Children Over Configuration Props

A component with 15 boolean and slot props quickly becomes a god component that has to know every possible variation. Accepting `children` (or named-slot children, the compound-component pattern) inverts the relationship — the caller composes the variation, and the component just provides structure and behavior. New use cases stop adding props.

**Incorrect (props explosion; every new variant adds a prop):**

```tsx
// Card knows about titles, subtitles, images, actions, footers, dismiss.
// The next variant — a badge in the header — adds a sixteenth prop.
type CardProps = {
  title: string;
  subtitle?: string;
  imageUrl?: string;
  actions?: ReactNode[];
  footer?: ReactNode;
  dismissible?: boolean;
  bordered?: boolean;
  elevation?: 0 | 1 | 2 | 3;
};

<Card
  title="Order #123"
  subtitle="Shipped"
  imageUrl="/box.png"
  actions={[<button key="cancel">Cancel</button>]}
  footer={<small>2 items</small>}
  dismissible
  elevation={2}
/>
```

**Correct (compound components; caller composes structure):**

```tsx
// Card provides structure; the call site composes variation.
// Adding a badge needs no new prop on Card.
<Card elevation={2}>
  <Card.Header>
    <Card.Image src="/box.png" />
    <Card.Title>Order #123</Card.Title>
    <Card.Subtitle>Shipped</Card.Subtitle>
  </Card.Header>
  <Card.Actions>
    <button>Cancel</button>
  </Card.Actions>
  <Card.Footer><small>2 items</small></Card.Footer>
</Card>
```

**When NOT to apply this pattern:**
- Tightly-constrained design systems where the prop API IS the contract — Button with `variant`/`size`/`intent` is intentionally closed.
- Accessibility-critical components — letting consumers freely compose children into a `Combobox` invites broken ARIA relationships.
- Trivially simple components where children make the call site less readable than a clear prop — `<Tooltip text="Save" />` beats `<Tooltip><TooltipText>Save</TooltipText></Tooltip>`.

**Why this matters:** Letting callers compose moves variation knowledge out of the component, the same way pure cores move framework knowledge out of business logic — small surfaces, many use cases.

Reference: [Clean Code, Chapter 10: Classes (substituted: Composition)](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [React Docs: Passing JSX as children](https://react.dev/learn/passing-props-to-a-component#passing-jsx-as-children)
