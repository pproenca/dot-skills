---
title: Model combinable behavior toggles as an OptionSet not a row of booleans
tags: api, optionset, function-signatures, configuration
---

## Model combinable behavior toggles as an OptionSet not a row of booleans

The wrong default for an operation with several independent, combinable switches is a row of `Bool` parameters — `fetchData(useCache: true, retryOnFailure: false, background: true)` — which makes call sites unreadable, cannot be stored or passed around as one value, and turns every new option into a source-breaking signature change. An `OptionSet` value composes at the call site (`[.useCache, .retryOnFailure]`), travels as a single argument, and extends without touching existing callers.

**Evidence of violation:** a function or initializer signature declaring three or more `Bool` parameters that each toggle an independent optional behavior of the same operation. PASS: combinable toggles arrive as one `OptionSet` (or an equivalent single configuration value), or the signature has at most two booleans. N/A: the booleans are domain data rather than behavior toggles (`isVerified`, `hasChildren`), or no multi-toggle signature occurs in the target.

**Incorrect (three positional toggles — unreadable call sites, source-breaking to extend):**

```swift
func fetchData(
    useCache: Bool,
    retryOnFailure: Bool,
    background: Bool
) {
    if useCache {
        // Implement cache logic
    }
    if retryOnFailure {
        // Implement retry logic
    }
    if background {
        // Implement background execution logic
    }

    // Rest of the fetch operation
}

fetchData(useCache: true, retryOnFailure: true, background: false)
```

**Correct (one OptionSet value composes and extends without breaking callers):**

```swift
struct FetchOptions: OptionSet {
    let rawValue: Int

    static let useCache = FetchOptions(rawValue: 1 << 0)
    static let retryOnFailure = FetchOptions(rawValue: 1 << 1)
    static let background = FetchOptions(rawValue: 1 << 2)
}

func fetchData(options: FetchOptions) {
    if options.contains(.useCache) {
        // Implement cache logic
    }
    if options.contains(.retryOnFailure) {
        // Implement retry logic
    }
    if options.contains(.background) {
        // Implement background execution logic
    }

    // Rest of the fetch operation
}

fetchData(options: [.useCache, .retryOnFailure])
```
