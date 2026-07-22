---
title: Match the TypeScript version tRPC and the editor both resolve
tags: mig, typescript, peer-dependencies, inference
---

## Match the TypeScript version tRPC and the editor both resolve

Scaffolding a v11 project from v10-era memory produces v10-era peers: `typescript ^5.4`, `@tanstack/react-query ^5.0.0`, a React range that still admits 17. v11.18.0 declares `typescript >=5.7.2` across every package, `@tanstack/react-query ^5.80.3`, `react >=18.2.0`, and Node 18+. The version floor failing at install is the good outcome — it is loud, and it names itself. The dangerous case is the one where the project satisfies all of it and the **editor** does not: VS Code defaults to its own bundled TypeScript, and if that build is older than the one tRPC compiled against, inference collapses. Procedures type as `any`, autocomplete on `trpc.invoice.byId` returns nothing, and `tsc` on the command line stays green — no error is raised anywhere, which is why this is the single most-reported tRPC symptom.

Pin the editor to the workspace compiler, then commit the setting so it is not one developer's local fix.

```json
// .vscode/settings.json
{
  "typescript.tsdk": "node_modules/typescript/lib",
  "typescript.enablePromptUseWorkspaceTsdk": true
}
```

```json
// package.json — v11.18.0 peer floors
{
  "dependencies": {
    "@trpc/server": "11.18.0",
    "@trpc/client": "11.18.0",
    "@trpc/tanstack-react-query": "11.18.0",
    "@tanstack/react-query": "^5.80.3",
    "react": "^18.2.0"
  },
  "devDependencies": {
    "typescript": "^5.7.2"
  }
}
```

The tell that separates this from a genuine typing bug: hovering a procedure gives `any` in the editor while `npx tsc --noEmit` reports no errors. That gap is always a resolver mismatch, not a router mistake — check the TypeScript version in the editor's status bar before touching the router.

Reference: [tRPC — FAQ: I'm getting `any` everywhere](https://trpc.io/faq)
