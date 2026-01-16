# Next.js 16 Best Practices Skill

Performance optimization guidelines for Next.js 16 applications using the App Router.

## Overview

This skill contains **45 rules** across **8 categories**, ordered by performance impact:

1. **Network Waterfalls & Data Fetching** (CRITICAL) - Eliminate request waterfalls
2. **Bundle Size & Code Splitting** (CRITICAL) - Reduce JavaScript payload
3. **Server vs Client Component Boundaries** (HIGH) - Optimize component placement
4. **Client-Side Data & State** (HIGH) - Efficient client-side patterns
5. **Rendering Strategy Selection** (MEDIUM-HIGH) - Static vs dynamic decisions
6. **Caching & Revalidation** (MEDIUM) - Cache configuration
7. **Routing & Navigation** (MEDIUM) - Link prefetching and organization
8. **Advanced Patterns & Security** (LOW-MEDIUM) - Auth, middleware, optimization

## File Structure

```
nextjs16-best-practices/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled guide (all rules)
├── metadata.json         # Version, references
├── README.md             # This file
└── rules/
    ├── _sections.md      # Category definitions
    ├── _template.md      # Rule template
    ├── async-*.md        # Data fetching rules (7)
    ├── bundle-*.md       # Bundle optimization rules (6)
    ├── server-*.md       # Server Component rules (6)
    ├── client-*.md       # Client Component rules (6)
    ├── render-*.md       # Rendering strategy rules (4)
    ├── cache-*.md        # Caching rules (5)
    ├── route-*.md        # Routing rules (4)
    └── advanced-*.md     # Advanced pattern rules (7)
```

## Usage

### For AI Agents

Reference `SKILL.md` for quick lookups or `AGENTS.md` for the complete compiled guide.

### For Developers

Browse individual rule files in `rules/` for detailed explanations and code examples.

## Key Principles

1. **Server Components by default** - Reduce client JS to zero for non-interactive content
2. **Eliminate waterfalls** - Parallelize fetches, use Suspense streaming
3. **Cache strategically** - Match revalidation times to data freshness needs
4. **Minimize client boundaries** - Push `'use client'` as deep as possible
5. **Prefer static** - Use generateStaticParams and avoid dynamic triggers

## Sources

- [Next.js Documentation](https://nextjs.org/docs)
- [Vercel React Best Practices](https://vercel.com/blog/introducing-react-best-practices)
- [Next.js Barrel Files Optimization](https://vercel.com/blog/how-we-optimized-package-imports-in-next-js)

## Version

- Skill Version: 1.0.0
- Next.js Version: 16.x
- Last Updated: January 2026
