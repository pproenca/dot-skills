# Migration Patterns — Tier A (Overlays, Form Controls, Disclosure)

Full before/after code for the components that most commonly exist as bespoke implementations or come from another library. Each pattern shows the *before* (a realistic bespoke or other-library version) and the *after* (Base UI equivalent), keeping the diff minimal so the agent can preserve surrounding code and styling.

> Each pattern uses Tailwind classes in the *after* for readability. The classes are illustrative — preserve whatever styling approach the project already uses (CSS Modules, vanilla CSS, styled-components, etc.). See [`styling-notes.md`](styling-notes.md) for the data-attribute selectors you'll need.

## Table of Contents

**Overlays:** [Dialog](#dialog) · [AlertDialog](#alertdialog) · [Popover](#popover) · [Tooltip](#tooltip) · [Menu](#menu) · [ContextMenu](#contextmenu) · [Drawer](#drawer)
**Form Controls:** [Select](#select) · [Combobox](#combobox) · [Autocomplete](#autocomplete) · [Switch](#switch) · [Checkbox](#checkbox) · [Radio](#radio) · [Slider](#slider)
**Disclosure & Nav:** [Tabs](#tabs) · [Accordion](#accordion) · [Collapsible](#collapsible) · [NavigationMenu](#navigationmenu)

---

## Dialog

**Trigger patterns:** `<dialog>`, `role="dialog"`, bespoke modal with portal + backdrop + focus trap, Radix `Dialog`, HeadlessUI `Dialog`.

### Before — bespoke modal with `useState` + manual portal

```tsx
import { useState, useEffect } from 'react';
import { createPortal } from 'react-dom';
import FocusTrap from 'focus-trap-react';

function EditProfile() {
  const [open, setOpen] = useState(false);

  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && setOpen(false);
    document.addEventListener('keydown', onKey);
    return () => document.removeEventListener('keydown', onKey);
  }, [open]);

  return (
    <>
      <button onClick={() => setOpen(true)}>Edit profile</button>
      {open &&
        createPortal(
          <FocusTrap>
            <div className="fixed inset-0 bg-black/50" onClick={() => setOpen(false)}>
              <div className="bg-white p-6 rounded-md" onClick={(e) => e.stopPropagation()}>
                <h2>Edit profile</h2>
                <p>Update your details.</p>
                <button onClick={() => setOpen(false)}>Close</button>
              </div>
            </div>
          </FocusTrap>,
          document.body
        )}
    </>
  );
}
```

### After — Base UI Dialog

```tsx
import { Dialog } from '@base-ui/react/dialog';

function EditProfile() {
  return (
    <Dialog.Root>
      <Dialog.Trigger>Edit profile</Dialog.Trigger>
      <Dialog.Portal>
        <Dialog.Backdrop className="fixed inset-0 bg-black/50 data-[starting-style]:opacity-0 data-[ending-style]:opacity-0 transition-opacity duration-150" />
        <Dialog.Popup className="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-white p-6 rounded-md data-[starting-style]:scale-95 data-[ending-style]:scale-95 transition-transform duration-150">
          <Dialog.Title>Edit profile</Dialog.Title>
          <Dialog.Description>Update your details.</Dialog.Description>
          <Dialog.Close>Close</Dialog.Close>
        </Dialog.Popup>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
```

**Wins:** Focus trap, ESC, click-outside, scroll lock, and ARIA roles are all built in. Remove `focus-trap-react` and the manual escape handler.

**Controlled mode** (when the source had `useState`):

```tsx
const [open, setOpen] = useState(false);
<Dialog.Root open={open} onOpenChange={setOpen}>...</Dialog.Root>
```

**Long / scrollable content** — wrap `Popup` in `Dialog.Viewport` so the inner content can scroll while the dialog frame stays centered:

```tsx
<Dialog.Portal>
  <Dialog.Backdrop className="fixed inset-0 bg-black/50" />
  <Dialog.Viewport className="fixed inset-0 flex items-center justify-center overflow-hidden p-6">
    <Dialog.Popup className="max-h-full overflow-auto bg-white p-6 rounded-md">
      {/* tall content here */}
    </Dialog.Popup>
  </Dialog.Viewport>
</Dialog.Portal>
```

Without `Dialog.Viewport`, tall content clips at the popup edges instead of scrolling internally.

---

## AlertDialog

**Trigger patterns:** Bespoke confirm modals for destructive actions, Radix `AlertDialog`. Use when the dialog REQUIRES user action (delete/save) and cannot be dismissed by click-outside.

### Before

```tsx
function DeleteAccount() {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button onClick={() => setOpen(true)}>Delete account</button>
      {open && (
        <div className="fixed inset-0 bg-black/50 grid place-items-center">
          <div className="bg-white p-6">
            <h2>Are you sure?</h2>
            <p>This action cannot be undone.</p>
            <button onClick={() => setOpen(false)}>Cancel</button>
            <button onClick={() => { deleteAccount(); setOpen(false); }}>Delete</button>
          </div>
        </div>
      )}
    </>
  );
}
```

### After

```tsx
import { AlertDialog } from '@base-ui/react/alert-dialog';

function DeleteAccount() {
  return (
    <AlertDialog.Root>
      <AlertDialog.Trigger>Delete account</AlertDialog.Trigger>
      <AlertDialog.Portal>
        <AlertDialog.Backdrop className="fixed inset-0 bg-black/50" />
        <AlertDialog.Popup className="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-white p-6">
          <AlertDialog.Title>Are you sure?</AlertDialog.Title>
          <AlertDialog.Description>This action cannot be undone.</AlertDialog.Description>
          <AlertDialog.Close>Cancel</AlertDialog.Close>
          <button onClick={deleteAccount}>Delete</button>
        </AlertDialog.Popup>
      </AlertDialog.Portal>
    </AlertDialog.Root>
  );
}
```

**Key difference vs Dialog:** AlertDialog disables click-outside-to-close. Confirm/cancel must be explicit clicks.

---

## Popover

**Trigger patterns:** Bespoke popovers using Floating UI directly, `position: absolute` + `useRef` measuring, Radix `Popover`.

### Before — Floating UI directly

```tsx
import { useFloating, autoUpdate, offset, flip, shift } from '@floating-ui/react';

function HelpInfo() {
  const [open, setOpen] = useState(false);
  const { refs, floatingStyles } = useFloating({
    open, onOpenChange: setOpen, whileElementsMounted: autoUpdate,
    middleware: [offset(8), flip(), shift()],
  });

  return (
    <>
      <button ref={refs.setReference} onClick={() => setOpen(!open)}>?</button>
      {open && (
        <div ref={refs.setFloating} style={floatingStyles} className="bg-white border p-3">
          Need help? Read the docs.
        </div>
      )}
    </>
  );
}
```

### After

```tsx
import { Popover } from '@base-ui/react/popover';

function HelpInfo() {
  return (
    <Popover.Root>
      <Popover.Trigger>?</Popover.Trigger>
      <Popover.Portal>
        <Popover.Positioner sideOffset={8}>
          <Popover.Popup className="bg-white border p-3">
            Need help? Read the docs.
          </Popover.Popup>
        </Popover.Positioner>
      </Popover.Portal>
    </Popover.Root>
  );
}
```

**Wins:** Floating UI is wrapped internally. `sideOffset`, `align`, `collisionPadding` are props on `Popover.Positioner`. Drop `@floating-ui/react` if no other usage remains.

---

## Tooltip

**Trigger patterns:** `title` attribute, hover-only popovers, Radix `Tooltip`. **Important:** wrap multiple tooltips in `Tooltip.Provider` once high in the tree to share delay.

### Before

```tsx
<button title="Save changes (⌘S)">Save</button>
// or bespoke:
const [hovered, setHovered] = useState(false);
<span onMouseEnter={...} onMouseLeave={...}>{hovered && <div className="tooltip">Tip</div>}</span>
```

### After

```tsx
import { Tooltip } from '@base-ui/react/tooltip';

// Once at app root (or layout):
<Tooltip.Provider delay={400}>
  <App />
</Tooltip.Provider>

// Then anywhere:
<Tooltip.Root>
  <Tooltip.Trigger render={<button>Save</button>} />
  <Tooltip.Portal>
    <Tooltip.Positioner sideOffset={6}>
      <Tooltip.Popup className="bg-gray-900 text-white text-xs px-2 py-1 rounded">
        Save changes (⌘S)
      </Tooltip.Popup>
    </Tooltip.Positioner>
  </Tooltip.Portal>
</Tooltip.Root>
```

**Wins:** Keyboard focus shows the tooltip too (the `title` attribute fails accessibility). Shared `delay` from the provider prevents tooltip-spam when moving between buttons.

**`render` prop pattern:** `<Tooltip.Trigger render={<button>...}/>` polymorphically renders the child element as the trigger, merging refs and event handlers. Use this everywhere instead of wrapping double-elements.

---

## Menu

**Trigger patterns:** Bespoke dropdown menus (`useState` + click-outside hook), Radix `DropdownMenu`, HeadlessUI `Menu`.

### Before — bespoke dropdown

```tsx
function UserMenu() {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    const onClick = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener('mousedown', onClick);
    return () => document.removeEventListener('mousedown', onClick);
  }, []);

  return (
    <div ref={ref} className="relative">
      <button onClick={() => setOpen(!open)}>Menu</button>
      {open && (
        <ul className="absolute top-full mt-1 bg-white border">
          <li onClick={() => { /* profile */; setOpen(false); }}>Profile</li>
          <li onClick={() => { /* settings */; setOpen(false); }}>Settings</li>
          <li onClick={() => { /* signout */; setOpen(false); }}>Sign out</li>
        </ul>
      )}
    </div>
  );
}
```

### After

```tsx
import { Menu } from '@base-ui/react/menu';

function UserMenu() {
  return (
    <Menu.Root>
      <Menu.Trigger>Menu</Menu.Trigger>
      <Menu.Portal>
        <Menu.Positioner sideOffset={4}>
          <Menu.Popup className="bg-white border min-w-[160px]">
            <Menu.Item onClick={() => { /* profile */ }}>Profile</Menu.Item>
            <Menu.Item onClick={() => { /* settings */ }}>Settings</Menu.Item>
            <Menu.Separator className="my-1 h-px bg-gray-200" />
            <Menu.Item onClick={() => { /* signout */ }}>Sign out</Menu.Item>
          </Menu.Popup>
        </Menu.Positioner>
      </Menu.Portal>
    </Menu.Root>
  );
}
```

**Wins:** Arrow-key navigation, type-ahead, ESC, click-outside, ARIA roles. `Menu.Item` is automatically focusable and closes the menu on selection.

**Submenu pattern** (Base UI calls these "Submenu", common need):

```tsx
<Menu.Item>Profile</Menu.Item>
<Menu.SubmenuRoot>
  <Menu.SubmenuTrigger>More options →</Menu.SubmenuTrigger>
  <Menu.Portal>
    <Menu.Positioner>
      <Menu.Popup>
        <Menu.Item>Option A</Menu.Item>
      </Menu.Popup>
    </Menu.Positioner>
  </Menu.Portal>
</Menu.SubmenuRoot>
```

---

## ContextMenu

**Trigger patterns:** Custom `onContextMenu` handlers that position a menu at the cursor, Radix `ContextMenu`.

### Before

```tsx
function FileRow({ file }) {
  const [menu, setMenu] = useState<{x: number; y: number} | null>(null);
  return (
    <>
      <div onContextMenu={(e) => { e.preventDefault(); setMenu({x: e.clientX, y: e.clientY}); }}>
        {file.name}
      </div>
      {menu && (
        <ul style={{ position: 'fixed', left: menu.x, top: menu.y }} className="bg-white border">
          <li>Rename</li><li>Delete</li>
        </ul>
      )}
    </>
  );
}
```

### After

```tsx
import { ContextMenu } from '@base-ui/react/context-menu';

function FileRow({ file }) {
  return (
    <ContextMenu.Root>
      <ContextMenu.Trigger render={<div>{file.name}</div>} />
      <ContextMenu.Portal>
        <ContextMenu.Positioner>
          <ContextMenu.Popup className="bg-white border">
            <ContextMenu.Item>Rename</ContextMenu.Item>
            <ContextMenu.Item>Delete</ContextMenu.Item>
          </ContextMenu.Popup>
        </ContextMenu.Positioner>
      </ContextMenu.Portal>
    </ContextMenu.Root>
  );
}
```

---

## Drawer

**Trigger patterns:** Slide-out panels (sheet-style), bespoke side-panels with transforms, the `vaul` library, HeadlessUI `Transition` used to slide a panel.

### Before — bespoke slide-in

```tsx
function CartDrawer() {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button onClick={() => setOpen(true)}>Cart</button>
      {open && <div className="fixed inset-0 bg-black/30" onClick={() => setOpen(false)} />}
      <div className={`fixed top-0 right-0 h-full w-80 bg-white transition-transform ${open ? 'translate-x-0' : 'translate-x-full'}`}>
        <button onClick={() => setOpen(false)}>X</button>
        <CartContents />
      </div>
    </>
  );
}
```

### After

```tsx
import { Drawer } from '@base-ui/react/drawer';

function CartDrawer() {
  return (
    <Drawer.Root>
      <Drawer.Trigger>Cart</Drawer.Trigger>
      <Drawer.Portal>
        <Drawer.Backdrop className="fixed inset-0 bg-black/30" />
        <Drawer.Popup className="fixed top-0 right-0 h-full w-80 bg-white data-[starting-style]:translate-x-full data-[ending-style]:translate-x-full transition-transform duration-200">
          <Drawer.Close>X</Drawer.Close>
          <CartContents />
        </Drawer.Popup>
      </Drawer.Portal>
    </Drawer.Root>
  );
}
```

**Wins:** Swipe-to-close on mobile is built in. Side variant configurable via `side="left|right|top|bottom"` on `Drawer.Root` (check the cached doc for the exact prop name in your version).

---

## Select

**Trigger patterns:** `<select>` with custom wrapper styling, Radix `Select`, HeadlessUI `Listbox`.

### Before — native select wrapped in a custom div for styling

```tsx
<div className="custom-select">
  <select value={country} onChange={(e) => setCountry(e.target.value)}>
    <option value="us">United States</option>
    <option value="uk">United Kingdom</option>
    <option value="de">Germany</option>
  </select>
</div>
```

### After

```tsx
import { Select } from '@base-ui/react/select';

<Select.Root value={country} onValueChange={setCountry}>
  <Select.Trigger>
    <Select.Value placeholder="Pick a country" />
    <Select.Icon>▾</Select.Icon>
  </Select.Trigger>
  <Select.Portal>
    <Select.Positioner sideOffset={4}>
      <Select.Popup className="bg-white border max-h-60 overflow-auto">
        <Select.Item value="us">
          <Select.ItemIndicator>✓</Select.ItemIndicator>
          <Select.ItemText>United States</Select.ItemText>
        </Select.Item>
        <Select.Item value="uk">
          <Select.ItemIndicator>✓</Select.ItemIndicator>
          <Select.ItemText>United Kingdom</Select.ItemText>
        </Select.Item>
        <Select.Item value="de">
          <Select.ItemIndicator>✓</Select.ItemIndicator>
          <Select.ItemText>Germany</Select.ItemText>
        </Select.Item>
      </Select.Popup>
    </Select.Positioner>
  </Select.Portal>
</Select.Root>
```

**Wins:** Full styling control on the listbox, while keeping keyboard-search, ARIA, and selection sync.

**Don't migrate to Select if:** You need a free-text input alongside the options — use `Combobox` or `Autocomplete` instead.

---

## Combobox

**Trigger patterns:** Bespoke dropdown-with-search, `downshift`, basic `react-select` usage.

### Before

```tsx
const [query, setQuery] = useState('');
const filtered = items.filter(i => i.label.toLowerCase().includes(query.toLowerCase()));
// + a lot of useState for open/highlighted index/refs ...
```

### After

```tsx
import { Combobox } from '@base-ui/react/combobox';

<Combobox.Root items={items}>
  <Combobox.Input placeholder="Search..." />
  <Combobox.Portal>
    <Combobox.Positioner>
      <Combobox.Popup>
        <Combobox.List>
          {(item) => (
            <Combobox.Item key={item.id} value={item}>
              {item.label}
            </Combobox.Item>
          )}
        </Combobox.List>
      </Combobox.Popup>
    </Combobox.Positioner>
  </Combobox.Portal>
</Combobox.Root>
```

**Use Combobox when:** items are predefined and the user is filtering. Use `Autocomplete` when the user can input free-form values not in the list.

---

## Autocomplete

**Trigger patterns:** Filtered text input with suggestions where the user MAY type a value not in the list (tagging, free-form search).

### Before — bespoke

```tsx
const [value, setValue] = useState('');
const [open, setOpen] = useState(false);
const suggestions = computeSuggestions(value);
// ... a lot of focus management
```

### After

```tsx
import { Autocomplete } from '@base-ui/react/autocomplete';

<Autocomplete.Root value={value} onValueChange={setValue}>
  <Autocomplete.Input />
  <Autocomplete.Portal>
    <Autocomplete.Positioner>
      <Autocomplete.Popup>
        {suggestions.map(s => (
          <Autocomplete.Item key={s} value={s}>{s}</Autocomplete.Item>
        ))}
      </Autocomplete.Popup>
    </Autocomplete.Positioner>
  </Autocomplete.Portal>
</Autocomplete.Root>
```

---

## Switch

**Trigger patterns:** Bespoke toggle (clickable circle in a pill), Radix `Switch`, HeadlessUI `Switch`.

### Before

```tsx
const [enabled, setEnabled] = useState(false);
<button
  role="switch"
  aria-checked={enabled}
  onClick={() => setEnabled(!enabled)}
  className={`w-10 h-6 rounded-full ${enabled ? 'bg-blue-500' : 'bg-gray-300'} relative`}
>
  <span className={`block w-4 h-4 rounded-full bg-white absolute top-1 ${enabled ? 'left-5' : 'left-1'} transition-all`} />
</button>
```

### After

```tsx
import { Switch } from '@base-ui/react/switch';

<Switch.Root checked={enabled} onCheckedChange={setEnabled}
  className="w-10 h-6 rounded-full bg-gray-300 data-[checked]:bg-blue-500 relative transition-colors">
  <Switch.Thumb className="block w-4 h-4 rounded-full bg-white absolute top-1 left-1 data-[checked]:left-5 transition-all" />
</Switch.Root>
```

**Wins:** Space-to-toggle keyboard, ARIA `role="switch"`, form integration (works inside `<form>` without extra effort).

---

## Checkbox

**Trigger patterns:** `<input type="checkbox">` with custom wrappers, Radix `Checkbox`.

### Before

```tsx
<label>
  <input type="checkbox" checked={agreed} onChange={(e) => setAgreed(e.target.checked)} />
  I agree to the terms
</label>
```

### After

```tsx
import { Checkbox } from '@base-ui/react/checkbox';

<label>
  <Checkbox.Root checked={agreed} onCheckedChange={setAgreed}
    className="w-5 h-5 border rounded data-[checked]:bg-blue-500">
    <Checkbox.Indicator className="text-white">✓</Checkbox.Indicator>
  </Checkbox.Root>
  I agree to the terms
</label>
```

**Indeterminate state** (the killer feature — native `<input>` doesn't surface this declaratively):

```tsx
<Checkbox.Root checked="indeterminate">
  <Checkbox.Indicator>—</Checkbox.Indicator>
</Checkbox.Root>
```

---

## Radio

**Trigger patterns:** `<input type="radio">` with custom styling, Radix `RadioGroup`.

### Before

```tsx
<div role="radiogroup">
  <label><input type="radio" name="size" value="sm" checked={size === 'sm'} onChange={...} />Small</label>
  <label><input type="radio" name="size" value="md" checked={size === 'md'} onChange={...} />Medium</label>
  <label><input type="radio" name="size" value="lg" checked={size === 'lg'} onChange={...} />Large</label>
</div>
```

### After

```tsx
import { Radio } from '@base-ui/react/radio';
import { RadioGroup } from '@base-ui/react/radio-group';

<RadioGroup value={size} onValueChange={setSize}>
  <label><Radio.Root value="sm"><Radio.Indicator /></Radio.Root>Small</label>
  <label><Radio.Root value="md"><Radio.Indicator /></Radio.Root>Medium</label>
  <label><Radio.Root value="lg"><Radio.Indicator /></Radio.Root>Large</label>
</RadioGroup>
```

**Wins:** Arrow-key navigation between radios, automatic single-selection enforcement.

**Note on imports:** Unlike most Base UI components, `Radio` and `RadioGroup` are two top-level exports from two subpaths. There is no `Radio.Group` namespace.

---

## Slider

**Trigger patterns:** `<input type="range">`, Radix `Slider`, `rc-slider`.

### Before

```tsx
<input type="range" min={0} max={100} value={volume} onChange={(e) => setVolume(+e.target.value)} />
```

### After

```tsx
import { Slider } from '@base-ui/react/slider';

<Slider.Root value={volume} onValueChange={setVolume} min={0} max={100} className="relative w-48 h-5">
  <Slider.Control className="absolute inset-0 flex items-center">
    <Slider.Track className="h-1 w-full bg-gray-200 rounded">
      <Slider.Indicator className="h-full bg-blue-500 rounded" />
    </Slider.Track>
    <Slider.Thumb className="w-4 h-4 bg-blue-500 rounded-full" />
  </Slider.Control>
</Slider.Root>
```

**Range slider** (two thumbs):

```tsx
<Slider.Root value={[20, 80]} onValueChange={setRange}>
  <Slider.Control>
    <Slider.Track><Slider.Indicator /></Slider.Track>
    <Slider.Thumb index={0} />
    <Slider.Thumb index={1} />
  </Slider.Control>
</Slider.Root>
```

---

## Tabs

**Trigger patterns:** Bespoke tab strips (`role="tab"`, `aria-selected`), Radix `Tabs`, HeadlessUI `Tab.Group`.

### Before — bespoke

```tsx
const [tab, setTab] = useState('profile');
<div>
  <div role="tablist">
    <button role="tab" aria-selected={tab === 'profile'} onClick={() => setTab('profile')}>Profile</button>
    <button role="tab" aria-selected={tab === 'security'} onClick={() => setTab('security')}>Security</button>
  </div>
  {tab === 'profile' && <ProfilePanel />}
  {tab === 'security' && <SecurityPanel />}
</div>
```

### After

```tsx
import { Tabs } from '@base-ui/react/tabs';

<Tabs.Root defaultValue="profile">
  <Tabs.List>
    <Tabs.Tab value="profile">Profile</Tabs.Tab>
    <Tabs.Tab value="security">Security</Tabs.Tab>
    <Tabs.Indicator className="absolute bottom-0 h-0.5 bg-blue-500 transition-all" />
  </Tabs.List>
  <Tabs.Panel value="profile"><ProfilePanel /></Tabs.Panel>
  <Tabs.Panel value="security"><SecurityPanel /></Tabs.Panel>
</Tabs.Root>
```

**Wins:** Arrow-key navigation between tabs, automatic ARIA wiring, `Tabs.Indicator` slides between tabs (no manual animation work).

---

## Accordion

**Trigger patterns:** Bespoke collapsible FAQ sections, Radix `Accordion`, HeadlessUI multiple `Disclosure`s.

### Before

```tsx
const [open, setOpen] = useState<string | null>(null);
{faqs.map(f => (
  <div key={f.id}>
    <button onClick={() => setOpen(open === f.id ? null : f.id)}>{f.question}</button>
    {open === f.id && <p>{f.answer}</p>}
  </div>
))}
```

### After

```tsx
import { Accordion } from '@base-ui/react/accordion';

<Accordion.Root>
  {faqs.map(f => (
    <Accordion.Item key={f.id} value={f.id}>
      <Accordion.Header>
        <Accordion.Trigger>{f.question}</Accordion.Trigger>
      </Accordion.Header>
      <Accordion.Panel>{f.answer}</Accordion.Panel>
    </Accordion.Item>
  ))}
</Accordion.Root>
```

**Multiple open at once:**

```tsx
<Accordion.Root openMultiple>...</Accordion.Root>
```

---

## Collapsible

**Trigger patterns:** Single show/hide section, Radix `Collapsible`, HeadlessUI single `Disclosure`.

### Before

```tsx
const [open, setOpen] = useState(false);
<>
  <button onClick={() => setOpen(!open)}>{open ? 'Hide' : 'Show'} details</button>
  {open && <div>...details...</div>}
</>
```

### After

```tsx
import { Collapsible } from '@base-ui/react/collapsible';

<Collapsible.Root>
  <Collapsible.Trigger>Show details</Collapsible.Trigger>
  <Collapsible.Panel>...details...</Collapsible.Panel>
</Collapsible.Root>
```

---

## NavigationMenu

**Trigger patterns:** Top-of-page nav with hover/click submenus, Radix `NavigationMenu`.

### Before

```tsx
// Usually a mess of hover handlers, position calculations, click-outside, mega-menu state...
```

### After

```tsx
import { NavigationMenu } from '@base-ui/react/navigation-menu';

<NavigationMenu.Root>
  <NavigationMenu.List>
    <NavigationMenu.Item>
      <NavigationMenu.Trigger>Products</NavigationMenu.Trigger>
      <NavigationMenu.Content>
        <NavigationMenu.Link href="/web">Web</NavigationMenu.Link>
        <NavigationMenu.Link href="/mobile">Mobile</NavigationMenu.Link>
      </NavigationMenu.Content>
    </NavigationMenu.Item>
    <NavigationMenu.Item>
      <NavigationMenu.Link href="/pricing">Pricing</NavigationMenu.Link>
    </NavigationMenu.Item>
  </NavigationMenu.List>
  <NavigationMenu.Portal>
    <NavigationMenu.Positioner>
      <NavigationMenu.Popup>
        <NavigationMenu.Viewport />
      </NavigationMenu.Popup>
    </NavigationMenu.Positioner>
  </NavigationMenu.Portal>
</NavigationMenu.Root>
```

**Wins:** Hover delay handling, keyboard navigation, mega-menu transitions, ARIA `role="navigation"`.

---

## Universal Tips When Migrating

1. **Preserve event handlers.** `onClick`, `onChange`, etc. are all forwarded through Base UI parts via the `render` prop or directly.
2. **Don't drop styling — adapt it.** If the bespoke version used `className="bg-blue-500"` for the open state, replace with `className="data-[state=open]:bg-blue-500"`. See [`styling-notes.md`](styling-notes.md).
3. **Keep refs working.** Base UI parts accept `ref` and forward to the underlying DOM node.
4. **Don't migrate everything at once.** One component family per commit. Use `scripts/scan-candidates.sh` to pick the next target.
5. **Check the cached doc for prop changes.** Base UI may add/rename props. `assets/data/components/<name>.md` has the source of truth.
