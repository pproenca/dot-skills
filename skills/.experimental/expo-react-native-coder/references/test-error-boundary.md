---
title: Add Error Boundaries for Graceful Error Handling
impact: MEDIUM
impactDescription: prevents entire app crash from component errors
tags: test, error-boundary, error-handling, reliability
---

## Add Error Boundaries for Graceful Error Handling

Use error boundaries to catch JavaScript errors in components and display fallback UI instead of crashing.

**Incorrect (no error boundary):**

```typescript
// Uncaught error crashes entire app
export default function App() {
  return (
    <Stack>
      <Stack.Screen name="index" />
    </Stack>
  );
}
```

**Correct (error boundary with fallback):**

```typescript
// components/ErrorBoundary.tsx
import { Component, ReactNode } from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    // Log to error reporting service
    console.error('Error caught by boundary:', error, errorInfo);
    // e.g., Sentry.captureException(error);
  }

  handleRetry = () => {
    this.setState({ hasError: false, error: undefined });
  };

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback;
      }

      return (
        <View style={styles.container}>
          <Text style={styles.title}>Something went wrong</Text>
          <Text style={styles.message}>{this.state.error?.message}</Text>
          <Pressable style={styles.button} onPress={this.handleRetry}>
            <Text style={styles.buttonText}>Try Again</Text>
          </Pressable>
        </View>
      );
    }

    return this.props.children;
  }
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', alignItems: 'center', padding: 20 },
  title: { fontSize: 20, fontWeight: 'bold', marginBottom: 10 },
  message: { color: '#666', marginBottom: 20, textAlign: 'center' },
  button: { backgroundColor: '#007AFF', padding: 16, borderRadius: 8 },
  buttonText: { color: '#fff', fontWeight: '600' },
});
```

```typescript
// app/_layout.tsx
import { ErrorBoundary } from '@/components/ErrorBoundary';
import { Stack } from 'expo-router';

export default function RootLayout() {
  return (
    <ErrorBoundary>
      <Stack />
    </ErrorBoundary>
  );
}
```

**Expo Router built-in:** Export `ErrorBoundary` from route files for route-specific error handling.

Reference: [Error handling - Expo Documentation](https://docs.expo.dev/router/error-handling/)
