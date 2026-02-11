---
title: Eager Load Associations to Eliminate N+1 Queries
impact: CRITICAL
impactDescription: 10-1000× fewer queries on association traversals
tags: db, eager-loading, includes, preload, n-plus-one
---

## Eager Load Associations to Eliminate N+1 Queries

Traversing associations without eager loading triggers one query per record. Use `includes` to load associations in 1-2 queries regardless of collection size.

**Incorrect (N+1 queries, 101 queries for 100 posts):**

```ruby
posts = Post.all
posts.each do |post|
  puts post.author.name  # Fires a SELECT for each post
end
```

**Correct (2 queries total):**

```ruby
posts = Post.includes(:author).all
posts.each do |post|
  puts post.author.name
end
```

**Alternative (use `preload` when you need separate queries):**

```ruby
posts = Post.preload(:author, :comments).all
```

**Alternative (use `eager_load` when filtering on association):**

```ruby
posts = Post.eager_load(:author).where(authors: { active: true })
```

**When NOT to use this pattern:**
- Single record lookups where you access only one association
- When you explicitly need lazy loading for conditional access

Reference: [Active Record Query Interface — Rails Guides](https://guides.rubyonrails.org/active_record_querying.html#eager-loading-associations)
