---
title: Use ListItem for List Rows Instead of Custom Views
impact: HIGH
impactDescription: reduces list item code by 50% with built-in accessibility
tags: comp, lists, accessibility, performance
---

## Use ListItem for List Rows Instead of Custom Views

ListItem provides built-in accessibility labels, proper touch feedback, and consistent styling out of the box. Building custom list rows with View and TouchableOpacity requires manually implementing these features, leading to inconsistent UX and accessibility gaps.

**Incorrect (custom View with TouchableOpacity):**

```tsx
// Bad: Manual implementation lacks built-in optimizations
const CustomListRow = ({ user, onPress }) => (
  <TouchableOpacity onPress={onPress} style={styles.row}>
    <View style={styles.avatarContainer}>
      <Image source={{ uri: user.avatar }} style={styles.avatar} />
    </View>
    <View style={styles.textContainer}>
      <Text style={styles.title}>{user.name}</Text>
      <Text style={styles.subtitle}>{user.email}</Text>
    </View>
    <Icon name="chevron-right" />
  </TouchableOpacity>
);

// Requires ~30 lines of manual styling
const styles = StyleSheet.create({
  row: { flexDirection: 'row', padding: 16, alignItems: 'center' },
  avatarContainer: { marginRight: 12 },
  avatar: { width: 40, height: 40, borderRadius: 20 },
  textContainer: { flex: 1 },
  title: { fontSize: 16, fontWeight: '600' },
  subtitle: { fontSize: 14, color: '#666' },
});
```

**Correct (ListItem with subcomponents):**

```tsx
import { ListItem, Avatar, Icon } from '@rneui/themed';

// Good: Built-in accessibility, touch handling, and theming
const UserListRow = ({ user, onPress }) => (
  <ListItem onPress={onPress} bottomDivider>
    <Avatar rounded source={{ uri: user.avatar }} />
    <ListItem.Content>
      <ListItem.Title>{user.name}</ListItem.Title>
      <ListItem.Subtitle>{user.email}</ListItem.Subtitle>
    </ListItem.Content>
    <ListItem.Chevron />
  </ListItem>
);

// Swipeable variant with built-in actions
const SwipeableUserRow = ({ user, onDelete }) => (
  <ListItem.Swipeable
    rightContent={(reset) => (
      <Button
        title="Delete"
        onPress={() => { onDelete(user.id); reset(); }}
        icon={{ name: 'delete', color: 'white' }}
        buttonStyle={{ minHeight: '100%', backgroundColor: 'red' }}
      />
    )}
  >
    <Avatar rounded source={{ uri: user.avatar }} />
    <ListItem.Content>
      <ListItem.Title>{user.name}</ListItem.Title>
    </ListItem.Content>
  </ListItem.Swipeable>
);
```

Reference: [React Native Elements ListItem](https://reactnativeelements.com/docs/components/listitem)
