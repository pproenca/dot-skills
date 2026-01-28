---
title: Keep Changes Small and Reviewable
impact: HIGH
impactDescription: PRs over 400 lines have 50% lower review quality and 2x more post-merge bugs according to Google research
tags: scope, diff-size, review-quality, pr-hygiene
---

## Keep Changes Small and Reviewable

Every simplification should produce the smallest possible diff. Large diffs exhaust reviewers, hide bugs in noise, and make rollbacks painful. A 50-line PR gets thorough review; a 500-line PR gets rubber-stamped. Small changes also make git bisect effective when bugs emerge.

**Incorrect (kitchen-sink simplification):**

```diff
# PR: "Simplify user service" - 847 lines changed

- import { UserRepository } from './repositories/user';
- import { Logger } from '../shared/logger';
- import { Cache } from '../shared/cache';
+ import { UserRepository } from '@/repos';
+ import { log } from '@/utils';
+ import { cache } from '@/utils';

- export class UserService {
-   private repo: UserRepository;
-   private logger: Logger;
-   private cache: Cache;
-
-   constructor(repo: UserRepository, logger: Logger, cache: Cache) {
-     this.repo = repo;
-     this.logger = logger;
-     this.cache = cache;
-   }
+ export class UserService {
+   constructor(
+     private repo = new UserRepository(),
+     private log = log,
+     private cache = cache
+   ) {}

-   async getUser(id: string): Promise<User | null> {
-     const cached = await this.cache.get(`user:${id}`);
-     if (cached !== null) {
-       return cached;
-     }
-     const user = await this.repo.findById(id);
-     if (user !== null) {
-       await this.cache.set(`user:${id}`, user);
-     }
-     return user;
-   }
+   getUser = async (id: string) =>
+     this.cache.get(`user:${id}`) ??
+     this.repo.findById(id).then(u => (u && this.cache.set(`user:${id}`, u), u));

# ... 800 more lines of "improvements" across 15 files
```

**Correct (atomic, focused simplification):**

```diff
# PR 1: "Simplify UserService.getUser caching logic" - 12 lines changed

  async getUser(id: string): Promise<User | null> {
-   const cached = await this.cache.get(`user:${id}`);
-   if (cached !== null) {
-     return cached;
-   }
-   const user = await this.repo.findById(id);
-   if (user !== null) {
-     await this.cache.set(`user:${id}`, user);
-   }
-   return user;
+   const cacheKey = `user:${id}`;
+   const cached = await this.cache.get(cacheKey);
+   if (cached) return cached;
+
+   const user = await this.repo.findById(id);
+   if (user) await this.cache.set(cacheKey, user);
+   return user;
  }

# PR 2 (separate): "Update import paths to use aliases" - if needed
# PR 3 (separate): "Simplify UserService constructor" - if needed
```

### Guidelines for Diff Size

- Aim for under 200 lines changed per PR
- Never exceed 400 lines without explicit approval
- If simplification grows large, split into multiple PRs
- Each PR should have a single, clear purpose

### Benefits

- Reviewers can give full attention to each change
- Bugs are easier to spot in small diffs
- Rollbacks affect minimal code
- CI/CD cycles are faster
- Merge conflicts are less likely
