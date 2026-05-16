---
title: Reuse stories in RTL/Vitest tests via `composeStories`
impact: HIGH
impactDescription: eliminates duplicate fixture setup between stories and unit tests
tags: test, portable-stories, composeStories, rtl
---

## Reuse stories in RTL/Vitest tests via `composeStories`

`composeStories` (from `@storybook/react/portable-stories`, or your framework's equivalent) takes a stories file and returns each story as a regular React component, with all decorators, args, parameters, and `play` functions pre-applied. This means the fixture work done in a stories file — providers, MSW handlers, args, even play interactions — is reusable in plain Vitest + React Testing Library tests. No more "the test mocks the same provider the story already wraps" duplication.

**Incorrect (duplicate setup — story has providers, test re-builds them):**

```tsx
// LoginForm.test.tsx — duplicates everything LoginForm.stories.tsx already declared
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

test('submits valid credentials', async () => {
  render(
    <ThemeProvider>
      <QueryClientProvider client={new QueryClient()}>
        <LoginForm onSubmit={vi.fn()} />
      </QueryClientProvider>
    </ThemeProvider>,
  );
  // …
});
```

**Correct (`composeStories` — reuses story setup, decorators, and play):**

```tsx
// LoginForm.test.tsx
import { composeStories } from '@storybook/react/portable-stories';
import { render } from '@testing-library/react';
import * as stories from './LoginForm.stories';

const { SubmitsValidCredentials, ValidatesEmail } = composeStories(stories);

test('SubmitsValidCredentials story passes', async () => {
  render(<SubmitsValidCredentials />);
  // run() executes the play function against the already-mounted DOM,
  // applying decorators, args, and parameters from the story file
  await SubmitsValidCredentials.run();
});

test('ValidatesEmail story passes with overridden args', async () => {
  render(<ValidatesEmail />);
  // Optional: override args/parameters/globals for this run
  await ValidatesEmail.run({ args: { email: 'override@example.com' } });
});
```

**A note on the Vitest addon:** `addon-vitest` runs each story's play function automatically, so portable stories are mainly useful when you want to (a) call story setups from a non-Vitest test runner (Jest), or (b) compose multiple stories within one test (e.g., snapshot all variants in one go).

**Setup hooks (project-wide story config in tests):**

```tsx
// vitest.setup.ts
import { setProjectAnnotations } from '@storybook/react/portable-stories';
import * as previewAnnotations from './.storybook/preview';

setProjectAnnotations(previewAnnotations);
// Now composeStories() applies preview.ts decorators globally
```

**Why this matters:** The whole point of writing stories is that they encode the component's testable contract — portable stories let unit tests inherit that contract for free.

Reference: [Storybook portable stories (React)](https://storybook.js.org/docs/api/portable-stories/portable-stories-vitest), [Setup project annotations](https://storybook.js.org/docs/api/portable-stories/portable-stories-vitest#setprojectannotations)
