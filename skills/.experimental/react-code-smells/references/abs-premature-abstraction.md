---
title: Resist Premature Abstraction (Rule of Three)
impact: HIGH
impactDescription: prevents wrong abstractions that cost 3-5× more to fix than duplication
tags: abs, premature-abstraction, rule-of-three, yagni, refactoring
---

## Resist Premature Abstraction (Rule of Three)

Creating abstractions before you have 3 concrete use cases leads to wrong abstractions. Duplication is cheaper than the wrong abstraction.

**Code Smell Indicators:**
- Abstract class/hook created after first use case
- "This might be useful elsewhere" without concrete need
- Abstraction has parameters for hypothetical variations
- Changing the abstraction requires changing all consumers

**Incorrect (abstraction after first use case):**

```tsx
// After building UserCard, immediately abstract to "EntityCard"
function EntityCard<T extends { id: string; name: string }>({
  entity,
  renderHeader,
  renderBody,
  renderFooter,
  variant = 'default',
  size = 'md',
  onAction,
  actionLabel,
  // ... 10 more params for hypothetical variations
}: EntityCardProps<T>) {
  // Complex logic to handle all possible variations
  return (
    <Card variant={variant} size={size}>
      {renderHeader?.(entity) ?? <CardHeader>{entity.name}</CardHeader>}
      {renderBody?.(entity)}
      {renderFooter?.(entity) ?? (
        <CardFooter>
          {onAction && <Button onClick={() => onAction(entity)}>{actionLabel}</Button>}
        </CardFooter>
      )}
    </Card>
  )
}

// UserCard, ProductCard, and OrderCard all use EntityCard
// but each fights against its assumptions
```

**Correct (wait for three concrete cases):**

```tsx
// First use case: just build it
function UserCard({ user, onEdit }) {
  return (
    <Card>
      <CardHeader>
        <Avatar src={user.avatar} />
        {user.name}
      </CardHeader>
      <CardBody>{user.bio}</CardBody>
      <CardFooter>
        <Button onClick={() => onEdit(user)}>Edit</Button>
      </CardFooter>
    </Card>
  )
}

// Second use case: note the similarity, but still build it
function ProductCard({ product, onAddToCart }) {
  return (
    <Card>
      <CardHeader>{product.name}</CardHeader>
      <CardBody>
        <img src={product.image} />
        <Price amount={product.price} />
      </CardBody>
      <CardFooter>
        <Button onClick={() => onAddToCart(product)}>Add to Cart</Button>
      </CardFooter>
    </Card>
  )
}

// Third use case: NOW look for the real abstraction
// The pattern emerges: Card/Header/Body/Footer + action
// But the content varies completely - composition is the abstraction!
function OrderCard({ order, onReorder }) {
  return (
    <Card>
      <CardHeader>Order #{order.id}</CardHeader>
      <CardBody>
        <OrderItems items={order.items} />
        <OrderTotal total={order.total} />
      </CardBody>
      <CardFooter>
        <Button onClick={() => onReorder(order)}>Reorder</Button>
      </CardFooter>
    </Card>
  )
}

// The real abstraction: Card is already abstract enough!
// No EntityCard needed - composition handles the variations
```

**Principal engineer judgment:**

Before abstracting, ask:
1. Do I have 3+ concrete use cases right now?
2. What's the cost of duplication vs wrong abstraction?
3. Is the variation in content or structure?

```
Wrong abstraction costs:
├── 3× to understand the abstraction
├── 5× to modify (all consumers affected)
└── 10× to replace (sunk cost fallacy)

Duplication costs:
├── 1× to write again
├── 1× to modify each copy
└── 0.5× to extract later (with hindsight)
```

**Safe extraction process:**
1. Build 3 concrete implementations
2. Identify the actual shared pattern (often smaller than expected)
3. Extract only what's truly common
4. Leave variation points as composition, not configuration

Reference: [The Wrong Abstraction](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction)
