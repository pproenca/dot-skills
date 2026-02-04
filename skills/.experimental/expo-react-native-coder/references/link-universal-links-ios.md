---
title: Set Up iOS Universal Links
impact: HIGH
impactDescription: enables seamless web-to-app transitions
tags: link, universal-links, ios, aasa
---

## Set Up iOS Universal Links

Universal Links open your app when users tap links to your website. Requires hosting an `apple-app-site-association` file.

**Incorrect (missing or misconfigured AASA):**

```json
{
  "expo": {
    "ios": {
      "bundleIdentifier": "com.company.myapp",
      "associatedDomains": ["https://myapp.com"]
    }
  }
}
```

The `https://` prefix breaks Universal Links - iOS silently ignores this configuration.

**Correct (proper AASA and app.json setup):**

**Step 1: Create AASA file (host at `/.well-known/apple-app-site-association`)**

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appIDs": ["TEAM_ID.com.company.myapp"],
        "components": [
          { "/": "/user/*" },
          { "/": "/post/*" },
          { "/": "/invite/*" }
        ]
      }
    ]
  }
}
```

**Step 2: Configure app.json (no https:// prefix)**

```json
{
  "expo": {
    "ios": {
      "bundleIdentifier": "com.company.myapp",
      "associatedDomains": ["applinks:myapp.com", "applinks:www.myapp.com"]
    }
  }
}
```

**Requirements:**
- HTTPS hosting (no HTTP)
- Content-Type: `application/json`
- No redirects
- Accessible without authentication

**Testing:**

```bash
curl -I https://myapp.com/.well-known/apple-app-site-association
curl "https://app-site-association.cdn-apple.com/a/v1/myapp.com"
```

Reference: [iOS Universal Links - Expo Documentation](https://docs.expo.dev/linking/ios-universal-links/)
