---
title: Avoid Barrel File Imports
impact: CRITICAL
impactDescription: 200-800ms bundle parse reduction, smaller memory footprint
tags: bundle, imports, barrel-files, tree-shaking
---

## Avoid Barrel File Imports

Import directly from source files instead of barrel files (index.js re-exports). Barrel files force the bundler to load entire libraries even when you only need one component.

**Incorrect (imports entire library):**

```typescript
import { Camera, MapView, Notifications } from '@/components'
// Loads ALL exports from components/index.ts

import { format, parse, isValid } from 'date-fns'
// Loads entire date-fns library
```

**Correct (direct imports):**

```typescript
import Camera from '@/components/Camera'
import MapView from '@/components/MapView'
import Notifications from '@/components/Notifications'

import format from 'date-fns/format'
import parse from 'date-fns/parse'
import isValid from 'date-fns/isValid'
```

**Alternative (configure optimizePackageImports in Metro):**

```javascript
// metro.config.js
const { getDefaultConfig } = require('expo/metro-config')

const config = getDefaultConfig(__dirname)

config.transformer.unstable_optimizePackageImports = [
  'date-fns',
  'lodash',
  '@expo/vector-icons',
]

module.exports = config
```

**Common barrel file offenders:**
- `@expo/vector-icons` - import specific icon set instead
- `lodash` - use `lodash-es` or direct imports
- Component libraries with index.ts re-exports

Reference: [Metro Configuration](https://metrobundler.dev/docs/configuration/)
