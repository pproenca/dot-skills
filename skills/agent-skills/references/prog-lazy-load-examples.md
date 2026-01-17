---
title: Lazy Load Examples and Reference Material
impact: MEDIUM-HIGH
impactDescription: saves 500-2000 tokens per activation
tags: prog, examples, lazy-loading, tokens
---

## Lazy Load Examples and Reference Material

Keep examples and reference material in separate files, loading them only when users ask for examples. Most interactions don't need examples, so loading them by default wastes tokens.

**Incorrect (examples embedded in SKILL.md):**

```markdown
# API Generator

## Instructions
Generate REST API endpoints following these patterns...

## Examples

### Example 1: User CRUD
```typescript
// 50 lines of user API example
```

### Example 2: Product Catalog
```typescript
// 50 lines of product API example
```

### Example 3: Order Processing
```typescript
// 50 lines of order API example
```

[... 10 more examples ...]
```

```text
# 650+ lines of examples in main file
# ~1300 tokens loaded every activation
# User just wants to generate one endpoint
# Examples rarely referenced
```

**Correct (examples in separate file):**

```markdown
# API Generator

## Instructions
Generate REST API endpoints following these patterns...

## Examples
For implementation examples, see [examples.md](examples.md).

Quick reference:
- User CRUD: `examples.md#user-crud`
- Product Catalog: `examples.md#products`
- Order Processing: `examples.md#orders`
```

```text
# Core file stays under 100 lines
# ~200 tokens on activation
# Examples loaded only when requested
# Quick reference enables targeted loading
```

**What to lazy load:**
- Code examples (especially multiple examples)
- API reference documentation
- Error code listings
- Configuration option catalogs
- Template collections

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
