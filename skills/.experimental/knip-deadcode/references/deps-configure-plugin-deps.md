---
title: Configure Plugins for Tool-Specific Dependencies
impact: HIGH
impactDescription: detects dependencies referenced in config files
tags: deps, plugins, tools, configuration
---

## Configure Plugins for Tool-Specific Dependencies

Tools like ESLint, Jest, and Webpack reference dependencies in config files. Enable and configure plugins so Knip detects these references.

**Incorrect (plugin not configured, eslint plugins appear unused):**

```json
{
  "devDependencies": {
    "eslint": "^8.0.0",
    "eslint-plugin-react": "^7.0.0",
    "@typescript-eslint/parser": "^6.0.0"
  }
}
```

Knip reports: `eslint-plugin-react`, `@typescript-eslint/parser` unused.

**Correct (ESLint plugin enabled and configured):**

```json
{
  "eslint": {
    "config": [".eslintrc.js", "eslint.config.js"]
  }
}
```

Knip reads the ESLint config and detects plugin/parser references.

**Common plugins to configure:**
- `eslint` - ESLint plugins and parsers
- `jest` - Transform and setup files
- `webpack` - Loaders and plugins
- `babel` - Presets and plugins

Reference: [Knip Plugins](https://knip.dev/reference/plugins)
