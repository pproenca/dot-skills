# Conventions

The conventions these templates enforce, and why. Each exists to make generated screens native-by-construction and consistent with the `expo-ios-hig` rules — so a scaffolded screen passes `expo-ios-hig-verify` without rework.

## File placement: under the Expo Router `app/` directory

Screens are routes. A screen file's path *is* its URL — `app/(trails)/[trailId].tsx` is the route `/trails/:trailId`.
**Why:** Expo Router is file-based; placing screens anywhere else means they aren't routable. The `app_dir` config key overrides the directory name.

## Component naming: PascalCase with a `Screen` suffix

The exported component is `TrailsScreen`, `TrailDetailScreen`, `NewTrailScreen`.
**Why:** Distinguishes route screens from shared components at a glance, and the suffix makes imports unambiguous in a large `app/` tree.

## Route param names match the file: `[trailId].tsx` → `trailId`

The `{entityId}` placeholder is the param the dynamic route file declares.
**Why:** `useLocalSearchParams<{ trailId: string }>()` must read the exact key Expo Router put there. A mismatch yields `undefined` at runtime with no compile error.

## Colors come from `PlatformColor`, never hardcoded hex

Every generated style uses semantic colors (`label`, `secondaryLabel`, `systemBackground`, `secondarySystemGroupedBackground`).
**Why:** Semantic colors track light/dark mode, increased contrast, and elevation automatically (`expo-ios-hig` rule `visual-semantic-colors`). Hardcoded hex is frozen to one appearance. Exception: a brand color that must stay constant — define it explicitly, with a dark variant.

## Large titles on root screens, inline titles on detail screens

List and settings templates set `headerLargeTitle: true`; detail templates use the default inline title.
**Why:** iOS shows a collapsing large title at the root of each tab and a standard title deeper in the stack (`nav-large-titles`). The large title only collapses when the scroll view is the screen's direct child — the templates keep it so.

## Lists are virtualized (`FlashList` by default)

The list template uses `FlashList`; the `list_component` config key can switch it to `FlatList`.
**Why:** Mapping rows into a `ScrollView` mounts everything at once and drops frames (`motion-virtualized-lists`). A virtualized list recycles rows for 60fps over large data. Both `FlashList` and `FlatList` support the `RefreshControl` and `ListEmptyComponent` the template wires up.

## Icons are SF Symbols via `expo-symbols`

Header actions and empty states use `SymbolView name="..."`.
**Why:** SF Symbols scale with Dynamic Type, match font weight, and look native (`native-sf-symbols`). Pick names from Apple's SF Symbols app.

## Modals get Cancel/Done; pushed screens keep the system back button

The modal-sheet template sets `headerLeft`/`headerRight` to Cancel/Done; other screens never replace `headerLeft`.
**Why:** Replacing `headerLeft` on a pushed screen disables the swipe-back edge gesture (`nav-system-back`). On a modal that is correct — modals dismiss with Cancel and swipe-down, not swipe-back (`nav-push-vs-present`).

## Each screen cites the rules it satisfies

Every template header lists the `expo-ios-hig` rules applied.
**Why:** Makes the generated code self-documenting and lets a reviewer (or the `expo-ios-hig-verify` skill) trace a decision back to its rationale.

## Companion files the user provides

Templates import a data hook (`use{Entity}List`, `use{Entity}`) or an API function (`create{Entity}`). These are intentionally *not* generated.
**Why:** Data access is app-specific. The scaffold owns the HIG-compliant view; the user owns the data layer. Adjust the import paths (`../hooks`, `../api`) to your project structure.
