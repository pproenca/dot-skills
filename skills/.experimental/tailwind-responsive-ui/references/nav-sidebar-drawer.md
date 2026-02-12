---
title: Convert Sidebar Nav to Off-Canvas Drawer on Mobile
impact: MEDIUM
impactDescription: recovers 40% of mobile viewport width
tags: nav, sidebar, drawer, off-canvas, responsive
---

## Convert Sidebar Nav to Off-Canvas Drawer on Mobile

Persistent sidebar navigation consumes 250px+ on mobile, leaving only ~125px for content on a 375px screen — making text unreadable and interactions impossible. An off-canvas drawer slides in from the left edge when triggered and sits completely out of view otherwise, giving the main content 100% of the viewport width. On desktop, the sidebar remains always visible as a static element in the normal flow.

**Incorrect (persistent sidebar squeezes content on mobile):**

```html
<!-- Sidebar always visible — on a 375px screen, main content gets only 111px -->
<div class="flex min-h-screen">
  <aside class="w-64 shrink-0 border-r bg-slate-900 p-4 text-white">
    <div class="mb-8 text-lg font-bold">WorkspaceApp</div>
    <nav class="flex flex-col gap-1">
      <a href="/dashboard" class="rounded-md bg-slate-800 px-3 py-2 text-sm font-medium">Dashboard</a>
      <a href="/projects" class="rounded-md px-3 py-2 text-sm font-medium text-slate-300 hover:bg-slate-800">Projects</a>
      <a href="/team" class="rounded-md px-3 py-2 text-sm font-medium text-slate-300 hover:bg-slate-800">Team</a>
      <a href="/calendar" class="rounded-md px-3 py-2 text-sm font-medium text-slate-300 hover:bg-slate-800">Calendar</a>
      <a href="/documents" class="rounded-md px-3 py-2 text-sm font-medium text-slate-300 hover:bg-slate-800">Documents</a>
      <a href="/settings" class="rounded-md px-3 py-2 text-sm font-medium text-slate-300 hover:bg-slate-800">Settings</a>
    </nav>
  </aside>
  <main class="flex-1 p-6">
    <h1 class="text-2xl font-bold">Dashboard</h1>
    <p class="mt-2 text-gray-600">Welcome back. Here is your project overview.</p>
  </main>
</div>
```

**Correct (off-canvas drawer on mobile, static sidebar on desktop):**

```html
<div class="relative min-h-screen lg:flex">

  <!-- Backdrop overlay — shown when drawer is open on mobile -->
  <div
    id="sidebar-backdrop"
    class="fixed inset-0 z-30 hidden bg-black/50 lg:hidden"
    data-close="sidebar"
  ></div>

  <!-- Sidebar / Drawer -->
  <aside
    id="sidebar"
    class="fixed inset-y-0 left-0 z-40 w-64 -translate-x-full border-r bg-slate-900 p-4 text-white transition-transform duration-300 ease-in-out lg:static lg:z-auto lg:translate-x-0 lg:transition-none"
  >
    <div class="flex items-center justify-between">
      <span class="text-lg font-bold">WorkspaceApp</span>
      <!-- Close button — only on mobile -->
      <button
        type="button"
        aria-label="Close sidebar"
        data-close="sidebar"
        class="rounded-md p-1 text-slate-400 hover:text-white lg:hidden"
      >
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    </div>
    <nav class="mt-8 flex flex-col gap-1">
      <a href="/dashboard" class="rounded-md bg-slate-800 px-3 py-2 text-sm font-medium">Dashboard</a>
      <a href="/projects" class="rounded-md px-3 py-2 text-sm font-medium text-slate-300 hover:bg-slate-800">Projects</a>
      <a href="/team" class="rounded-md px-3 py-2 text-sm font-medium text-slate-300 hover:bg-slate-800">Team</a>
      <a href="/calendar" class="rounded-md px-3 py-2 text-sm font-medium text-slate-300 hover:bg-slate-800">Calendar</a>
      <a href="/documents" class="rounded-md px-3 py-2 text-sm font-medium text-slate-300 hover:bg-slate-800">Documents</a>
      <a href="/settings" class="rounded-md px-3 py-2 text-sm font-medium text-slate-300 hover:bg-slate-800">Settings</a>
    </nav>
  </aside>

  <!-- Main content -->
  <main class="flex-1 p-4 lg:p-6">
    <!-- Toggle button — only on mobile -->
    <button
      type="button"
      aria-label="Open sidebar"
      data-open="sidebar"
      class="mb-4 rounded-md border p-2 text-gray-700 hover:bg-gray-100 lg:hidden"
    >
      <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
      </svg>
    </button>
    <h1 class="text-2xl font-bold">Dashboard</h1>
    <p class="mt-2 text-gray-600">Welcome back. Here is your project overview.</p>
  </main>
</div>
```

**Key principle:** Use `fixed inset-y-0 left-0 w-64 -translate-x-full lg:static lg:translate-x-0` on the sidebar. On mobile it is fixed and translated off-screen; JS toggles `translate-x-0` / `-translate-x-full` when the user taps the hamburger. On `lg:` it becomes `static` with `translate-x-0`, sitting in normal flow. Always include a backdrop overlay and a close button for the mobile drawer state.
