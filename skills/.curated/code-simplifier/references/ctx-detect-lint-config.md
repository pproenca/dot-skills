---
title: Check for Linting and Formatting Configs
impact: CRITICAL
impactDescription: Eliminates 100% of style-related CI failures from simplification changes
tags: ctx, linting, formatting, tooling
---

## Check for Linting and Formatting Configs

Linting and formatting tools enforce project-wide code standards automatically. Simplifications that ignore these configs will fail CI checks or introduce inconsistent formatting. Always detect and respect ESLint, Prettier, rustfmt, Biome, and similar tool configurations before making changes.

**Incorrect (ignoring project's Prettier config):**

```javascript
// Simplified code uses single quotes, but project's .prettierrc specifies double quotes
const message = 'Hello, world';
const items = ['one', 'two', 'three'];

function greet(name) {
  return 'Hello, ' + name;
}
```

**Correct (matching project's Prettier config with double quotes):**

```javascript
// .prettierrc: { "singleQuote": false }
const message = "Hello, world";
const items = ["one", "two", "three"];

function greet(name) {
  return "Hello, " + name;
}
```

**Config files to check:**

- JavaScript/TypeScript: `.eslintrc.*`, `.prettierrc.*`, `biome.json`, `.editorconfig`
- Rust: `rustfmt.toml`, `.rustfmt.toml`
- Python: `pyproject.toml`, `.flake8`, `.black`, `ruff.toml`
- Go: `.golangci.yml`

**Benefits:**

- CI passes on first push
- Code matches existing project formatting
- No manual reformatting required after review

**References:**

- Run `npm run lint` or equivalent before committing
- Use editor integrations to auto-format on save
