# Conventions

These templates generate Expo / React Native design system code that obeys the
[`expo-design-system`](../../expo-design-system/SKILL.md) rules by construction. This document
explains the conventions the templates enforce and *why*, so you can make informed exceptions.

## Styling: Unistyles `StyleSheet.create((theme) => ...)` only

Every template styles with `StyleSheet.create` from `react-native-unistyles`, reading values from
the `theme` argument. **Why:** the style reference is stable and Unistyles repaints it natively on
theme change with no React re-render. Inline objects re-allocate per render and cannot be themed.
Rules: `style-stylesheet-create`, `theme-stylesheet-theme-arg`.

## Component API: variant props, never a `style` escape hatch

Components expose `variant`, `size`, `tone`, and `inset` props and call `styles.useVariants({ ... })`.
They do **not** accept a `style` prop; the text primitive even `Omit`s it from its props.
**Why:** this is the Airbnb DLS contract — a closed, reviewable set of options keeps every "primary"
button identical, while a `style` prop lets any screen bypass tokens. Rules:
`api-variants-over-style-prop`, `api-no-style-escape-hatch`, `style-variants-api`.

## Composition: slots over a prop per element

Composite surfaces accept `leading`/`trailing`/`children` slots of type `ReactNode` rather than a
`show*` boolean plus payload per element. **Why:** slots cover content the author never predicted
without an ever-growing API. Rule: `api-slots-for-composition`.

## State: controlled or uncontrolled

Inputs accept an optional `value` with a `defaultValue` fallback, so simple screens stay terse and
forms keep full control. **Why:** controlled-only forces every call site to own state. Rule:
`api-controlled-uncontrolled`.

## Refs: `ref` as a prop (React 19)

Leaf components declare `ref?: Ref<...>` and pass it to the native element. **Why:** React 19
(React Native 0.81+) makes `ref` a regular prop, so `forwardRef` is the legacy form; forwarding the
ref keeps focus and measurement available to forms. Rule: `api-forward-ref`.

## Accessibility: baked into the contract

Interactive templates set `accessibilityRole`, derive an `accessibilityLabel`, expose
`accessibilityState`, and keep OS font scaling on with a capped `maxFontSizeMultiplier`. **Why:**
accessibility left to the caller is forgotten; building it in means an inaccessible instance cannot
ship. Rules: `api-accessibility-in-contract`, `type-respect-font-scaling`.

## Lists & native feel

The list template uses `FlashList` with a `keyExtractor`, a memoized row, and safe-area bottom
padding from `rt.insets`. **Why:** a `ScrollView` mounts every row; an un-memoized row re-renders on
every parent update; hardcoded insets collide with the home indicator. Rules:
`perf-flashlist-for-lists`, `perf-memoize-list-items`, `space-safe-area-insets`.

## Tokens: three layers in the theme

The token-group template adds raw → semantic → component layers to the Unistyles theme and names
tokens by role, never by value. **Why:** role names stay honest through a rebrand, and one theme is
the single source of truth. Rules: `token-three-layer-scale`, `token-semantic-naming`,
`token-define-in-unistyles-theme`.

## Placeholder syntax

Placeholders are single-brace identifier tokens (`{ComponentName}`, `{Entity}`, `{entity_plural}`,
`{token_group}`, `{file_path}`). **Why:** they are distinct from literal TSX and Unistyles braces
(`{item.title}`, `{ variant }`), which contain expressions or spaces and must stay as-is. Substitute
only the named tokens.

## When to deviate

- A one-off, never-reused view does not need a primitive — compose inline.
- A genuinely free-form container (e.g. a chart host) may take a constrained `style` if documented.
- Skip the story for an internal primitive that is never used outside one screen.
