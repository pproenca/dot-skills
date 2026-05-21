---
name: expo-design-system-scaffolder
description: Use this skill to scaffold new Expo / React Native design system components that obey the expo-design-system rules by construction — a variant-driven pressable primitive, a slot-based card surface, a typed text primitive, a labeled form field, a FlashList entity screen, a theme token group, and a Storybook variant catalog. Trigger whenever the user wants to create, add, generate, or scaffold a new shared UI component, primitive, design token group, or screen for the clinic mobile app, even if they don't mention the design system — the generated code uses Unistyles v3 variants instead of style props, ref-as-prop, design tokens, and built-in accessibility, so it follows expo-design-system without rework. Output is TSX/TS using react-native-unistyles.
---

# Expo Design System Scaffolder

Parameterized templates that generate Expo / React Native design system components which start
correct instead of being retrofitted. Every template uses Unistyles v3 variants (never a `style`
escape hatch), `ref`-as-prop, design tokens, and built-in accessibility, and cites the
[`expo-design-system`](../../expo-design-system/SKILL.md) rule IDs it satisfies.

## When to Apply

Use this skill when the user wants to:

- **Create or add a new shared component** — a button, card, text, input, or other primitive
- Scaffold a **new screen** that lists a domain entity (appointments, patients, notes)
- Add a **new design token group** (colors, etc.) to the Unistyles theme
- Add a **Storybook story** that catalogs a component's variants
- Start a new feature and want its components to follow the design system from the first commit

## Available Templates

To scaffold: read the template, substitute the placeholders, and write the result under the
design system package (or `app/` for the screen). Placeholders are single-brace identifier tokens
(e.g., `{ComponentName}`); literal TSX and Unistyles braces (e.g., `{ variant }`, `{item.title}`)
stay as-is.

| Template | Generates | Placeholders |
|----------|-----------|--------------|
| [`variant-component.tsx.template`](assets/templates/variant-component.tsx.template) | Pressable primitive with `variant`/`size` variants, press/disabled states, accessibility, `ref` prop | `{ComponentName}` `{file_path}` |
| [`card-surface.tsx.template`](assets/templates/card-surface.tsx.template) | Composite surface with `leading`/`trailing`/children slots, `tone`/`inset` variants, elevation token | `{ComponentName}` `{file_path}` |
| [`text-primitive.tsx.template`](assets/templates/text-primitive.tsx.template) | Typed text component with `variant`/`tone`, no raw style, capped font scaling | `{ComponentName}` `{file_path}` |
| [`form-field.tsx.template`](assets/templates/form-field.tsx.template) | Labeled input: controlled/uncontrolled, `ref` prop, error variant, accessibility | `{ComponentName}` `{file_path}` |
| [`list-screen.tsx.template`](assets/templates/list-screen.tsx.template) | Entity list composed from primitives: FlashList, memoized row, safe-area insets | `{ScreenName}` `{Entity}` `{entity}` `{entity_plural}` `{route_path}` `{file_path}` |
| [`token-group.ts.template`](assets/templates/token-group.ts.template) | Raw → semantic → component token group to merge into the Unistyles theme | `{token_group}` `{file_path}` |
| [`component-story.tsx.template`](assets/templates/component-story.tsx.template) | Storybook story rendering every variant side by side | `{ComponentName}` `{file_path}` |

Common placeholders:

- `{ComponentName}` — PascalCase component, e.g. `AppButton`, `AppCard`, `AppText`, `AppTextField`
- `{ScreenName}` — PascalCase screen with a `Screen` suffix, e.g. `AppointmentsScreen`
- `{Entity}` / `{entity}` / `{entity_plural}` — PascalCase, camelCase, and plural, e.g. `Appointment` / `appointment` / `appointments`
- `{route_path}` — route segment pushed for a row, e.g. `appointments`
- `{token_group}` — camelCase token group name, e.g. `statusBadge`
- `{file_path}` — the destination path, written into the header comment

## How to Use

1. Pick the template for what you are building.
2. Choose values for its placeholders (see the table and each template's header comment).
3. Substitute the tokens and write the file under `design_system_dir` (or `app_dir` for the screen).
4. Generate a matching story with `component-story.tsx.template` so the variants are cataloged.
5. Fill in the data layer the screen imports (`use{Entity}List`, the `domain` type) — the scaffold
   owns the view; you own the data.
6. Read [references/conventions.md](references/conventions.md) for the rules each template enforces
   and when to deviate.

## Setup

`config.json` is optional. Override on first use if your project differs:

- `design_system_dir` — design system package source (default `packages/design-system/src`)
- `app_dir` — Expo Router routes directory for the screen template (default `app`)

## Related Skills

- **`expo-design-system`** — the rule pack these templates follow; each generated file cites it.
- **`expo-react-native-coder`** — feature development around the scaffolded components.
