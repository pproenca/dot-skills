---
title: Implement OAuth with AuthSession
impact: HIGH
impactDescription: enables third-party login (Google, Apple, etc.)
tags: auth, oauth, authsession, social-login
---

## Implement OAuth with AuthSession

Use `expo-auth-session` for OAuth flows with providers like Google, Apple, or custom OAuth servers.

**Incorrect (manual WebView for OAuth):**

```typescript
// Opening OAuth in WebView - won't redirect back properly
<WebView source={{ uri: oauthUrl }} />
```

**Correct (AuthSession for OAuth):**

```typescript
import * as AuthSession from 'expo-auth-session';
import * as WebBrowser from 'expo-web-browser';
import { Button } from 'react-native';

// Required for web browser redirect
WebBrowser.maybeCompleteAuthSession();

// OAuth configuration
const discovery = {
  authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
  tokenEndpoint: 'https://oauth2.googleapis.com/token',
  revocationEndpoint: 'https://oauth2.googleapis.com/revoke',
};

export default function SignInScreen() {
  const [request, response, promptAsync] = AuthSession.useAuthRequest(
    {
      clientId: 'YOUR_GOOGLE_CLIENT_ID',
      scopes: ['openid', 'profile', 'email'],
      redirectUri: AuthSession.makeRedirectUri({
        scheme: 'myapp',
        path: 'auth',
      }),
    },
    discovery
  );

  useEffect(() => {
    if (response?.type === 'success') {
      const { code } = response.params;
      // Exchange code for token on your server
      exchangeCodeForToken(code);
    }
  }, [response]);

  const exchangeCodeForToken = async (code: string) => {
    const response = await fetch('/api/auth/exchange', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ code }),
    });
    const { token } = await response.json();
    // Store token and update auth state
  };

  return (
    <Button
      title="Sign in with Google"
      disabled={!request}
      onPress={() => promptAsync()}
    />
  );
}
```

**Note:** For production, use provider-specific libraries (e.g., `@react-native-google-signin/google-signin`) for better UX.

Reference: [AuthSession - Expo Documentation](https://docs.expo.dev/versions/latest/sdk/auth-session/)
