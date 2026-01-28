---
title: Type and interface naming
impact: HIGH
impactDescription: Consistent type naming improves TypeScript code readability
tags: naming, typescript, types
---

# Type and interface naming

Use PascalCase for types and interfaces without prefixes. Use descriptive suffixes for common patterns.

## Naming Patterns

| Pattern | Suffix | Example |
|---------|--------|---------|
| Component props | `Props` | `ButtonProps`, `SliderProps` |
| Component state | `State` | `BodyState`, `PopupState` |
| Configuration | `Config` | `ThemeConfig`, `FilterConfig` |
| Settings | `Settings` | `UserSettings`, `ExtensionSettings` |
| Data structures | - | `ExtensionData`, `TabInfo` |
| Union types | - | `AutomationState`, `MessageType` |

## Incorrect

```typescript
// Hungarian notation prefixes
interface IUserSettings { }
type TAutomationState = 'on' | 'off';

// Lowercase types
type automationState = 'on' | 'off';

// Inconsistent suffixes
interface UserSettingsInterface { }
interface userSettingsType { }
```

## Correct

```typescript
interface UserSettings {
    enabled: boolean;
    theme: Theme;
    automation: AutomationState;
}

interface ExtensionData {
    isEnabled: boolean;
    settings: UserSettings;
}

interface SliderProps {
    value: number;
    min: number;
    max: number;
    onChange: (value: number) => void;
}

interface BodyState {
    activeTab: string;
    newsOpen: boolean;
}

type AutomationState = 'turn-on' | 'turn-off' | 'scheme-dark' | 'scheme-light' | '';
```

## Why This Matters

- **Consistency**: Same conventions across the codebase
- **No noise**: No unnecessary prefixes like `I` or `T`
- **Semantic**: Suffixes indicate purpose (Props, State, Config)
