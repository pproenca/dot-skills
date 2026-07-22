---
title: Pin the Yjs 13 dependency track explicitly
tags: host, versioning, dependencies, prerelease
---

## Pin the Yjs 13 dependency track explicitly

Yjs is mid-migration to v14 under the `@y/*` scope, and several ecosystem packages have already moved their `latest` tag or `main` branch onto that prerelease track. Installing the newest version of a server or binding therefore pulls a Yjs 14 release candidate into an application running Yjs 13, and the resulting failures look like protocol bugs rather than a version mismatch. `@y/websocket-server@0.1.5` depends on `yjs: "^14.0.0-7"`; version `0.1.1` is the last release carrying a Yjs 13 peer dependency.

**Incorrect (installing latest silently mixes two major versions):**

```bash
npm install yjs@13.6.31 @y/websocket-server   # resolves 0.1.5 -> yjs ^14.0.0-7
```

**Correct (both sides pinned to the v13 line):**

```json
{
  "dependencies": {
    "yjs": "13.6.31",
    "y-websocket": "3.0.0",
    "y-protocols": "1.0.7",
    "y-indexeddb": "9.0.12",
    "@y/websocket-server": "0.1.1"
  }
}
```

The same split applies when reading source or documentation: `y-prosemirror`, `y-codemirror.next`, and `y-websocket` all keep the stable Yjs 13 line on npm and tags while `main` targets v14. The y-websocket README states it directly — "Most users should continue to use the stable `y-websocket` package with Yjs v13 for now" — so consult tagged sources such as `y-protocols` at `v1.0.7` rather than `master`, which now imports `@y/y`.

Reference: [y-websocket README](https://github.com/yjs/y-websocket/blob/master/README.md)
