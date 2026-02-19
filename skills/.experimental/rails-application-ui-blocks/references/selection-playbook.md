# Selection Playbook

Use this playbook to choose premium blocks consistently for Rails backend UI work.

## 1. Choose the Path

- `new-page`: Build a new feature screen.
- `refactor-page`: Rework an existing page/partial with premium blocks.

## 2. New Page Decision Order

1. Start with `ui.page-examples.*` to set structure and pacing.
2. Select an application shell from `ui.application-shells.*`.
3. Add page and section headers from `ui.headings.*`.
4. Fill primary content with:
- `ui.forms.*` for input-heavy flows
- `ui.lists.*` for repeated records
- `ui.data-display.*` for read-heavy metrics/details
5. Add movement and overlays:
- `ui.navigation.*` for movement/context
- `ui.overlays.*` for temporary focus interactions
6. Add feedback states from `ui.feedback.*`.

## 3. Refactor Decision Order

1. Preserve existing routes, params, DOM hooks, and server-rendering flow.
2. Partition the page into regions:
- shell
- header
- primary content
- secondary content
- actions/overlays
3. Map each region to candidate IDs from `template-catalog.json`.
4. Replace one region per change to reduce regression risk.
5. Run tests and verify accessibility after each region replacement.

## 4. When to Avoid Premium Blocks

- Avoid blocks that require behavior your page does not have (extra tabs, fake KPIs, placeholder controls).
- Avoid full-shell replacements when only one component is problematic.
- Avoid changing form names, IDs, or Turbo/Stimulus hooks just to match template markup.
- Avoid visual drift that conflicts with the app's established design tokens/components.

## 5. Catalog Query Patterns

- Search by domain/collection:
```bash
rg -n '"id": "ui.forms\\.' .agents/skills/rails-application-ui-blocks/references/template-catalog.json
```

- Search by intent keyword:
```bash
rg -n 'breadcrumb|empty state|command palette|sidebar' .agents/skills/rails-application-ui-blocks/references/template-catalog.json
```

- Inspect a specific candidate's source path:
```bash
rg -n '"id": "ui.navigation.navbars.with-search"' .agents/skills/rails-application-ui-blocks/references/template-catalog.json
```

## 6. Integration Rules

- Keep semantics first: headings, form labels, table relationships, button purpose.
- Keep behavior first: existing Turbo frames/streams and Stimulus contracts remain stable.
- Prefer partial extraction only after repeated use is evident.
- Document selected catalog IDs in implementation notes or PR descriptions.
