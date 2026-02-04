/**
 * Auth Layout Template
 *
 * Root layout with protected routes based on authentication state.
 * Place this file at: app/_layout.tsx
 */

import { Stack, SplashScreen } from 'expo-router';
import { useEffect } from 'react';
import { useFonts } from 'expo-font';
import { AuthProvider, useAuth } from '@/context/auth';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { SafeAreaProvider } from 'react-native-safe-area-context';

// Prevent splash from auto-hiding
SplashScreen.preventAutoHideAsync();

function RootLayoutNav() {
  const { session, isLoading } = useAuth();

  useEffect(() => {
    if (!isLoading) {
      SplashScreen.hideAsync();
    }
  }, [isLoading]);

  if (isLoading) {
    return null; // Splash screen remains visible
  }

  return (
    <Stack screenOptions={{ headerShown: false }}>
      {/* Protected app routes */}
      <Stack.Protected guard={!!session}>
        <Stack.Screen name="(app)" />
      </Stack.Protected>

      {/* Auth routes */}
      <Stack.Protected guard={!session}>
        <Stack.Screen name="sign-in" />
        <Stack.Screen name="sign-up" />
        <Stack.Screen name="forgot-password" />
      </Stack.Protected>

      {/* Modal screens (always accessible) */}
      <Stack.Screen
        name="modal"
        options={{
          presentation: 'modal',
          headerShown: true,
        }}
      />
    </Stack>
  );
}

export default function RootLayout() {
  const [fontsLoaded, fontError] = useFonts({
    // Add your custom fonts here
    // 'Inter-Regular': require('@/assets/fonts/Inter-Regular.otf'),
  });

  useEffect(() => {
    if (fontError) {
      console.error('Font loading error:', fontError);
    }
  }, [fontError]);

  if (!fontsLoaded && !fontError) {
    return null;
  }

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        <AuthProvider>
          <RootLayoutNav />
        </AuthProvider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}
