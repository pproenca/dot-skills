---
title: Apply Interface Segregation to Props
impact: MEDIUM-HIGH
impactDescription: reduces component coupling, enables independent testing
tags: couple, interface-segregation, props, typescript, decoupling
---

## Apply Interface Segregation to Props

Components that accept entire objects when they only need a few properties create unnecessary coupling. Accept only what you use.

**Code Smell Indicators:**
- Component imports entire entity types for 2-3 fields
- Tests require creating full objects for simple components
- Changing entity structure breaks unrelated components
- Type errors cascade across components

**Incorrect (accepts more than needed):**

```tsx
interface User {
  id: string
  email: string
  name: string
  avatar: string
  role: 'admin' | 'user'
  preferences: UserPreferences
  subscription: SubscriptionDetails
  billingInfo: BillingInfo
  activityLog: Activity[]
}

// Component only uses 2 fields but requires entire User
function UserAvatar({ user }: { user: User }) {
  return (
    <img
      src={user.avatar}
      alt={user.name}
      className="avatar"
    />
  )
}

// Test requires creating full User object
test('renders avatar', () => {
  const user: User = {
    id: '1',
    email: 'test@test.com',
    name: 'Test User',
    avatar: '/avatar.jpg',
    role: 'user',
    preferences: { /* ... */ },
    subscription: { /* ... */ },
    billingInfo: { /* ... */ },
    activityLog: [],
  }
  render(<UserAvatar user={user} />)
})
```

**Correct (accepts only what's needed):**

```tsx
// Component declares exactly what it needs
interface UserAvatarProps {
  name: string
  avatar: string
  size?: 'sm' | 'md' | 'lg'
}

function UserAvatar({ name, avatar, size = 'md' }: UserAvatarProps) {
  return (
    <img
      src={avatar}
      alt={name}
      className={`avatar avatar-${size}`}
    />
  )
}

// Usage - extract what's needed
<UserAvatar name={user.name} avatar={user.avatar} />
<UserAvatar name={teamMember.displayName} avatar={teamMember.imageUrl} />

// Test is simple
test('renders avatar', () => {
  render(<UserAvatar name="Test User" avatar="/avatar.jpg" />)
  expect(screen.getByAltText('Test User')).toHaveAttribute('src', '/avatar.jpg')
})
```

**Pattern: Pick from larger types:**

```tsx
// When you need subset of a larger type
type UserAvatarProps = Pick<User, 'name' | 'avatar'> & {
  size?: 'sm' | 'md' | 'lg'
}

// Component still decoupled, but type relationship documented
```

**Pattern: Adapter at boundary:**

```tsx
// Container component adapts full entity to presentational component
function UserCard({ user }: { user: User }) {
  return (
    <Card>
      <UserAvatar name={user.name} avatar={user.avatar} />
      <UserBio bio={user.preferences.bio} />
      <UserBadge role={user.role} />
    </Card>
  )
}

// Presentational components stay decoupled
function UserBio({ bio }: { bio: string }) {
  return <p className="bio">{bio}</p>
}

function UserBadge({ role }: { role: 'admin' | 'user' }) {
  return <span className={`badge badge-${role}`}>{role}</span>
}
```

**Benefits:**
- Components are reusable with different data sources
- Tests are simple - no mock factories
- Changes to entity don't cascade
- Clear documentation of what component actually uses

**Decision heuristic:**
```
Component needs N fields from object with M fields:
├── N < 3 and M > 5 → Pass individual props
├── N > 5 and M > 10 → Use Pick<> to subset
└── N ≈ M → Passing whole object is fine
```

Reference: [Interface Segregation Principle](https://www.oodesign.com/interface-segregation-principle)
