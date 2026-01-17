# nuqs Best Practices for Next.js

A comprehensive best practices skill for using [nuqs](https://nuqs.dev) - type-safe URL query state management - in Next.js applications.

## Overview

This skill provides 42 rules across 8 categories to help AI agents and developers write correct, performant, and maintainable code when using nuqs for URL state management.

## Categories

1. **Parser Configuration** (CRITICAL) - Type-safe URL parameter parsing
2. **Adapter & Setup** (CRITICAL) - Proper nuqs initialization
3. **State Management** (HIGH) - Effective state patterns
4. **Server Integration** (HIGH) - Server Component integration
5. **Performance Optimization** (MEDIUM) - Throttling and efficiency
6. **History & Navigation** (MEDIUM) - Browser history management
7. **Debugging & Testing** (LOW-MEDIUM) - Troubleshooting and testing
8. **Advanced Patterns** (LOW) - Custom parsers and framework adapters

## Usage

Reference [SKILL.md](SKILL.md) for the quick reference guide or [AGENTS.md](AGENTS.md) for the complete compiled documentation.

## Key Topics Covered

- Setting up NuqsAdapter for App Router and Pages Router
- Choosing correct parsers (parseAsInteger, parseAsString, etc.)
- Using withDefault for non-nullable types
- Server Component integration with createSearchParamsCache
- Throttling URL updates to prevent rate limiting
- History management (push vs replace)
- Custom parser creation
- Testing components with URL state

## Version

- nuqs: v2.x
- Next.js: 14.2.0+ (App Router) / 12.0.0+ (Pages Router)

## References

- [nuqs Documentation](https://nuqs.dev)
- [nuqs GitHub](https://github.com/47ng/nuqs)
- [Next.js Documentation](https://nextjs.org/docs)
