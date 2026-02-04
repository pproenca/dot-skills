---
title: Create Auth Context with Session Management
impact: HIGH
impactDescription: provides auth state to entire app
tags: auth, context, session, state
---

## Create Auth Context with Session Management

Create an AuthContext that manages session state, handles sign in/out, and persists tokens with SecureStore.

**Incorrect (auth state scattered across components):**

```typescript
// Each component manages its own auth state
const [token, setToken] = useState(null);
// Inconsistent state across app
```

**Correct (centralized auth context):**

```typescript
// context/auth.tsx
import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import * as SecureStore from 'expo-secure-store';

interface AuthContextType {
  session: string | null;
  isLoading: boolean;
  signIn: (token: string) => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Load token on mount
  useEffect(() => {
    async function loadSession() {
      try {
        const token = await SecureStore.getItemAsync('session');
        setSession(token);
      } finally {
        setIsLoading(false);
      }
    }
    loadSession();
  }, []);

  const signIn = async (token: string) => {
    await SecureStore.setItemAsync('session', token);
    setSession(token);
  };

  const signOut = async () => {
    await SecureStore.deleteItemAsync('session');
    setSession(null);
  };

  return (
    <AuthContext.Provider value={{ session, isLoading, signIn, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}
```

```typescript
// app/_layout.tsx - Wrap app with provider
import { AuthProvider } from '@/context/auth';

export default function RootLayout() {
  return (
    <AuthProvider>
      <Stack>...</Stack>
    </AuthProvider>
  );
}
```

Reference: [Authentication in Expo Router - Expo Documentation](https://docs.expo.dev/router/advanced/authentication/)
