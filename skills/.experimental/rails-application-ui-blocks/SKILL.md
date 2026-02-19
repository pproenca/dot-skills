---
name: rails-application-ui-blocks
description: Compose new Rails backend pages and refactor existing Rails UI to use premium blocks from templates/application-ui. Use when requests mention ERB views, Rails partials, admin/dashboard screens, Tailwind UI assembly, or replacing custom markup with existing premium blocks while preserving behavior, accessibility, and Turbo/Stimulus hooks.
---

# Rails Application UI Blocks

Use this skill to choose, adapt, and integrate premium UI blocks from `templates/application-ui` into Rails views.

## Workflow

1. Determine mode:
- new-page for brand new features/pages
- refactor-page for existing views/partials
2. Identify constraints first:
- Required interactions (Turbo Frames/Streams, Stimulus targets/actions, form semantics)
- Accessibility constraints (labels, keyboard flow, ARIA)
- Existing component boundaries (partials, helpers, shared layouts)
3. Pick candidate blocks from catalog:
- Read `references/selection-playbook.md`
- Query `references/template-catalog.json`
4. Integrate minimally:
- Keep existing routes/controllers/domain logic unchanged
- Replace markup in thin steps (shell first, then sections, then micro-components)
5. Verify:
- Ensure no loss of behavior, accessibility, or test coverage
- Keep existing design tokens and class conventions where required by project standards

## Selection Order

For `new-page`:
1. Start with `ui.page-examples.*` to anchor page structure.
2. Choose shell from `ui.application-shells.*`.
3. Add page/section headings from `ui.headings.*`.
4. Add core body blocks (`ui.forms.*`, `ui.lists.*`, `ui.data-display.*`, `ui.feedback.*`).
5. Finish with navigation and overlay details (`ui.navigation.*`, `ui.overlays.*`).

For `refactor-page`:
1. Preserve current information architecture and interaction contracts.
2. Map each existing UI region to one candidate catalog block.
3. Replace one region at a time and run relevant tests.
4. Extract repeated markup into partials only after reuse is proven.

## Guardrails

- Do not change controllers/models/policies unless explicitly requested.
- Do not remove `data-controller`, `data-action`, `data-turbo-*`, `aria-*`, or form field names without replacement.
- Prefer adapting blocks to project styles over introducing conflicting visual systems.
- Avoid block insertion that duplicates existing design-system components when native components already solve the same need.

## Output Expectations

When completing a task with this skill, include:
- Selected catalog IDs (for traceability)
- Source template paths used
- Any behavior/accessibility deltas introduced
- What was intentionally not replaced and why

## Resources

- `references/selection-playbook.md`
  - Decision rules for what template families to check first, and when not to use them.
- `references/template-catalog.json`
  - Canonical block IDs with aliases and source paths.
- `scripts/build_template_catalog.py`
  - Regenerates the catalog after template updates.

## Maintenance

Regenerate the catalog when files under `templates/application-ui` change:

```bash
python3 .agents/skills/rails-application-ui-blocks/scripts/build_template_catalog.py \
  --root .
```
