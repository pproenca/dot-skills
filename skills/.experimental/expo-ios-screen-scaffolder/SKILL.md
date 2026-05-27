---
name: expo-ios-screen-scaffolder
description: Use this skill to scaffold new Expo (React Native) iOS screens that follow Apple Human Interface Guidelines by construction — list, detail, form, modal sheet, native tabs layout, and settings screens, each wired with native navigation, FlashList, safe-area insets, semantic colors, SF Symbols, haptics, and empty/loading states. Trigger whenever the user wants to create, add, generate, or scaffold a new Expo screen, route, tab layout, or form for iOS, even if they don't mention HIG — the generated code follows the expo-ios-hig rules so it passes expo-ios-hig-verify without rework. Each screen is TSX for Expo Router, not Swift.
---

# Expo iOS Screen Scaffolder

Parameterized templates that generate HIG-compliant Expo Router screens. Every template produces a screen that is native-by-construction — native navigation, virtualized lists, safe areas, semantic colors, SF Symbols, haptics, and honest empty states — so new screens start correct instead of being retrofitted. Each generated file cites the `expo-ios-hig` rules it satisfies.

## When to Apply

Use this skill when the user wants to:

- **Create or add a new screen, route, or layout** in an Expo app for iOS
- Scaffold a **list, detail, form, modal sheet, tab bar, or settings** screen
- Start a new Expo feature and want the screens to feel native from the first commit
- Bring an existing screen up to the conventions in `references/conventions.md`

## Available Templates

To scaffold: read the template, substitute the placeholders, and write the result to its route path under `app/`. Placeholders use single braces (e.g., `{ScreenName}`); the literal TSX braces stay as-is.

| Template | Generates | Placeholders |
|----------|-----------|--------------|
| [`list-screen.tsx.template`](assets/templates/list-screen.tsx.template) | Large-title list: `FlashList` + `RefreshControl` + empty state + bottom safe-area inset | `{ScreenName}` `{Entity}` `{entity_plural}` `{Title}` `{route_path}` `{sf_symbol}` |
| [`detail-screen.tsx.template`](assets/templates/detail-screen.tsx.template) | Pushed detail: edge-to-edge scroll, semantic colors, system share button | `{ScreenName}` `{Entity}` `{entity}` `{entityId}` |
| [`form-screen.tsx.template`](assets/templates/form-screen.tsx.template) | Create form: keyboard avoidance, configured input, optimistic save + haptics | `{ScreenName}` `{Entity}` `{entity}` |
| [`modal-sheet.tsx.template`](assets/templates/modal-sheet.tsx.template) | `formSheet` route with detents + grabber and Cancel/Done | `{ScreenName}` `{Title}` `{route_name}` |
| [`native-tabs-layout.tsx.template`](assets/templates/native-tabs-layout.tsx.template) | Root `NativeTabs` layout with SF Symbol icons (repeat per tab) | `{tab_name}` `{Tab_label}` `{tab_sf_symbol}` |
| [`settings-screen.tsx.template`](assets/templates/settings-screen.tsx.template) | Grouped settings: `SectionList` + platform `Switch` rows | `{ScreenName}` `{Title}` |

Common placeholders:

- `{ScreenName}` — PascalCase component with a `Screen` suffix, e.g. `TrailsScreen`
- `{Entity}` / `{entity}` / `{entity_plural}` — PascalCase, camelCase, and plural forms, e.g. `Trail` / `trail` / `trails`
- `{entityId}` — dynamic route param name, matching the file (`[trailId].tsx` → `trailId`)
- `{Title}` — navigation bar title text, e.g. `Trails`
- `{route_path}` / `{route_name}` — route segment(s) used for navigation
- `{sf_symbol}` / `{tab_sf_symbol}` — SF Symbol name from Apple's SF Symbols app
- `{file_path}` — the destination path, written into the header comment

## How to Use

1. Pick the template for the screen type.
2. Choose values for its placeholders (see the table above and the header comment inside each template).
3. Substitute and write to the route path, e.g. `app/(trails)/index.tsx`, `app/(trails)/[trailId].tsx`.
4. Implement the imported companion (`use{Entity}List`, `create{Entity}`, …) — the scaffold owns the view, you own the data layer.
5. Read [references/conventions.md](references/conventions.md) for the rules each template enforces and when to deviate.

## Setup

`config.json` is optional. Override on first use if your project differs:

- `app_dir` — Expo Router routes directory (default `app`)
- `components_dir` — shared components directory (default `components`)
- `list_component` — `FlashList` (default) or `FlatList` for the list template

## Related Skills

- **`expo-ios-hig`** — the rules these templates follow; each generated file cites them.
- **`expo-ios-hig-verify`** — run it after scaffolding to confirm the screen stays native.
