---
title: Reserve Tailwind for Primitive Components, Compose for Domain
impact: MEDIUM
impactDescription: reduces duplication across feature modules
tags: arch, components, composition, architecture, design-system
---

## Reserve Tailwind for Primitive Components, Compose for Domain

Applying utility classes directly in domain-level components (checkout forms, user profiles, dashboards) creates massive duplication across feature modules. The same input styling, card layout, and button pattern get copy-pasted dozens of times. Instead, build a library of styled primitive components with Tailwind utilities, then compose those primitives in domain code without any utility classes.

**Incorrect (what's wrong):**

```tsx
// Tailwind classes directly in domain components — duplicated everywhere
<form class="flex flex-col gap-4 rounded-lg bg-white p-6 shadow-md">
  <input class="rounded-md border border-gray-300 px-3 py-2 focus:outline-hidden focus:ring-2 focus:ring-blue-500" />
  <input class="rounded-md border border-gray-300 px-3 py-2 focus:outline-hidden focus:ring-2 focus:ring-blue-500" />
  <button class="rounded-lg bg-blue-500 px-4 py-2 text-white hover:bg-blue-600">Submit</button>
</form>
```

**Correct (what's right):**

```tsx
// Styled primitives (Tailwind lives here)
function Card({ children }) {
  return <div className="flex flex-col gap-4 rounded-lg bg-white p-6 shadow-md">{children}</div>;
}

function Input(props) {
  return <input className="rounded-md border border-gray-300 px-3 py-2 focus:outline-hidden focus:ring-2 focus:ring-blue-500" {...props} />;
}

function Button({ children, ...props }) {
  return <button className="rounded-lg bg-blue-500 px-4 py-2 text-white hover:bg-blue-600" {...props}>{children}</button>;
}

// Domain component — clean composition, zero utility classes
<Card>
  <Input placeholder="Email" />
  <Input placeholder="Password" type="password" />
  <Button>Submit</Button>
</Card>
```
