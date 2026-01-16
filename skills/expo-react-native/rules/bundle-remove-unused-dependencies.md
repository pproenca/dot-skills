---
title: Remove Unused Dependencies
impact: CRITICAL
impactDescription: 100-500KB reduction per removed library
tags: bundle, dependencies, cleanup, depcheck
---

## Remove Unused Dependencies

Audit your package.json regularly for unused dependencies. Libraries installed for experimentation often remain, bloating the bundle even if never imported.

**Incorrect (unused dependencies remain):**

```json
{
  "dependencies": {
    "@react-native-async-storage/async-storage": "^1.21.0",
    "expo": "^52.0.0",
    "react": "18.2.0",
    "react-native": "0.76.0",
    "react-native-chart-kit": "^6.12.0",
    "react-native-maps": "^1.8.0",
    "react-native-svg": "^14.0.0",
    "victory-native": "^36.6.0"
  }
}
```

**Correct (audited and cleaned):**

```bash
# Find unused dependencies
npx depcheck

# Output example:
# Unused dependencies
# * react-native-chart-kit
# * victory-native
# * react-native-maps

# Remove unused
npm uninstall react-native-chart-kit victory-native react-native-maps
```

**Resulting clean package.json:**

```json
{
  "dependencies": {
    "@react-native-async-storage/async-storage": "^1.21.0",
    "expo": "^52.0.0",
    "react": "18.2.0",
    "react-native": "0.76.0",
    "react-native-svg": "^14.0.0"
  }
}
```

**Automate in CI:**

```yaml
# .github/workflows/check-deps.yml
- name: Check for unused dependencies
  run: npx depcheck --ignores="@types/*,typescript"
```

**Note:** Some dependencies may appear unused but are required by Metro plugins or native modules. Use `--ignores` flag for legitimate cases.
