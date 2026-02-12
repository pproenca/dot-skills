---
title: Stack Form Fields on Mobile, Use Grid on Desktop
impact: MEDIUM
impactDescription: prevents form fields from becoming too narrow to use
tags: data, forms, grid, inputs, responsive
---

## Stack Form Fields on Mobile, Use Grid on Desktop

Side-by-side form fields like first name and last name produce inputs that are only 150px wide on a 375px mobile screen — too narrow for comfortable typing and barely enough to show the placeholder text. On iOS, the auto-zoom on input focus (triggered by text smaller than 16px) compounds the problem. Stack form fields vertically on mobile so each input gets the full viewport width, and arrange them in a grid on desktop where there is room for side-by-side layout.

**Incorrect (grid-cols-2 produces cramped inputs on mobile):**

```html
<form class="space-y-4 p-4">
  <!-- Two 150px-wide inputs on a 375px screen — users can barely see what they type -->
  <div class="grid grid-cols-2 gap-4">
    <div>
      <label for="first-name" class="block text-sm font-medium text-gray-700">First name</label>
      <input
        type="text"
        id="first-name"
        name="first_name"
        placeholder="Jane"
        class="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-blue-500 focus:ring-blue-500"
      />
    </div>
    <div>
      <label for="last-name" class="block text-sm font-medium text-gray-700">Last name</label>
      <input
        type="text"
        id="last-name"
        name="last_name"
        placeholder="Smith"
        class="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-blue-500 focus:ring-blue-500"
      />
    </div>
  </div>
  <div class="grid grid-cols-2 gap-4">
    <div>
      <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
      <input
        type="email"
        id="email"
        name="email"
        placeholder="jane@example.com"
        class="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-blue-500 focus:ring-blue-500"
      />
    </div>
    <div>
      <label for="phone" class="block text-sm font-medium text-gray-700">Phone</label>
      <input
        type="tel"
        id="phone"
        name="phone"
        placeholder="+1 (555) 000-0000"
        class="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-blue-500 focus:ring-blue-500"
      />
    </div>
  </div>
  <div>
    <label for="message" class="block text-sm font-medium text-gray-700">Message</label>
    <textarea
      id="message"
      name="message"
      rows="4"
      class="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-blue-500 focus:ring-blue-500"
    ></textarea>
  </div>
  <button type="submit" class="rounded-md bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700">
    Submit
  </button>
</form>
```

**Correct (stacked on mobile, grid on desktop with proper input sizing):**

```html
<form class="space-y-4 p-4 md:space-y-6">
  <!-- Full-width stacked inputs on mobile, side-by-side from md up -->
  <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
    <div>
      <label for="first-name" class="block text-sm font-medium text-gray-700">First name</label>
      <!-- h-12 + text-base on mobile prevents iOS auto-zoom; h-10 + text-sm on desktop -->
      <input
        type="text"
        id="first-name"
        name="first_name"
        placeholder="Jane"
        class="mt-1 block h-12 w-full rounded-md border border-gray-300 px-3 py-2 text-base shadow-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500 md:h-10 md:text-sm"
      />
    </div>
    <div>
      <label for="last-name" class="block text-sm font-medium text-gray-700">Last name</label>
      <input
        type="text"
        id="last-name"
        name="last_name"
        placeholder="Smith"
        class="mt-1 block h-12 w-full rounded-md border border-gray-300 px-3 py-2 text-base shadow-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500 md:h-10 md:text-sm"
      />
    </div>
  </div>
  <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
    <div>
      <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
      <input
        type="email"
        id="email"
        name="email"
        placeholder="jane@example.com"
        class="mt-1 block h-12 w-full rounded-md border border-gray-300 px-3 py-2 text-base shadow-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500 md:h-10 md:text-sm"
      />
    </div>
    <div>
      <label for="phone" class="block text-sm font-medium text-gray-700">Phone</label>
      <input
        type="tel"
        id="phone"
        name="phone"
        placeholder="+1 (555) 000-0000"
        class="mt-1 block h-12 w-full rounded-md border border-gray-300 px-3 py-2 text-base shadow-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500 md:h-10 md:text-sm"
      />
    </div>
  </div>
  <div>
    <label for="message" class="block text-sm font-medium text-gray-700">Message</label>
    <textarea
      id="message"
      name="message"
      rows="4"
      class="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-base shadow-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500 md:text-sm"
    ></textarea>
  </div>
  <!-- Full-width button on mobile, auto-width on desktop -->
  <button
    type="submit"
    class="h-12 w-full rounded-md bg-blue-600 px-6 text-base font-medium text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 md:h-10 md:w-auto md:text-sm"
  >
    Submit
  </button>
</form>
```

**Key principle:** Use `grid grid-cols-1 md:grid-cols-2 gap-4` to stack fields on mobile and pair them on desktop. Set `h-12 text-base` on mobile inputs to create comfortable 48px touch targets and prevent the iOS auto-zoom that triggers on inputs smaller than 16px. Scale down to `md:h-10 md:text-sm` on desktop for a more compact form. Make the submit button `w-full md:w-auto` so it is an easy full-width tap target on mobile.
