---
title: Configure TypeScript with Strict Mode
impact: CRITICAL
impactDescription: catches type errors at compile time
tags: setup, typescript, configuration, type-safety
---

## Configure TypeScript with Strict Mode

Enable strict mode in tsconfig.json to catch type errors before runtime. Expo has first-class TypeScript support with the `expo/tsconfig.base` preset.

**Incorrect (permissive defaults allow runtime errors):**

```json
{
  "extends": "expo/tsconfig.base",
  "compilerOptions": {
    "strict": false
  }
}
```

**Correct (strict mode catches errors at compile time):**

```json
{
  "extends": "expo/tsconfig.base",
  "compilerOptions": {
    "strict": true,
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["**/*.ts", "**/*.tsx", ".expo/types/**/*.ts", "expo-env.d.ts"]
}
```

**Note:** Path aliases like `@/*` are automatically supported by Expo CLI and enable cleaner imports.

Reference: [Using TypeScript - Expo Documentation](https://docs.expo.dev/guides/typescript/)
