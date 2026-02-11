---
title: Use Server Actions for Data Mutations
impact: HIGH
impactDescription: eliminates API route boilerplate, reduces client JS for mutations
tags: migrate, server-actions, mutations, api-routes
---

## Use Server Actions for Data Mutations

Client-side fetch calls to API route handlers for data mutations require maintaining both the client fetch logic and the API route file. Server Actions colocate the mutation with the form, eliminate the API route layer, and work without JavaScript for progressive enhancement.

**Incorrect (client-side fetch to a dedicated API route handler):**

```tsx
// app/api/newsletter/route.ts — boilerplate API route
export async function POST(request: Request) {
  const { email } = await request.json();
  if (!email || !email.includes("@")) {
    return Response.json({ error: "Invalid email" }, { status: 400 });
  }
  await db.newsletter.create({ data: { email } });
  return Response.json({ success: true });
}

// components/NewsletterSignup.tsx
"use client";

import { useState } from "react";

export function NewsletterSignup() {
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState<"idle" | "loading" | "success" | "error">("idle");
  const [errorMessage, setErrorMessage] = useState("");

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setStatus("loading");
    try {
      const response = await fetch("/api/newsletter", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email }),
      });
      if (!response.ok) {
        const body = await response.json();
        throw new Error(body.error);
      }
      setStatus("success");
    } catch (err) {
      setStatus("error");
      setErrorMessage(err instanceof Error ? err.message : "Signup failed");
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <input value={email} onChange={(e) => setEmail(e.target.value)} />
      <button disabled={status === "loading"}>Subscribe</button>
      {status === "error" && <p>{errorMessage}</p>}
    </form>
  );
}
```

**Correct (Server Action colocated with the form, no API route needed):**

```tsx
// app/actions/newsletter.ts
"use server";

export async function subscribeToNewsletter(formData: FormData) {
  const email = formData.get("email") as string;
  if (!email || !email.includes("@")) {
    return { error: "Invalid email address" };
  }
  await db.newsletter.create({ data: { email } });
  return { success: true };
}

// components/NewsletterSignup.tsx
"use client";

import { useActionState } from "react";
import { subscribeToNewsletter } from "@/app/actions/newsletter";

export function NewsletterSignup() {
  const [state, formAction, isPending] = useActionState(subscribeToNewsletter, null);

  return (
    // Works without JS — progressive enhancement built in
    <form action={formAction}>
      <input name="email" type="email" required />
      <button disabled={isPending}>
        {isPending ? "Subscribing..." : "Subscribe"}
      </button>
      {state?.error && <p>{state.error}</p>}
    </form>
  );
}
```

Reference: [Server Actions and Mutations](https://react.dev/reference/rsc/server-actions)
