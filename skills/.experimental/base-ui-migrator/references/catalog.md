# Base UI Component Catalog

The full Base UI catalog — 37 components — mapped from the patterns they replace to the Base UI component, import path, and docs URL. This is the primary lookup the agent uses during migration.

> Catalog snapshot from `https://base-ui.com/llms.txt`. Refresh with `scripts/refresh-catalog.sh`.

## Package

```bash
# Install
pnpm add @base-ui/react        # or npm i / yarn add / bun add

# Note: previously published as @base-ui-components/react — rename if you see the old name.
```

All components import as a namespace from a per-component subpath:

```tsx
import { Dialog } from '@base-ui/react/dialog';
import { Popover } from '@base-ui/react/popover';
import { Select } from '@base-ui/react/select';
```

## Overlays & Floating UI (Tier A — full migration patterns)

| Component | Replaces | Import | Docs |
|-----------|----------|--------|------|
| **Dialog** | `<dialog>`, bespoke modals, Radix `Dialog`, HeadlessUI `Dialog`, Reach `Dialog` | `'@base-ui/react/dialog'` | [dialog](https://base-ui.com/react/components/dialog) |
| **AlertDialog** | Bespoke confirm/destructive modals, Radix `AlertDialog` | `'@base-ui/react/alert-dialog'` | [alert-dialog](https://base-ui.com/react/components/alert-dialog) |
| **Popover** | Bespoke popovers using Floating UI, Radix `Popover`, react-popper | `'@base-ui/react/popover'` | [popover](https://base-ui.com/react/components/popover) |
| **Tooltip** | Title attributes, bespoke hover hints, Radix `Tooltip`, HeadlessUI tooltips | `'@base-ui/react/tooltip'` | [tooltip](https://base-ui.com/react/components/tooltip) |
| **Menu** | Bespoke dropdown menus (useState + click-outside), Radix `DropdownMenu`, HeadlessUI `Menu` | `'@base-ui/react/menu'` | [menu](https://base-ui.com/react/components/menu) |
| **ContextMenu** | Custom right-click menus, Radix `ContextMenu` | `'@base-ui/react/context-menu'` | [context-menu](https://base-ui.com/react/components/context-menu) |
| **Menubar** | Application menu bars (File/Edit/View), Radix `Menubar` | `'@base-ui/react/menubar'` | [menubar](https://base-ui.com/react/components/menubar) |
| **NavigationMenu** | Site-nav with submenus, Radix `NavigationMenu` | `'@base-ui/react/navigation-menu'` | [navigation-menu](https://base-ui.com/react/components/navigation-menu) |
| **Drawer** | Slide-out panels, bespoke sheet implementations, vaul, HeadlessUI `Transition` for drawers | `'@base-ui/react/drawer'` | [drawer](https://base-ui.com/react/components/drawer) |
| **PreviewCard** | Hover-to-preview link cards, Radix `HoverCard` | `'@base-ui/react/preview-card'` | [preview-card](https://base-ui.com/react/components/preview-card) |
| **Toast** | Sonner, react-hot-toast (when not styled), Radix `Toast`, bespoke notification stacks | `'@base-ui/react/toast'` | [toast](https://base-ui.com/react/components/toast) |

## Form Controls (Tier A)

| Component | Replaces | Import | Docs |
|-----------|----------|--------|------|
| **Checkbox** | `<input type="checkbox">` + custom styling, Radix `Checkbox` | `'@base-ui/react/checkbox'` | [checkbox](https://base-ui.com/react/components/checkbox) |
| **CheckboxGroup** | Multiple `<input type="checkbox">` with shared label | `'@base-ui/react/checkbox-group'` | [checkbox-group](https://base-ui.com/react/components/checkbox-group) |
| **Radio** | `<input type="radio">` + custom styling, Radix `RadioGroup` | `'@base-ui/react/radio'` + `'@base-ui/react/radio-group'` (the wrapper is a separate import) | [radio](https://base-ui.com/react/components/radio) |
| **Switch** | Toggle switches, Radix `Switch`, HeadlessUI `Switch` | `'@base-ui/react/switch'` | [switch](https://base-ui.com/react/components/switch) |
| **Select** | `<select>` with custom styling, Radix `Select`, HeadlessUI `Listbox` | `'@base-ui/react/select'` | [select](https://base-ui.com/react/components/select) |
| **Combobox** | Custom dropdown-with-search, downshift, react-select (when basic) | `'@base-ui/react/combobox'` | [combobox](https://base-ui.com/react/components/combobox) |
| **Autocomplete** | Filtered text input with suggestions, HeadlessUI `Combobox` | `'@base-ui/react/autocomplete'` | [autocomplete](https://base-ui.com/react/components/autocomplete) |
| **Slider** | `<input type="range">` + custom styling, Radix `Slider`, rc-slider | `'@base-ui/react/slider'` | [slider](https://base-ui.com/react/components/slider) |
| **NumberField** | `<input type="number">` + custom +/- buttons, react-number-format (basic) | `'@base-ui/react/number-field'` | [number-field](https://base-ui.com/react/components/number-field) |
| **OTPField** | Custom one-time-password inputs, react-otp-input | `'@base-ui/react/otp-field'` | [otp-field](https://base-ui.com/react/components/otp-field) |
| **Field** | Bespoke label + input + error message wrappers, react-hook-form `<Controller>` (just the wrapper) | `'@base-ui/react/field'` | [field](https://base-ui.com/react/components/field) |
| **Fieldset** | `<fieldset>` + `<legend>` | `'@base-ui/react/fieldset'` | [fieldset](https://base-ui.com/react/components/fieldset) |
| **Form** | `<form>` wrapper with validation orchestration, Radix `Form` | `'@base-ui/react/form'` | [form](https://base-ui.com/react/components/form) |
| **Input** | `<input>` with formatting/composition needs | `'@base-ui/react/input'` | [input](https://base-ui.com/react/components/input) |

## Disclosure & Navigation (Tier A)

| Component | Replaces | Import | Docs |
|-----------|----------|--------|------|
| **Accordion** | Bespoke collapsible sections, Radix `Accordion`, HeadlessUI `Disclosure` (for grouped) | `'@base-ui/react/accordion'` | [accordion](https://base-ui.com/react/components/accordion) |
| **Collapsible** | Single expandable panel, Radix `Collapsible`, HeadlessUI `Disclosure` | `'@base-ui/react/collapsible'` | [collapsible](https://base-ui.com/react/components/collapsible) |
| **Tabs** | Bespoke tab strips (ARIA `role="tab"`), Radix `Tabs`, HeadlessUI `Tab` | `'@base-ui/react/tabs'` | [tabs](https://base-ui.com/react/components/tabs) |
| **Toolbar** | Grouped action buttons with shared focus, Radix `Toolbar` | `'@base-ui/react/toolbar'` | [toolbar](https://base-ui.com/react/components/toolbar) |
| **Toggle** | Two-state buttons, Radix `Toggle` | `'@base-ui/react/toggle'` | [toggle](https://base-ui.com/react/components/toggle) |
| **ToggleGroup** | Mutually exclusive or multi-select button groups, Radix `ToggleGroup` | `'@base-ui/react/toggle-group'` | [toggle-group](https://base-ui.com/react/components/toggle-group) |

## Primitives & Display (Tier B — condensed recipes)

| Component | Replaces | Import | Docs |
|-----------|----------|--------|------|
| **Button** | `<button>` when you need consistent ripple/focus/loading behavior | `'@base-ui/react/button'` | [button](https://base-ui.com/react/components/button) |
| **Avatar** | Bespoke image-with-fallback (initials, broken image handling), Radix `Avatar` | `'@base-ui/react/avatar'` | [avatar](https://base-ui.com/react/components/avatar) |
| **Progress** | `<progress>`, Radix `Progress`, bespoke progress bars | `'@base-ui/react/progress'` | [progress](https://base-ui.com/react/components/progress) |
| **Meter** | `<meter>` (capacity gauges, ratings) | `'@base-ui/react/meter'` | [meter](https://base-ui.com/react/components/meter) |
| **Separator** | `<hr>` + custom styling, Radix `Separator` | `'@base-ui/react/separator'` | [separator](https://base-ui.com/react/components/separator) |
| **ScrollArea** | Bespoke `overflow: auto` containers with custom scrollbars, Radix `ScrollArea` | `'@base-ui/react/scroll-area'` | [scroll-area](https://base-ui.com/react/components/scroll-area) |

## Quick Migration Matrix (Other Libraries → Base UI)

### Radix UI → Base UI

Radix has the closest composition model. Most components are a 1:1 import swap.

| Radix Package | Base UI Equivalent |
|---|---|
| `@radix-ui/react-dialog` | `Dialog` |
| `@radix-ui/react-alert-dialog` | `AlertDialog` |
| `@radix-ui/react-popover` | `Popover` |
| `@radix-ui/react-tooltip` | `Tooltip` |
| `@radix-ui/react-dropdown-menu` | `Menu` |
| `@radix-ui/react-context-menu` | `ContextMenu` |
| `@radix-ui/react-menubar` | `Menubar` |
| `@radix-ui/react-navigation-menu` | `NavigationMenu` |
| `@radix-ui/react-select` | `Select` |
| `@radix-ui/react-tabs` | `Tabs` |
| `@radix-ui/react-accordion` | `Accordion` |
| `@radix-ui/react-collapsible` | `Collapsible` |
| `@radix-ui/react-checkbox` | `Checkbox` |
| `@radix-ui/react-radio-group` | `Radio` + `RadioGroup` (two separate imports: `@base-ui/react/radio` for the item, `@base-ui/react/radio-group` for the wrapper) |
| `@radix-ui/react-switch` | `Switch` |
| `@radix-ui/react-slider` | `Slider` |
| `@radix-ui/react-progress` | `Progress` |
| `@radix-ui/react-separator` | `Separator` |
| `@radix-ui/react-scroll-area` | `ScrollArea` |
| `@radix-ui/react-avatar` | `Avatar` |
| `@radix-ui/react-toggle` | `Toggle` |
| `@radix-ui/react-toggle-group` | `ToggleGroup` |
| `@radix-ui/react-toolbar` | `Toolbar` |
| `@radix-ui/react-toast` | `Toast` |
| `@radix-ui/react-hover-card` | `PreviewCard` |
| `@radix-ui/react-form` | `Form` |
| `@radix-ui/react-aspect-ratio` | (not in catalog — keep as-is or use CSS `aspect-ratio`) |

### HeadlessUI → Base UI

HeadlessUI uses different naming. Composition is similar but APIs differ — read the Base UI docs per component.

| HeadlessUI | Base UI Equivalent | Notes |
|---|---|---|
| `Dialog` | `Dialog` | Add `Dialog.Portal` + `Dialog.Backdrop` |
| `Menu` | `Menu` | Slightly different part names: `Menu.Item` stays, `Menu.Button` → `Menu.Trigger` |
| `Listbox` | `Select` | Different model — `Select.Value` is required |
| `Combobox` | `Combobox` or `Autocomplete` | `Combobox` if list is finite/known, `Autocomplete` for free-form |
| `Disclosure` | `Collapsible` or `Accordion` | Single → `Collapsible`, grouped → `Accordion` |
| `Switch` | `Switch` | Same model, prop names differ slightly |
| `Tab.Group` | `Tabs` | `Tabs.Root` + `Tabs.List` + `Tabs.Tab` + `Tabs.Panel` |
| `Transition` | (built in) | Base UI uses `data-[starting-style]` + `data-[ending-style]` instead |

### Reach UI → Base UI

Reach UI is deprecated. Migration to Base UI is a direct upgrade path.

| Reach | Base UI Equivalent |
|---|---|
| `@reach/dialog` | `Dialog` |
| `@reach/menu-button` | `Menu` |
| `@reach/tabs` | `Tabs` |
| `@reach/alert-dialog` | `AlertDialog` |
| `@reach/tooltip` | `Tooltip` |
| `@reach/combobox` | `Combobox` or `Autocomplete` |
| `@reach/slider` | `Slider` |
| `@reach/checkbox` | `Checkbox` |
| `@reach/listbox` | `Select` |

## Composition Model — Universal Pattern

Every Base UI component follows the same pattern: a `Root` provider plus a tree of named parts.

```
<Component.Root>          ← state owner, accepts open/onOpenChange/etc.
  <Component.Trigger>     ← the thing the user clicks/focuses
  <Component.Portal>      ← REQUIRED for overlays (Dialog, Popover, Menu, Select, Tooltip, AlertDialog, ContextMenu, Drawer, PreviewCard)
    <Component.Backdrop>  ← dimmed overlay (Dialog, AlertDialog, Drawer)
    <Component.Positioner>← anchored positioning (Popover, Menu, Select, Tooltip, ContextMenu, PreviewCard)
      <Component.Popup>   ← the visible content container
        ...children
      </Component.Popup>
    </Component.Positioner>
  </Component.Portal>
</Component.Root>
```

When migrating: identify which parts the source code already had (trigger, content, close button) and map them to the equivalent Base UI parts. Don't try to compress — Base UI's verbosity is the API surface that enables styling each part independently.

## How the Agent Should Use This Catalog

1. **Scan returned `suggested: "Dialog"`?** Read `references/migration-patterns.md` for full before/after.
2. **Scan returned a Tier B component (e.g., "Avatar")?** Read `references/migration-patterns-primitives.md`.
3. **Need exact prop names for an edge case?** Look up the cached doc: `assets/data/components/<name>.md`. Fetch with `scripts/fetch-component-doc.sh <name>` if missing.
4. **Catalog doesn't have a component the user wants?** Run `scripts/refresh-catalog.sh --force` — Base UI may have added it.
