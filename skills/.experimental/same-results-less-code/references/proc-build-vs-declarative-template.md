---
title: Use the Declarative Form When the Framework Provides One
impact: MEDIUM-HIGH
impactDescription: eliminates imperative DOM/string builders in favour of the framework's template form
tags: proc, declarative, jsx, templates
---

## Use the Declarative Form When the Framework Provides One

When a framework offers a declarative form for what you want — JSX in React, a template in Vue/Svelte, a query builder in an ORM, a configuration block in IaC — using `document.createElement`, string concatenation, or a procedural builder is a step backwards. The declarative form was the framework's whole contribution. Procedural rebuilds inside a declarative system give up the framework's diffing, validation, and tooling — and trade them for lines you maintain by hand.

**Incorrect (building DOM imperatively inside a React component):**

```tsx
function UserCard({ user }: { user: User }) {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const root = ref.current!;
    root.innerHTML = '';

    const card = document.createElement('div');
    card.className = 'user-card';

    const name = document.createElement('h3');
    name.textContent = user.name;
    card.appendChild(name);

    const email = document.createElement('a');
    email.href = `mailto:${user.email}`;
    email.textContent = user.email;
    card.appendChild(email);

    root.appendChild(card);
  }, [user]);

  return <div ref={ref} />;
  // Built imperative DOM inside React. React's reconciler is gone.
  // CSP, accessibility, server rendering, hydration — all broken.
  // 15 lines for what is six JSX lines.
}
```

**Correct (let React do its job):**

```tsx
function UserCard({ user }: { user: User }) {
  return (
    <div className="user-card">
      <h3>{user.name}</h3>
      <a href={`mailto:${user.email}`}>{user.email}</a>
    </div>
  );
}
// The framework handles diffing, SSR, and accessibility. Your code is the structure.
```

**Same family across stacks:**

- **SQL via concatenated strings.** Use a query builder or parameterised template literal — `db.query`'s `sql\`SELECT * FROM users WHERE id = ${id}\`` form. Concatenation is also a SQL injection risk.
- **HTML emails via string concat.** Use a template (MJML, JSX-email, Handlebars) — concatenation breaks the moment you need encoding or i18n.
- **Terraform via `local-exec` shell scripts** when a resource exists for the thing you want. The resource has lifecycle, plan, and rollback. The shell has none.
- **Webpack/Vite config edited by JS code at build time** when a config object would do.
- **GraphQL queries built by string concat from arguments.** Use a query document with variables; clients cache by document.

**Symptoms:**

- A `useEffect`/`onMounted` that mutates the DOM the framework just rendered.
- String-builder code that ends in `.join('')` and is passed to `innerHTML`/`dangerouslySetInnerHTML`.
- An ORM raw query when the ORM has a method for what you're doing.
- A `forEach` inside a render function that pushes JSX nodes instead of `.map`.

**When NOT to use this pattern:**

- The framework genuinely can't express what you need — e.g. integrating a non-React widget that wants raw DOM, or a query whose shape the ORM lacks. Then drop to the imperative form, but keep it contained.
- Performance-critical low-level rendering (canvas, WebGL) — declarative wrappers exist (react-three-fiber), but raw imperative may be warranted.

Reference: [React docs — Manipulating the DOM with Refs](https://react.dev/learn/manipulating-the-dom-with-refs) (note the "escape hatch" framing)
