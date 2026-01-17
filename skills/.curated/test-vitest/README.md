# Vitest Best Practices Skill

A comprehensive testing best practices skill for Vitest, the next-generation testing framework powered by Vite.

## Overview

This skill contains 44 rules across 8 categories, organized by impact level to help prioritize the most important patterns when writing and reviewing Vitest tests.

## Categories

| Category | Impact | Rules | Description |
|----------|--------|-------|-------------|
| Async Patterns | CRITICAL | 7 | Prevent race conditions, false positives, and flaky async tests |
| Test Setup & Isolation | CRITICAL | 6 | Ensure proper test isolation and cleanup |
| Mocking Patterns | HIGH | 7 | Effective mocking strategies without over-mocking |
| Performance | HIGH | 6 | Optimize test execution speed |
| Snapshot Testing | MEDIUM | 5 | Maintainable snapshot practices |
| Environment | MEDIUM | 4 | Proper environment configuration |
| Assertions | LOW-MEDIUM | 5 | Effective assertion patterns |
| Test Organization | LOW | 4 | File structure and naming conventions |

## File Structure

```
vitest/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version and references
├── README.md             # This file
└── rules/
    ├── _sections.md      # Category definitions
    ├── _template.md      # Rule template
    ├── async-*.md        # Async pattern rules
    ├── setup-*.md        # Setup and isolation rules
    ├── mock-*.md         # Mocking pattern rules
    ├── perf-*.md         # Performance rules
    ├── snap-*.md         # Snapshot rules
    ├── env-*.md          # Environment rules
    ├── assert-*.md       # Assertion rules
    └── org-*.md          # Organization rules
```

## Usage

### For AI Agents

Reference `SKILL.md` for quick navigation or `AGENTS.md` for the complete compiled guide.

### For Humans

Browse individual rule files in the `rules/` directory for detailed explanations and code examples.

## Key Patterns

### Critical: Async Testing

```typescript
// Always await async assertions
await expect(asyncFn()).rejects.toThrow('Error')

// Use fake timers for time-dependent code
vi.useFakeTimers()
vi.advanceTimersByTime(1000)

// Use vi.waitFor instead of arbitrary timeouts
await vi.waitFor(() => expect(element).toBeVisible())
```

### Critical: Test Isolation

```typescript
// Clean up after each test
afterEach(() => {
  vi.restoreAllMocks()
  vi.useRealTimers()
})

// Avoid shared mutable state
let testData: User[]
beforeEach(() => {
  testData = [createTestUser()]  // Fresh for each test
})
```

### High: Effective Mocking

```typescript
// Prefer vi.spyOn for targeted mocking
vi.spyOn(api, 'fetchUser').mockResolvedValue(testUser)

// Use MSW for network mocking
const server = setupServer(
  http.get('/api/users', () => HttpResponse.json([testUser]))
)
```

### High: Performance

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    pool: 'threads',           // Faster than forks
    isolate: false,            // If tests are properly isolated
    environment: 'happy-dom',  // Faster than jsdom
  },
})
```

## References

- [Vitest Documentation](https://vitest.dev/)
- [Vitest Performance Guide](https://vitest.dev/guide/improving-performance)
- [MSW Documentation](https://mswjs.io/docs/)
