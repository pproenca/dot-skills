---
title: Store Sensitive Data with SecureStore
impact: HIGH
impactDescription: encrypts tokens and credentials on device
tags: data, securestore, security, storage
---

## Store Sensitive Data with SecureStore

Use `expo-secure-store` for sensitive data like auth tokens. It encrypts data using the device's secure enclave (iOS) or Keystore (Android).

**Incorrect (storing tokens in AsyncStorage):**

```typescript
import AsyncStorage from '@react-native-async-storage/async-storage';

// AsyncStorage is NOT encrypted - tokens can be extracted
await AsyncStorage.setItem('authToken', token);
```

**Correct (SecureStore for sensitive data):**

```typescript
import * as SecureStore from 'expo-secure-store';

// Store token securely
async function saveToken(token: string) {
  await SecureStore.setItemAsync('authToken', token);
}

// Retrieve token
async function getToken(): Promise<string | null> {
  return await SecureStore.getItemAsync('authToken');
}

// Delete token (on logout)
async function deleteToken() {
  await SecureStore.deleteItemAsync('authToken');
}

// Usage in auth context
export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function loadToken() {
      const storedToken = await getToken();
      setToken(storedToken);
      setIsLoading(false);
    }
    loadToken();
  }, []);

  const signIn = async (newToken: string) => {
    await saveToken(newToken);
    setToken(newToken);
  };

  const signOut = async () => {
    await deleteToken();
    setToken(null);
  };

  return (
    <AuthContext.Provider value={{ token, isLoading, signIn, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}
```

**Limitations:** 2KB value size limit per key. For larger data, use encryption + AsyncStorage.

Reference: [SecureStore - Expo Documentation](https://docs.expo.dev/versions/latest/sdk/securestore/)
