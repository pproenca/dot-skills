# Uniwind

**Version 0.1.0**  
Uniwind  
February 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive best practices guide for Uniwind, the fastest Tailwind CSS bindings for React Native. Contains 45+ rules across 8 categories, prioritized by impact from critical (build-time configuration, theme architecture) to incremental (migration compatibility). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Build-Time Configuration](#1-build-time-configuration) — **CRITICAL**
   - 1.1 [Configure Metro Plugin with Required Options](#11-configure-metro-plugin-with-required-options)
   - 1.2 [Configure rem Base Value for Design System Consistency](#12-configure-rem-base-value-for-design-system-consistency)
   - 1.3 [Configure TypeScript Definition File Location](#13-configure-typescript-definition-file-location)
   - 1.4 [Enable Debug Mode During Development](#14-enable-debug-mode-during-development)
   - 1.5 [Place CSS Entry File in App Root Directory](#15-place-css-entry-file-in-app-root-directory)
   - 1.6 [Restart Metro After Configuration Changes](#16-restart-metro-after-configuration-changes)
2. [Theme Architecture](#2-theme-architecture) — **CRITICAL**
   - 2.1 [Define Identical Variables Across All Themes](#21-define-identical-variables-across-all-themes)
   - 2.2 [Define Theme Variables with @theme Directive](#22-define-theme-variables-with-theme-directive)
   - 2.3 [Register Custom Themes in Metro Config](#23-register-custom-themes-in-metro-config)
   - 2.4 [Remove ThemeProvider Wrapper from App](#24-remove-themeprovider-wrapper-from-app)
   - 2.5 [Use @variant Blocks for Theme Definitions](#25-use-variant-blocks-for-theme-definitions)
   - 2.6 [Use light-dark() Function for Adaptive Colors](#26-use-light-dark-function-for-adaptive-colors)
   - 2.7 [Use OKLCH Color Space for Perceptual Uniformity](#27-use-oklch-color-space-for-perceptual-uniformity)
3. [Component Integration](#3-component-integration) — **HIGH**
   - 3.1 [Define Wrapped Components at Module Level](#31-define-wrapped-components-at-module-level)
   - 3.2 [Reanimated Components Work Without withUniwind](#32-reanimated-components-work-without-withuniwind)
   - 3.3 [Use accent-* Classes for Color Prop Extraction](#33-use-accent-classes-for-color-prop-extraction)
   - 3.4 [Use Custom CSS Classes for Complex Reusable Styles](#34-use-custom-css-classes-for-complex-reusable-styles)
   - 3.5 [Use Custom Prop Mappings for Non-Style Props](#35-use-custom-prop-mappings-for-non-style-props)
   - 3.6 [Use withUniwind for Third-Party Components](#36-use-withuniwind-for-third-party-components)
4. [Responsive Design](#4-responsive-design) — **HIGH**
   - 4.1 [Define Custom Breakpoints with Semantic Names](#41-define-custom-breakpoints-with-semantic-names)
   - 4.2 [Design Mobile-First with Progressive Enhancement](#42-design-mobile-first-with-progressive-enhancement)
   - 4.3 [Limit Breakpoints to 3-5 for Maintainability](#43-limit-breakpoints-to-3-5-for-maintainability)
   - 4.4 [Scale Spacing and Typography Responsively](#44-scale-spacing-and-typography-responsively)
   - 4.5 [Use hidden/flex for Responsive Visibility](#45-use-hiddenflex-for-responsive-visibility)
5. [Performance Optimization](#5-performance-optimization) — **MEDIUM-HIGH**
   - 5.1 [Combine className and style Prop Correctly](#51-combine-classname-and-style-prop-correctly)
   - 5.2 [Memoize Variant Style Objects](#52-memoize-variant-style-objects)
   - 5.3 [Prefer className Over Inline style Prop](#53-prefer-classname-over-inline-style-prop)
   - 5.4 [Use Complete Static Class Names for Build-Time Resolution](#54-use-complete-static-class-names-for-build-time-resolution)
   - 5.5 [Use tailwind-merge for Class Deduplication](#55-use-tailwind-merge-for-class-deduplication)
   - 5.6 [Use useResolveClassNames Sparingly](#56-use-useresolveclassnames-sparingly)
6. [Platform Patterns](#6-platform-patterns) — **MEDIUM**
   - 6.1 [Configure Font Families Without Fallbacks](#61-configure-font-families-without-fallbacks)
   - 6.2 [Understand Yoga Layout Engine Differences](#62-understand-yoga-layout-engine-differences)
   - 6.3 [Use Platform Selectors for iOS/Android Differences](#63-use-platform-selectors-for-iosandroid-differences)
   - 6.4 [Use react-native-safe-area-context for Safe Areas](#64-use-react-native-safe-area-context-for-safe-areas)
   - 6.5 [Use web: Selector for Cross-Platform Apps](#65-use-web-selector-for-cross-platform-apps)
7. [State & Interaction](#7-state-interaction) — **MEDIUM**
   - 7.1 [Avoid hover: on Native - Use active: Instead](#71-avoid-hover-on-native-use-active-instead)
   - 7.2 [Use dark: Variant for Dark Mode Styles](#72-use-dark-variant-for-dark-mode-styles)
   - 7.3 [Use Data Selectors for Component State Styling](#73-use-data-selectors-for-component-state-styling)
   - 7.4 [Use Group Variants for Parent-Child Styling (WIP)](#74-use-group-variants-for-parent-child-styling-wip)
   - 7.5 [Use Pressable with active:/focus:/disabled: States](#75-use-pressable-with-activefocusdisabled-states)
8. [Migration & Compatibility](#8-migration-compatibility) — **LOW-MEDIUM**
   - 8.1 [Account for Different rem Default Values](#81-account-for-different-rem-default-values)
   - 8.2 [Follow NativeWind Migration Checklist](#82-follow-nativewind-migration-checklist)
   - 8.3 [Replace *-safe Classes with Safe Area Context](#83-replace-safe-classes-with-safe-area-context)
   - 8.4 [Replace cssInterop with withUniwind](#84-replace-cssinterop-with-withuniwind)
   - 8.5 [Use Tailwind 4 CSS-First Configuration](#85-use-tailwind-4-css-first-configuration)

---

## 1. Build-Time Configuration

**Impact: CRITICAL**

Metro plugin setup, CSS entry points, and type generation determine base performance ceiling. Misconfigurations cascade through the entire app, causing missing styles or build failures.

### 1.1 Configure Metro Plugin with Required Options

**Impact: CRITICAL (missing configuration causes zero styles to apply)**

The Metro plugin is required for Uniwind to function. Without proper configuration, no styles will be processed at build time.

**Incorrect (missing Uniwind configuration):**

```javascript
// metro.config.js
const { getDefaultConfig } = require('expo/metro-config')

module.exports = getDefaultConfig(__dirname)
// No Uniwind integration - styles won't work
```

**Correct (properly configured):**

```javascript
// metro.config.js
const { getDefaultConfig } = require('expo/metro-config')
const { withUniwindConfig } = require('uniwind/metro')

const config = getDefaultConfig(__dirname)

module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  dtsFile: './src/uniwind-types.d.ts',
})
```

**Key configuration options:**

- `cssEntryFile` (required): Path to your CSS entry file
- `dtsFile` (optional): Path for generated TypeScript definitions
- `extraThemes` (optional): Array of custom theme names
- `debug` (optional): Enable debug mode for development

Reference: [Uniwind Metro Config](https://docs.uniwind.dev/api/metro-config)

### 1.2 Configure rem Base Value for Design System Consistency

**Impact: HIGH (mismatched rem values cause incorrect spacing across entire app)**

Uniwind defaults to 16px for rem calculations. If your design system uses a different base, configure the polyfill to match.

**Incorrect (assuming NativeWind's 14px default):**

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  // Using default 16px, but design uses 14px base
})
```

```tsx
// p-4 = 16px (1rem × 16), but design expects 14px
<View className="p-4" />
```

**Correct (matching design system):**

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  polyfills: {
    rem: 14,  // Match your design system's base
  },
})
```

**When to change rem:**

- Migrating from NativeWind (uses 14px default)
- Design system specifies different base font size
- Web app migration with existing rem-based spacing

**Keep default 16px when:**
- Starting fresh with Uniwind
- Using Tailwind's standard spacing scale
- No existing design system constraints

Reference: [Uniwind Metro Config](https://docs.uniwind.dev/api/metro-config)

### 1.3 Configure TypeScript Definition File Location

**Impact: CRITICAL (enables autocomplete for all utilities and theme tokens)**

Uniwind generates TypeScript definitions during build. Proper placement enables autocomplete for all utilities, platform variants, and custom CSS classes.

**Incorrect (types in root, not included in tsconfig):**

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  dtsFile: './uniwind-types.d.ts',  // Root level, may not be included
})
```

**Correct (types in src for automatic inclusion):**

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  dtsFile: './src/uniwind-types.d.ts',  // Auto-included by TypeScript
})
```

**Alternative (explicit tsconfig inclusion):**

```json
// tsconfig.json
{
  "compilerOptions": {
    "types": ["./uniwind-types.d.ts"]
  }
}
```

**Benefits of proper type generation:**
- Autocomplete for all Tailwind utilities
- Type checking for platform variants (`ios:`, `android:`)
- IntelliSense for custom CSS classes
- Theme token suggestions

Reference: [Uniwind Metro Config](https://docs.uniwind.dev/api/metro-config)

### 1.4 Enable Debug Mode During Development

**Impact: HIGH (identifies unsupported CSS properties before they cause runtime issues)**

Debug mode logs warnings for unsupported CSS properties and invalid classNames. This catches issues at build time rather than runtime.

**Incorrect (no debug feedback):**

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  // Web-specific CSS silently ignored, no feedback
})
```

**Correct (debug enabled in development):**

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  debug: __DEV__,  // Only in development
})
```

**What debug mode catches:**

- Web-specific CSS properties (`float`, `cursor`, etc.)
- Invalid className syntax
- Missing theme variables
- Unsupported pseudo-classes (`hover:`, `visited:`)

**Disable in production:**

```javascript
debug: process.env.NODE_ENV !== 'production',
```

Reference: [Uniwind Metro Config](https://docs.uniwind.dev/api/metro-config)

### 1.5 Place CSS Entry File in App Root Directory

**Impact: CRITICAL (wrong placement causes className scanning to miss files)**

Tailwind scans for classNames starting from the CSS entry file's directory. Wrong placement causes missing styles.

**Incorrect (CSS file isolated from components):**

```text
project/
├── config/
│   └── global.css      # Tailwind won't scan src/
├── src/
│   └── components/
│       └── Button.tsx  # classNames not detected
```

**Correct (CSS file in app root):**

```text
project/
├── src/
│   ├── global.css      # Tailwind scans entire src/ tree
│   └── components/
│       └── Button.tsx  # classNames detected
```

```css
/* src/global.css */
@import 'tailwindcss';
@import 'uniwind';

/* Your theme and custom styles */
```

**For monorepos with components outside the CSS directory:**

```css
/* src/global.css */
@import 'tailwindcss';
@import 'uniwind';

@source '../../packages/ui/src';  /* Include external packages */
```

Reference: [Uniwind Metro Config](https://docs.uniwind.dev/api/metro-config)

### 1.6 Restart Metro After Configuration Changes

**Impact: CRITICAL (stale cache causes new themes and classes to be ignored)**

Metro caches configuration at startup. Changes to themes, breakpoints, or metro.config.js require a full restart with cache clear.

**Incorrect (just saving files after changes):**

```bash
# Made changes to metro.config.js or global.css
# Expecting hot reload to pick up new themes...
# New theme variables are undefined, styles missing
```

**Correct (restart with cache clear):**

```bash
# After any configuration changes:
npx expo start --clear

# Or for bare React Native:
npx react-native start --reset-cache
```

**Changes that require Metro restart:**

- Adding themes to `extraThemes` array
- Modifying CSS `@theme` variables
- Changing `cssEntryFile` or `dtsFile` paths
- Adding `@source` directives for monorepos
- Modifying custom breakpoints

**Debug tip:** If themes don't appear after restart, verify:
1. Theme is registered in `extraThemes`
2. Theme has `@variant` block in CSS
3. All themes define the same CSS variables

Reference: [Uniwind Metro Config](https://docs.uniwind.dev/api/metro-config)

---

## 2. Theme Architecture

**Impact: CRITICAL**

CSS variables, custom themes, and theming patterns affect every styled component. Poor theme setup causes inconsistent UI, runtime overhead, and broken dark mode.

### 2.1 Define Identical Variables Across All Themes

**Impact: CRITICAL (missing variables cause undefined colors and broken UI)**

Every theme must define the same CSS variables. Missing variables cause undefined colors and Uniwind will warn in development mode.

**Incorrect (inconsistent variables):**

```css
@layer theme {
  :root {
    @variant light {
      --color-background: #ffffff;
      --color-foreground: #000000;
      --color-primary: #3b82f6;
    }

    @variant dark {
      --color-background: #000000;
      --color-foreground: #ffffff;
      /* Missing --color-primary! Will be undefined in dark mode */
    }
  }
}
```

**Correct (all variables defined):**

```css
@layer theme {
  :root {
    @variant light {
      --color-background: #ffffff;
      --color-foreground: #000000;
      --color-primary: #3b82f6;
      --color-secondary: #6b7280;
      --color-accent: #f59e0b;
    }

    @variant dark {
      --color-background: #0a0a0a;
      --color-foreground: #fafafa;
      --color-primary: #60a5fa;
      --color-secondary: #9ca3af;
      --color-accent: #fbbf24;
    }
  }
}
```

**Uniwind validation:**
- Warns in `__DEV__` mode when variables are missing
- Enable `debug: true` for detailed variable reports

Reference: [Uniwind Custom Themes](https://docs.uniwind.dev/theming/custom-themes)

### 2.2 Define Theme Variables with @theme Directive

**Impact: CRITICAL (enables semantic color classes across entire app)**

Uniwind uses Tailwind 4's @theme directive for CSS variables. This enables semantic classes like `bg-background` and `text-foreground`.

**Incorrect (hardcoded colors everywhere):**

```tsx
<View className="bg-white dark:bg-black">
  <Text className="text-gray-900 dark:text-white">
    {/* Repeated throughout app, hard to maintain */}
  </Text>
</View>
```

**Correct (semantic theme variables):**

```css
/* global.css */
@import 'tailwindcss';
@import 'uniwind';

@theme {
  --color-background: #ffffff;
  --color-foreground: #000000;
  --color-primary: #3b82f6;
  --color-muted: #6b7280;
}
```

```tsx
<View className="bg-background">
  <Text className="text-foreground">
    {/* Automatically adapts to theme */}
  </Text>
</View>
```

**Benefits:**
- Single source of truth for colors
- Easy theme switching
- Consistent design system
- No JavaScript theme provider needed

Reference: [Tailwind CSS Theme Variables](https://tailwindcss.com/docs/theme)

### 2.3 Register Custom Themes in Metro Config

**Impact: CRITICAL (unregistered themes are not compiled and won't work at runtime)**

Custom themes beyond light/dark must be registered in Metro's `extraThemes` array. Unregistered themes won't be compiled.

**Incorrect (theme defined but not registered):**

```css
/* global.css */
@layer theme {
  :root {
    @variant ocean {
      --color-background: #0c4a6e;
      --color-foreground: #e0f2fe;
    }
  }
}
```

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  // extraThemes missing - 'ocean' won't work!
})
```

**Correct (theme registered):**

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  extraThemes: ['ocean', 'sunset', 'forest'],  // Register all custom themes
})
```

```typescript
// Now you can switch to custom themes
Uniwind.setTheme('ocean')
```

**After adding themes:**
1. Register in `extraThemes`
2. Define `@variant` block in CSS
3. Restart Metro with `--clear` flag

Reference: [Uniwind Custom Themes](https://docs.uniwind.dev/theming/custom-themes)

### 2.4 Remove ThemeProvider Wrapper from App

**Impact: HIGH (eliminates unnecessary context and re-renders)**

Uniwind handles themes via CSS variables, not React context. Remove NativeWind's ThemeProvider to avoid unnecessary wrapper and re-renders.

**Incorrect (keeping NativeWind's ThemeProvider):**

```tsx
import { ThemeProvider } from 'nativewind'

export default function App() {
  return (
    <ThemeProvider value={{ colorScheme: 'dark' }}>
      <NavigationContainer>
        <RootNavigator />
      </NavigationContainer>
    </ThemeProvider>
  )
}
```

**Correct (no theme provider needed):**

```tsx
export default function App() {
  return (
    <NavigationContainer>
      <RootNavigator />
    </NavigationContainer>
  )
}
```

**Switch themes programmatically:**

```typescript
import { Uniwind } from 'uniwind'
import { useColorScheme } from 'react-native'

function useSystemTheme() {
  const colorScheme = useColorScheme()

  useEffect(() => {
    Uniwind.setTheme(colorScheme ?? 'light')
  }, [colorScheme])
}
```

**Keep React Navigation's theme:**

```tsx
// NavigationContainer theme is still needed for navigation UI
<NavigationContainer theme={colorScheme === 'dark' ? DarkTheme : DefaultTheme}>
```

Reference: [Uniwind Migration Guide](https://docs.uniwind.dev/migration-from-nativewind)

### 2.5 Use @variant Blocks for Theme Definitions

**Impact: CRITICAL (enables dark mode and custom themes without JavaScript)**

Each theme requires an `@variant` block defining its CSS variables. Themes switch by changing CSS variables, not JavaScript state.

**Incorrect (JavaScript-based theming):**

```tsx
// Requires context, re-renders, and manual color mapping
const ThemeProvider = ({ children }) => {
  const [theme, setTheme] = useState('light')
  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  )
}
```

**Correct (CSS-based theming):**

```css
/* global.css */
@import 'tailwindcss';
@import 'uniwind';

@layer theme {
  :root {
    @variant light {
      --color-background: #ffffff;
      --color-foreground: #0a0a0a;
      --color-primary: #3b82f6;
    }

    @variant dark {
      --color-background: #0a0a0a;
      --color-foreground: #fafafa;
      --color-primary: #60a5fa;
    }
  }
}
```

```tsx
// No ThemeProvider needed!
<View className="bg-background">
  <Text className="text-foreground">Adapts to system theme</Text>
</View>
```

**Switch themes programmatically:**

```typescript
import { Uniwind } from 'uniwind'

Uniwind.setTheme('dark')
```

Reference: [Uniwind Custom Themes](https://docs.uniwind.dev/theming/custom-themes)

### 2.6 Use light-dark() Function for Adaptive Colors

**Impact: HIGH (automatically switches colors based on active theme)**

The CSS `light-dark()` function automatically selects values based on the active color scheme, reducing theme boilerplate.

**Incorrect (duplicating values in each variant):**

```css
@layer theme {
  :root {
    @variant light {
      --color-surface: #ffffff;
      --color-border: #e5e7eb;
    }

    @variant dark {
      --color-surface: #1f2937;
      --color-border: #374151;
    }
  }
}
```

**Correct (using light-dark function):**

```css
@theme {
  --color-surface: light-dark(#ffffff, #1f2937);
  --color-border: light-dark(#e5e7eb, #374151);
  --color-shadow: light-dark(
    rgba(0, 0, 0, 0.1),
    rgba(0, 0, 0, 0.5)
  );
}
```

**When to use light-dark():**
- Simple two-theme setups (light/dark only)
- Reducing CSS duplication
- Inline adaptive values

**When to use @variant blocks:**
- More than two themes
- Complex theme-specific logic
- Different variable sets per theme

Reference: [Uniwind CSS Parser](https://docs.uniwind.dev/api/css)

### 2.7 Use OKLCH Color Space for Perceptual Uniformity

**Impact: HIGH (creates more visually consistent color palettes across themes)**

OKLCH provides perceptually uniform colors. Changing lightness or chroma produces visually consistent results, unlike hex or RGB.

**Incorrect (RGB-based colors with inconsistent contrast):**

```css
@theme {
  --color-primary-light: #60a5fa;  /* Looks okay */
  --color-primary: #3b82f6;        /* Looks darker than expected */
  --color-primary-dark: #2563eb;   /* Jump in perceived darkness */
}
```

**Correct (OKLCH for uniform perception):**

```css
@theme {
  /* OKLCH: lightness (0-100%), chroma, hue */
  --color-primary-light: oklch(75% 0.15 250);
  --color-primary: oklch(60% 0.15 250);
  --color-primary-dark: oklch(45% 0.15 250);

  /* Consistent 15% lightness steps */
}
```

**Benefits of OKLCH:**
- Predictable lightness gradients
- Better accessibility contrast ratios
- Easier to generate color scales programmatically
- More consistent across different displays

**When to use:**
- Building design systems
- Creating accessible color palettes
- Generating hover/active state variations

Reference: [OKLCH Color Picker](https://oklch.com/)

---

## 3. Component Integration

**Impact: HIGH**

withUniwind wrapper, third-party component styling, and className bindings. Incorrect integration causes missing styles, broken props, or unnecessary re-renders.

### 3.1 Define Wrapped Components at Module Level

**Impact: HIGH (prevents wrapper recreation on every render)**

Create wrapped components outside of render functions. Defining inside causes new wrapper creation on every render.

**Incorrect (wrapper created every render):**

```tsx
function MyScreen() {
  // New wrapper created on every render!
  const StyledSlider = withUniwind(ThirdPartySlider)

  return <StyledSlider className="w-full" />
}
```

**Correct (wrapper defined at module level):**

```tsx
// styled.ts
import { withUniwind } from 'uniwind'
import { ThirdPartySlider } from 'some-library'
import { ThirdPartyChart } from 'another-library'

export const StyledSlider = withUniwind(ThirdPartySlider)
export const StyledChart = withUniwind(ThirdPartyChart)
```

```tsx
// MyScreen.tsx
import { StyledSlider, StyledChart } from './styled'

function MyScreen() {
  return (
    <>
      <StyledSlider className="w-full" />
      <StyledChart className="h-64" />
    </>
  )
}
```

**Best practice:** Create a centralized `styled.ts` file for all wrapped components.

Reference: [Uniwind withUniwind API](https://docs.uniwind.dev/api/with-uniwind)

### 3.2 Reanimated Components Work Without withUniwind

**Impact: MEDIUM-HIGH (avoids unnecessary wrapping of animated components)**

React Native Reanimated's components are built on core RN components and support `className` automatically. Don't wrap them with `withUniwind`.

**Incorrect (unnecessary wrapping):**

```tsx
import { withUniwind } from 'uniwind'
import Animated from 'react-native-reanimated'

// Unnecessary - adds overhead without benefit
const AnimatedView = withUniwind(Animated.View)
```

**Correct (use directly):**

```tsx
import Animated from 'react-native-reanimated'

function AnimatedCard() {
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }))

  return (
    <Animated.View
      className="bg-card rounded-xl p-4"
      style={animatedStyle}
    />
  )
}
```

**Components that work without wrapping:**
- `Animated.View`
- `Animated.Text`
- `Animated.Image`
- `Animated.ScrollView`
- Any component created with `Animated.createAnimatedComponent()`

Reference: [Uniwind withUniwind API](https://docs.uniwind.dev/api/with-uniwind)

### 3.3 Use accent-* Classes for Color Prop Extraction

**Impact: HIGH (correctly extracts color values for non-style props)**

When extracting color values for props (not styles), use `accent-*` prefixed classes. Standard `text-*` or `bg-*` classes won't work for value extraction.

**Incorrect (using text-* for color extraction):**

```tsx
const StyledIcon = withUniwind(Icon, {
  color: {
    fromClassName: 'colorClassName',
    styleProperty: 'color',
  },
})

// text-primary doesn't work for color prop extraction
<StyledIcon name="heart" colorClassName="text-primary" />
```

**Correct (using accent-* for extraction):**

```tsx
const StyledIcon = withUniwind(Icon, {
  color: {
    fromClassName: 'colorClassName',
    styleProperty: 'accentColor',  // Note: accentColor, not color
  },
})

// accent-* classes work for value extraction
<StyledIcon name="heart" colorClassName="accent-primary" />
```

**Pattern for SVG components:**

```tsx
export const SvgIcon = withUniwind(BaseSvgIcon, {
  stroke: {
    fromClassName: 'strokeClassName',
    styleProperty: 'accentColor',
  },
  fill: {
    fromClassName: 'fillClassName',
    styleProperty: 'accentColor',
  },
})
```

```tsx
<SvgIcon
  strokeClassName="accent-foreground"
  fillClassName="accent-primary"
/>
```

Reference: [Uniwind withUniwind API](https://docs.uniwind.dev/api/with-uniwind)

### 3.4 Use Custom CSS Classes for Complex Reusable Styles

**Impact: MEDIUM-HIGH (reduces className verbosity for complex component styles)**

Define custom CSS classes for complex, frequently used component styles. Combine them with Tailwind utilities in className.

**Incorrect (verbose repeated utility classes):**

```tsx
// Repeated across many files
<View className="flex-1 bg-card rounded-2xl shadow-lg border border-border p-6 mx-4 my-2">
  <Text className="text-lg font-semibold text-foreground mb-2">Title</Text>
  <Text className="text-sm text-muted leading-relaxed">Content</Text>
</View>
```

**Correct (custom CSS class):**

```css
/* global.css */
.card {
  flex: 1;
  background-color: var(--color-card);
  border-radius: 16px;
  border-width: 1px;
  border-color: var(--color-border);
  padding: 24px;
  margin-horizontal: 16px;
  margin-vertical: 8px;
}

.card-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--color-foreground);
  margin-bottom: 8px;
}
```

```tsx
// Clean, readable component
<View className="card shadow-lg">
  <Text className="card-title">Title</Text>
  <Text className="text-sm text-muted">Content</Text>
</View>
```

**Best practices:**
- Use flat selectors (no nesting)
- Reference theme variables for consistency
- Combine custom classes with utility overrides

Reference: [Uniwind CSS Parser](https://docs.uniwind.dev/api/css)

### 3.5 Use Custom Prop Mappings for Non-Style Props

**Impact: HIGH (enables Tailwind classes for color, width, and other non-style props)**

Some components accept props like `color` or `size` as values, not styles. Use custom mappings to extract specific values from Tailwind classes.

**Incorrect (trying to use className for color prop):**

```tsx
import { Icon } from 'some-icon-library'

// Icon expects color="#3b82f6", not a style object
<Icon name="star" className="text-primary" />
```

**Correct (custom prop mapping):**

```tsx
// styled.ts
import { withUniwind } from 'uniwind'
import { Icon as BaseIcon } from 'some-icon-library'

export const Icon = withUniwind(BaseIcon, {
  color: {
    fromClassName: 'colorClassName',
    styleProperty: 'color',  // Extract color value
  },
  size: {
    fromClassName: 'sizeClassName',
    styleProperty: 'width',  // Extract width value as size
  },
})
```

```tsx
// Now use accent-* classes for color extraction
<Icon
  name="star"
  colorClassName="accent-primary"
  sizeClassName="w-6"
/>
```

**Common mappings:**
- `color` → `colorClassName` with `accent-*` classes
- `strokeColor` / `fillColor` for SVGs
- `size` from width classes

Reference: [Uniwind withUniwind API](https://docs.uniwind.dev/api/with-uniwind)

### 3.6 Use withUniwind for Third-Party Components

**Impact: HIGH (enables className support on components that only accept style props)**

Third-party components that don't natively support `className` need to be wrapped with `withUniwind`.

**Incorrect (className ignored on third-party component):**

```tsx
import { CustomSlider } from 'some-library'

// className prop is ignored, no styles applied
<CustomSlider className="w-full h-12 bg-primary" />
```

**Correct (wrapped with withUniwind):**

```tsx
// styled.ts - define wrappers at module level
import { withUniwind } from 'uniwind'
import { CustomSlider as BaseSlider } from 'some-library'

export const CustomSlider = withUniwind(BaseSlider)
```

```tsx
// Component.tsx
import { CustomSlider } from './styled'

// Now className works!
<CustomSlider className="w-full h-12 bg-primary" />
```

**When NOT needed:**
- React Native core components (View, Text, etc.)
- Components built on View/Text that forward style prop
- Libraries that already support className

Reference: [Uniwind withUniwind API](https://docs.uniwind.dev/api/with-uniwind)

---

## 4. Responsive Design

**Impact: HIGH**

Breakpoints, media queries, and mobile-first patterns. Wrong approaches cause layout breaks across device sizes and inconsistent spacing.

### 4.1 Define Custom Breakpoints with Semantic Names

**Impact: MEDIUM-HIGH (improves code readability and matches design specifications)**

Override default breakpoints or add new ones using the @theme directive. Use meaningful names like `tablet` instead of arbitrary values.

**Incorrect (using arbitrary values inline):**

```tsx
// Hard to understand what 834px means
<View className="flex-col min-[834px]:flex-row" />
```

**Correct (semantic custom breakpoints):**

```css
/* global.css */
@theme {
  /* Override defaults */
  --breakpoint-sm: 640px;
  --breakpoint-md: 768px;
  --breakpoint-lg: 1024px;

  /* Add semantic names */
  --breakpoint-tablet: 768px;
  --breakpoint-desktop: 1024px;
  --breakpoint-ultrawide: 1920px;
}
```

```tsx
<View className="flex-col tablet:flex-row desktop:gap-8">
  {/* Clear intent: tablet and desktop layouts */}
</View>
```

**Naming conventions:**
- `phone` / `tablet` / `desktop` - Device categories
- `compact` / `regular` / `expanded` - iOS size classes
- `portrait` / `landscape` - Orientation (if needed)

Reference: [Uniwind Responsive Breakpoints](https://docs.uniwind.dev/breakpoints)

### 4.2 Design Mobile-First with Progressive Enhancement

**Impact: HIGH (ensures optimal experience on smallest screens first)**

Uniwind uses mobile-first breakpoints. Unprefixed utilities apply to all screens; prefixed utilities apply at that breakpoint and above.

**Incorrect (desktop-first approach):**

```tsx
// Starting with large screen, then overriding for mobile
<View className="flex-row sm:flex-col p-8 sm:p-4">
  {/* Confusing: base is desktop, overrides for mobile */}
</View>
```

**Correct (mobile-first approach):**

```tsx
// Start mobile, enhance for larger screens
<View className="flex-col sm:flex-row p-4 sm:p-6 lg:p-8">
  {/* Clear: mobile base, progressive enhancement */}
</View>
```

**Mobile-first pattern:**

```tsx
<View className="
  flex-col gap-4          // Mobile: stacked, small gap
  sm:flex-row sm:gap-6    // Tablet: row layout, medium gap
  lg:gap-8                // Desktop: larger gap
">
  <View className="w-full sm:w-1/2 lg:w-1/3">
    {/* Responsive width */}
  </View>
</View>
```

**Default breakpoints:**
- `sm:` - 640px and up
- `md:` - 768px and up
- `lg:` - 1024px and up
- `xl:` - 1280px and up

Reference: [Uniwind Responsive Breakpoints](https://docs.uniwind.dev/breakpoints)

### 4.3 Limit Breakpoints to 3-5 for Maintainability

**Impact: HIGH (reduces complexity and testing burden)**

Using too many breakpoints creates complex, hard-to-test layouts. Focus on 3-5 key breakpoints that match your target devices.

**Incorrect (too many breakpoints):**

```tsx
<Text className="
  text-xs
  xs:text-sm
  sm:text-base
  md:text-lg
  lg:text-xl
  xl:text-2xl
  2xl:text-3xl
">
  {/* 7 breakpoints - hard to maintain and test */}
</Text>
```

**Correct (focused breakpoints):**

```tsx
<Text className="
  text-sm           // Mobile phones
  md:text-base      // Tablets
  lg:text-lg        // Desktop/large tablets
">
  {/* 3 breakpoints - clear and testable */}
</Text>
```

**Recommended breakpoint strategy:**

| Breakpoint | Target | Use Case |
|------------|--------|----------|
| (none) | < 640px | Phones |
| `sm:` | 640px+ | Large phones, small tablets |
| `md:` or `lg:` | 768px-1024px | Tablets |
| `xl:` | 1280px+ | Desktop (web) |

Reference: [Uniwind Responsive Breakpoints](https://docs.uniwind.dev/breakpoints)

### 4.4 Scale Spacing and Typography Responsively

**Impact: MEDIUM-HIGH (creates visually balanced layouts across screen sizes)**

Adjust spacing, padding, and font sizes based on screen size. Larger screens need more whitespace to avoid cramped layouts.

**Incorrect (fixed spacing on all screens):**

```tsx
// Same tight spacing on phone and tablet
<View className="p-4 gap-4">
  <Text className="text-lg">Title</Text>
  <Text className="text-sm">Description</Text>
</View>
```

**Correct (responsive scaling):**

```tsx
<View className="
  p-4 gap-4          // Phone: compact
  sm:p-6 sm:gap-6    // Tablet: more breathing room
  lg:p-8 lg:gap-8    // Desktop: generous spacing
">
  <Text className="text-lg sm:text-xl lg:text-2xl">
    Title
  </Text>
  <Text className="text-sm sm:text-base">
    Description
  </Text>
</View>
```

**Spacing scale recommendation:**

| Element | Phone | Tablet | Desktop |
|---------|-------|--------|---------|
| Container padding | p-4 | p-6 | p-8 |
| Card padding | p-3 | p-4 | p-6 |
| Section gap | gap-4 | gap-6 | gap-8 |
| List item gap | gap-2 | gap-3 | gap-4 |

Reference: [Uniwind Responsive Breakpoints](https://docs.uniwind.dev/breakpoints)

### 4.5 Use hidden/flex for Responsive Visibility

**Impact: HIGH (cleanly shows/hides content across breakpoints)**

Toggle element visibility across breakpoints using `hidden` and display utilities. This is cleaner than conditional rendering.

**Incorrect (JavaScript conditional rendering):**

```tsx
function Header() {
  const isDesktop = useMediaQuery('(min-width: 1024px)')

  return (
    <View>
      {isDesktop ? <DesktopNav /> : <MobileMenu />}
    </View>
  )
}
```

**Correct (CSS visibility toggle):**

```tsx
function Header() {
  return (
    <View className="flex-row items-center justify-between">
      {/* Mobile menu - visible on mobile, hidden on desktop */}
      <Pressable className="flex lg:hidden">
        <MenuIcon />
      </Pressable>

      {/* Desktop nav - hidden on mobile, visible on desktop */}
      <View className="hidden lg:flex flex-row gap-4">
        <NavLink>Home</NavLink>
        <NavLink>About</NavLink>
        <NavLink>Contact</NavLink>
      </View>
    </View>
  )
}
```

**Common patterns:**

```tsx
// Show only on mobile
<View className="flex sm:hidden" />

// Show only on tablet and up
<View className="hidden sm:flex" />

// Show only on desktop
<View className="hidden lg:flex" />
```

Reference: [Uniwind Responsive Breakpoints](https://docs.uniwind.dev/breakpoints)

---

## 5. Performance Optimization

**Impact: MEDIUM-HIGH**

Runtime style resolution, dynamic classNames, and render optimization. Impacts FPS, app responsiveness, and memory usage on lower-end devices.

### 5.1 Combine className and style Prop Correctly

**Impact: MEDIUM (ensures both static and dynamic styles apply properly)**

When combining className with style prop (for animations or dynamic values), both apply with style taking precedence for conflicts.

**Incorrect (style overwriting all className styles):**

```tsx
function AnimatedCard({ scale }: { scale: number }) {
  // Trying to pass object directly, won't work as expected
  return (
    <View
      className="bg-card p-4 rounded"
      style={{ transform: `scale(${scale})` }}  // Wrong: string transform
    />
  )
}
```

**Correct (proper style array with Reanimated):**

```tsx
import Animated, { useAnimatedStyle } from 'react-native-reanimated'

function AnimatedCard({ scale }: { scale: SharedValue<number> }) {
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }))

  return (
    <Animated.View
      className="bg-card p-4 rounded"  // Static styles via className
      style={animatedStyle}             // Dynamic styles via style
    />
  )
}
```

**Combining with StyleSheet:**

```tsx
import { useResolveClassNames } from 'uniwind'

function Card() {
  const tailwindStyles = useResolveClassNames('p-4 rounded-lg')
  const customStyles = StyleSheet.create({
    shadow: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.25,
      elevation: 5,
    },
  })

  return (
    <View style={[tailwindStyles, customStyles.shadow]}>
      Content
    </View>
  )
}
```

Reference: [Uniwind useResolveClassNames](https://docs.uniwind.dev/api/use-resolve-class-names)

### 5.2 Memoize Variant Style Objects

**Impact: MEDIUM-HIGH (prevents object recreation on every render)**

When using variant mapping objects, define them outside components or memoize them to prevent recreation on every render.

**Incorrect (object recreated every render):**

```tsx
function Button({ variant, children }: ButtonProps) {
  // New object created on every render
  const variants = {
    primary: 'bg-primary text-primary-foreground',
    secondary: 'bg-secondary text-secondary-foreground',
    destructive: 'bg-destructive text-destructive-foreground',
  }

  return (
    <Pressable className={`px-4 py-2 rounded ${variants[variant]}`}>
      <Text>{children}</Text>
    </Pressable>
  )
}
```

**Correct (object defined outside component):**

```tsx
const buttonVariants = {
  primary: 'bg-primary text-primary-foreground',
  secondary: 'bg-secondary text-secondary-foreground',
  destructive: 'bg-destructive text-destructive-foreground',
} as const

function Button({ variant, children }: ButtonProps) {
  return (
    <Pressable className={`px-4 py-2 rounded ${buttonVariants[variant]}`}>
      <Text>{children}</Text>
    </Pressable>
  )
}
```

**Alternative (useMemo for computed variants):**

```tsx
function Button({ variant, size, disabled, children }: ButtonProps) {
  const className = useMemo(() => {
    const base = 'rounded font-medium'
    const variantStyle = buttonVariants[variant]
    const sizeStyle = sizeVariants[size]
    const disabledStyle = disabled ? 'opacity-50' : ''
    return `${base} ${variantStyle} ${sizeStyle} ${disabledStyle}`
  }, [variant, size, disabled])

  return <Pressable className={className}>...</Pressable>
}
```

### 5.3 Prefer className Over Inline style Prop

**Impact: MEDIUM (enables build-time optimization and consistent design tokens)**

Use className for styling whenever possible. Inline style props bypass build-time optimization and can't use theme variables.

**Incorrect (inline styles):**

```tsx
function Card() {
  return (
    <View
      style={{
        backgroundColor: '#ffffff',
        padding: 16,
        borderRadius: 12,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
      }}
    >
      <Text style={{ fontSize: 18, fontWeight: '600' }}>
        Title
      </Text>
    </View>
  )
}
```

**Correct (className with theme tokens):**

```tsx
function Card() {
  return (
    <View className="bg-card p-4 rounded-xl shadow-md">
      <Text className="text-lg font-semibold">Title</Text>
    </View>
  )
}
```

**When inline styles ARE appropriate:**

```tsx
// Animated values from Reanimated
<Animated.View
  className="bg-card rounded-xl"
  style={animatedStyle}  // useAnimatedStyle result
/>

// Dynamic values from props or calculations
<View
  className="bg-primary"
  style={{ width: calculatedWidth }}
/>
```

**Benefits of className:**
- Theme variable access
- Build-time compilation
- TypeScript autocomplete
- Consistent design tokens

### 5.4 Use Complete Static Class Names for Build-Time Resolution

**Impact: MEDIUM-HIGH (enables build-time compilation, 2.5× faster than runtime resolution)**

Uniwind compiles static class names at build time. Dynamic string construction bypasses the compiler, forcing slower runtime resolution.

**Incorrect (dynamic class construction):**

```tsx
function Badge({ color }: { color: 'red' | 'green' | 'blue' }) {
  // Tailwind compiler can't detect these classes!
  return (
    <View className={`bg-${color}-500 p-2 rounded`}>
      <Text className={`text-${color}-900`}>Badge</Text>
    </View>
  )
}
```

**Correct (complete static class names):**

```tsx
const colorStyles = {
  red: 'bg-red-500 text-red-900',
  green: 'bg-green-500 text-green-900',
  blue: 'bg-blue-500 text-blue-900',
} as const

function Badge({ color }: { color: keyof typeof colorStyles }) {
  return (
    <View className={`${colorStyles[color]} p-2 rounded`}>
      <Text>Badge</Text>
    </View>
  )
}
```

**Why this matters:**
- Uniwind precomputes styles at build time
- Dynamic construction forces runtime parsing
- Build-time resolution is ~2.5× faster (81ms vs 197ms)

**Rule of thumb:** If you can grep for the class name in your source code, it will be compiled.

Reference: [Uniwind Performance](https://uniwind.dev/)

### 5.5 Use tailwind-merge for Class Deduplication

**Impact: MEDIUM (prevents conflicting utilities from both applying)**

Uniwind doesn't automatically deduplicate conflicting utilities. Use `tailwind-merge` to ensure only the last conflicting class applies.

**Incorrect (both classes apply based on CSS specificity):**

```tsx
function Card({ className }: { className?: string }) {
  // Both bg-card AND bg-red-500 may apply!
  return (
    <View className={`bg-card p-4 rounded ${className}`}>
      <Text>Content</Text>
    </View>
  )
}

// Usage - unpredictable which background wins
<Card className="bg-red-500" />
```

**Correct (using tailwind-merge):**

```tsx
import { twMerge } from 'tailwind-merge'

function Card({ className }: { className?: string }) {
  return (
    <View className={twMerge('bg-card p-4 rounded', className)}>
      <Text>Content</Text>
    </View>
  )
}

// Usage - bg-red-500 correctly overrides bg-card
<Card className="bg-red-500" />
```

**When to use tailwind-merge:**
- Components that accept className prop for overrides
- Composing multiple class sources
- Building component libraries

**Performance tip:** twMerge has minimal overhead for typical use cases.

```bash
npm install tailwind-merge
```

Reference: [Uniwind Migration Guide](https://docs.uniwind.dev/migration-from-nativewind)

### 5.6 Use useResolveClassNames Sparingly

**Impact: MEDIUM-HIGH (runtime resolution is slower than build-time compilation)**

The `useResolveClassNames` hook resolves styles at runtime. Use it only when className prop isn't available, as it's slower than build-time compilation.

**Incorrect (using hook for standard components):**

```tsx
function Card() {
  // Unnecessary runtime resolution
  const styles = useResolveClassNames('bg-card rounded-xl p-4')

  return (
    <View style={styles}>
      <Text>Content</Text>
    </View>
  )
}
```

**Correct (use className directly):**

```tsx
function Card() {
  // Build-time compiled, faster
  return (
    <View className="bg-card rounded-xl p-4">
      <Text>Content</Text>
    </View>
  )
}
```

**When useResolveClassNames IS appropriate:**

```tsx
// Library configuration that requires style objects
import { NavigationContainer, DefaultTheme } from '@react-navigation/native'

function App() {
  const cardStyle = useResolveClassNames('bg-card')
  const textStyle = useResolveClassNames('text-foreground')

  const theme = {
    ...DefaultTheme,
    colors: {
      ...DefaultTheme.colors,
      card: cardStyle.backgroundColor,
      text: textStyle.color,
    },
  }

  return <NavigationContainer theme={theme}>...</NavigationContainer>
}
```

Reference: [Uniwind useResolveClassNames](https://docs.uniwind.dev/api/use-resolve-class-names)

---

## 6. Platform Patterns

**Impact: MEDIUM**

iOS/Android selectors, safe area handling, and platform-specific styling. Ensures correct behavior across platforms without conditional code.

### 6.1 Configure Font Families Without Fallbacks

**Impact: MEDIUM (React Native requires exact font file names)**

React Native doesn't support font fallbacks. Specify only the exact font file name, not a stack of fonts.

**Incorrect (web-style font stack):**

```css
@theme {
  --font-family-sans: 'Inter', 'Helvetica', 'Arial', sans-serif;
  /* React Native will fail to find this font! */
}
```

**Correct (exact font file name):**

```css
@theme {
  --font-family-sans: 'Inter-Regular';
  --font-family-sans-medium: 'Inter-Medium';
  --font-family-sans-bold: 'Inter-Bold';
  --font-family-mono: 'FiraCode-Regular';
}
```

**Font weight mapping:**

```css
@theme {
  /* Map Tailwind weights to font files */
  --font-weight-normal: 'Inter-Regular';
  --font-weight-medium: 'Inter-Medium';
  --font-weight-semibold: 'Inter-SemiBold';
  --font-weight-bold: 'Inter-Bold';
}
```

**Usage in components:**

```tsx
// Use font-sans, font-mono etc.
<Text className="font-sans text-base">Regular text</Text>
<Text className="font-sans-medium text-base">Medium weight</Text>
<Text className="font-mono text-sm">Code text</Text>
```

**Loading fonts with Expo:**

```tsx
import { useFonts, Inter_400Regular, Inter_500Medium } from '@expo-google-fonts/inter'

function App() {
  const [fontsLoaded] = useFonts({
    'Inter-Regular': Inter_400Regular,
    'Inter-Medium': Inter_500Medium,
  })

  if (!fontsLoaded) return null
  return <RootNavigator />
}
```

Reference: [Uniwind Migration Guide](https://docs.uniwind.dev/migration-from-nativewind)

### 6.2 Understand Yoga Layout Engine Differences

**Impact: MEDIUM (prevents confusion from web CSS assumptions)**

React Native uses Yoga, not browser CSS. Key differences affect layout behavior and available properties.

**Incorrect (assuming web CSS behavior):**

```tsx
// These web CSS patterns don't work in React Native!
<View className="float-left">      {/* No floats */}
<View className="grid">            {/* No CSS grid (work in progress) */}
<View className="hover:bg-red">    {/* No hover on mobile */}
<Text className="cursor-pointer">  {/* No cursor */}
```

**Correct (understanding Yoga defaults):**

```tsx
// All Views are flexbox by default with flexDirection: 'column'
<View className="flex-1">
  <View className="flex-row">      {/* Explicit row layout */}
    <View className="flex-1" />    {/* Flex children */}
    <View className="flex-1" />
  </View>
</View>
```

**Key Yoga differences:**

| Web CSS | Yoga/React Native |
|---------|-------------------|
| `display: block` (default) | `display: flex` (always) |
| `flex-direction: row` | `flex-direction: column` (default) |
| Styles cascade/inherit | Styles don't inherit |
| `em`/`rem` units | Use Uniwind's rem polyfill |
| CSS Grid | Not supported (in progress) |
| `position: fixed` | Use `absolute` + safe areas |

**Unsupported web features:**
- `float`, `clear`
- Pseudo-elements (`::before`, `::after`)
- `hover:`, `visited:` pseudo-classes

Reference: [Uniwind Supported ClassNames](https://docs.uniwind.dev/class-names)

### 6.3 Use Platform Selectors for iOS/Android Differences

**Impact: MEDIUM (eliminates Platform.select boilerplate in components)**

Use `ios:` and `android:` prefixes to apply platform-specific styles without JavaScript conditionals.

**Incorrect (JavaScript Platform.select):**

```tsx
import { Platform, View, Text } from 'react-native'

function Card() {
  return (
    <View
      style={Platform.select({
        ios: { shadowColor: '#000', shadowOpacity: 0.1 },
        android: { elevation: 4 },
      })}
      className="bg-card rounded-lg p-4"
    >
      <Text>Content</Text>
    </View>
  )
}
```

**Correct (platform selectors):**

```tsx
function Card() {
  return (
    <View className="
      bg-card rounded-lg p-4
      ios:shadow-md
      android:elevation-4
    ">
      <Text>Content</Text>
    </View>
  )
}
```

**Common platform differences:**

```tsx
// Fonts differ by platform
<Text className="ios:font-sf-pro android:font-roboto">
  Platform-specific font
</Text>

// Padding for status bar
<View className="ios:pt-12 android:pt-8">
  Header content
</View>

// Shadows vs elevation
<View className="ios:shadow-lg android:elevation-8">
  Elevated card
</View>
```

Reference: [Uniwind Supported ClassNames](https://docs.uniwind.dev/class-names)

### 6.4 Use react-native-safe-area-context for Safe Areas

**Impact: MEDIUM (correctly handles notches, status bars, and home indicators)**

Uniwind doesn't support `*-safe` utility classes. Use `react-native-safe-area-context` for safe area insets.

**Incorrect (NativeWind safe area classes):**

```tsx
// These classes don't work in Uniwind!
<View className="pt-safe pb-safe">
  Content that avoids notches
</View>
```

**Correct (safe area context):**

```tsx
import { useSafeAreaInsets } from 'react-native-safe-area-context'

function Screen() {
  const insets = useSafeAreaInsets()

  return (
    <View
      className="flex-1 bg-background"
      style={{
        paddingTop: insets.top,
        paddingBottom: insets.bottom,
      }}
    >
      <Text>Safe content</Text>
    </View>
  )
}
```

**Alternative (SafeAreaView component):**

```tsx
import { SafeAreaView } from 'react-native-safe-area-context'

function Screen() {
  return (
    <SafeAreaView className="flex-1 bg-background" edges={['top', 'bottom']}>
      <Text>Safe content</Text>
    </SafeAreaView>
  )
}
```

**App setup required:**

```tsx
import { SafeAreaProvider } from 'react-native-safe-area-context'

function App() {
  return (
    <SafeAreaProvider>
      <RootNavigator />
    </SafeAreaProvider>
  )
}
```

Reference: [react-native-safe-area-context](https://docs.expo.dev/versions/latest/sdk/safe-area-context/)

### 6.5 Use web: Selector for Cross-Platform Apps

**Impact: MEDIUM (enables web-specific styles without affecting native)**

For apps targeting both native and web (Expo Web, React Native Web), use `web:` prefix for web-specific styles.

**Incorrect (web styles applying to native):**

```tsx
// cursor and hover apply to native where they do nothing
<Pressable className="cursor-pointer hover:bg-gray-100">
  Click me
</Pressable>
```

**Correct (platform-specific):**

```tsx
<Pressable className="
  active:bg-gray-100
  web:cursor-pointer
  web:hover:bg-gray-100
">
  Click me
</Pressable>
```

**Common web-specific patterns:**

```tsx
// Web hover effects
<View className="web:hover:scale-105 web:transition-transform">
  Hover to scale on web
</View>

// Web-specific layout
<View className="
  flex-col
  web:flex-row
  web:max-w-4xl
  web:mx-auto
">
  Responsive layout
</View>

// Web cursor states
<Pressable className="web:cursor-pointer web:select-none">
  Interactive element
</Pressable>
```

Reference: [Uniwind Supported ClassNames](https://docs.uniwind.dev/class-names)

---

## 7. State & Interaction

**Impact: MEDIUM**

Pressable states, pseudo-classes, and data selectors for conditional styling. Incorrect patterns cause broken interactive UI and inaccessible components.

### 7.1 Avoid hover: on Native - Use active: Instead

**Impact: MEDIUM (prevents unused styles and reduces bundle size)**

Mobile devices don't have hover states. Use `active:` for touch feedback on native, and `web:hover:` for web targets only.

**Incorrect (hover on native):**

```tsx
// hover: is ignored on iOS/Android
<Pressable className="bg-primary hover:bg-primary/80">
  <Text>Button</Text>
</Pressable>
```

**Correct (platform-appropriate states):**

```tsx
<Pressable className="
  bg-primary
  active:bg-primary/80
  web:hover:bg-primary/80
">
  <Text>Button</Text>
</Pressable>
```

**Complete interactive pattern:**

```tsx
function InteractiveCard() {
  return (
    <Pressable className="
      bg-card rounded-xl p-4
      active:bg-card/90
      active:scale-98
      web:hover:bg-card/95
      web:hover:shadow-lg
      web:cursor-pointer
      focus:ring-2 focus:ring-primary
    ">
      <Text>Interactive content</Text>
    </Pressable>
  )
}
```

**Ignored pseudo-classes on native:**
- `hover:`
- `visited:`
- Web-specific cursor states

Reference: [Uniwind Supported ClassNames](https://docs.uniwind.dev/class-names)

### 7.2 Use dark: Variant for Dark Mode Styles

**Impact: MEDIUM (eliminates 20+ lines of conditional color logic)**

Use the `dark:` prefix for dark mode overrides. Styles automatically apply based on the active theme.

**Incorrect (manual dark mode logic):**

```tsx
function Card() {
  const colorScheme = useColorScheme()
  const isDark = colorScheme === 'dark'

  return (
    <View className={isDark ? 'bg-gray-800' : 'bg-white'}>
      <Text className={isDark ? 'text-white' : 'text-gray-900'}>
        Content
      </Text>
    </View>
  )
}
```

**Correct (dark: variant):**

```tsx
function Card() {
  return (
    <View className="bg-white dark:bg-gray-800">
      <Text className="text-gray-900 dark:text-white">
        Content
      </Text>
    </View>
  )
}
```

**Better (semantic theme variables):**

```tsx
// Using theme variables instead of explicit dark: overrides
function Card() {
  return (
    <View className="bg-card">
      <Text className="text-foreground">
        Content
      </Text>
    </View>
  )
}
```

**When to use dark: vs theme variables:**

| Use `dark:` | Use theme variables |
|-------------|-------------------|
| One-off overrides | Consistent design system |
| Quick prototyping | Production apps |
| Color exceptions | Standard colors |

Reference: [Uniwind Theming](https://docs.uniwind.dev/theming/custom-themes)

### 7.3 Use Data Selectors for Component State Styling

**Impact: MEDIUM (enables conditional styling based on data attributes)**

Use `data-[prop=value]:` syntax to style based on component data attributes. This enables prop-based conditional styling.

**Incorrect (ternary operators in className):**

```tsx
function ListItem({ isSelected, isHighlighted }: Props) {
  return (
    <View className={`
      p-4 rounded-lg
      ${isSelected ? 'bg-primary text-white' : 'bg-card'}
      ${isHighlighted ? 'border-2 border-primary' : ''}
    `}>
      <Text>Item</Text>
    </View>
  )
}
```

**Correct (data selectors):**

```tsx
function ListItem({ isSelected, isHighlighted }: Props) {
  return (
    <View
      data-selected={isSelected}
      data-highlighted={isHighlighted}
      className="
        p-4 rounded-lg bg-card
        data-[selected=true]:bg-primary
        data-[selected=true]:text-white
        data-[highlighted=true]:border-2
        data-[highlighted=true]:border-primary
      "
    >
      <Text>Item</Text>
    </View>
  )
}
```

**Complex state combinations:**

```tsx
function Tab({ isActive, hasNotification }: TabProps) {
  return (
    <Pressable
      data-active={isActive}
      data-notification={hasNotification}
      className="
        px-4 py-2
        data-[active=true]:bg-primary
        data-[active=true]:text-white
        data-[notification=true]:after:content-['•']
      "
    >
      <Text>Tab</Text>
    </Pressable>
  )
}
```

Reference: [Uniwind Supported ClassNames](https://docs.uniwind.dev/class-names)

### 7.4 Use Group Variants for Parent-Child Styling (WIP)

**Impact: LOW-MEDIUM (reduces 10-20 lines of context boilerplate)**

Group variants allow styling children based on parent state. Note: This feature is work in progress in Uniwind.

**Incorrect (no parent-child state coordination):**

```tsx
// Children don't respond to parent press state
<Pressable className="bg-card p-4 rounded">
  <Text className="text-foreground">
    Title doesn't change when card is pressed
  </Text>
  <View className="opacity-100">
    Opacity stays the same
  </View>
</Pressable>
```

**Correct (workaround with context):**

```tsx
function Card({ children }: CardProps) {
  const [isPressed, setIsPressed] = useState(false)

  return (
    <Pressable
      onPressIn={() => setIsPressed(true)}
      onPressOut={() => setIsPressed(false)}
      className="bg-card p-4 rounded"
    >
      <CardContext.Provider value={{ isPressed }}>
        {children}
      </CardContext.Provider>
    </Pressable>
  )
}

function CardTitle() {
  const { isPressed } = useCardContext()
  return (
    <Text className={isPressed ? 'text-primary' : 'text-foreground'}>
      Title changes when card is pressed
    </Text>
  )
}
```

**Future pattern (when group-* is supported):**

```tsx
// This will work when group variants are implemented
<Pressable className="group bg-card p-4 rounded">
  <Text className="text-foreground group-active:text-primary">
    Title changes color when card is pressed
  </Text>
</Pressable>
```

**Status:** Group variants are listed as "Work in Progress" in Uniwind documentation.

Reference: [Uniwind Supported ClassNames](https://docs.uniwind.dev/class-names)

### 7.5 Use Pressable with active:/focus:/disabled: States

**Impact: MEDIUM (eliminates 10-15 lines of manual state management)**

Uniwind supports `active:`, `focus:`, and `disabled:` pseudo-classes on Pressable components for touch feedback.

**Incorrect (manual press state management):**

```tsx
function Button({ onPress }: ButtonProps) {
  const [isPressed, setIsPressed] = useState(false)

  return (
    <Pressable
      onPressIn={() => setIsPressed(true)}
      onPressOut={() => setIsPressed(false)}
      onPress={onPress}
      className={isPressed ? 'bg-primary/80' : 'bg-primary'}
    >
      <Text className="text-white">Press me</Text>
    </Pressable>
  )
}
```

**Correct (pseudo-class states):**

```tsx
function Button({ onPress, disabled }: ButtonProps) {
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled}
      className="
        bg-primary
        active:bg-primary/80
        focus:ring-2 focus:ring-primary/50
        disabled:opacity-50 disabled:bg-gray-400
      "
    >
      <Text className="text-white">Press me</Text>
    </Pressable>
  )
}
```

**Available pseudo-classes:**

| Pseudo-class | Trigger |
|--------------|---------|
| `active:` | While pressed/touched |
| `focus:` | When focused (accessibility) |
| `disabled:` | When disabled prop is true |

**Note:** `hover:` is not supported on native (no mouse). Use `web:hover:` for web targets.

Reference: [Uniwind Supported ClassNames](https://docs.uniwind.dev/class-names)

---

## 8. Migration & Compatibility

**Impact: LOW-MEDIUM**

NativeWind migration, Tailwind 4 syntax, and common pitfalls. Helps teams transition smoothly and avoid breaking changes.

### 8.1 Account for Different rem Default Values

**Impact: LOW-MEDIUM (prevents 14% spacing difference after migration)**

NativeWind uses 14px as rem default, Uniwind uses 16px. Adjust the polyfill if preserving existing spacing.

**Incorrect (ignoring rem difference):**

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  // Using default 16px when app was designed for 14px
})
```

```tsx
// p-4 = 16px in Uniwind, but was 14px in NativeWind
// 14% larger spacing across the entire app!
<View className="p-4 gap-4">
  <Text className="text-base">Spacing is off</Text>
</View>
```

**Correct (matching NativeWind's rem for migration):**

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  polyfills: {
    rem: 14,  // Match NativeWind's default
  },
})
```

```tsx
// Now p-4 = 14px, matching original design
<View className="p-4 gap-4">
  <Text className="text-base">Spacing matches original</Text>
</View>
```

**When to use each:**

| Scenario | rem Value |
|----------|-----------|
| Migrating existing NativeWind app | 14px |
| Design system uses 14px base | 14px |
| New Uniwind project | 16px (default) |
| Web app migration | 16px |

Reference: [Uniwind Migration Guide](https://docs.uniwind.dev/migration-from-nativewind)

### 8.2 Follow NativeWind Migration Checklist

**Impact: LOW-MEDIUM (prevents 5-10 common migration errors)**

Migrating from NativeWind to Uniwind requires several configuration changes. Follow this checklist to avoid issues.

**Incorrect (keeping NativeWind configuration):**

```javascript
// babel.config.js - WRONG: NativeWind preset
module.exports = {
  presets: ['nativewind/babel'],  // Remove this!
}
```

```javascript
// metro.config.js - WRONG: No Uniwind config
const { getDefaultConfig } = require('expo/metro-config')
module.exports = getDefaultConfig(__dirname)  // Missing withUniwindConfig!
```

**Correct (Uniwind configuration):**

```javascript
// babel.config.js - No NativeWind preset needed
module.exports = {
  presets: ['babel-preset-expo'],
}
```

```javascript
// metro.config.js - Uniwind configuration
const { getDefaultConfig } = require('expo/metro-config')
const { withUniwindConfig } = require('uniwind/metro')

const config = getDefaultConfig(__dirname)
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
})
```

**Full migration checklist:**

1. Install: `bun add uniwind tailwindcss && bun remove nativewind`
2. Remove Babel preset from babel.config.js
3. Update Metro config with withUniwindConfig
4. Update CSS: `@import 'tailwindcss'; @import 'uniwind';`
5. Delete nativewind.d.ts
6. Remove ThemeProvider
7. Replace cssInterop with withUniwind
8. Delete tailwind.config.js

Reference: [Uniwind Migration Guide](https://docs.uniwind.dev/migration-from-nativewind)

### 8.3 Replace *-safe Classes with Safe Area Context

**Impact: LOW-MEDIUM (prevents content overlapping notch and home indicator)**

NativeWind's `*-safe` utility classes don't exist in Uniwind. Use `react-native-safe-area-context` instead.

**Incorrect (NativeWind safe area classes):**

```tsx
// These classes don't work in Uniwind!
<View className="pt-safe pb-safe px-4">
  <View className="mt-safe-or-4">
    Content overlaps notch because classes are ignored
  </View>
</View>
```

**Correct (Safe Area Context hook):**

```tsx
import { useSafeAreaInsets } from 'react-native-safe-area-context'

function Screen() {
  const insets = useSafeAreaInsets()

  return (
    <View
      className="px-4"
      style={{
        paddingTop: insets.top,
        paddingBottom: insets.bottom,
      }}
    >
      <View
        className="px-4"
        style={{
          marginTop: Math.max(insets.top, 16),  // safe-or-4 equivalent
        }}
      >
        Content properly avoids notch
      </View>
    </View>
  )
}
```

**Alternative (SafeAreaView component):**

```tsx
import { SafeAreaView } from 'react-native-safe-area-context'

function Screen() {
  return (
    <SafeAreaView className="flex-1 px-4" edges={['top', 'bottom']}>
      Content with safe area padding
    </SafeAreaView>
  )
}
```

Reference: [react-native-safe-area-context](https://docs.expo.dev/versions/latest/sdk/safe-area-context/)

### 8.4 Replace cssInterop with withUniwind

**Impact: LOW-MEDIUM (prevents runtime errors from incompatible API)**

NativeWind uses `cssInterop` for third-party components. Uniwind uses `withUniwind` with a different API.

**Incorrect (NativeWind's cssInterop):**

```tsx
import { cssInterop } from 'nativewind'  // Doesn't exist in Uniwind!
import { LinearGradient } from 'expo-linear-gradient'

cssInterop(LinearGradient, {
  className: 'style',
  contentContainerClassName: 'contentContainerStyle',
})

// Runtime error: cssInterop is not a function
```

**Correct (Uniwind's withUniwind):**

```tsx
import { withUniwind } from 'uniwind'
import { LinearGradient as BaseLinearGradient } from 'expo-linear-gradient'

export const LinearGradient = withUniwind(BaseLinearGradient)

// For custom prop mappings
export const LinearGradientWithProps = withUniwind(BaseLinearGradient, {
  contentContainerStyle: {
    fromClassName: 'contentContainerClassName',
  },
})
```

**Key API differences:**

| NativeWind `cssInterop` | Uniwind `withUniwind` |
|------------------------|---------------------|
| Mutates globally | Returns new component |
| Called once at setup | Define at module level |
| Maps className to style | className works by default |

Reference: [Uniwind withUniwind API](https://docs.uniwind.dev/api/with-uniwind)

### 8.5 Use Tailwind 4 CSS-First Configuration

**Impact: LOW-MEDIUM (enables proper theming and eliminates tailwind.config.js)**

Uniwind requires Tailwind 4 syntax. Configuration moves from JavaScript (tailwind.config.js) to CSS (@theme directive).

**Incorrect (Tailwind 3 JavaScript config):**

```javascript
// tailwind.config.js - DON'T USE THIS
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: '#3b82f6',
        background: '#ffffff',
      },
    },
  },
}
```

**Correct (Tailwind 4 CSS config):**

```css
/* global.css */
@import 'tailwindcss';
@import 'uniwind';

@theme {
  --color-primary: #3b82f6;
  --color-background: #ffffff;
  --color-foreground: #0a0a0a;

  /* Custom spacing */
  --spacing-18: 4.5rem;

  /* Custom breakpoints */
  --breakpoint-tablet: 768px;
}
```

**Key differences:**

| Tailwind 3 | Tailwind 4 |
|------------|------------|
| `tailwind.config.js` | `@theme` in CSS |
| `theme.extend.colors` | `--color-*` variables |
| `theme.extend.spacing` | `--spacing-*` variables |
| `theme.screens` | `--breakpoint-*` variables |
| JavaScript module | Pure CSS |

Reference: [Tailwind CSS v4 Theme](https://tailwindcss.com/docs/theme)

---

## References

1. [https://docs.uniwind.dev](https://docs.uniwind.dev)
2. [https://github.com/uni-stack/uniwind](https://github.com/uni-stack/uniwind)
3. [https://uniwind.dev](https://uniwind.dev)
4. [https://tailwindcss.com/docs/theme](https://tailwindcss.com/docs/theme)
5. [https://docs.expo.dev/versions/latest/sdk/safe-area-context/](https://docs.expo.dev/versions/latest/sdk/safe-area-context/)
6. [https://reactnative.dev](https://reactnative.dev)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |