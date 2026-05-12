# Gotchas

Failure points discovered when using this skill. Append-only with dates so the agent learns from past mistakes.

## Seeded gotchas (May 2026)

### The package was renamed mid-2025
Imports of `@base-ui-components/react` still resolve in some installations but are not the canonical name. Always migrate to `@base-ui/react`. Search for the old name during verification — `verify-migration.sh` fails the run if it lingers.
Added: 2026-05-12

### Overlays require Portal between Root and Backdrop/Positioner
The #1 cause of "the component renders but I can't see it." Dialog, AlertDialog, Popover, Menu, Select, Tooltip, ContextMenu, Drawer, PreviewCard all need `<Component.Portal>` immediately inside `<Component.Root>` and wrapping `<Component.Backdrop>` / `<Component.Positioner>` / `<Component.Popup>`. Forget the Portal and the parts render inside their parent stacking context — usually clipped or hidden.
Added: 2026-05-12

### Transitions need BOTH starting-style AND ending-style
A common partial migration: developer adds `data-[starting-style]:opacity-0` for the open animation but forgets `data-[ending-style]:opacity-0`. The component fades in but pops out on close. Always add both selectors for symmetric enter/exit.
Added: 2026-05-12

### `render` prop expects ONE element, not children
Wrong: `<Tooltip.Trigger>{() => <button>Save</button>}</Tooltip.Trigger>` (looks like a render prop function but isn't).
Wrong: `<Tooltip.Trigger render={() => <button>Save</button>} />` (function — also wrong).
Right: `<Tooltip.Trigger render={<button>Save</button>} />` — pass a single React element, Base UI clones it with merged refs and handlers.
Added: 2026-05-12

### HeadlessUI part names don't all map 1:1
HeadlessUI uses `Menu.Button`, Base UI uses `Menu.Trigger`. HeadlessUI uses `Listbox`, Base UI uses `Select`. HeadlessUI uses `Disclosure` for both single and grouped — Base UI splits these into `Collapsible` (single) and `Accordion` (grouped). When migrating from HeadlessUI, don't assume same-name = same-behavior. Read the migration pattern for each component.
Added: 2026-05-12

### Radio is split across two imports, not a single namespace
Most Base UI components are a single namespace (`Dialog.Root`, `Dialog.Trigger`, …). Radio breaks the pattern: the wrapper is `RadioGroup` from `@base-ui/react/radio-group`, and the item is `Radio.Root` from `@base-ui/react/radio`. There is no `Radio.Group`. Writing `<Radio.Group>` compiles to `undefined` and crashes at render time with "Element type is invalid."
Correct usage:
```tsx
import { Radio } from '@base-ui/react/radio';
import { RadioGroup } from '@base-ui/react/radio-group';
<RadioGroup value={...} onValueChange={...}>
  <Radio.Root value="a"><Radio.Indicator /></Radio.Root>
</RadioGroup>
```
Added: 2026-05-12

### Controlled state migrations need both `open` AND `onOpenChange`
A bespoke modal with `useState` becomes `<Dialog.Root open={open} onOpenChange={setOpen}>`. Forgetting `onOpenChange` makes the dialog uncloseable from inside — clicks on `Dialog.Close` won't update the parent state, and the dialog stays open after ESC even though Base UI's internal state thinks it closed.
Added: 2026-05-12

### Tailwind v3.0 doesn't support data-attribute variants
Older Tailwind installations silently drop `data-[state=open]:...` classes during purge. Required version is 3.1+. If migrations don't visually update on state change, check `tailwind` version in package.json before debugging the components.
Added: 2026-05-12

### Form components need `name` to participate in form submission
`<Switch.Root>`, `<Checkbox.Root>`, `<Radio.Root>` inside a `<form>` need `name="..."` to be picked up by `FormData`. The bespoke `<input type="checkbox" name="...">` had this for free; the migrated version doesn't unless you add it explicitly. Verify forms still submit correctly after migration.
Added: 2026-05-12

### Click-outside disable for "intentional modal blocking"
Sometimes the bespoke modal intentionally blocked click-outside (e.g., a payment confirmation that must be explicitly accepted/cancelled). Don't preserve this with a manual handler. Two correct options:
1. Switch to `<AlertDialog.Root>` — designed for required-action confirmations, blocks click-outside by default.
2. Keep `<Dialog.Root>` but make it controlled and intercept close requests: `<Dialog.Root open={open} onOpenChange={(next) => { if (!next && !canClose) return; setOpen(next); }}>`.

Do NOT use `modal={false}` for this — it has the opposite effect (allows outside interaction and unlocks page scroll). The `modal` prop on `Dialog.Root` accepts `boolean | 'trap-focus'`; the default `true` is what gives you the modal blocking behavior.
Added: 2026-05-12

---

## Template for new gotchas

```markdown
### Short, specific title — what goes wrong
1-3 sentences explaining the failure mode.
The fix: how to avoid or recover.
Added: YYYY-MM-DD
```

Append new gotchas at the bottom of the seeded list. Keep them specific — "be careful with Dialog" is useless; "Dialog without Portal renders inside its parent's stacking context and gets clipped by `overflow: hidden`" is actionable.
