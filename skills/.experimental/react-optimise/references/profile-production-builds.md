---
title: Benchmark with Production Builds Only
impact: MEDIUM
impactDescription: prevents false positives from dev-mode overhead
tags: profile, production, benchmarking, dev-mode
---

## Benchmark with Production Builds Only

React development mode includes StrictMode double-rendering, prop validation, and detailed warning checks that add 2-10x overhead. Profiling a dev build produces inflated numbers that do not reflect real user experience and leads to optimizing problems that do not exist in production.

**Incorrect (profiling dev build with inflated timings):**

```tsx
// Developer runs "npm start" (development mode) and opens Chrome DevTools

// Profiler shows:
//   ContactList render: 120ms ← inflated by StrictMode double render
//   ContactCard render: 8ms each ← includes prop-type validation overhead
//   Total frame: 340ms ← not representative of production

// Developer concludes ContactCard is slow and wraps every instance in memo
const ContactCard = memo(function ContactCard({ contact }: { contact: Contact }) {
  return (
    <div className="contact-card">
      <img src={contact.avatarUrl} alt={contact.name} />
      <h3>{contact.name}</h3>
      <p>{contact.email}</p>
      <span className="department">{contact.department}</span>
    </div>
  )
})

// In production, ContactCard renders in 0.4ms — memo overhead is wasted
```

**Correct (profile production build with React profiling enabled):**

```bash
# Build production bundle with profiling support
npx react-scripts build --profile
# or for Next.js:
# next build && next start
```

```tsx
// Production profiler shows actual timings:
//   ContactList render: 18ms ← no StrictMode double render
//   ContactCard render: 0.4ms each ← no dev-mode validation
//   Total frame: 22ms ← within 16ms budget at scale

// Production data reveals the real bottleneck: ContactSearch filtering
// 10,000 contacts filtered with .includes() on every keystroke = 85ms
function ContactSearch({ contacts }: { contacts: Contact[] }) {
  const [query, setQuery] = useState("")

  const filteredContacts = useDeferredValue(
    contacts.filter(
      (contact) =>
        contact.name.toLowerCase().includes(query.toLowerCase()) ||
        contact.email.toLowerCase().includes(query.toLowerCase())
    )
  )

  return (
    <div>
      <input value={query} onChange={(e) => setQuery(e.target.value)} />
      <ContactList contacts={filteredContacts} />
    </div>
  )
}
```

Reference: [React Docs — Profiler](https://react.dev/reference/react/Profiler)
