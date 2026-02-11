---
title: Convert Render Props to Custom Hooks
impact: CRITICAL
impactDescription: eliminates 2-4 levels of nesting, improves readability
tags: arch, render-props, hooks, migration, nesting
---

## Convert Render Props to Custom Hooks

Legacy render prop components create deep nesting when composed together. Each wrapper adds an indentation level, making the component tree hard to follow. Custom hooks provide the same behavior reuse with a flat call structure.

**Incorrect (render props — nested callback pyramid):**

```tsx
function UserDashboard() {
  return (
    <AuthProvider>
      {(auth) => (
        <ThemeProvider>
          {(theme) => (
            <FeatureFlagProvider>
              {(flags) => (
                <NotificationProvider userId={auth.userId}>
                  {(notifications) => (
                    // 4 levels deep — adding another provider means level 5
                    <DashboardLayout
                      theme={theme}
                      userName={auth.userName}
                      unreadCount={notifications.unreadCount}
                      showBetaBanner={flags.isEnabled("beta-banner")}
                    />
                  )}
                </NotificationProvider>
              )}
            </FeatureFlagProvider>
          )}
        </ThemeProvider>
      )}
    </AuthProvider>
  );
}
```

**Correct (custom hooks — flat composition):**

```tsx
function UserDashboard() {
  const auth = useAuth();
  const theme = useTheme();
  const flags = useFeatureFlags();
  const notifications = useNotifications(auth.userId);

  // Flat — adding another hook is one line, not another nesting level
  return (
    <DashboardLayout
      theme={theme}
      userName={auth.userName}
      unreadCount={notifications.unreadCount}
      showBetaBanner={flags.isEnabled("beta-banner")}
    />
  );
}
```

Reference: [React Docs - Reusing Logic with Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)
