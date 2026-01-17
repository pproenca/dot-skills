# TanStack Query Best Practices Skill

A comprehensive performance optimization guide for TanStack Query v5 applications.

## Overview

This skill contains **40 rules** across **8 categories**, prioritized by impact to guide code generation, refactoring, and review. It's designed for AI agents and LLMs working with React/TanStack Query codebases.

## Categories

| Priority | Category | Rules | Description |
|----------|----------|-------|-------------|
| 1 | Query Key Structure | 6 | Key factories, hierarchy, serialization |
| 2 | Caching Configuration | 6 | staleTime, gcTime, invalidation |
| 3 | Mutation Patterns | 5 | Optimistic updates, rollback |
| 4 | Prefetching & Waterfalls | 5 | Parallel fetching, hoisting |
| 5 | Infinite Queries | 4 | maxPages, pagination |
| 6 | Suspense Integration | 4 | Error boundaries, parallel queries |
| 7 | Error & Retry | 5 | Retry strategies, global handling |
| 8 | Render Optimization | 5 | select, notifyOnChangeProps |

## Files

- **SKILL.md** - Quick reference entry point with rule index
- **AGENTS.md** - Full compiled document with all rules expanded
- **metadata.json** - Version, organization, references
- **rules/** - Individual rule files with detailed examples

## Usage

### For AI Agents
The skill is automatically applied when working with TanStack Query code. Reference individual rules or AGENTS.md for comprehensive guidance.

### For Humans
Read SKILL.md for the quick reference, or dive into specific rule files under `rules/` for detailed examples.

## Sources

- [TanStack Query v5 Docs](https://tanstack.com/query/v5/docs)
- [TkDodo's Blog](https://tkdodo.eu/blog) (Query maintainer)
- [lukemorales/query-key-factory](https://github.com/lukemorales/query-key-factory)
- [TanStack Query Discussions](https://github.com/TanStack/query/discussions)

## Version

1.0.0 - January 2026
