---
title: Feature-based directory structure
impact: HIGH
impactDescription: Enables clear separation of browser extension contexts and improves code navigation
tags: organization, structure, browser-extension
---

# Feature-based directory structure

Organize code by browser extension context rather than by technical layer. This maps directly to how browser extensions work: background scripts, content scripts (inject), and UI (popup/options).

## Incorrect

```
src/
├── components/
├── services/
├── helpers/
└── utils/
```

Generic organization ignores the distinct execution contexts of browser extensions.

## Correct

```
src/
├── background/           # Service worker / background scripts
│   ├── index.ts         # Entry point
│   ├── tab-manager.ts
│   └── utils/           # Background-specific utilities
├── inject/              # Content scripts
│   ├── index.ts
│   ├── dynamic-theme/
│   └── utils/
├── ui/                  # Popup, options, devtools
│   ├── popup/
│   ├── options/
│   └── controls/        # Shared UI components
├── generators/          # CSS/theme generation logic
├── utils/               # Shared utilities
└── defaults.ts          # Default configuration values
```

## Why This Matters

- **Context isolation**: Each directory maps to a distinct runtime context with different APIs available
- **Build configuration**: Easier to configure separate entry points for each context
- **Mental model**: Developers can reason about code based on where it runs
- **Cross-browser compatibility**: Easier to manage browser-specific code paths
