---
title: Use withUniwind for Third-Party Components
impact: HIGH
impactDescription: enables className support on components that only accept style props
tags: comp, with-uniwind, third-party, wrapper
---

## Use withUniwind for Third-Party Components

Third-party components that don't natively support `className` need to be wrapped with `withUniwind`.

**Incorrect (className ignored on third-party component):**

```tsx
import { CustomSlider } from 'some-library'

// className prop is ignored, no styles applied
<CustomSlider className="w-full h-12 bg-primary" />
```

**Correct (wrapped with withUniwind):**

```tsx
// styled.ts - define wrappers at module level
import { withUniwind } from 'uniwind'
import { CustomSlider as BaseSlider } from 'some-library'

export const CustomSlider = withUniwind(BaseSlider)
```

```tsx
// Component.tsx
import { CustomSlider } from './styled'

// Now className works!
<CustomSlider className="w-full h-12 bg-primary" />
```

**When NOT needed:**
- React Native core components (View, Text, etc.)
- Components built on View/Text that forward style prop
- Libraries that already support className

Reference: [Uniwind withUniwind API](https://docs.uniwind.dev/api/with-uniwind)
