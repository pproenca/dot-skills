---
name: expo-ios-hig-verify
description: Use this skill to verify that an Expo / React Native iOS app follows Apple Human Interface Guidelines and native-feel best practices — it statically scans the codebase for the most common non-native patterns (Material component kits, JS navigators instead of native stack/tabs, PanResponder, disabled font scaling, hardcoded hex colors, unvirtualized lists) and reports each violation with file:line and a link to the rule. Trigger whenever the user asks to check, lint, audit, or review an Expo iOS app for HIG compliance or "native feel," or before shipping/merging Expo iOS UI. Pairs with the expo-ios-hig rules skill (it checks what that skill teaches) and the expo-ios-screen-scaffolder.
metadata:
  internal: true
---
# Expo iOS HIG Verifier

A read-only static checker that scans an Expo (React Native) project for violations of the `expo-ios-hig` rules and reports them grouped by severity, with `file:line` locations and links to the rule that explains the fix. It is the automated counterpart to the `expo-ios-hig` reference skill: that skill teaches the rules; this one checks them.

## When to Apply

Run this skill when:

- The user asks to **check, lint, audit, or review** an Expo app for HIG compliance or native feel
- Before merging or shipping Expo iOS UI changes, as a quality gate
- After scaffolding new screens, to confirm they stay native
- Investigating why an Expo app "feels like a web wrapper" or "feels like Android"

It is **read-only** — it never modifies the target project, so it is safe to run unsupervised.

## Workflow Overview

```
verify-hig.sh [project-dir]
  1. Resolve search roots (app/ src/ components/ by default, or config.json)
  2. Run static checks — one per detectable expo-ios-hig rule (rg, or grep fallback)
  3. Aggregate findings: severity, rule, message, file:line
  4. Print grouped report (ERRORS then ADVISORIES) with a link to each rule
  5. Exit 0 if clean, 1 if any ERROR (with --strict, advisories fail too)
```

Run it:

```bash
bash scripts/verify-hig.sh /path/to/expo-app          # text report
bash scripts/verify-hig.sh /path/to/expo-app --strict # advisories also fail
bash scripts/verify-hig.sh /path/to/expo-app --json   # machine-readable
```

## Checks

**ERRORS** are high-precision (import and literal-flag matches, low false positives). **ADVISORIES** are heuristics that warrant a look but don't fail the run unless `--strict`.

| Severity | Rule | Detects |
|----------|------|---------|
| ERROR | `native-avoid-material-ui` | `react-native-paper`, `@react-native-material/*`, `@rneui/*`, `react-native-elements` imports |
| ERROR | `nav-native-stack` | `@react-navigation/stack` / `createStackNavigator` |
| ERROR | `touch-gesture-handler-thread` | `PanResponder` |
| ERROR | `touch-pressable-feedback` | `TouchableWithoutFeedback` |
| ERROR | `acc-dynamic-type` | `allowFontScaling={false}` |
| ERROR | `motion-ui-thread-animation` | `useNativeDriver: false` |
| ADVISORY | `nav-native-tabs` | `createBottomTabNavigator` (JS tab bar) |
| ADVISORY | `visual-semantic-colors` | hardcoded hex in `color:`/`backgroundColor:`/`borderColor:`/`tintColor:` |
| ADVISORY | `visual-system-font` | custom `fontFamily:` |
| ADVISORY | `system-status-bar` | hardcoded `StatusBar style="dark"/"light"` |
| ADVISORY | `motion-virtualized-lists` | a file using both `<ScrollView>` and `.map(` |

Each finding links to `expo-ios-hig/references/{rule}.md` (path configurable in `config.json`) for the explanation and fix.

## Setup

`config.json` is optional — sensible defaults apply. Override on first use if your project differs:

- `search_roots` — space-separated source dirs to scan (default `app src components`)
- `skill_rules_dir` — path used in report links to the `expo-ios-hig` rule files (default `../expo-ios-hig/references`)

If `jq` is installed, the script reads these from `config.json`; otherwise it uses the defaults. `rg` (ripgrep) is used when available, with a `grep` fallback — no hard dependency.

## How to Use

1. Run `scripts/verify-hig.sh` against the Expo project root.
2. Read the grouped report; open the linked rule file for any finding to see the fix.
3. Treat ERRORS as must-fix before shipping; review ADVISORIES (they include intentional exceptions).
4. To extend: add a `check ERROR|ADVISORY <rule> "<message>" "<regex>"` line in `run_checks()` — see [references/workflow.md](references/workflow.md).

## Related Skills

- **`expo-ios-hig`** — the rules this verifier checks; every finding links back to it.
- **`expo-ios-screen-scaffolder`** — generates screens that pass these checks by construction.
