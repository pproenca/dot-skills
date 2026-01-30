---
title: Break Circular Dependencies with Inversion
impact: HIGH
impactDescription: eliminates bundler issues, enables tree-shaking, clarifies architecture
tags: couple, circular-dependencies, inversion, architecture, refactoring
---

## Break Circular Dependencies with Inversion

Circular imports indicate architectural problems and cause runtime issues. Break cycles by inverting dependencies or extracting shared code.

**Code Smell Indicators:**
- Bundler warnings about circular dependencies
- `undefined` imports at runtime
- Can't tree-shake because everything imports everything
- Module load order issues

**Incorrect (circular dependency):**

```tsx
// user.ts
import { Order } from './order' // Imports Order

export interface User {
  id: string
  name: string
  orders: Order[]
}

export function getUserOrders(user: User): Order[] {
  return user.orders.filter(o => o.status === 'completed')
}

// order.ts
import { User, getUserOrders } from './user' // Imports User - CIRCULAR!

export interface Order {
  id: string
  userId: string
  user?: User
  status: 'pending' | 'completed'
}

export function getOrderUser(order: Order): User | undefined {
  return order.user
}

// At runtime, one of these will be partially undefined
```

**Correct (extract shared types):**

```tsx
// types.ts - shared types, no logic, no imports
export interface User {
  id: string
  name: string
}

export interface Order {
  id: string
  userId: string
  status: 'pending' | 'completed'
}

// user.ts - imports types only
import { User, Order } from './types'

export function getUserOrders(user: User, orders: Order[]): Order[] {
  return orders.filter(o => o.userId === user.id && o.status === 'completed')
}

// order.ts - imports types only
import { User, Order } from './types'

export function getOrderUser(order: Order, users: User[]): User | undefined {
  return users.find(u => u.id === order.userId)
}

// No circular dependency - types flow down, logic is separate
```

**Pattern: Dependency inversion:**

```tsx
// BEFORE: Component directly imports service
// UserList.tsx → userService.ts → UserList.tsx (circular via types)

// AFTER: Inject dependency
interface UserService {
  getUsers(): Promise<User[]>
}

function UserList({ userService }: { userService: UserService }) {
  const [users, setUsers] = useState<User[]>([])

  useEffect(() => {
    userService.getUsers().then(setUsers)
  }, [userService])

  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>
}

// userService.ts doesn't need to import UserList
// Types are separate from implementations
```

**Pattern: Event-based decoupling:**

```tsx
// BEFORE: Direct coupling between modules
// cart.ts imports user.ts, user.ts imports cart.ts

// AFTER: Event bus decouples them
// events.ts
export const events = new EventEmitter()

// user.ts
export function logoutUser() {
  events.emit('user:logout')
}

// cart.ts
events.on('user:logout', () => {
  clearCart()
})

// No direct imports between user and cart
```

**Detecting circular dependencies:**

```bash
# With madge
npx madge --circular src/

# With ESLint
// eslint.config.js
import importPlugin from 'eslint-plugin-import'

export default [
  {
    plugins: { import: importPlugin },
    rules: {
      'import/no-cycle': 'error',
    },
  },
]
```

**Breaking strategies:**
1. Extract shared types to separate file
2. Invert dependency direction
3. Use dependency injection
4. Use events for cross-cutting concerns
5. Move shared logic to a third module

Reference: [Circular Dependencies in JavaScript](https://spin.atomicobject.com/2018/06/25/circular-dependencies-javascript/)
