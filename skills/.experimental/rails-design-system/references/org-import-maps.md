---
title: Use Import Maps for Zero-Build JavaScript Delivery
impact: MEDIUM
impactDescription: eliminates npm, node_modules, and bundler configuration entirely
tags: org, import-maps, javascript, dependencies
---

## Use Import Maps for Zero-Build JavaScript Delivery

Rails 7+ ships with Import Maps as the default JavaScript delivery mechanism. Import Maps let the browser resolve module imports directly from URLs — no npm, no node_modules, no Webpack, no esbuild. Pin your dependencies in `config/importmap.rb` and the browser handles the rest. This is the Rails Way for JavaScript in design system work.

**Incorrect (installing npm, adding a bundler, configuring build pipelines):**

```json
// package.json — unnecessary in a Rails 7+ app
{
  "dependencies": {
    "@hotwired/stimulus": "^3.2.0",
    "@hotwired/turbo-rails": "^8.0.0",
    "@stimulus-components/clipboard": "^5.0.0"
  },
  "devDependencies": {
    "esbuild": "^0.20.0"
  },
  "scripts": {
    "build": "esbuild app/javascript/*.* --bundle --outdir=app/assets/builds"
  }
}
```

**Correct (Import Maps — pins in Ruby, no build step):**

```ruby
# config/importmap.rb
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# Pin all Stimulus controllers from app/javascript/controllers
pin_all_from "app/javascript/controllers", under: "controllers"

# Third-party Stimulus components
pin "@stimulus-components/clipboard", to: "@stimulus-components--clipboard.js"
pin "sortablejs", to: "https://ga.jspm.io/npm:sortablejs@1.15.3/modular/sortable.esm.js"
```

```javascript
// app/javascript/application.js
import "@hotwired/turbo-rails"
import "controllers"
```

```javascript
// app/javascript/controllers/index.js
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

eagerLoadControllersFrom("controllers", application)
```

### Adding Third-Party JS Packages

```bash
# Pin from CDN (jspm, unpkg, or jsdelivr)
bin/importmap pin @stimulus-components/clipboard

# Vendor locally for offline/CI reliability
bin/importmap pin @stimulus-components/clipboard --download
```

Vendored files are saved to `vendor/javascript/` and served by Propshaft alongside your own JavaScript.

### When Import Maps Don't Fit

Import Maps work for the vast majority of Rails apps. Switch to a bundler (jsbundling-rails with esbuild) only if you need:
- TypeScript compilation
- JSX/React components
- Tree-shaking for large dependency trees
- CSS Modules or CSS-in-JS

For standard Rails apps with Turbo, Stimulus, and a few third-party controllers, Import Maps are the simpler and faster choice.

Reference: [Import Maps for Rails](https://github.com/rails/importmap-rails)
