---
title: Choose Dialog / Popover / Full-Page by Content Weight; Never Stack Modals
impact: HIGH
impactDescription: Stacked dialogs cause 50%+ task abandonment (NN/g); mis-chosen modality (dialog for a complex flow) doubles time-on-task
tags: ux, modality, dialog, popover, sheet, intercepting-routes
---

## Choose Dialog / Popover / Full-Page by Content Weight; Never Stack Modals

Pick the lightest container that fits the task:

- **Popover** — anchored to a trigger; ≤ 5 quick choices or compact form (date picker, share menu)
- **Dialog (modal)** — single focused task; ≤ 7 fields or one decision; centered on desktop, sheet on mobile
- **Sheet (slide-over)** — secondary task that benefits from staying visually connected to the page (filters, details panel)
- **Full page** — multi-step flows, anything > 7 fields, or content that must be deep-linkable (shareable URL)

Never open a dialog from inside another dialog. If a dialog needs more depth, switch the entire content of the existing dialog, or escalate to a full page.

**Incorrect (using a dialog for a 15-field form; stacking dialogs):**

```tsx
function CreateInvoice() {
  return (
    <Dialog.Root>
      <Dialog.Content className="w-[90vw] max-w-3xl">
        {/* 15 fields, sub-forms, file pickers, customer selector that opens another dialog */}
        <Dialog.Root>
          <Dialog.Content>Customer picker — stacked modal</Dialog.Content>
        </Dialog.Root>
      </Dialog.Content>
    </Dialog.Root>
  )
}
```

**Correct (each modality matches its weight; use intercepting routes for "open as modal"):**

```tsx
// 1. POPOVER — compact share menu
<Popover.Root>
  <Popover.Trigger asChild><Button size="sm">Share</Button></Popover.Trigger>
  <Popover.Content className="w-64 rounded-md border bg-popover p-3 shadow-md">
    <CopyLinkButton url={shareUrl} />
    <EmailShareButton url={shareUrl} />
  </Popover.Content>
</Popover.Root>

// 2. DIALOG — one focused task with ≤ 7 fields
<Dialog.Root>
  <Dialog.Trigger asChild><Button>Edit profile</Button></Dialog.Trigger>
  <Dialog.Portal>
    <Dialog.Overlay className="fixed inset-0 bg-black/40" />
    <Dialog.Content className="fixed left-1/2 top-1/2 max-w-md -translate-x-1/2 -translate-y-1/2 rounded-lg bg-background p-6">
      <Dialog.Title>Edit profile</Dialog.Title>
      <ProfileForm /> {/* 3-4 fields */}
    </Dialog.Content>
  </Dialog.Portal>
</Dialog.Root>

// 3. SHEET — filters panel, stays connected to the list
<Sheet.Root>
  <Sheet.Trigger asChild><Button variant="outline"><Filter className="mr-2 size-4" />Filters</Button></Sheet.Trigger>
  <Sheet.Content side="right" className="w-full sm:max-w-md">
    <FiltersForm />
  </Sheet.Content>
</Sheet.Root>

// 4. FULL PAGE via intercepting routes — "open as modal" but with a real URL
// app/projects/@modal/(...)new/page.tsx
import { Dialog } from '@/components/ui/dialog'
import { NewProjectForm } from './new-project-form'

export default function NewProjectModal() {
  // Intercepted from /projects/new — same content as the full page, presented as a dialog
  return (
    <Dialog defaultOpen>
      <NewProjectForm />
    </Dialog>
  )
}

// app/projects/new/page.tsx — the same content as a full page when deep-linked
export default function NewProject() {
  return <NewProjectForm />
}
```

**Rule:**
- Choose modality by weight: popover < dialog < sheet < full page
- Maximum nesting depth: one. Never open a dialog from inside another dialog
- Anything > 7 fields, multi-step, or deep-linkable is a full page (or an intercepting route)
- Mobile: dialogs become bottom sheets (Radix Sheet `side="bottom"` or shadcn/ui Drawer)
- Provide a real URL via intercepting routes (`(..)slug`) when the modal content deserves deep-linking

Reference: [Modality — Apple HIG](https://developer.apple.com/design/human-interface-guidelines/modality) · [Intercepting routes — Next.js](https://nextjs.org/docs/app/building-your-application/routing/intercepting-routes)
