---
title: Use Data Selectors for Component State Styling
impact: MEDIUM
impactDescription: enables conditional styling based on data attributes
tags: state, data-selectors, conditional, props
---

## Use Data Selectors for Component State Styling

Use `data-[prop=value]:` syntax to style based on component data attributes. This enables prop-based conditional styling.

**Incorrect (ternary operators in className):**

```tsx
function ListItem({ isSelected, isHighlighted }: Props) {
  return (
    <View className={`
      p-4 rounded-lg
      ${isSelected ? 'bg-primary text-white' : 'bg-card'}
      ${isHighlighted ? 'border-2 border-primary' : ''}
    `}>
      <Text>Item</Text>
    </View>
  )
}
```

**Correct (data selectors):**

```tsx
function ListItem({ isSelected, isHighlighted }: Props) {
  return (
    <View
      data-selected={isSelected}
      data-highlighted={isHighlighted}
      className="
        p-4 rounded-lg bg-card
        data-[selected=true]:bg-primary
        data-[selected=true]:text-white
        data-[highlighted=true]:border-2
        data-[highlighted=true]:border-primary
      "
    >
      <Text>Item</Text>
    </View>
  )
}
```

**Complex state combinations:**

```tsx
function Tab({ isActive, hasNotification }: TabProps) {
  return (
    <Pressable
      data-active={isActive}
      data-notification={hasNotification}
      className="
        px-4 py-2
        data-[active=true]:bg-primary
        data-[active=true]:text-white
        data-[notification=true]:after:content-['•']
      "
    >
      <Text>Tab</Text>
    </Pressable>
  )
}
```

Reference: [Uniwind Supported ClassNames](https://docs.uniwind.dev/class-names)
