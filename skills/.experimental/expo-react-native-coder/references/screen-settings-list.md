---
title: Build Settings Screens with Section Lists
impact: MEDIUM
impactDescription: familiar iOS/Android settings pattern
tags: screen, settings, sectionlist, pattern
---

## Build Settings Screens with Section Lists

Use SectionList for settings screens with grouped options. This follows native platform conventions.

**Incorrect (flat list without grouping):**

```typescript
<View>
  <Pressable><Text>Edit Profile</Text></Pressable>
  <Pressable><Text>Notifications</Text></Pressable>
  <Pressable><Text>Privacy</Text></Pressable>
  <Pressable><Text>About</Text></Pressable>
  <Pressable><Text>Log Out</Text></Pressable>
</View>
```

**Correct (SectionList with proper grouping):**

```typescript
import { SectionList, Text, Pressable, View, StyleSheet } from 'react-native';
import { router } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';

interface SettingItem {
  id: string;
  title: string;
  icon: keyof typeof Ionicons.glyphMap;
  onPress: () => void;
  destructive?: boolean;
}

const sections = [
  {
    title: 'Account',
    data: [
      { id: 'profile', title: 'Edit Profile', icon: 'person', onPress: () => router.push('/settings/profile') },
      { id: 'notifications', title: 'Notifications', icon: 'notifications', onPress: () => router.push('/settings/notifications') },
      { id: 'privacy', title: 'Privacy', icon: 'lock-closed', onPress: () => router.push('/settings/privacy') },
    ] as SettingItem[],
  },
  {
    title: 'Support',
    data: [
      { id: 'help', title: 'Help Center', icon: 'help-circle', onPress: () => router.push('/settings/help') },
      { id: 'about', title: 'About', icon: 'information-circle', onPress: () => router.push('/settings/about') },
    ] as SettingItem[],
  },
  {
    title: '',
    data: [
      { id: 'logout', title: 'Log Out', icon: 'log-out', onPress: () => {}, destructive: true },
    ] as SettingItem[],
  },
];

export default function SettingsScreen() {
  return (
    <SectionList
      sections={sections}
      keyExtractor={(item) => item.id}
      renderItem={({ item }) => (
        <Pressable style={styles.row} onPress={item.onPress}>
          <Ionicons name={item.icon} size={22} color={item.destructive ? 'red' : '#333'} />
          <Text style={[styles.title, item.destructive && styles.destructive]}>
            {item.title}
          </Text>
          <Ionicons name="chevron-forward" size={20} color="#ccc" />
        </Pressable>
      )}
      renderSectionHeader={({ section: { title } }) =>
        title ? <Text style={styles.sectionHeader}>{title}</Text> : null
      }
      stickySectionHeadersEnabled={false}
    />
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center', padding: 16, backgroundColor: '#fff' },
  title: { flex: 1, marginLeft: 12, fontSize: 16 },
  destructive: { color: 'red' },
  sectionHeader: { padding: 16, paddingBottom: 8, fontSize: 13, color: '#666', textTransform: 'uppercase' },
});
```

Reference: [SectionList - React Native](https://reactnative.dev/docs/sectionlist)
