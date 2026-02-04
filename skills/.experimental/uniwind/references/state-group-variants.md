---
title: Use Group Variants for Parent-Child Styling (WIP)
impact: LOW-MEDIUM
impactDescription: reduces 10-20 lines of context boilerplate
tags: state, group, parent-child, variants
---

## Use Group Variants for Parent-Child Styling (WIP)

Group variants allow styling children based on parent state. Note: This feature is work in progress in Uniwind.

**Incorrect (no parent-child state coordination):**

```tsx
// Children don't respond to parent press state
<Pressable className="bg-card p-4 rounded">
  <Text className="text-foreground">
    Title doesn't change when card is pressed
  </Text>
  <View className="opacity-100">
    Opacity stays the same
  </View>
</Pressable>
```

**Correct (workaround with context):**

```tsx
function Card({ children }: CardProps) {
  const [isPressed, setIsPressed] = useState(false)

  return (
    <Pressable
      onPressIn={() => setIsPressed(true)}
      onPressOut={() => setIsPressed(false)}
      className="bg-card p-4 rounded"
    >
      <CardContext.Provider value={{ isPressed }}>
        {children}
      </CardContext.Provider>
    </Pressable>
  )
}

function CardTitle() {
  const { isPressed } = useCardContext()
  return (
    <Text className={isPressed ? 'text-primary' : 'text-foreground'}>
      Title changes when card is pressed
    </Text>
  )
}
```

**Future pattern (when group-* is supported):**

```tsx
// This will work when group variants are implemented
<Pressable className="group bg-card p-4 rounded">
  <Text className="text-foreground group-active:text-primary">
    Title changes color when card is pressed
  </Text>
</Pressable>
```

**Status:** Group variants are listed as "Work in Progress" in Uniwind documentation.

Reference: [Uniwind Supported ClassNames](https://docs.uniwind.dev/class-names)
