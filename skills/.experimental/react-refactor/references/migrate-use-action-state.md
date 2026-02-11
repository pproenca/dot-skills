---
title: Migrate Form State to useActionState
impact: HIGH
impactDescription: eliminates 60% of form state management code
tags: migrate, useActionState, forms, state-management
---

## Migrate Form State to useActionState

Manual form state management with separate useState calls for loading, error, and success creates boilerplate that every form must duplicate. `useActionState` replaces this pattern with a single hook that tracks pending state, manages the action lifecycle, and returns the server response directly.

**Incorrect (manual state management with multiple useState for every form):**

```tsx
"use client";

import { useState } from "react";

export function ContactForm() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setIsSubmitting(true);
    setError(null);
    setSuccess(false);
    try {
      const response = await fetch("/api/contact", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name, email, message }),
      });
      if (!response.ok) throw new Error("Failed to send");
      setSuccess(true);
      setName("");
      setEmail("");
      setMessage("");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Something went wrong");
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <input value={name} onChange={(e) => setName(e.target.value)} placeholder="Name" />
      <input value={email} onChange={(e) => setEmail(e.target.value)} placeholder="Email" />
      <textarea value={message} onChange={(e) => setMessage(e.target.value)} />
      <button disabled={isSubmitting}>
        {isSubmitting ? "Sending..." : "Send Message"}
      </button>
      {error && <p className="error">{error}</p>}
      {success && <p className="success">Message sent!</p>}
    </form>
  );
}
```

**Correct (useActionState manages the entire form lifecycle):**

```tsx
// app/actions/contact.ts
"use server";

interface ContactFormState {
  error?: string;
  success?: boolean;
}

export async function submitContact(
  _previousState: ContactFormState | null,
  formData: FormData
): Promise<ContactFormState> {
  const name = formData.get("name") as string;
  const email = formData.get("email") as string;
  const message = formData.get("message") as string;

  if (!name || !email || !message) {
    return { error: "All fields are required" };
  }
  await db.contactMessages.create({ data: { name, email, message } });
  return { success: true };
}

// components/ContactForm.tsx
"use client";

import { useActionState } from "react";
import { submitContact } from "@/app/actions/contact";

export function ContactForm() {
  // One hook replaces 6 useState calls and the entire submit handler
  const [state, formAction, isPending] = useActionState(submitContact, null);

  return (
    <form action={formAction}>
      <input name="name" placeholder="Name" required />
      <input name="email" type="email" placeholder="Email" required />
      <textarea name="message" required />
      <button disabled={isPending}>
        {isPending ? "Sending..." : "Send Message"}
      </button>
      {state?.error && <p className="error">{state.error}</p>}
      {state?.success && <p className="success">Message sent!</p>}
    </form>
  );
}
```

Reference: [useActionState](https://react.dev/reference/react/useActionState)
