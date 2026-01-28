---
name: browser-extension-ts
description: TypeScript patterns and best practices for building cross-browser extensions (Chrome, Firefox, Edge)
---

# Dark Reader Browser Extension TypeScript Best Practices

TypeScript patterns and best practices for building cross-browser extensions, extracted from the Dark Reader codebase.

## When to Apply

- Building Chrome, Firefox, or Edge browser extensions
- Working with Manifest V3 service workers
- Content script development
- Extension popup and options UI
- Cross-context messaging between extension components

## Rule Categories

### 1. Manifest V3 (mv-)
| Rule | Impact | Summary |
|------|--------|---------|
| [service-worker](references/mv-service-worker.md) | CRITICAL | Design for ephemeral service workers |
| [alarms](references/mv-alarms.md) | CRITICAL | Use alarms instead of setTimeout |
| [scripting-api](references/mv-scripting-api.md) | CRITICAL | New scripting API for injection |
| [storage-session](references/mv-storage-session.md) | HIGH | Session storage for temporary state |
| [cross-browser](references/mv-cross-browser.md) | HIGH | Chrome/Firefox/Edge compatibility |

### 2. Code Style (style-)
| Rule | Impact | Summary |
|------|--------|---------|
| [directory-structure](references/style-directory-structure.md) | HIGH | Feature-based organization by extension context |
| [file-naming](references/style-file-naming.md) | HIGH | Kebab-case for all file names |
| [function-naming](references/style-function-naming.md) | HIGH | Consistent prefixes (on, create, get, is) |
| [type-naming](references/style-type-naming.md) | HIGH | PascalCase types with semantic suffixes |
| [message-enums](references/style-message-enums.md) | HIGH | Directional naming for message types |
| [index-entry-points](references/style-index-entry-points.md) | MEDIUM | Use index.ts as entry points |
| [constants](references/style-constants.md) | MEDIUM | SCREAMING_SNAKE_CASE for constants |
| [boolean-naming](references/style-boolean-naming.md) | MEDIUM | is/has/was/did prefixes for booleans |
| [import-type](references/style-import-type.md) | MEDIUM | Use import type for type-only imports |
| [cache-naming](references/style-cache-naming.md) | LOW | Cache suffix for caching structures |

### 3. Component Patterns (comp-)
| Rule | Impact | Summary |
|------|--------|---------|
| [manager-class](references/comp-manager-class.md) | HIGH | Static singleton pattern for background managers |
| [adapter-interface](references/comp-adapter-interface.md) | HIGH | Typed interfaces for cross-context communication |
| [content-script-structure](references/comp-content-script-structure.md) | HIGH | Initialization, messaging, and cleanup |
| [ui-components](references/comp-ui-components.md) | HIGH | Props/state interfaces for UI components |
| [css-class-patterns](references/comp-css-class-patterns.md) | MEDIUM | BEM-inspired class naming |
| [type-guards](references/comp-type-guards.md) | MEDIUM | Runtime type validation functions |

### 4. Error Handling (err-)
| Rule | Impact | Summary |
|------|--------|---------|
| [storage-operations](references/err-storage-operations.md) | HIGH | Try-catch for storage API calls |
| [url-parsing](references/err-url-parsing.md) | HIGH | Safe URL parsing with fallbacks |
| [validation-pattern](references/err-validation-pattern.md) | HIGH | Return errors array, don't throw |
| [context-invalidation](references/err-context-invalidation.md) | HIGH | Handle extension update gracefully |
| [promise-barrier](references/err-promise-barrier.md) | MEDIUM | Coordinate async initialization |
| [null-coalescing](references/err-null-coalescing.md) | MEDIUM | Use ?? and ?. for safe access |
| [early-return](references/err-early-return.md) | MEDIUM | Guard clauses reduce nesting |

### 5. Testing (test-)
| Rule | Impact | Summary |
|------|--------|---------|
| [organization](references/test-organization.md) | MEDIUM | Tests in tests/ with .tests.ts suffix |
| [browser-api-mocking](references/test-browser-api-mocking.md) | MEDIUM | Mock chrome APIs for unit tests |
| [validation-functions](references/test-validation-functions.md) | MEDIUM | Table-driven validation tests |

## Source

Patterns extracted from [Dark Reader](https://github.com/darkreader/darkreader) - a popular open-source browser extension with 20k+ stars.
