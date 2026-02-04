---
title: Define Wrapped Components at Module Level
impact: HIGH
impactDescription: prevents wrapper recreation on every render
tags: comp, with-uniwind, performance, module-level
---

## Define Wrapped Components at Module Level

Create wrapped components outside of render functions. Defining inside causes new wrapper creation on every render.

**Incorrect (wrapper created every render):**

```tsx
function MyScreen() {
  // New wrapper created on every render!
  const StyledSlider = withUniwind(ThirdPartySlider)

  return <StyledSlider className="w-full" />
}
```

**Correct (wrapper defined at module level):**

```tsx
// styled.ts
import { withUniwind } from 'uniwind'
import { ThirdPartySlider } from 'some-library'
import { ThirdPartyChart } from 'another-library'

export const StyledSlider = withUniwind(ThirdPartySlider)
export const StyledChart = withUniwind(ThirdPartyChart)
```

```tsx
// MyScreen.tsx
import { StyledSlider, StyledChart } from './styled'

function MyScreen() {
  return (
    <>
      <StyledSlider className="w-full" />
      <StyledChart className="h-64" />
    </>
  )
}
```

**Best practice:** Create a centralized `styled.ts` file for all wrapped components.

Reference: [Uniwind withUniwind API](https://docs.uniwind.dev/api/with-uniwind)
