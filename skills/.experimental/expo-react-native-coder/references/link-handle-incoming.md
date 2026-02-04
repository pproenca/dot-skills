---
title: Handle Incoming Links with Expo Router
impact: MEDIUM
impactDescription: automatic deep link routing to screens
tags: link, routing, params, navigation
---

## Handle Incoming Links with Expo Router

Expo Router automatically routes incoming URLs to matching screens. Use dynamic segments to capture URL parameters.

**Incorrect (manual link parsing):**

```typescript
import * as Linking from 'expo-linking';
import { useEffect } from 'react';

export default function App() {
  useEffect(() => {
    const handleUrl = ({ url }: { url: string }) => {
      const parsed = Linking.parse(url);
      if (parsed.path?.startsWith('invite/')) {
        const code = parsed.path.split('/')[1];
        navigation.navigate('Invite', { code });  // Manual routing
      }
    };
    Linking.addEventListener('url', handleUrl);
  }, []);
}
```

**Correct (file-based routing handles links automatically):**

```plaintext
app/
├── user/
│   └── [id].tsx        # Handles myapp://user/123
├── post/
│   └── [postId].tsx    # Handles myapp://post/abc
└── invite/
    └── [code].tsx      # Handles myapp://invite/XYZ123
```

```typescript
// app/invite/[code].tsx - Screen receives params automatically
import { useLocalSearchParams, router } from 'expo-router';
import { useEffect, useState } from 'react';
import { View, Text, Button, ActivityIndicator } from 'react-native';

export default function InviteScreen() {
  const { code } = useLocalSearchParams<{ code: string }>();
  const [invite, setInvite] = useState<Invite | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function validateInvite() {
      const response = await fetch(`/api/invites/${code}`);
      const data = await response.json();
      setInvite(data);
      setLoading(false);
    }
    validateInvite();
  }, [code]);

  if (loading) return <ActivityIndicator />;

  return (
    <View style={{ flex: 1, padding: 16 }}>
      <Text style={{ fontSize: 24 }}>You're invited!</Text>
      <Text>{invite?.message}</Text>
      <Button title="Accept" onPress={() => router.replace('/')} />
    </View>
  );
}
```

**Note:** Expo Router handles both cold starts and warm links automatically.

Reference: [Customizing links - Expo Documentation](https://docs.expo.dev/router/advanced/native-intent/)
