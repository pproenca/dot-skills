---
title: Validate Once at the Boundary, Trust Inside
impact: MEDIUM
impactDescription: eliminates re-validation at every internal call; reduces N defensive checks to 1
tags: defense, validation, boundary, trust
---

## Validate Once at the Boundary, Trust Inside

When the same precondition is checked at every layer — the controller checks the email format, the service checks it again, the model checks it again, the repository checks it again — the precondition is being treated as untrusted everywhere. Validation belongs at the *boundary* where untyped data enters the system. Inside, the type should say "this is a `ValidEmail`, you don't need to check." Re-validation is a sign the system has no clear inside.

**Incorrect (every layer re-validates the same thing):**

```typescript
// controller:
async function createUserController(req: Request) {
  const { email, name } = req.body;
  if (typeof email !== 'string' || !email.includes('@')) return error('bad email');
  if (typeof name !== 'string' || name.length < 2) return error('bad name');
  return userService.create({ email, name });
}

// service:
async function create(input: { email: string; name: string }) {
  if (!input.email.includes('@')) throw new Error('bad email');     // again
  if (input.name.length < 2) throw new Error('bad name');           // again
  return userRepository.insert(input);
}

// repository:
async function insert(input: { email: string; name: string }) {
  if (!input.email.includes('@')) throw new Error('bad email');     // and again
  return db.users.create({ data: input });
}
// 6 lines of defensive duplication. Update the validation rules → edit 3 places.
```

**Correct (validate at the boundary; the type carries the guarantee inside):**

```typescript
// validation/user.ts — at the boundary:
import { z } from 'zod';

const CreateUserInputSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2),
});
type CreateUserInput = z.infer<typeof CreateUserInputSchema>;

// controller:
async function createUserController(req: Request) {
  const parsed = CreateUserInputSchema.safeParse(req.body);
  if (!parsed.success) return error(parsed.error);
  return userService.create(parsed.data);
}

// service:
async function create(input: CreateUserInput) {           // type guarantees valid shape
  return userRepository.insert(input);
}

// repository:
async function insert(input: CreateUserInput) {            // ditto
  return db.users.create({ data: input });
}
// Validation: 1 place. The type system carries the guarantee the rest of the way.
```

**The mental model — "parse, don't validate":**

`validate` returns `boolean`: callers must still believe it. `parse` returns a *new type* that *proves* the validation succeeded. Inside the system, code receives parsed types and can trust them. The trust boundary is visible: it's the parser.

**Common reflexive double-validations to delete:**

- The controller validated `id` is a UUID; the service validates again. Trust the parsed input.
- The form library produced a typed value; you assert its constraints again before submit.
- The ORM constraints the field; you constrain it again in the application code.
- The previous function returned a `NonEmpty<T>`; you check `.length > 0` anyway.

**When NOT to use this pattern:**

- The internal function is a **public library API** that JS consumers can call without types. Defend at *its* boundary too — that's where untyped data enters.
- The data may have been *mutated* between boundary and use, and you can't make it immutable. Then a fresh check is warranted at the new use site — though usually the better fix is "make it immutable."
- The cost of being wrong is catastrophic (a financial calculation, a permissions check that gates destructive ops). Belt-and-braces is acceptable. Document why; otherwise it gets ripped out later.

Reference: [Alexis King — Parse, Don't Validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/)
