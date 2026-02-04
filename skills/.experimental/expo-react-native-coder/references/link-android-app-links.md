---
title: Set Up Android App Links
impact: HIGH
impactDescription: enables verified web-to-app transitions
tags: link, app-links, android, assetlinks
---

## Set Up Android App Links

Android App Links allow your app to open when users tap links to your website. Requires hosting an `assetlinks.json` file.

**Incorrect (missing autoVerify or wrong fingerprint):**

```json
{
  "expo": {
    "android": {
      "package": "com.company.myapp",
      "intentFilters": [
        {
          "action": "VIEW",
          "data": [{ "scheme": "https", "host": "myapp.com" }],
          "category": ["BROWSABLE", "DEFAULT"]
        }
      ]
    }
  }
}
```

Without `autoVerify: true`, Android shows a disambiguation dialog instead of opening the app directly.

**Correct (complete App Links setup):**

**Step 1: Get SHA-256 fingerprint**

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
eas credentials --platform android
```

**Step 2: Create assetlinks.json (host at `/.well-known/assetlinks.json`)**

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.company.myapp",
      "sha256_cert_fingerprints": ["AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99"]
    }
  }
]
```

**Step 3: Configure app.json with autoVerify**

```json
{
  "expo": {
    "android": {
      "package": "com.company.myapp",
      "intentFilters": [
        {
          "action": "VIEW",
          "autoVerify": true,
          "data": [
            { "scheme": "https", "host": "myapp.com", "pathPrefix": "/user" },
            { "scheme": "https", "host": "myapp.com", "pathPrefix": "/post" }
          ],
          "category": ["BROWSABLE", "DEFAULT"]
        }
      ]
    }
  }
}
```

**Testing:**

```bash
curl https://myapp.com/.well-known/assetlinks.json
adb shell am start -W -a android.intent.action.VIEW -d "https://myapp.com/user/123" com.company.myapp
```

Reference: [Android App Links - Expo Documentation](https://docs.expo.dev/linking/android-app-links/)
