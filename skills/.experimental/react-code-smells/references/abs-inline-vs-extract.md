---
title: Know When to Inline vs Extract Components
impact: MEDIUM-HIGH
impactDescription: right-sizes components for maintenance, prevents both bloat and fragmentation
tags: abs, inline, extraction, component-size, judgment
---

## Know When to Inline vs Extract Components

Both over-extraction (too many tiny components) and under-extraction (god components) harm maintainability. Use clear criteria to decide.

**Code Smell Indicators (Over-extraction):**
- Components that are only used once
- Need to jump between 10 files to understand one feature
- Prop drilling to pass data to extracted components
- Files with 5 lines of actual logic

**Code Smell Indicators (Under-extraction):**
- Components over 200 lines
- Multiple unrelated responsibilities
- Hard to find where to make changes
- Scrolling to understand the component

**Incorrect (over-extracted):**

```tsx
// 7 files for a simple form
// UserNameInput.tsx
function UserNameInput({ value, onChange }) {
  return <input value={value} onChange={e => onChange(e.target.value)} />
}

// UserNameLabel.tsx
function UserNameLabel() {
  return <label>Username</label>
}

// UserNameField.tsx
function UserNameField({ value, onChange }) {
  return (
    <div>
      <UserNameLabel />
      <UserNameInput value={value} onChange={onChange} />
    </div>
  )
}

// ... same for email, password, submit button
```

**Incorrect (under-extracted):**

```tsx
// 500-line component doing everything
function UserDashboard() {
  // User profile state
  const [user, setUser] = useState(null)
  // Notification state
  const [notifications, setNotifications] = useState([])
  // Settings state
  const [settings, setSettings] = useState({})
  // Activity state
  const [activities, setActivities] = useState([])

  // ... 10 useEffects for different concerns
  // ... 20 event handlers
  // ... 300 lines of JSX mixing all concerns
}
```

**Correct (right-sized extraction):**

```tsx
// User form - extracted because it's a cohesive unit with its own state
function UserProfileForm({ user, onSave }) {
  const [formData, setFormData] = useState(user)
  const [errors, setErrors] = useState({})

  // Form has its own state and validation logic
  // But individual fields are inline - they're not reused

  return (
    <form onSubmit={handleSubmit}>
      <div className="field">
        <label htmlFor="name">Name</label>
        <input
          id="name"
          value={formData.name}
          onChange={e => setFormData({ ...formData, name: e.target.value })}
        />
        {errors.name && <span className="error">{errors.name}</span>}
      </div>

      <div className="field">
        <label htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          value={formData.email}
          onChange={e => setFormData({ ...formData, email: e.target.value })}
        />
        {errors.email && <span className="error">{errors.email}</span>}
      </div>

      <button type="submit">Save</button>
    </form>
  )
}

// Dashboard composes cohesive units
function UserDashboard() {
  const user = useUser()

  return (
    <DashboardLayout>
      <UserProfileForm user={user} onSave={updateUser} />
      <NotificationPanel />
      <ActivityFeed />
      <SettingsSection />
    </DashboardLayout>
  )
}
```

**Decision framework:**

```
Should I extract this to a component?

├── Is it reused in 2+ places?
│   └── YES → Extract
│
├── Does it have its own state or effects?
│   └── YES → Probably extract
│
├── Is it > 50 lines of JSX?
│   └── YES → Consider extracting
│
├── Would it make the parent clearer?
│   └── YES → Extract
│
├── Does extracting require 4+ props?
│   └── Consider keeping inline
│
└── Is it a single use, simple element?
    └── Keep inline
```

**Size guidelines:**
- Inline: Simple JSX, no state, single use
- Extract: Has own state, reused, or >50 lines
- Split: >200 lines, multiple concerns

Reference: [Thinking in React](https://react.dev/learn/thinking-in-react)
