/**
 * Auth Context Template
 *
 * A complete authentication context with:
 * - Session management
 * - Secure token storage
 * - Loading state handling
 */

import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import * as SecureStore from 'expo-secure-store';

const SESSION_KEY = 'user-session';

interface User {
  id: string;
  email: string;
  name: string;
}

interface AuthContextType {
  user: User | null;
  session: string | null;
  isLoading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (email: string, password: string, name: string) => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Load session on mount
  useEffect(() => {
    async function loadSession() {
      try {
        const token = await SecureStore.getItemAsync(SESSION_KEY);
        if (token) {
          // Validate token and get user
          const response = await fetch('/api/auth/me', {
            headers: { Authorization: `Bearer ${token}` },
          });
          if (response.ok) {
            const userData = await response.json();
            setUser(userData);
            setSession(token);
          } else {
            // Token invalid, clear it
            await SecureStore.deleteItemAsync(SESSION_KEY);
          }
        }
      } catch (error) {
        console.error('Failed to load session:', error);
      } finally {
        setIsLoading(false);
      }
    }
    loadSession();
  }, []);

  const signIn = async (email: string, password: string) => {
    const response = await fetch('/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || 'Login failed');
    }

    const { token, user: userData } = await response.json();
    await SecureStore.setItemAsync(SESSION_KEY, token);
    setSession(token);
    setUser(userData);
  };

  const signUp = async (email: string, password: string, name: string) => {
    const response = await fetch('/api/auth/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password, name }),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || 'Registration failed');
    }

    const { token, user: userData } = await response.json();
    await SecureStore.setItemAsync(SESSION_KEY, token);
    setSession(token);
    setUser(userData);
  };

  const signOut = async () => {
    await SecureStore.deleteItemAsync(SESSION_KEY);
    setSession(null);
    setUser(null);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        session,
        isLoading,
        signIn,
        signUp,
        signOut,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
