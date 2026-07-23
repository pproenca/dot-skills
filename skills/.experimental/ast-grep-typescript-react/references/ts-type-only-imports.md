---
title: Distinguish type-only imports from value imports
tags: ts, imports, type-only, codemod
---

## Distinguish type-only imports from value imports

TypeScript has two type-only import forms and they parse differently: statement-level `import type { Props } from './types'` carries a `type` keyword on the `import_statement`, while inline `import { useState, type Dispatch } from 'react'` marks only the individual `import_specifier`. A generic `import { $$$NAMES } from '$SRC'` pattern matches all three shapes and cannot tell values from types — which breaks any codemod that must move or preserve type-only imports (e.g. enforcing `verbatimModuleSyntax`). Match the specific form.

```yaml
# Match statement-level type-only imports.
language: tsx
rule:
  pattern: import type { $$$NAMES } from '$SRC'
```

Note the source must stay quoted: `from '$SRC'` binds `$SRC` to the module string, but a bare `from $SRC` puts a metavariable where the grammar requires a string literal, producing an `ERROR` node that matches nothing. The same holds for every import pattern.

Reference: [ast-grep pattern syntax](https://ast-grep.github.io/guide/pattern-syntax.html)
