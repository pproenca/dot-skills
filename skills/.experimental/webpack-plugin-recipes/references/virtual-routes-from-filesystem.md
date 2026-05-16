---
title: Generate a Route Map From the Filesystem (Pages Pattern)
impact: HIGH
impactDescription: 100% route coverage without manual registration
tags: virtual, routing, filesystem, codegen, next-pattern
---

## Generate a Route Map From the Filesystem (Pages Pattern)

## Problem

You have a `pages/` directory of route components — `pages/index.tsx`, `pages/users/[id].tsx`, `pages/blog/[...slug].tsx` — and you want `react-router` (or your custom router) to know about all of them automatically. Hand-maintaining a `routes.ts` array means forgetting to register every new page (you ship the page, it works in dev because someone manually edited routes, breaks for the next person who adds a page). You want Next.js's filesystem-based routing without using Next.js.

This is the pattern behind Next.js's `pages/` and `app/` routing, Nuxt's `pages/`, Remix's flat routes, Astro's `pages/`, and SvelteKit's `routes/` — all generate route registries at build time from directory contents.

## Pattern

Scan the routes directory in `beforeRun` to discover route files, emit a virtual module (`virtual:routes`) whose source is a generated import map, and add the directory itself as a `contextDependency` so watch-mode rebuilds when new pages are added.

**Incorrect (without a plugin — hand-maintained routes file):**

```js
// src/routes.ts — hand-maintained
import Index from './pages/index';
import UsersList from './pages/users';
import UserDetail from './pages/users/[id]';
// ...

export const routes = [
  { path: '/', component: Index },
  { path: '/users', component: UsersList },
  { path: '/users/:id', component: UserDetail },
  // Adding pages/blog/[...slug].tsx? Don't forget to:
  //   1. Import it here  2. Add to this array  3. Map params correctly
  // (You will forget.)
];
```

**Correct (with this plugin — auto-generated from `pages/` directory):**

```js
const fs = require('node:fs');
const path = require('node:path');
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    pagesDir: { type: 'string', minLength: 1 },
    extensions: { type: 'array', items: { type: 'string' } },
    virtualModule: { type: 'string', description: 'Module path for `import` (default "virtual:routes")' },
  },
  required: ['pagesDir'],
  additionalProperties: false,
};

const DEFAULTS = {
  extensions: ['.tsx', '.ts', '.jsx', '.js'],
  virtualModule: 'virtual:routes',
};

class FilesystemRoutesPlugin {
  constructor(options) {
    validate(schema, options, { name: 'FilesystemRoutesPlugin', baseDataPath: 'options' });
    this.options = { ...DEFAULTS, ...options };
    this.pagesDir = path.resolve(options.pagesDir);
  }

  apply(compiler) {
    const PLUGIN = 'FilesystemRoutesPlugin';

    // Step 1: virtual module resolution (see virtual-module-from-memory recipe)
    compiler.hooks.normalModuleFactory.tap(PLUGIN, (nmf) => {
      nmf.hooks.beforeResolve.tap(PLUGIN, (data) => {
        if (data.request !== this.options.virtualModule) return;
        data.request = path.join(compiler.context, '__routes__', 'index.js');
      });
    });

    // Step 2: serve content + register dependency on the pages directory
    compiler.hooks.compilation.tap(PLUGIN, (compilation) => {
      const NormalModule = compiler.webpack.NormalModule;

      NormalModule.getCompilationHooks(compilation).readResource
        .for(undefined)
        .tap(PLUGIN, (loaderContext) => {
          if (!loaderContext.resourcePath.endsWith(path.join('__routes__', 'index.js'))) return;
          const routes = this.scan();
          const source = this.generate(routes);

          // CRITICAL: watch the pages directory so new files trigger rebuild
          loaderContext._compilation.contextDependencies.add(this.pagesDir);

          return Buffer.from(source, 'utf8');
        });
    });
  }

  scan() {
    const routes = [];
    const walk = (dir, prefix = '') => {
      for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
        const abs = path.join(dir, entry.name);
        if (entry.isDirectory()) {
          walk(abs, `${prefix}/${this.pathSegment(entry.name)}`);
          continue;
        }
        const ext = this.options.extensions.find((e) => entry.name.endsWith(e));
        if (!ext) continue;
        const base = entry.name.slice(0, -ext.length);
        const routePath = base === 'index'
          ? prefix || '/'
          : `${prefix}/${this.pathSegment(base)}`;
        routes.push({ path: routePath, file: abs });
      }
    };
    walk(this.pagesDir);
    // Static routes first (so /users/new matches before /users/:id)
    routes.sort((a, b) => a.path.split(':').length - b.path.split(':').length);
    return routes;
  }

  pathSegment(name) {
    // [...slug] → *  (catch-all)
    if (name.startsWith('[...') && name.endsWith(']')) return `*`;
    // [id] → :id    (dynamic)
    if (name.startsWith('[') && name.endsWith(']')) return `:${name.slice(1, -1)}`;
    return name;
  }

  generate(routes) {
    const imports = routes.map((r, i) =>
      `import Route${i} from ${JSON.stringify(r.file)};`).join('\n');
    const entries = routes.map((r, i) =>
      `  { path: ${JSON.stringify(r.path)}, component: Route${i} },`).join('\n');
    return [
      '// Auto-generated by FilesystemRoutesPlugin — do not edit',
      imports,
      'export const routes = [',
      entries,
      '];',
      '',
    ].join('\n');
  }
}

module.exports = FilesystemRoutesPlugin;
```

## Usage

```js
new FilesystemRoutesPlugin({ pagesDir: path.resolve(__dirname, 'src/pages') })

// src/app.tsx
import { routes } from 'virtual:routes';
import { BrowserRouter, Route, Routes } from 'react-router-dom';

export function App() {
  return (
    <BrowserRouter>
      <Routes>
        {routes.map(({ path, component: Component }) => (
          <Route key={path} path={path} element={<Component />} />
        ))}
      </Routes>
    </BrowserRouter>
  );
}
```

## How it works

- **`contextDependencies.add(this.pagesDir)`** — critical for watch mode: new pages added to the directory trigger rebuilds. Without it, dev-server doesn't notice until full restart. See [`webpack-plugin-authoring/cache-context-dependencies-for-directories`].
- **`compilation.fileDependencies` not needed** for the page files themselves — they're imported normally from the generated module, so webpack tracks them automatically via the module graph
- **Static-first sorting** — `/users/new` must match before `/users/:id`, otherwise React Router matches the dynamic route first
- **`[...slug]` → `*`** and **`[id]` → `:id`** — Next.js's filesystem convention, mapped to react-router's path syntax

## Variations

- **Per-route metadata** (extract `export const meta = {...}` from each page): parse with `@babel/parser`, attach to route entry
- **Async routes** (lazy-loaded with `React.lazy(() => import(...))`): change `imports` to lazy form
- **Nested layouts**: scan for `_layout.tsx` files, build a layout chain per route
- **Route groups** (Next.js `(group)/` directories that don't appear in URL): strip parens from segment
- **API routes split** (only emit non-API pages): filter by directory prefix

## When NOT to use this pattern

- You're using a framework that does this (Next.js, Nuxt, Remix, SvelteKit, Astro, RedwoodJS)
- Your routing isn't path-based (SPA with tab-style navigation, modal-driven)
- You have <10 routes — manual maintenance is cheaper than the abstraction

Reference: [Next.js filesystem routing](https://nextjs.org/docs/pages/building-your-application/routing) · [Vite Plugin Pages](https://github.com/hannoeru/vite-plugin-pages) · [contextDependencies](https://webpack.js.org/api/compilation-object/#contextdependencies)
