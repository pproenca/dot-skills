# Migration Patterns — Tier B (Primitives)

Condensed migration recipes for the components that are mostly drop-in replacements, or that have minimal composition complexity. Each entry: trigger pattern, import, minimal example, gotcha.

For overlay and form-control migrations with full before/after pairs, see [`migration-patterns.md`](migration-patterns.md).

---

## Button

**Trigger pattern:** `<button>` with project-specific loading/disabled/focus styling repeated across many files.

```tsx
import { Button } from '@base-ui/react/button';

<Button disabled={loading} className="px-4 py-2 rounded">
  {loading ? 'Saving…' : 'Save'}
</Button>
```

**Gotcha:** Base UI's `Button` is intentionally thin — its main wins are normalized focus-visible behavior and `disabled` semantics. If you have a fully working `<button>` design system already, migration to `Button` is optional. Keep `<button>` if no behavior gain.

---

## Input

**Trigger pattern:** `<input>` wrappers that re-implement focus styles, prefix/suffix slots, or controlled-with-formatting logic.

```tsx
import { Input } from '@base-ui/react/input';

<Input value={value} onValueChange={setValue} placeholder="Email" />
```

**Gotcha:** Like `Button`, `Input` is a thin wrapper. Replace ad-hoc `<input>` wrappers that exist purely for styling consistency — keep `<input>` if the wrapper has substantive logic (debouncing, validation) you don't want to refactor.

---

## Avatar

**Trigger pattern:** Bespoke image-with-fallback-initials. Common in user lists, chat UIs, comments.

### Before

```tsx
const [error, setError] = useState(false);
{error || !user.avatarUrl
  ? <span>{user.name.charAt(0)}</span>
  : <img src={user.avatarUrl} onError={() => setError(true)} />}
```

### After

```tsx
import { Avatar } from '@base-ui/react/avatar';

<Avatar.Root className="inline-flex w-8 h-8 rounded-full bg-gray-200 items-center justify-center overflow-hidden">
  <Avatar.Image src={user.avatarUrl} alt={user.name} className="w-full h-full object-cover" />
  <Avatar.Fallback>{user.name.charAt(0)}</Avatar.Fallback>
</Avatar.Root>
```

**Gotcha:** `Avatar.Fallback` renders only after the image fails or while it's loading. Don't conditionally render it manually — the component handles it.

---

## Progress

**Trigger pattern:** `<progress>`, custom progress bars built from two divs.

```tsx
import { Progress } from '@base-ui/react/progress';

<Progress.Root value={uploadPct} className="w-full h-2 bg-gray-200 rounded overflow-hidden">
  <Progress.Track>
    <Progress.Indicator className="h-full bg-blue-500 transition-all" />
  </Progress.Track>
</Progress.Root>
```

**Gotcha:** For indeterminate progress, pass `value={null}` — the indicator animates automatically. Don't try to drive an indeterminate animation yourself.

---

## Meter

**Trigger pattern:** `<meter>` (capacity / rating gauges — disk space, password strength).

```tsx
import { Meter } from '@base-ui/react/meter';

<Meter.Root value={strength} min={0} max={4}>
  <Meter.Track>
    <Meter.Indicator className="h-full bg-green-500" />
  </Meter.Track>
</Meter.Root>
```

**Gotcha:** `Meter` is semantically different from `Progress` — use `Meter` for measurements within a known range (battery 80%), `Progress` for tasks that move toward completion (upload at 80%).

---

## Separator

**Trigger pattern:** `<hr>`, custom dividers (a div with `border-bottom`).

```tsx
import { Separator } from '@base-ui/react/separator';

<Separator className="my-4 h-px bg-gray-200" />
<Separator orientation="vertical" className="mx-2 w-px h-6 bg-gray-200" />
```

**Gotcha:** Use `decorative` prop when the separator is purely visual (no ARIA role exposed). Without it, screen readers announce it as a section break.

---

## ScrollArea

**Trigger pattern:** Bespoke `overflow: auto` containers with custom scrollbars (CSS pseudo-elements that don't work cross-browser).

```tsx
import { ScrollArea } from '@base-ui/react/scroll-area';

<ScrollArea.Root className="h-60 w-64">
  <ScrollArea.Viewport className="h-full w-full">
    {longList.map(item => <div key={item.id}>{item.label}</div>)}
  </ScrollArea.Viewport>
  <ScrollArea.Scrollbar orientation="vertical">
    <ScrollArea.Thumb className="bg-gray-400 rounded" />
  </ScrollArea.Scrollbar>
</ScrollArea.Root>
```

**Gotcha:** ScrollArea hides native scrollbars and renders custom ones. Don't migrate plain `overflow: auto` if you're happy with native scrollbars — the custom version has perf cost and breaks some keyboard behaviors users expect from the OS.

---

## NumberField

**Trigger pattern:** `<input type="number">` with custom +/- buttons, or `react-number-format` used for basic stepping.

```tsx
import { NumberField } from '@base-ui/react/number-field';

<NumberField.Root value={qty} onValueChange={setQty} min={0} max={99}>
  <NumberField.Decrement>−</NumberField.Decrement>
  <NumberField.Input className="w-12 text-center" />
  <NumberField.Increment>+</NumberField.Increment>
</NumberField.Root>
```

**Gotcha:** `onValueChange` receives `null` when the user clears the input. Coerce to a default (e.g., `setQty(v ?? 0)`) if your state must always be a number.

---

## OTPField

**Trigger pattern:** Custom one-time-password inputs (a row of single-character inputs with auto-focus advancement), `react-otp-input`.

```tsx
import { OTPField } from '@base-ui/react/otp-field';

<OTPField.Root length={6} onValueChange={setCode}>
  <OTPField.Input />
  <OTPField.Input />
  <OTPField.Input />
  <OTPField.Input />
  <OTPField.Input />
  <OTPField.Input />
</OTPField.Root>
```

**Gotcha:** Paste-the-whole-code-into-the-first-box is handled automatically. Don't override the paste handler.

---

## Toast

**Trigger patterns:** `sonner`, `react-hot-toast` (when not using custom render), bespoke notification stacks, Radix `Toast`.

```tsx
import { Toast } from '@base-ui/react/toast';

// At app root:
<Toast.Provider>
  <App />
  <Toast.Portal>
    <Toast.Viewport className="fixed bottom-4 right-4" />
  </Toast.Portal>
</Toast.Provider>

// To raise a toast (use the hook):
const toaster = Toast.useToastManager();
toaster.add({ title: 'Saved', description: 'Your changes are saved.' });
```

**Gotcha:** The `Toast.Viewport` is where toasts render. Place it once at the app root, not per-component. Multiple viewports cause duplicate-render bugs.

---

## Toggle

**Trigger pattern:** Two-state button (bold/italic in a rich-text toolbar), Radix `Toggle`.

```tsx
import { Toggle } from '@base-ui/react/toggle';

<Toggle pressed={bold} onPressedChange={setBold} className="p-1 data-[pressed]:bg-blue-100">
  <BoldIcon />
</Toggle>
```

**Gotcha:** Not the same as `Switch`. `Toggle` is for editor-style toolbars (a button that "stays pressed"); `Switch` is for settings/forms (on/off semantics).

---

## ToggleGroup

**Trigger pattern:** Mutually exclusive or multi-select button groups (text-align, view mode), Radix `ToggleGroup`.

```tsx
import { ToggleGroup } from '@base-ui/react/toggle-group';

<ToggleGroup.Root value={align} onValueChange={setAlign}>
  <ToggleGroup.Item value="left">Left</ToggleGroup.Item>
  <ToggleGroup.Item value="center">Center</ToggleGroup.Item>
  <ToggleGroup.Item value="right">Right</ToggleGroup.Item>
</ToggleGroup.Root>
```

**Gotcha:** For multi-select (independent toggles), pass `toggleMultiple`. Default is single-select.

---

## Toolbar

**Trigger pattern:** Grouped action buttons with shared focus (rich-text editor toolbar, file-manager actions).

```tsx
import { Toolbar } from '@base-ui/react/toolbar';

<Toolbar.Root className="flex gap-1">
  <Toolbar.Button>Cut</Toolbar.Button>
  <Toolbar.Button>Copy</Toolbar.Button>
  <Toolbar.Button>Paste</Toolbar.Button>
  <Toolbar.Separator />
  <Toolbar.Button>Find</Toolbar.Button>
</Toolbar.Root>
```

**Gotcha:** Toolbar items get arrow-key navigation as a single composite focus stop. Tab moves out of the toolbar, not between items.

---

## PreviewCard

**Trigger pattern:** Hover-to-preview link cards (Twitter user previews, GitHub repo previews), Radix `HoverCard`.

```tsx
import { PreviewCard } from '@base-ui/react/preview-card';

<PreviewCard.Root>
  <PreviewCard.Trigger render={<a href="/users/alice">@alice</a>} />
  <PreviewCard.Portal>
    <PreviewCard.Positioner>
      <PreviewCard.Popup className="bg-white border p-3 shadow">
        <Avatar.Root>...</Avatar.Root>
        <div>Alice — Software Engineer</div>
      </PreviewCard.Popup>
    </PreviewCard.Positioner>
  </PreviewCard.Portal>
</PreviewCard.Root>
```

**Gotcha:** PreviewCard is hover-triggered, not click. For touch devices, the preview opens on long-press automatically. Don't conditionally swap to a click handler.

---

## Menubar

**Trigger pattern:** Application menu bars (File / Edit / View at the top of a desktop-style app), Radix `Menubar`.

```tsx
import { Menubar } from '@base-ui/react/menubar';

<Menubar.Root className="flex gap-2">
  <Menubar.Menu>
    <Menubar.Trigger>File</Menubar.Trigger>
    <Menubar.Portal>
      <Menubar.Positioner>
        <Menubar.Popup>
          <Menubar.Item>New</Menubar.Item>
          <Menubar.Item>Open…</Menubar.Item>
          <Menubar.Separator />
          <Menubar.Item>Quit</Menubar.Item>
        </Menubar.Popup>
      </Menubar.Positioner>
    </Menubar.Portal>
  </Menubar.Menu>
  <Menubar.Menu>
    <Menubar.Trigger>Edit</Menubar.Trigger>
    {/* ... */}
  </Menubar.Menu>
</Menubar.Root>
```

**Gotcha:** Don't use Menubar for site nav (that's `NavigationMenu`). Menubar is for desktop-app-style top menus where the user expects File/Edit/View patterns.

---

## CheckboxGroup

**Trigger pattern:** Multiple checkboxes sharing a label/state (filter selections, multi-select prefs).

```tsx
import { CheckboxGroup } from '@base-ui/react/checkbox-group';
import { Checkbox } from '@base-ui/react/checkbox';

<CheckboxGroup.Root value={tags} onValueChange={setTags}>
  <label><Checkbox.Root value="urgent"><Checkbox.Indicator>✓</Checkbox.Indicator></Checkbox.Root>Urgent</label>
  <label><Checkbox.Root value="bug"><Checkbox.Indicator>✓</Checkbox.Indicator></Checkbox.Root>Bug</label>
  <label><Checkbox.Root value="feature"><Checkbox.Indicator>✓</Checkbox.Indicator></Checkbox.Root>Feature</label>
</CheckboxGroup.Root>
```

**Gotcha:** Individual `Checkbox.Root` instances inside the group derive their checked state from the group's `value` array. Don't set `checked` on individual checkboxes when they're inside a group.

---

## Field, Fieldset, Form

These are form-orchestration primitives. Migrate when you're consolidating ad-hoc label/input/error wrappers into a consistent pattern.

### Field

**Trigger pattern:** Bespoke wrappers that bundle `<label>` + `<input>` + error message.

```tsx
import { Field } from '@base-ui/react/field';

<Field.Root>
  <Field.Label>Email</Field.Label>
  <Field.Control type="email" required />
  <Field.Error>Email is required</Field.Error>
  <Field.Description>We'll never share it.</Field.Description>
</Field.Root>
```

**Gotcha:** `Field.Control` wires `id`, `aria-describedby`, `aria-invalid` automatically. Don't pass these props manually — Base UI generates them.

### Fieldset

**Trigger pattern:** `<fieldset>` + `<legend>` for grouping related form controls.

```tsx
import { Fieldset } from '@base-ui/react/fieldset';

<Fieldset.Root>
  <Fieldset.Legend>Shipping address</Fieldset.Legend>
  {/* ...Fields */}
</Fieldset.Root>
```

### Form

**Trigger pattern:** `<form>` with per-field validation orchestration, Radix `Form`.

```tsx
import { Form } from '@base-ui/react/form';

<Form errors={errors} onClearErrors={clearErrors} onSubmit={handleSubmit}>
  <Field.Root name="email">
    <Field.Label>Email</Field.Label>
    <Field.Control type="email" required />
  </Field.Root>
  <button type="submit">Submit</button>
</Form>
```

**Gotcha:** `Form` is most valuable when paired with server-side validation. If you're using `react-hook-form` or `formik`, you can keep them and migrate only the inner controls to `Field` — `Form` is optional.

---

## When to Skip a Migration

Not every match in `scan-candidates.sh` is worth migrating. Skip when:

- The bespoke component has substantial business logic (analytics, multi-step state machines) and migrating risks regressions.
- The library you're using is intentionally specialized (Mantine date pickers, react-big-calendar) — Base UI doesn't have a 1:1 equivalent.
- The component is one-of-a-kind and tested. Migration cost > maintenance cost.

Document the skip in the PR description so reviewers don't ask.
