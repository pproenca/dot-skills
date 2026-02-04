---
title: Use Avatar for Profile and User Images
impact: HIGH
impactDescription: reduces avatar implementation code by 70% with built-in fallbacks
tags: comp, images, profiles, ux
---

## Use Avatar for Profile and User Images

The Avatar component provides built-in rounded styling, placeholder handling, initials fallback for missing images, and accessory badges. Using the basic Image component for user avatars requires manually implementing all these features, leading to inconsistent profile displays and poor fallback handling.

**Incorrect (Image with manual rounded styling and fallback):**

```tsx
// Bad: Manual implementation of avatar features
const UserAvatar = ({ user }) => {
  const [imageError, setImageError] = useState(false);

  const getInitials = (name) => {
    return name
      .split(' ')
      .map((n) => n[0])
      .join('')
      .toUpperCase();
  };

  if (imageError || !user.avatarUrl) {
    return (
      <View style={styles.initialsContainer}>
        <Text style={styles.initials}>{getInitials(user.name)}</Text>
      </View>
    );
  }

  return (
    <Image
      source={{ uri: user.avatarUrl }}
      style={styles.avatar}
      onError={() => setImageError(true)}
    />
  );
};

// Lots of manual styling
const styles = StyleSheet.create({
  avatar: { width: 50, height: 50, borderRadius: 25 },
  initialsContainer: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: '#ccc',
    justifyContent: 'center',
    alignItems: 'center',
  },
  initials: { color: '#fff', fontSize: 18, fontWeight: '600' },
});
```

**Correct (Avatar with built-in features):**

```tsx
import { Avatar } from '@rneui/themed';

// Good: Built-in rounded, placeholder, and error handling
const UserAvatar = ({ user }) => (
  <Avatar
    rounded
    size="medium"
    source={{ uri: user.avatarUrl }}
    title={user.name
      .split(' ')
      .map((n) => n[0])
      .join('')}
  />
);

// Size variants
const AvatarSizes = ({ user }) => (
  <View style={{ flexDirection: 'row', gap: 8 }}>
    <Avatar rounded size="small" source={{ uri: user.avatarUrl }} />
    <Avatar rounded size="medium" source={{ uri: user.avatarUrl }} />
    <Avatar rounded size="large" source={{ uri: user.avatarUrl }} />
    <Avatar rounded size="xlarge" source={{ uri: user.avatarUrl }} />
  </View>
);

// With accessory badge (online status, edit button)
const AvatarWithStatus = ({ user, isOnline }) => (
  <Avatar
    rounded
    size="large"
    source={{ uri: user.avatarUrl }}
    title={user.initials}
  >
    <Avatar.Accessory
      size={18}
      style={{ backgroundColor: isOnline ? 'green' : 'gray' }}
    />
  </Avatar>
);

// Editable avatar with camera icon
const EditableAvatar = ({ user, onEdit }) => (
  <Avatar
    rounded
    size="xlarge"
    source={{ uri: user.avatarUrl }}
    title={user.initials}
    onPress={onEdit}
  >
    <Avatar.Accessory size={24} name="camera" type="material" onPress={onEdit} />
  </Avatar>
);

// Icon avatar for placeholder or system users
const SystemAvatar = () => (
  <Avatar
    rounded
    size="medium"
    icon={{ name: 'person', type: 'material' }}
    containerStyle={{ backgroundColor: '#c2c2c2' }}
  />
);

// Avatar group for multiple users
const AvatarGroup = ({ users }) => (
  <View style={{ flexDirection: 'row' }}>
    {users.slice(0, 3).map((user, index) => (
      <Avatar
        key={user.id}
        rounded
        size="small"
        source={{ uri: user.avatarUrl }}
        title={user.initials}
        containerStyle={{ marginLeft: index > 0 ? -10 : 0 }}
      />
    ))}
    {users.length > 3 && (
      <Avatar
        rounded
        size="small"
        title={`+${users.length - 3}`}
        containerStyle={{ marginLeft: -10, backgroundColor: '#666' }}
      />
    )}
  </View>
);
```

Reference: [React Native Elements Avatar](https://reactnativeelements.com/docs/components/avatar)
