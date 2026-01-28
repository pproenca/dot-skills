---
title: Index files as entry points
impact: MEDIUM
impactDescription: Clear public API boundaries for each feature module
tags: organization, modules, exports
---

# Index files as entry points

Use `index.ts` as the main entry point for each feature directory to control the public API and simplify imports.

## Incorrect

```typescript
// Multiple entry files cause confusion
src/background/
├── background.ts      // Which is the entry point?
├── main.ts
├── entry.ts
└── init.ts
```

```typescript
// Deep imports expose internal structure
import { TabManager } from '../background/managers/tabs/tab-manager';
import { startListening } from '../background/listeners/message-listener';
```

## Correct

```typescript
// Clear single entry point
src/background/
├── index.ts           // The only entry point
├── tab-manager.ts
├── messenger.ts
└── utils/
    └── extension-api.ts
```

```typescript
// index.ts controls public API
export { TabManager } from './tab-manager';
export { Messenger } from './messenger';
// Internal utils not exported

// Clean imports from consumers
import { TabManager, Messenger } from '../background';
```

## Why This Matters

- **Encapsulation**: Internal implementation details stay hidden
- **Refactoring**: Can restructure internals without changing imports
- **Build optimization**: Tree-shaking works better with explicit exports
- **Discoverability**: New developers know where to start
