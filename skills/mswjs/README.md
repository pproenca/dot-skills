# MSW Best Practices Skill

A comprehensive guide for using Mock Service Worker (MSW) v2 effectively in JavaScript/TypeScript applications.

## Overview

This skill provides 45 rules across 8 categories for API mocking with MSW, covering:

- **Setup & Initialization** - Configuring MSW for Node.js and browser environments
- **Handler Architecture** - Organizing and structuring request handlers
- **Test Integration** - Best practices for testing with MSW
- **Response Patterns** - Constructing mock responses correctly
- **Request Matching** - URL patterns, parameters, and predicates
- **GraphQL Mocking** - Handling GraphQL queries, mutations, and batching
- **Advanced Patterns** - Authentication, streaming, file uploads
- **Debugging** - Troubleshooting common issues

## Usage

This skill is automatically activated when working with:
- MSW handler files (`handlers.ts`, `mocks/*.ts`)
- Test setup files that configure MSW
- API mocking patterns in tests

## Key Concepts

### MSW v2 Requirements
- Node.js 18+ required
- TypeScript 4.7+ for proper type inference
- New `HttpResponse` API (replaces `res(ctx.json())`)

### Handler Organization
```typescript
// mocks/handlers.ts - happy paths only
export const handlers = [
  http.get('/api/user', () => HttpResponse.json({ name: 'John' })),
]

// Tests override for edge cases
server.use(
  http.get('/api/user', () => new HttpResponse(null, { status: 500 }))
)
```

### Test Setup
```typescript
// vitest.setup.ts
beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

## Files

- `SKILL.md` - Entry point with quick reference
- `AGENTS.md` - Complete compiled guide
- `rules/` - Individual rule files with detailed examples
- `metadata.json` - Version and reference information

## References

- [MSW Documentation](https://mswjs.io/docs/)
- [MSW Best Practices](https://mswjs.io/docs/best-practices/)
- [MSW v2 Migration Guide](https://mswjs.io/docs/migrations/1.x-to-2.x/)
