---
title: Configure Avatar ImageComponent for Caching
impact: LOW
impactDescription: Faster image loading, reduced bandwidth, and lower memory usage with cached images
tags: adv, avatar, image, caching, performance
---

## Configure Avatar ImageComponent for Caching

The Avatar component uses React Native's default Image component which lacks persistent caching. For avatars loaded from remote URLs, this means repeated network requests and slower perceived performance. Providing a cached ImageComponent like FastImage dramatically improves load times and reduces data usage.

**Incorrect (default Image without caching):**

```tsx
import { Avatar } from '@rneui/themed';

// Bad: Default Image re-fetches on every mount
const UserAvatar = ({ user }) => (
  <Avatar
    rounded
    size="large"
    source={{ uri: user.avatarUrl }}
    // No caching - network request every time
  />
);

// Bad: List of avatars causes many redundant requests
const UserList = ({ users }) => (
  <FlatList
    data={users}
    renderItem={({ item }) => (
      <Avatar
        rounded
        source={{ uri: item.avatarUrl }}
        // Each scroll may re-fetch these images
      />
    )}
  />
);
```

**Correct (FastImage as ImageComponent for cached loading):**

```tsx
import { Avatar } from '@rneui/themed';
import FastImage from 'react-native-fast-image';

// Good: FastImage provides aggressive caching
const UserAvatar = ({ user }) => (
  <Avatar
    rounded
    size="large"
    source={{ uri: user.avatarUrl }}
    // Custom ImageComponent with caching
    ImageComponent={FastImage}
    // FastImage-specific props for cache control
    imageProps={{
      resizeMode: FastImage.resizeMode.cover,
      priority: FastImage.priority.normal,
    }}
  />
);

// Good: Preload avatars for instant display
const UserList = ({ users }) => {
  useEffect(() => {
    // Preload all avatar URLs
    FastImage.preload(
      users.map((u) => ({ uri: u.avatarUrl }))
    );
  }, [users]);

  return (
    <FlatList
      data={users}
      renderItem={({ item }) => (
        <Avatar
          rounded
          source={{ uri: item.avatarUrl }}
          ImageComponent={FastImage}
          imageProps={{
            resizeMode: FastImage.resizeMode.cover,
          }}
        />
      )}
    />
  );
};
```

Reference: [React Native Elements Avatar](https://reactnativeelements.com/docs/components/avatar)
