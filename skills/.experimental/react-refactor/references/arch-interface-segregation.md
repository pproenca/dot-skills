---
title: Apply Interface Segregation to Component Props
impact: CRITICAL
impactDescription: prevents 30-50% of unnecessary re-renders from unrelated prop changes
tags: arch, interface-segregation, props, type-safety, re-renders
---

## Apply Interface Segregation to Component Props

Components accepting a wide union of optional props for different contexts create false dependencies. A change to any prop — even one the component ignores in its current usage — triggers a re-render. Focused prop interfaces per use case narrow the contract and eliminate phantom dependencies.

**Incorrect (one wide interface for all contexts):**

```tsx
interface UserCardProps {
  userId: string;
  userName: string;
  avatarUrl: string;
  email?: string;            // Only used in admin view
  lastLoginAt?: Date;        // Only used in admin view
  onFollow?: () => void;     // Only used in social view
  followerCount?: number;    // Only used in social view
  isOnline?: boolean;        // Only used in chat view
  lastMessage?: string;      // Only used in chat view
}

// Admin page passes social/chat props as undefined — still triggers re-renders
function UserCard({ userId, userName, avatarUrl, email, lastLoginAt, onFollow, followerCount, isOnline, lastMessage }: UserCardProps) {
  return (
    <div className="user-card">
      <img src={avatarUrl} alt={userName} />
      <h3>{userName}</h3>
      {email && <p>{email}</p>}
      {lastLoginAt && <p>Last login: {lastLoginAt.toLocaleDateString()}</p>}
      {onFollow && <button onClick={onFollow}>Follow ({followerCount})</button>}
      {isOnline !== undefined && <span className={isOnline ? "online" : "offline"} />}
      {lastMessage && <p>{lastMessage}</p>}
    </div>
  );
}
```

**Correct (focused interfaces per context):**

```tsx
interface UserCardBaseProps {
  userId: string;
  userName: string;
  avatarUrl: string;
}

interface AdminUserCardProps extends UserCardBaseProps {
  email: string;
  lastLoginAt: Date;
}

interface SocialUserCardProps extends UserCardBaseProps {
  onFollow: () => void;
  followerCount: number;
}

// Each component only re-renders for props it uses
function AdminUserCard({ userId, userName, avatarUrl, email, lastLoginAt }: AdminUserCardProps) {
  return (
    <div className="user-card">
      <img src={avatarUrl} alt={userName} />
      <h3>{userName}</h3>
      <p>{email}</p>
      <p>Last login: {lastLoginAt.toLocaleDateString()}</p>
    </div>
  );
}

function SocialUserCard({ userId, userName, avatarUrl, onFollow, followerCount }: SocialUserCardProps) {
  return (
    <div className="user-card">
      <img src={avatarUrl} alt={userName} />
      <h3>{userName}</h3>
      <button onClick={onFollow}>Follow ({followerCount})</button>
    </div>
  );
}
```

Reference: [React TypeScript Cheatsheet - Component Props](https://react-typescript-cheatsheet.netlify.app/docs/basic/getting-started/basic_type_example)
