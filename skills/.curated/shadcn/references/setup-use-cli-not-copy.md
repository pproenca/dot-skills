---
title: Use CLI to Add Components Instead of Copy-Paste
impact: CRITICAL
impactDescription: ensures correct imports, dependencies, and file structure
tags: setup, cli, npx, shadcn, add, installation
---

## Use CLI to Add Components Instead of Copy-Paste

The CLI handles import paths, peer dependencies, and file placement automatically. Manual copying often misses dependencies or uses wrong import paths.

**Incorrect (manual copy without dependencies):**

```typescript
// Copied button.tsx manually
import { Slot } from "@radix-ui/react-slot"
// Error: @radix-ui/react-slot is not installed

import { cva, type VariantProps } from "class-variance-authority"
// Error: class-variance-authority is not installed
```

**Correct (CLI installation):**

```bash
# Installs component with all dependencies
pnpm dlx shadcn@latest add button

# Adds: @radix-ui/react-slot, class-variance-authority
# Creates: components/ui/button.tsx with correct imports
```

**Adding multiple components:**

```bash
# Add multiple components at once
pnpm dlx shadcn@latest add button card dialog input

# Add all components
pnpm dlx shadcn@latest add --all
```

Reference: [shadcn/ui CLI](https://ui.shadcn.com/docs/cli)
