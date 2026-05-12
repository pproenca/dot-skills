---
title: Implement sendMagicLink Before Enabling the magicLink Plugin
impact: HIGH
impactDescription: prevents passwordless sign-in from silently failing in production
tags: auth, magic-link, plugins, email
---

## Implement sendMagicLink Before Enabling the magicLink Plugin

The `magicLink` plugin issues a passwordless one-time URL — Better Auth generates the URL and token, but you own the delivery via the `sendMagicLink` callback. The plugin will accept being initialized with an empty callback (it doesn't throw at startup), so it's easy to ship a deployment where `authClient.signIn.magicLink({ email })` returns success and the user never receives an email. Always wire the callback to a real transactional sender, log delivery failures, and consider rate-limiting sends per email.

**Incorrect (plugin enabled with empty/no-op callback):**

```typescript
import { betterAuth } from "better-auth";
import { magicLink } from "better-auth/plugins";

export const auth = betterAuth({
  plugins: [
    magicLink({
      sendMagicLink: async () => { /* TODO: implement */ }, // ← never sends
    }),
  ],
});
```

**Correct (real send + error propagation):**

```typescript
import { betterAuth } from "better-auth";
import { magicLink } from "better-auth/plugins";
import { sendEmail } from "@/lib/email";

export const auth = betterAuth({
  plugins: [
    magicLink({
      sendMagicLink: async ({ email, url, token }) => {
        try {
          await sendEmail({
            to: email,
            subject: "Your sign-in link",
            html: `<a href="${url}">Sign in to Example</a>`,
            text: `Sign in: ${url}\nThis link expires in 5 minutes.`,
          });
        } catch (err) {
          // Better Auth will surface this as a 500 to the client — fail loud, don't swallow
          console.error("[magic-link] delivery failed", { email, err });
          throw err;
        }
      },
      expiresIn: 60 * 5, // 5 minutes — short window for passwordless tokens
    }),
  ],
});
```

```typescript
// Client side — pair with the matching client plugin
import { createAuthClient } from "better-auth/react";
import { magicLinkClient } from "better-auth/client/plugins";

export const authClient = createAuthClient({
  plugins: [magicLinkClient()],
});

await authClient.signIn.magicLink({ email: "user@example.com", callbackURL: "/dashboard" });
```

**Common use cases:**
- Add per-email rate-limit on top of Better Auth's global limit — "1 link per email per minute" prevents inbox spamming when users click "send again" repeatedly.
- For B2B SaaS, allow-list send-to domains so test accounts can't burn quota with random external mail.

Reference: [Better Auth — magicLink Plugin](https://www.better-auth.com/docs/plugins/magic-link)
