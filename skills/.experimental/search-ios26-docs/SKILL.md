---
name: search-ios26-docs
description: Search and inspect local iOS 26 SDK documentation and Swift interfaces, especially SwiftUI and SwiftUICore. Use when Codex needs current iOS 26 SwiftUI APIs, Liquid Glass components, view modifiers, availability, signatures, deprecations, symbol docs, or SDK-only facts and should not rely on memory or public web docs being available.
---

# Search iOS 26 Docs

Use the local Xcode iPhone Simulator SDK as the source of truth for iOS 26 APIs. Prefer this skill before web search when the task asks what is available in the current SDK, how a SwiftUI symbol is declared, what availability it has, or whether an iOS 26 API exists.

## Quick Start

Build or refresh the cached symbol graphs:

```bash
python3 "$HOME/.codex/skills/search-ios26-docs/scripts/build_cache.py"
```

Search SwiftUI and SwiftUICore symbol docs:

```bash
python3 "$HOME/.codex/skills/search-ios26-docs/scripts/search_symbols.py glass button style
python3 "$HOME/.codex/skills/search-ios26-docs/scripts/search_symbols.py backgroundExtensionEffect --ios26
python3 "$HOME/.codex/skills/search-ios26-docs/scripts/search_symbols.py toolbar spacer --module SwiftUI --limit 12
```

Probe a symbol or concept with exact SDK source snippets attached:

```bash
python3 "$HOME/.codex/skills/search-ios26-docs/scripts/probe_symbol.py" ZoomNavigationTransition --module SwiftUI
python3 "$HOME/.codex/skills/search-ios26-docs/scripts/search_symbols.py" VNRecognizeTextRequest --module Vision --verify-interfaces --limit 12
```

Discover SDK modules before deciding where to search:

```bash
python3 "$HOME/.codex/skills/search-ios26-docs/scripts/search_symbols.py" --find-module vision
python3 "$HOME/.codex/skills/search-ios26-docs/scripts/search_symbols.py" --list-modules
```

The search script auto-builds the default cache on first use. Use `--force` on `build_cache.py` when Xcode changes or search results look stale.

## Workflow

1. Resolve the active SDK with `xcrun --sdk iphonesimulator --show-sdk-path`.
2. Use `scripts/search_symbols.py` for prose docs, symbol names, declarations, and availability. This reads cached `swift-symbolgraph-extract` output from the local SDK.
3. Add `--verify-interfaces` or use `scripts/probe_symbol.py` when exact compiler declarations, overloads, underscored symbols, generated attributes, or platform availability matter. Verification searches `.swiftinterface`, headers, and apinotes and reports source snippets plus diagnostics.
4. Use `--find-module PATTERN` or `--list-modules` to discover candidate SDK modules, then rerun with explicit `--module` values.
5. Cite findings as local SDK facts. If a symbol is not found in symbol graphs, check `sourceOnlyMatches` from `--verify-interfaces` before concluding it does not exist.

## Interface Inspection

Swift interfaces are API surfaces, not full documentation. They are still the best fallback for exact signatures and attributes:

```bash
SDK_PATH=$(xcrun --sdk iphonesimulator --show-sdk-path)
SWIFTUI="$SDK_PATH/System/Library/Frameworks/SwiftUI.framework/Modules/SwiftUI.swiftmodule/arm64-apple-ios-simulator.swiftinterface"
SWIFTUICORE="$SDK_PATH/System/Library/Frameworks/SwiftUICore.framework/Modules/SwiftUICore.swiftmodule/arm64-apple-ios-simulator.swiftinterface"

rg -n "GlassButtonStyle|backgroundExtensionEffect|SpacerSizing" "$SWIFTUI" "$SWIFTUICORE"
sed -n '1200,1235p' "$SWIFTUI"
```

Use interface grep for:

- overload sets and generic constraints
- `@available`, deprecation, and rename messages
- internal-adjacent underscored declarations visible in the SDK
- declarations missing prose docs in symbol graphs

## Symbol Graph Cache

The cache defaults to:

```text
${CODEX_IOS26_DOCS_CACHE:-$HOME/.cache/codex/search-ios26-docs}/<sdk-name>/<target>/<module>/
```

Default modules are `SwiftUI` and `SwiftUICore`. Add more modules when needed:

```bash
python3 "$HOME/.codex/skills/search-ios26-docs/scripts/build_cache.py --module UIKit --module Foundation
python3 "$HOME/.codex/skills/search-ios26-docs/scripts/search_symbols.py safeAreaRegions --module UIKit
```

Useful options:

- `build_cache.py --list` prints cache location and SDK details without extracting.
- `build_cache.py --force` deletes and rebuilds selected module caches.
- `search_symbols.py --json` emits machine-readable results.
- `search_symbols.py --verify-interfaces` attaches matching `.swiftinterface`, header, or apinotes snippets and diagnostics to shown results.
- `probe_symbol.py QUERY ...` is shorthand for a verified, non-deduped symbol probe with full docs.
- `search_symbols.py --find-module PATTERN` lists SDK modules with names matching a substring.
- `search_symbols.py --list-modules` lists SDK framework modules visible to the helper.
- `search_symbols.py --kind "Instance Method"` narrows result kind.
- `search_symbols.py --ios26` filters to symbols introduced in iOS 26 or later.
- `search_symbols.py --introduced iOS:26` filters by an explicit availability domain and major version.
- `search_symbols.py --no-doc` hides doc snippets for compact output.
- `search_symbols.py --no-dedupe` keeps repeated extension results when every concrete receiver matters.
- `search_symbols.py --source-limit 8 --source-context-lines 6` adjusts verified source snippets.

## Test

Run the end-to-end tests after changing the helper scripts. They use the actual installed SDK and validate symbol graph search, verified source snippets, module discovery, and explicit module drill-down:

```bash
python3 "$HOME/.codex/skills/search-ios26-docs/tests/test_search_symbols_e2e.py"
```

## Interpretation Rules

- Treat symbol graph docs as extracted local Apple SDK metadata, not generated guesses.
- Treat `.swiftinterface` as the compiler-facing declaration source.
- Treat headers and apinotes as first-class fallback sources for Objective-C-backed frameworks.
- When symbol graphs and verified SDK source disagree, prefer the verified SDK source and report the mismatch.
- Do not assume public Apple Developer web pages are complete or current for iOS 26 beta/new SDK APIs.
- If symbol graph extraction fails for a module, fall back to `rg` over framework interfaces under `$SDK_PATH/System/Library/Frameworks` and `$SDK_PATH/System/Library/PrivateFrameworks`.
- Report the active SDK basename, target triple, and module when precision matters.
