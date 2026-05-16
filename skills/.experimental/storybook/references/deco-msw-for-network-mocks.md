---
title: Mock network with MSW handlers, not by stubbing the SDK
impact: HIGH
impactDescription: prevents stories from breaking when the data-fetching layer is refactored
tags: deco, msw, network, mocking
---

## Mock network with MSW handlers, not by stubbing the SDK

Components fetch through layers (TanStack Query → custom hook → fetcher → fetch). Stubbing one layer (mocking the hook in a decorator, replacing the fetcher with a fake) ties the story to that exact internal layer; refactoring the fetcher or swapping the data library breaks every story. Mocking at the network level with `msw-storybook-addon` and `msw` handlers tests the full stack — request building, parsing, error mapping, retry logic — and survives any refactor that doesn't change the API contract.

**Incorrect (stubbing the hook — story passes, real network path is untested):**

```tsx
// UserCard.stories.tsx
const meta = {
  component: UserCard,
  decorators: [
    (Story) => {
      vi.spyOn(useUserModule, 'useUser').mockReturnValue({
        data: { id: '1', name: 'Ada' },
        isLoading: false,
      });
      return <Story />;
    },
  ],
} satisfies Meta<typeof UserCard>;
```

**Correct (MSW handler — full network → query → render path runs):**

```tsx
// UserCard.stories.tsx
import { http, HttpResponse } from 'msw';

const meta = {
  component: UserCard,
  args: { userId: '1' },
} satisfies Meta<typeof UserCard>;
export default meta;

type Story = StoryObj<typeof meta>;

export const Loaded: Story = {
  parameters: {
    msw: {
      handlers: [
        http.get('/api/users/:id', () =>
          HttpResponse.json({ id: '1', name: 'Ada Lovelace', email: 'ada@example.com' }),
        ),
      ],
    },
  },
};

export const NotFound: Story = {
  parameters: {
    msw: {
      handlers: [http.get('/api/users/:id', () => new HttpResponse(null, { status: 404 }))],
    },
  },
};

export const Slow: Story = {
  parameters: {
    msw: {
      handlers: [
        http.get('/api/users/:id', async () => {
          await new Promise((r) => setTimeout(r, 2000));
          return HttpResponse.json({ id: '1', name: 'Ada' });
        }),
      ],
    },
  },
};
```

**Setup (preview.ts):**

```ts
import { initialize, mswLoader } from 'msw-storybook-addon';

initialize();

const preview: Preview = {
  loaders: [mswLoader],
};
```

**Why this matters:** Loading, empty, error, and slow states are the four states designers care about — MSW handlers are the cleanest way to express each one declaratively, story-by-story, without the test ever knowing what data fetching library you use.

Reference: [Storybook + MSW](https://storybook.js.org/addons/msw-storybook-addon), [MSW handlers](https://mswjs.io/docs/concepts/request-handler)
