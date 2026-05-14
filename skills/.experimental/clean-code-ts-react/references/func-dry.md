---
title: Do Not Repeat Yourself — Until the Concepts Diverge
impact: CRITICAL
impactDescription: collapses duplicated concepts into one source of truth without coupling unrelated code
tags: func, dry, duplication, abstraction
---

## Do Not Repeat Yourself — Until the Concepts Diverge

Duplicated code is often a symptom of a duplicated *concept* that should live in one place — a single change point, a single test surface. But not all repetition is conceptual duplication: two functions can look identical today and represent different ideas that will diverge tomorrow. Sandi Metz: *duplication is far cheaper than the wrong abstraction*. Extract when the concept is real; tolerate repetition when the similarity is coincidental.

**Incorrect (duplicated authorization check and duplicated currency formatting):**

```tsx
// Same auth predicate written three times — change one role rule, you must change three.
function PostEditor({ post, user }: { post: Post; user: User }) {
  const canEdit = user.role === 'admin' || user.role === 'owner' || post.authorId === user.id;
  return canEdit ? <Editor post={post} /> : <ReadOnlyView post={post} />;
}

function CommentActions({ comment, user }: { comment: Comment; user: User }) {
  const canEdit = user.role === 'admin' || user.role === 'owner' || comment.authorId === user.id;
  return canEdit ? <DeleteButton id={comment.id} /> : null;
}

// Currency formatting repeated in three places — each could format differently if "fixed" carelessly.
const cartTotal = `$${(cart.total / 100).toFixed(2)}`;
const invoiceTotal = `$${(invoice.total / 100).toFixed(2)}`;
const refundTotal = `$${(refund.amount / 100).toFixed(2)}`;
```

**Correct (single source of truth for each genuine concept):**

```tsx
// One predicate captures the concept "user has edit rights on a resource they authored or co-own".
function canUserEditResource(user: User, resource: { authorId: string }): boolean {
  return user.role === 'admin' || user.role === 'owner' || resource.authorId === user.id;
}

function PostEditor({ post, user }: { post: Post; user: User }) {
  return canUserEditResource(user, post) ? <Editor post={post} /> : <ReadOnlyView post={post} />;
}

function CommentActions({ comment, user }: { comment: Comment; user: User }) {
  return canUserEditResource(user, comment) ? <DeleteButton id={comment.id} /> : null;
}

// One formatter — locale, currency, and decimal rules all live in one place.
function formatCurrency(cents: number, locale = 'en-US', currency = 'USD'): string {
  return new Intl.NumberFormat(locale, { style: 'currency', currency }).format(cents / 100);
}

const cartTotal = formatCurrency(cart.total);
const invoiceTotal = formatCurrency(invoice.total);
const refundTotal = formatCurrency(refund.amount);
```

**When NOT to apply this pattern:**
- Code that looks identical but represents different concepts: `formatUserDisplayName` and `formatProductSlug` may both be `s.trim().toLowerCase().replace(/\s+/g, '-')` today, but they will diverge (user names need unicode support, slugs need transliteration). Premature extraction couples concepts that should evolve independently.
- DRY across module or service boundaries that *should* be independently deployable: a `User` type in your public API and a `User` row in your database may overlap 95% but should not share a single source — coupling them forces lockstep evolution.
- Test fixtures and example data where repetition makes each test self-contained and easy to read; extracting `commonUserFixture` often hurts readability more than it helps maintenance.

**Why this matters:** DRY is a tool for managing *conceptual* coupling, not visual similarity; applied to the wrong axis it produces brittle, premature abstractions.

Reference: [Clean Code, Chapter 17: Smells and Heuristics — G5 Duplication](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Sandi Metz: The Wrong Abstraction](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction)
