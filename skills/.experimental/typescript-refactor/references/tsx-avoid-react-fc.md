---
title: Type Props Directly Instead of React.FC
impact: HIGH
impactDescription: makes children opt-in and enables generic components
tags: tsx, react-fc, props, children
---

## Type Props Directly Instead of React.FC

`React.FC` blocks generic components and obscures the `children` contract — historically it forced a `children` prop the component may not render. Typing the props parameter directly is simpler, makes `children` opt-in, and lets a component be generic.

**Incorrect (React.FC hides the children contract and can't be generic):**

```tsx
const UserCard: React.FC<UserCardProps> = ({ user }) => {
  return <div>{user.name}</div>
}
// children is silently accepted even though UserCard never renders it
// Cannot write `const List: React.FC<ListProps<T>>` — FC is not generic
```

**Correct (plain function; children opt-in; generics work):**

```tsx
interface UserCardProps {
  user: User
  children?: React.ReactNode // declared only because this card renders it
}

function UserCard({ user, children }: UserCardProps) {
  return <div>{user.name}{children}</div>
}

function List<T>({ items, renderItem }: ListProps<T>) {
  return <ul>{items.map(renderItem)}</ul>
}
```

Type `children` as `React.ReactNode` (the widest renderable type), not `React.ReactElement`/`React.JSX.Element`, which reject strings, numbers, arrays, and `null`.

Reference: [React — Using TypeScript](https://react.dev/learn/typescript)
