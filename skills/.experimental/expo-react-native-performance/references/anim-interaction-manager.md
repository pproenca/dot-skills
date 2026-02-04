---
title: Defer Heavy Work During Animations
impact: HIGH
impactDescription: prevents dropped frames during transitions
tags: anim, interaction-manager, deferred, performance
---

## Defer Heavy Work During Animations

Heavy JavaScript execution during animations causes dropped frames. Use `InteractionManager.runAfterInteractions()` to defer expensive work until animations complete.

**Incorrect (heavy work during navigation animation):**

```typescript
// screens/ProfileScreen.tsx
export function ProfileScreen({ userId }: Props) {
  const [profile, setProfile] = useState<Profile | null>(null);

  useEffect(() => {
    // Runs immediately, blocks JS thread during screen transition
    fetchProfile(userId).then(setProfile);
    loadAnalytics(userId);
    preloadImages(userId);
  }, [userId]);

  return profile ? <ProfileView profile={profile} /> : <Loading />;
}
// Navigation animation stutters as JS thread is blocked
```

**Correct (defer until animation completes):**

```typescript
// screens/ProfileScreen.tsx
import { InteractionManager } from 'react-native';

export function ProfileScreen({ userId }: Props) {
  const [profile, setProfile] = useState<Profile | null>(null);

  useEffect(() => {
    const task = InteractionManager.runAfterInteractions(() => {
      fetchProfile(userId).then(setProfile);
      loadAnalytics(userId);
      preloadImages(userId);
    });

    return () => task.cancel();
  }, [userId]);

  return profile ? <ProfileView profile={profile} /> : <Loading />;
}
// Navigation animation completes smoothly, then data loads
```

**When to defer:**
- Screen mount data fetching
- Heavy list rendering
- Image processing
- Analytics/logging

**Trade-off:** Users see loading state slightly longer, but transitions are smooth.

Reference: [InteractionManager](https://reactnative.dev/docs/interactionmanager)
