---
title: Mark shipped pending work with a warning directive not a TODO comment
tags: err, warnings, todo, diagnostics
---

## Mark shipped pending work with a warning directive not a TODO comment

The wrong default when shipping known-incomplete code is a `// TODO:` or `// FIXME:` comment — invisible the moment the PR merges, so the stub silently becomes permanent. `#warning("TODO: …")` surfaces the pending work in every build until it is addressed, which is the difference between a note to a future reader and a signal the toolchain refuses to forget.

**Evidence of violation:** a `// TODO:` or `// FIXME:` comment introduced by the reviewed diff inside Swift source, marking incomplete or placeholder behavior (a stubbed body, an unhandled case, a missing branch) where `#warning` is expressible. PASS: pending work introduced by the diff carries `#warning` (or the work is complete and no marker is needed). N/A: TODO markers in non-Swift files or documentation comments; pre-existing TODOs the diff does not touch; targets whose supplied build facts show warnings treated as errors (a `#warning` would break the build); or a visible TODO-linter convention (for example SwiftLint's `todo` rule) already surfacing them. The dispatcher supplies build-configuration stack facts with the target — when those facts are absent, judge only diff-introduced TODOs against this rule.

**Incorrect (a comment nothing surfaces after merge):**

```swift
import Foundation

func fetchUserData(from url: URL) {
    // TODO: Implement caching to optimize network calls
    URLSession.shared.dataTask(with: url) { data, response, error in
        // Handle response and error
    }.resume()
}
```

**Correct (the build carries the reminder until the work is done):**

```swift
import Foundation

func fetchUserData(from url: URL) {
    #warning("TODO: Implement caching to optimize network calls")
    URLSession.shared.dataTask(with: url) { data, response, error in
        // Handle response and error
    }.resume()
}
```
