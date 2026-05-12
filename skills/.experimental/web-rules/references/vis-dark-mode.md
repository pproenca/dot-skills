---
title: Use CSS Custom Properties + `dark:` Variant; Never Hardcode `text-black` / `bg-white`
impact: HIGH
impactDescription: ~80% of users have light/dark preference set at the OS level; hardcoded colors break readability for whichever half doesn't match; theme-token systems make multi-theme expansion ~free
tags: vis, dark-mode, semantic-colors, css-variables, tailwind-theme, prefers-color-scheme
---

## Use CSS Custom Properties + `dark:` Variant; Never Hardcode `text-black` / `bg-white`

Define semantic color tokens (`--background`, `--foreground`, `--muted-foreground`, `--border`, `--ring`, `--primary`, `--destructive`) in `app/globals.css` under `@theme` and switch them in a `.dark` selector. Reference tokens via Tailwind's color utilities (`bg-background`, `text-foreground`). Never write `text-black`, `bg-white`, `text-gray-500`, or any literal grayscale class — those don't theme.

**Incorrect (hardcoded grayscale; no dark mode support; arbitrary opacities):**

```tsx
function Card() {
  return (
    <div className="bg-white border-gray-200 text-black">
      <h2 className="text-gray-900">Title</h2>
      <p className="text-gray-500">Description</p>
      {/* Glaring white in dark mode; near-invisible text-gray-500 contrast */}
    </div>
  )
}
```

**Correct (semantic tokens + `dark:` switched once, components use the tokens):**

```css
/* app/globals.css */
@import "tailwindcss";

@theme {
  --color-background: oklch(1 0 0);
  --color-foreground: oklch(0.15 0 0);
  --color-muted: oklch(0.97 0 0);
  --color-muted-foreground: oklch(0.45 0 0);
  --color-border: oklch(0.92 0 0);
  --color-ring: oklch(0.55 0.18 250);
  --color-primary: oklch(0.55 0.18 250);
  --color-primary-foreground: oklch(0.98 0 0);
  --color-destructive: oklch(0.55 0.22 25);
  --color-destructive-foreground: oklch(0.98 0 0);
}

.dark {
  --color-background: oklch(0.13 0 0);
  --color-foreground: oklch(0.96 0 0);
  --color-muted: oklch(0.18 0 0);
  --color-muted-foreground: oklch(0.65 0 0);
  --color-border: oklch(0.25 0 0);
  --color-ring: oklch(0.65 0.18 250);
  --color-primary: oklch(0.65 0.18 250);
  --color-primary-foreground: oklch(0.13 0 0);
  --color-destructive: oklch(0.65 0.22 25);
}
```

```tsx
// Components reference tokens — never raw grayscale
function Card({ title, description }: { title: string; description: string }) {
  return (
    <article className="rounded-lg border border-border bg-background p-6 text-foreground">
      <h2 className="text-lg font-semibold">{title}</h2>
      <p className="mt-1 text-sm text-muted-foreground">{description}</p>
    </article>
  )
}

// Theme toggle — respects system preference by default, user override via class
'use client'
import { useTheme } from 'next-themes'

export function ThemeToggle() {
  const { theme, setTheme } = useTheme()
  return (
    <Button
      variant="ghost"
      size="icon"
      aria-label={`Switch to ${theme === 'dark' ? 'light' : 'dark'} mode`}
      onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
    >
      <Sun className="size-4 dark:hidden" aria-hidden="true" />
      <Moon className="size-4 hidden dark:block" aria-hidden="true" />
    </Button>
  )
}

// Root layout — class strategy + system default
import { ThemeProvider } from 'next-themes'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>
        <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
          {children}
        </ThemeProvider>
      </body>
    </html>
  )
}
```

**Rule:**
- Define semantic tokens once in `@theme`; switch them in a `.dark` selector
- Components reference tokens (`bg-background`, `text-foreground`, `border-border`) — never raw grayscale (`bg-white`, `text-gray-500`)
- Default to system theme; allow override via `next-themes` `attribute="class"`
- Verify both themes — color contrast (4.5:1) must pass in both
- Use `suppressHydrationWarning` on `<html>` to avoid the brief flash from theme-class injection

Reference: [next-themes docs](https://github.com/pacocoursey/next-themes) · [Tailwind v4 theming](https://tailwindcss.com/docs/theme)
