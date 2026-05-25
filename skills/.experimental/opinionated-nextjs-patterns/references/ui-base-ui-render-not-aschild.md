---
title: Use Base UI `render` Prop, Not Radix `asChild`
impact: MEDIUM
impactDescription: prevents silent prop drops on misused composition
tags: ui, base-ui, radix, render-prop, composition
---

## Use Base UI `render` Prop, Not Radix `asChild`

This stack uses Base UI (the shadcn-compatible component library that succeeds Radix) for composition. The composition pattern is `render={<CustomElement />}`, NOT `asChild`. Mixing the two looks like it works but silently drops the wrapper's props — `asChild` on a Base UI component compiles, runs, and ignores its child, leaving a `<Link>` without the click handler the `Button` was supposed to forward.

**Incorrect (Radix-style `asChild` — silently broken on Base UI):**

```tsx
// Looks like Radix syntax. Compiles. Renders. Doesn't work.
<Button asChild>
  <Link href="/settings">Settings</Link>
</Button>
// Result: a <Link> is rendered, but the Button's styling, focus ring,
// and any forwarded props (data-state, aria-*) are missing.
```

**Correct (Base UI `render` prop):**

```tsx
import Link from 'next/link';
import { Button } from '@app/ui/button';

<Button render={<Link href="/settings" />}>
  <Trans i18nKey="common.settings" />
</Button>
// The button's styles, ARIA attributes, and event handlers compose
// onto the <Link>, which becomes the rendered element.
```

**`render` prop signature variants:**

```tsx
// Plain element (most common):
<Tooltip.Trigger render={<button type="button" />}>Hover me</Tooltip.Trigger>

// Function form (when you need access to merged props):
<Tooltip.Trigger render={(props) => <CustomButton {...props}>Hover me</CustomButton>} />
```

**Common Base UI composition patterns:**

```tsx
// Button as a Link.
<Button render={<Link href={path} />}>Go</Button>

// Tooltip trigger that's not the default button.
<Tooltip>
  <Tooltip.Trigger render={<IconButton />}>...</Tooltip.Trigger>
  <Tooltip.Content>Help text</Tooltip.Content>
</Tooltip>

// Custom Dialog trigger.
<Dialog>
  <Dialog.Trigger render={<MenuItem />}>Open settings</Dialog.Trigger>
  <Dialog.Content>...</Dialog.Content>
</Dialog>
```

**Why this isn't just a syntax preference:** Base UI's `render` prop applies *prop composition* — the Button's merged className, focus ring styles, data attributes, and event handlers go onto the element you supply. Radix's `asChild` uses `Slot` which clones the child and forwards refs. They look similar; they implement differently. A Base UI component receiving `asChild` doesn't have `Slot` wiring, so the prop is dropped.

**Watch for `@radix-ui/*` imports in the codebase.** They're a smell — Base UI is the contract. Migrating a stray Radix import:

```tsx
// Before:
import * as DialogPrimitive from '@radix-ui/react-dialog';
<DialogPrimitive.Trigger asChild>
  <Button>Open</Button>
</DialogPrimitive.Trigger>

// After (via your Base UI wrapper):
import { Dialog } from '@app/ui/dialog';
<Dialog.Trigger render={<Button>Open</Button>}>Open</Dialog.Trigger>
```

For bulk migrations, a codemod that rewrites Radix `asChild` → Base UI `render` syntax pays for itself across a large codebase.

**`render` with conditionals:** if you need to swap the rendered element based on a condition, do the swap outside the prop:

```tsx
// Cleanest:
const Trigger = isLink
  ? <Link href={href} />
  : <button type="button" onClick={onClick} />;

<Button render={Trigger}>{label}</Button>
```

**Forwarding refs:** Base UI handles ref forwarding automatically through `render` — no `React.forwardRef` boilerplate on the consuming side. The element you pass receives the merged ref.

**Don't add `asChild` to your own components.** If you're writing a wrapper that needs to compose, mirror Base UI's `render` prop. Consistency across the codebase makes "how do I customise this trigger?" a question with one answer.

Reference: [Base UI composition](https://base-ui.com/react/handbook/composition)
