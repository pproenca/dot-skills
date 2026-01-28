---
title: Type-only imports
impact: MEDIUM
impactDescription: Type-only imports are removed at compile time, reducing bundle size
tags: typescript, imports, bundling
---

# Type-only imports

Use `import type` for imports that are only used for type annotations. This ensures they are removed during compilation and don't affect bundle size.

## Incorrect

```typescript
// Types imported as regular imports
import { UserSettings, Theme, ExtensionData } from '../definitions';

// Won't be tree-shaken if module has side effects
function processSettings(settings: UserSettings): void { }
```

## Correct

```typescript
// Type-only imports - guaranteed removed at compile time
import type { UserSettings, Theme, ExtensionData } from '../definitions';
import type { TabInfo, MessageType } from './types';

function processSettings(settings: UserSettings): void { }

// Mixed imports when you need both types and values
import { DEFAULT_SETTINGS, type UserSettings } from '../defaults';

const settings: UserSettings = { ...DEFAULT_SETTINGS };
```

## When to Use

```typescript
// ✓ Use import type for:
import type { RGBA, HSL } from '../utils/color';           // Only used in annotations
import type { Props } from './component.types';             // Prop interfaces
import type { Message, Response } from '../definitions';    // Message types

// ✓ Use regular import for:
import { parseColor, mixColors } from '../utils/color';    // Function calls
import { DEFAULT_THEME } from '../defaults';               // Runtime values
import { MessageType } from './enums';                     // Enum values

// ✓ Mixed import:
import { parseColor, type RGBA } from '../utils/color';
```

## Re-exporting Types

```typescript
// Export types from barrel files
export type { UserSettings, Theme } from './types';
export type { Props as SliderProps } from './slider';

// Or combined
export { Slider, type SliderProps } from './slider';
```

## Build Tool Configuration

Most bundlers (esbuild, rollup, webpack) automatically remove type imports, but explicit `import type` provides:

1. **Documentation**: Makes intent clear to readers
2. **Circular dependency prevention**: Type imports can't cause circular import issues
3. **Build guarantee**: Works even with bundlers that don't analyze types

## Why This Matters

- **Bundle size**: Type imports don't add to runtime bundle
- **Circular imports**: Type-only imports break circular dependency chains
- **Clarity**: Makes clear distinction between types and runtime code
- **Refactoring**: Moving types doesn't break runtime imports
