---
title: Generate a LICENSES.txt by Walking the Module Graph
impact: HIGH
impactDescription: provides legal-required OSS attribution without manual upkeep
tags: meta, license, compliance, oss, attribution
---

## Generate a LICENSES.txt by Walking the Module Graph

## Problem

Your legal team requires every distributed build to include attribution for OSS dependencies — MIT/BSD/Apache packages need their license text shipped with the bundle. Maintaining `LICENSES.txt` by hand drifts the moment someone adds `lodash` (BSD-3) or removes `moment` (MIT). `webpack-license-plugin` and `license-webpack-plugin` exist but produce file shapes legal usually pushes back on, and they often miss transitively-bundled packages because they walk `node_modules/*/package.json` instead of the actual module graph.

The correct source of truth is webpack's own module graph: every Module has a `resource` path, every resource lives inside a package, every package has a `license` and a `LICENSE` file. Walk THOSE, deduplicate by package name+version, emit the notice. The result lists exactly what's in the bundle — nothing more (no devDependencies), nothing less (no missed sub-deps).

## Pattern

In `compilation.hooks.afterSeal`, walk every Module in the compilation, map each `resource` path to its owning `package.json` (climb up directories until found), collect `{ name, version, license, licenseText, repository }`, deduplicate, and emit a formatted `LICENSES.txt` in `processAssets`.

**Incorrect (without a plugin — manual maintenance of LICENSES.txt):**

```bash
# Engineering manager pings the team:
# "We added 4 new deps last sprint — please update LICENSES.txt"

# Someone runs:
npx license-checker --production --summary > LICENSES.txt
# Reads package.json dependencies field — MISSES transitive bundled deps,
# INCLUDES devDependencies that aren't actually shipped,
# doesn't include LICENSE TEXT (just the SPDX identifier)
# Legal: "Where's the actual MIT license text for each package?"
```

**Correct (with this plugin — sourced from webpack's actual module graph):**

```js
const fs = require('node:fs');
const path = require('node:path');
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    filename: { type: 'string' },
    excludeLicenses: { type: 'array', items: { type: 'string' } },
    overrides: {
      type: 'object',
      additionalProperties: {
        type: 'object',
        properties: {
          license: { type: 'string' },
          licenseText: { type: 'string' },
        },
        additionalProperties: false,
      },
      description: 'Package name → license overrides for unlicensed/proprietary packages',
    },
    failOn: {
      type: 'array',
      items: { type: 'string' },
      description: 'Fail build if any package has one of these licenses (e.g. ["GPL-3.0", "AGPL-3.0"])',
    },
  },
  additionalProperties: false,
};

const DEFAULTS = { filename: 'LICENSES.txt' };

class LicenseNoticePlugin {
  constructor(options = {}) {
    validate(schema, options, { name: 'LicenseNoticePlugin', baseDataPath: 'options' });
    this.options = { ...DEFAULTS, ...options };
    this.packageCache = new Map(); // resourceDir → packageJsonPath
  }

  apply(compiler) {
    const { Compilation, sources, WebpackError } = compiler.webpack;

    compiler.hooks.thisCompilation.tap('LicenseNoticePlugin', (compilation) => {
      const packages = new Map();  // `name@version` → metadata

      compilation.hooks.afterSeal.tap('LicenseNoticePlugin', () => {
        for (const mod of compilation.modules) {
          const resource = mod.resource;
          if (!resource || !resource.includes('node_modules')) continue;

          const pkg = this.findPackageJson(resource);
          if (!pkg) continue;

          const key = `${pkg.name}@${pkg.version}`;
          if (packages.has(key)) continue;

          const override = this.options.overrides?.[pkg.name];
          const license = override?.license ?? normalizeLicense(pkg.license ?? pkg.licenses);
          if (this.options.excludeLicenses?.includes(license)) continue;

          packages.set(key, {
            name: pkg.name,
            version: pkg.version,
            license,
            licenseText: override?.licenseText ?? this.readLicenseFile(path.dirname(pkg._path)),
            repository: typeof pkg.repository === 'string' ? pkg.repository : pkg.repository?.url,
            author: typeof pkg.author === 'string' ? pkg.author : pkg.author?.name,
          });
        }

        // Fail-on check
        if (this.options.failOn) {
          for (const [, p] of packages) {
            if (this.options.failOn.includes(p.license)) {
              const err = new WebpackError(
                `LicenseNoticePlugin: bundled package ${p.name}@${p.version} ` +
                `has forbidden license "${p.license}"\n` +
                `  Repository: ${p.repository ?? '(unknown)'}\n` +
                `  Either remove the dependency or move it to a non-bundled context.`,
              );
              err.hideStack = true;
              compilation.errors.push(err);
            }
          }
        }
      });

      compilation.hooks.processAssets.tap(
        { name: 'LicenseNoticePlugin', stage: Compilation.PROCESS_ASSETS_STAGE_REPORT },
        () => {
          const sorted = [...packages.values()].sort((a, b) => a.name.localeCompare(b.name));
          const content = render(sorted);
          compilation.emitAsset(
            this.options.filename,
            new sources.RawSource(content),
            { development: false, immutable: false },
          );
        },
      );
    });
  }

  findPackageJson(resource) {
    let dir = path.dirname(resource);
    while (dir !== path.dirname(dir)) {
      if (this.packageCache.has(dir)) return this.packageCache.get(dir);
      const candidate = path.join(dir, 'package.json');
      if (fs.existsSync(candidate)) {
        try {
          const pkg = JSON.parse(fs.readFileSync(candidate, 'utf8'));
          pkg._path = candidate;
          this.packageCache.set(dir, pkg);
          return pkg;
        } catch { /* fallthrough */ }
      }
      this.packageCache.set(dir, null);
      dir = path.dirname(dir);
    }
    return null;
  }

  readLicenseFile(dir) {
    for (const name of ['LICENSE', 'LICENSE.md', 'LICENSE.txt', 'license', 'LICENCE']) {
      try { return fs.readFileSync(path.join(dir, name), 'utf8'); } catch {}
    }
    return null;
  }
}

function normalizeLicense(raw) {
  if (!raw) return 'UNKNOWN';
  if (typeof raw === 'string') return raw;
  if (Array.isArray(raw)) return raw.map((l) => l.type ?? l).join(' OR ');
  return raw.type ?? 'UNKNOWN';
}

function render(packages) {
  const lines = [
    'Third-Party Software Notices and Information',
    '='.repeat(60),
    `Generated ${new Date().toISOString()}`,
    `Total packages: ${packages.length}`,
    '',
  ];
  for (const p of packages) {
    lines.push('-'.repeat(60));
    lines.push(`${p.name}@${p.version}`);
    lines.push(`License: ${p.license}`);
    if (p.author) lines.push(`Author: ${p.author}`);
    if (p.repository) lines.push(`Repository: ${p.repository}`);
    lines.push('');
    if (p.licenseText) {
      lines.push(p.licenseText.trim());
      lines.push('');
    }
  }
  return lines.join('\n');
}

module.exports = LicenseNoticePlugin;
```

## How it works

- **`afterSeal`** runs after webpack has finalized which modules are in the build — earlier hooks would miss dynamic imports added by `splitChunks`
- **`mod.resource.includes('node_modules')`** is the cheap discriminator — your own source code doesn't need attribution
- **`findPackageJson` walks UP from the module file** — handles scoped packages (`@org/pkg`), monorepo internal packages, and packages with nested `node_modules`
- **`packageCache: Map<dir, pkg>`** avoids re-reading the same package.json hundreds of times (one entry per package, not per module)
- **`PROCESS_ASSETS_STAGE_REPORT`** is the right stage for files generated FROM the asset graph — runs after everything else is settled. See [`webpack-plugin-authoring/hook-process-assets-stage`].
- **`failOn: ['GPL-3.0', 'AGPL-3.0']`** uses [`webpack-plugin-authoring/diag-push-webpack-error-not-throw`] to fail builds containing copyleft licenses incompatible with proprietary distribution

## Variations

- **JSON output** for legal review tooling:
  ```js
  filename: 'licenses.json',
  // render() returns JSON.stringify(packages, null, 2) instead
  ```
- **SPDX expression compatibility check**: use [`spdx-satisfies`](https://www.npmjs.com/package/spdx-satisfies) to validate per-license compatibility with your project's license
- **Group by license** in output (all MIT together, all Apache together)
- **Append to existing notice file** instead of replacing (for hand-curated additions)

## When NOT to use this pattern

- You're shipping a non-distributed product (internal server only, never given to customers) — most OSS licenses don't require attribution for non-distributed use
- Your dependencies are all internal / first-party — no third-party attribution needed
- You use [license-webpack-plugin](https://github.com/xz64/license-webpack-plugin) or [@webpack-cli/info](https://webpack.js.org/api/cli/) — both work well for common cases

Reference: [SPDX License List](https://spdx.org/licenses/) · [license-webpack-plugin](https://github.com/xz64/license-webpack-plugin) · [Compilation API — modules](https://webpack.js.org/api/compilation-object/#modules)
