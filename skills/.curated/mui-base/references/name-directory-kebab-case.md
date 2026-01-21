---
title: Directory Naming kebab-case
impact: HIGH
impactDescription: provides consistent filesystem organization that works across all operating systems
tags: name, directory, kebab-case, organization
---

## Directory Naming kebab-case

Use kebab-case for component directories containing multiple words.

**Incorrect (anti-pattern):**

```text
src/
  checkboxGroup/
  alertDialog/
  NavigationMenu/
  radioGroup/
```

**Correct (recommended):**

```text
src/
  checkbox-group/
  alert-dialog/
  navigation-menu/
  radio-group/
```

**When to use:**
- All multi-word component directories
- Consistent across the entire codebase
- Single-word directories remain lowercase: `accordion/`, `dialog/`, `tabs/`
