---
title: "Place `Component.stories.tsx` next to `Component.tsx`"
impact: CRITICAL
impactDescription: prevents story rot by surfacing stories in every component file tree and diff
tags: csf, organization, file-structure, co-location
---

## Place `Component.stories.tsx` next to `Component.tsx`

Stories rot when they live in a separate `/stories` directory because the developer changing the component has no friction-free reminder that stories exist. Co-located files (`Card.tsx` + `Card.stories.tsx` + `Card.test.tsx`) appear together in every file tree, every PR diff, and every "find references" hit, so updating the component naturally surfaces its stories. The auto-title feature (when `title` is omitted) generates a sidebar path from the filesystem path, so co-location and a clean sidebar are not in tension.

**Incorrect (centralized `/stories` directory — components drift, stories rot):**

```text
src/
├── components/
│   ├── Card.tsx
│   ├── Button.tsx
│   └── Avatar.tsx
└── stories/                    # nobody opens this when editing Card.tsx
    ├── Card.stories.tsx        # 6 months stale
    ├── Button.stories.tsx
    └── Avatar.stories.tsx
```

**Correct (co-located — story sits next to the component it documents):**

```text
src/
└── components/
    ├── Card/
    │   ├── Card.tsx
    │   ├── Card.stories.tsx
    │   ├── Card.test.tsx
    │   └── index.ts
    ├── Button/
    │   ├── Button.tsx
    │   ├── Button.stories.tsx
    │   └── index.ts
    └── Avatar/
        ├── Avatar.tsx
        └── Avatar.stories.tsx
```

```tsx
// Card.stories.tsx — no `title`; sidebar path comes from the file path
const meta = {
  component: Card,
  // title: 'Components/Card' — optional; auto-derived from src/components/Card/Card.stories.tsx
} satisfies Meta<typeof Card>;
```

**Configure auto-title prefix in main.ts:**

```ts
const config = {
  stories: [
    {
      directory: '../src/components',
      files: '**/*.stories.@(ts|tsx)', // required: limits to story files within `directory`
      titlePrefix: 'Components',
    },
  ],
} satisfies StorybookConfig;
```

**When NOT to use this pattern:**
- *Cross-component* showcases (e.g., a "Form Patterns" gallery composed of Input, Select, and Submit) — those belong in a `docs/` or `patterns/` directory because they don't have a single home component.

**Why this matters:** Out-of-sync stories are worse than no stories — they actively mislead. Co-location is the cheapest way to keep them honest.

Reference: [Storybook configure: stories specifier](https://storybook.js.org/docs/configure#with-a-configuration-object)
