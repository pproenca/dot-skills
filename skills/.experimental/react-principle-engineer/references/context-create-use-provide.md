---
title: Follow the create-use-provide pattern
impact: MEDIUM
impactDescription: Context workflow: createContext defines it, useContext reads it, Provider supplies it
tags: [context, pattern, createContext, useContext, provider]
---

# Follow the Create-Use-Provide Pattern

Context has three steps: create the context, use it in consumers, provide it from a parent. Understanding this flow is key to using Context correctly.

## Step 1: Create the Context

```tsx
// LevelContext.ts
import { createContext } from 'react';

// Create with a default value (used if no provider found)
export const LevelContext = createContext<number>(1);

// Default value is:
// - Used when no provider exists in tree
// - Should be a sensible fallback
// - Not a placeholder - it should work
```

## Step 2: Use the Context (Consume)

```tsx
// Heading.tsx
import { useContext } from 'react';
import { LevelContext } from './LevelContext';

function Heading({ children }: { children: React.ReactNode }) {
  // Read the current value from nearest provider
  const level = useContext(LevelContext);

  switch (level) {
    case 1: return <h1>{children}</h1>;
    case 2: return <h2>{children}</h2>;
    case 3: return <h3>{children}</h3>;
    case 4: return <h4>{children}</h4>;
    default: return <p>{children}</p>;
  }
}
```

## Step 3: Provide the Context

```tsx
// Section.tsx
import { LevelContext } from './LevelContext';

function Section({
  level,
  children,
}: {
  level: number;
  children: React.ReactNode;
}) {
  return (
    <section>
      {/* All children can read this level value */}
      <LevelContext value={level}>
        {children}
      </LevelContext>
    </section>
  );
}

// Usage
function Page() {
  return (
    <Section level={1}>
      <Heading>Title</Heading>  {/* Renders as h1 */}
      <Section level={2}>
        <Heading>Subtitle</Heading>  {/* Renders as h2 */}
      </Section>
    </Section>
  );
}
```

## Complete Example with All Three Steps

```tsx
// 1. CREATE: ThemeContext.ts
import { createContext, useContext, useState } from 'react';

type Theme = 'light' | 'dark';

const ThemeContext = createContext<{
  theme: Theme;
  toggle: () => void;
} | null>(null);

// Custom hook for consuming (safer than raw useContext)
export function useTheme() {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
}

// Provider component (combines provide with state)
export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<Theme>('light');

  const toggle = () => setTheme(t => t === 'light' ? 'dark' : 'light');

  return (
    <ThemeContext value={{ theme, toggle }}>
      {children}
    </ThemeContext>
  );
}
```

```tsx
// 2. PROVIDE: App.tsx
import { ThemeProvider } from './ThemeContext';

function App() {
  return (
    <ThemeProvider>
      <Page />
    </ThemeProvider>
  );
}
```

```tsx
// 3. USE: Button.tsx
import { useTheme } from './ThemeContext';

function Button({ children }: { children: React.ReactNode }) {
  const { theme, toggle } = useTheme();

  return (
    <button
      className={theme === 'dark' ? 'btn-dark' : 'btn-light'}
      onClick={toggle}
    >
      {children}
    </button>
  );
}
```

## Nested Providers Override

```tsx
// Inner provider overrides outer
function App() {
  return (
    <ThemeContext value="light">
      <Header />  {/* Uses "light" */}

      <ThemeContext value="dark">
        <Sidebar />  {/* Uses "dark" - inner overrides */}
      </ThemeContext>

      <Footer />  {/* Uses "light" */}
    </ThemeContext>
  );
}
```

## Reading and Providing in Same Component

```tsx
// Component that reads context and provides new value to children
function Section({ children }: { children: React.ReactNode }) {
  const level = useContext(LevelContext);  // Read current

  return (
    <LevelContext value={level + 1}>  {/* Provide incremented */}
      {children}
    </LevelContext>
  );
}

// Usage: automatic nesting
function Article() {
  return (
    <Section>  {/* level 1 */}
      <Heading>Title</Heading>
      <Section>  {/* level 2 */}
        <Heading>Subtitle</Heading>
        <Section>  {/* level 3 */}
          <Heading>Sub-subtitle</Heading>
        </Section>
      </Section>
    </Section>
  );
}
```

## Key Principle

Context = Create + Use + Provide. Create once, provide at the right level in the tree, use wherever needed below. The nearest provider wins.
