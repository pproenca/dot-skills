---
title: Import Modifiers from the @expo/ui/swift-ui/modifiers Subpath
impact: HIGH
impactDescription: prevents bundling the modifier graph through the main entry — direct subpath import keeps tree-shaking accurate
tags: mod, imports, tree-shaking, package-exports
---

## Import Modifiers from the @expo/ui/swift-ui/modifiers Subpath

`@expo/ui` exposes modifiers through a dedicated subpath export (`@expo/ui/swift-ui/modifiers`). Importing from the main `@expo/ui/swift-ui` entry pulls in component bindings the modifier file doesn't need, defeating the package's tree-shaking design. The subpath also makes intent explicit at the import site — readers see at a glance which symbols are modifiers vs components.

**Incorrect (deep import that bypasses the package export map):**

```tsx
import { Button } from '@expo/ui/swift-ui';
import { padding, cornerRadius } from '@expo/ui/build/swift-ui/modifiers';
```

**Correct (subpath export — declared in package.json):**

```tsx
import { Button, Host } from '@expo/ui/swift-ui';
import { padding, cornerRadius, foregroundStyle } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <Button label="Done" onPress={done} modifiers={[padding({ all: 12 }), cornerRadius(8)]} />
</Host>
```

**Alternative (importing only types when no runtime usage):**

```tsx
import type { ViewModifier } from '@expo/ui/swift-ui/modifiers';

function applyDestructiveLook(): ViewModifier[] {
  return [/* shared modifier stack */];
}
```

Reference: [@expo/ui package.json exports](https://github.com/expo/expo/blob/main/packages/expo-ui/package.json)
