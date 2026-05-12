---
title: Enable requireEmailVerification and Implement sendVerificationEmail Together
impact: HIGH
impactDescription: prevents account-takeover via signup with someone else's email
tags: auth, email, verification, security
---

## Enable requireEmailVerification and Implement sendVerificationEmail Together

Without email verification, anyone can sign up with `victim@example.com`, set a password, and own the account until the real owner notices. `requireEmailVerification` blocks sign-in until the email is confirmed — but if you set the flag without implementing `sendVerificationEmail`, Better Auth has no way to deliver the verification link and users sit blocked forever. The two settings are a pair: enabling one without the other is a bug. Setting `sendOnSignIn: true` ensures the verification email also sends on every blocked sign-in attempt, not just once at signup.

**Incorrect (verification required but no send function):**

```typescript
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  emailAndPassword: {
    enabled: true,
    requireEmailVerification: true, // blocks login
  },
  // emailVerification missing → no email ever sent → users locked out
});
```

**Incorrect (send function but verification not required):**

```typescript
export const auth = betterAuth({
  emailAndPassword: { enabled: true }, // unverified users can still sign in
  emailVerification: {
    sendVerificationEmail: async ({ user, url }) => { /* ... */ },
  },
});
```

**Correct (paired configuration):**

```typescript
import { betterAuth } from "better-auth";
import { sendEmail } from "@/lib/email";

export const auth = betterAuth({
  emailAndPassword: {
    enabled: true,
    requireEmailVerification: true,
    autoSignIn: false, // don't grant a session until verified
    sendResetPassword: async ({ user, url }) => {
      await sendEmail({ to: user.email, subject: "Reset your password", text: `Reset: ${url}` });
    },
  },
  emailVerification: {
    sendOnSignIn: true, // resend on every blocked sign-in
    sendVerificationEmail: async ({ user, url }) => {
      await sendEmail({
        to: user.email,
        subject: "Verify your email",
        text: `Verify your account: ${url}`,
      });
    },
  },
});
```

**Common use cases:**
- Use a transactional provider (Resend, Postmark, SendGrid) — not your application SMTP — so verification mails don't get throttled with marketing email.
- Render the verification link as a button in HTML, but always include the raw URL as text fallback (some clients strip buttons).

Reference: [Better Auth — Email Verification](https://www.better-auth.com/docs/concepts/email#email-verification)
