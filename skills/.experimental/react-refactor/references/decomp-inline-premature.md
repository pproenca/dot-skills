---
title: Inline Premature Abstractions Before Re-Extracting
impact: HIGH
impactDescription: 40-60% simpler code after inlining wrong abstractions
tags: decomp, abstraction, inlining, duplication
---

## Inline Premature Abstractions Before Re-Extracting

A wrong abstraction resists change more than duplicated code. When a shared component accumulates mode flags and conditional branches to serve diverging use cases, inline it back into each call site first, then re-extract only the genuinely shared parts.

**Incorrect (forced abstraction with mode flags serving three divergent patterns):**

```tsx
interface NotificationCardProps {
  notification: Notification;
  variant: "banner" | "toast" | "inline";
  showAvatar?: boolean;
  showTimestamp?: boolean;
  showDismiss?: boolean;
  showActions?: boolean;
  onDismiss?: () => void;
  onActionClick?: (action: string) => void;
  autoHideDuration?: number;
  position?: "top" | "bottom";
  compact?: boolean;
}

function NotificationCard({
  notification, variant, showAvatar, showTimestamp,
  showDismiss, showActions, onDismiss, onActionClick,
  autoHideDuration, position, compact,
}: NotificationCardProps) {
  // Every variant adds branches, none can evolve independently
  const className = variant === "banner"
    ? `banner ${position}`
    : variant === "toast"
      ? `toast ${position} ${compact ? "compact" : ""}`
      : "inline";

  return (
    <div className={className}>
      {showAvatar && variant !== "toast" && <Avatar user={notification.sender} />}
      <p>{notification.message}</p>
      {showTimestamp && variant !== "banner" && <time>{notification.createdAt}</time>}
      {showDismiss && <button onClick={onDismiss}>Dismiss</button>}
      {showActions && variant === "inline" && (
        <div>{notification.actions?.map((a) => (
          <button key={a} onClick={() => onActionClick?.(a)}>{a}</button>
        ))}</div>
      )}
    </div>
  );
}
```

**Correct (inline back to call sites, then extract only genuinely shared logic):**

```tsx
// Step 1: Each variant is its own component — free to evolve independently
function BannerNotification({ notification, position, onDismiss }: BannerProps) {
  return (
    <div className={`banner ${position}`}>
      <Avatar user={notification.sender} />
      <p>{notification.message}</p>
      <button onClick={onDismiss}>Dismiss</button>
    </div>
  );
}

function ToastNotification({ notification, compact, onDismiss }: ToastProps) {
  return (
    <div className={`toast ${compact ? "compact" : ""}`}>
      <p>{notification.message}</p>
      <button onClick={onDismiss}>Dismiss</button>
    </div>
  );
}

function InlineNotification({ notification, onActionClick }: InlineProps) {
  return (
    <div className="inline">
      <Avatar user={notification.sender} />
      <p>{notification.message}</p>
      <time>{notification.createdAt}</time>
      {notification.actions?.map((action) => (
        <button key={action} onClick={() => onActionClick(action)}>
          {action}
        </button>
      ))}
    </div>
  );
}
```

Reference: [The Wrong Abstraction — Sandi Metz](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction)
