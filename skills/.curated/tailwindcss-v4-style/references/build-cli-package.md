---
title: Use Correct CLI Package
impact: HIGH
impactDescription: prevents build failures, ensures v4 compatibility
tags: build, cli, package, migration, tooling
---

## Use Correct CLI Package

Tailwind CSS v4 uses a separate CLI package. Using the old CLI command with v4 will cause build failures.

**Incorrect (v3 CLI command):**

```bash
# Old CLI - incompatible with v4
npx tailwindcss -i input.css -o output.css

# Results in missing utilities or errors
```

**Correct (v4 CLI package):**

```bash
# New CLI package for v4
npx @tailwindcss/cli -i input.css -o output.css
```

```json
{
  "scripts": {
    "build:css": "tailwindcss -i ./src/input.css -o ./dist/output.css"
  },
  "devDependencies": {
    "@tailwindcss/cli": "^4.0.0"
  }
}
```

**Note:** If using Vite or PostCSS integration, you typically don't need the CLI at all.

Reference: [Tailwind CSS Installation](https://tailwindcss.com/docs/installation)
