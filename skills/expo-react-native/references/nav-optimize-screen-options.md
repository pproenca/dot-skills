---
title: Optimize Screen Options to Reduce Navigation Overhead
impact: MEDIUM
impactDescription: reduces header recalculation and re-renders
tags: nav, screen-options, header, performance
---

## Optimize Screen Options to Reduce Navigation Overhead

Define screen options statically when possible and avoid inline functions that cause re-renders. Dynamic headers should use minimal dependencies.

**Incorrect (inline options cause re-renders):**

```typescript
import { Stack } from 'expo-router'

export default function Layout() {
  const theme = useTheme()

  return (
    <Stack>
      <Stack.Screen
        name="profile"
        options={{
          headerStyle: { backgroundColor: theme.colors.primary },
          headerTintColor: theme.colors.text,
          headerTitle: () => <CustomTitle />,  // Recreated every render
        }}
      />
    </Stack>
  )
}
```

**Correct (stable options with memoization):**

```typescript
import { Stack } from 'expo-router'
import { useMemo } from 'react'

export default function Layout() {
  const theme = useTheme()

  const profileOptions = useMemo(() => ({
    headerStyle: { backgroundColor: theme.colors.primary },
    headerTintColor: theme.colors.text,
    headerTitle: CustomTitle,  // Component reference, not inline function
  }), [theme.colors.primary, theme.colors.text])

  return (
    <Stack>
      <Stack.Screen name="profile" options={profileOptions} />
    </Stack>
  )
}
```

**Define static options in screen file:**

```typescript
// app/profile.tsx
import { Stack } from 'expo-router'

export default function ProfileScreen() {
  return (
    <>
      <Stack.Screen
        options={{
          title: 'Profile',
          headerLargeTitle: true,
        }}
      />
      <ProfileContent />
    </>
  )
}
```

**Dynamic titles with navigation.setOptions:**

```typescript
function ProductScreen() {
  const { id } = useLocalSearchParams()
  const { data: product } = useQuery(['product', id], fetchProduct)
  const navigation = useNavigation()

  useEffect(() => {
    if (product) {
      navigation.setOptions({ title: product.name })
    }
  }, [product?.name, navigation])

  return <ProductDetail product={product} />
}
```

**Avoid in screen options:**
- Inline arrow functions
- Object literals (create new reference each render)
- Heavy computations
- Hooks (use parent component instead)
