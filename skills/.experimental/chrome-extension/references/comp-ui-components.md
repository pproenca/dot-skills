---
title: UI component patterns
impact: HIGH
impactDescription: Consistent component structure improves maintainability of extension UI
tags: patterns, ui, components
---

# UI component patterns

Structure UI components with explicit props interface, typed state, and consistent export patterns.

## Component File Structure

```typescript
// src/ui/controls/slider/index.tsx
import { useState, useRef } from 'preact/hooks';

interface SliderProps {
    value: number;
    min: number;
    max: number;
    step?: number;
    class?: string;
    onChange: (value: number) => void;
}

interface SliderState {
    isActive: boolean;
    displayValue: number;
}

export default function Slider(props: SliderProps): JSX.Element {
    const { value, min, max, step = 1, onChange } = props;
    const [state, setState] = useState<SliderState>({
        isActive: false,
        displayValue: value,
    });
    const trackRef = useRef<HTMLDivElement>(null);

    const handlePointerDown = (e: PointerEvent): void => {
        setState((prev) => ({ ...prev, isActive: true }));
        // Handle interaction
    };

    const percentage = ((value - min) / (max - min)) * 100;

    return (
        <div
            class={`slider ${props.class || ''}`}
            ref={trackRef}
            onPointerDown={handlePointerDown}
        >
            <div class="slider__track">
                <div
                    class="slider__fill"
                    style={{ width: `${percentage}%` }}
                />
                <div
                    class="slider__thumb"
                    style={{ left: `${percentage}%` }}
                />
            </div>
        </div>
    );
}
```

## Component Organization

```
src/ui/
├── controls/              # Reusable UI controls
│   ├── button/
│   │   └── index.tsx
│   ├── slider/
│   │   └── index.tsx
│   └── checkbox/
│       └── index.tsx
├── popup/
│   ├── index.tsx         # Popup entry point
│   ├── body/
│   │   └── index.tsx
│   └── components/
│       ├── header/
│       └── settings-list/
└── options/
    └── index.tsx
```

## Props Interface Pattern

```typescript
// Common attribute props pattern
interface ButtonProps {
    class?: string;
    disabled?: boolean;
    onClick?: () => void;
}

// With children
interface ContainerProps {
    class?: string;
    children: ComponentChildren;
}

// Required vs optional
interface SettingsProps {
    settings: UserSettings;        // Required
    theme?: Theme;                 // Optional
    onSettingsChange: (s: Partial<UserSettings>) => void;
}
```

## State Interface Pattern

```typescript
interface BodyState {
    activeTab: string;
    isNewsOpen: boolean;
    didNewsSlideIn: boolean;
}

// Initialize with all properties
const [state, setState] = useState<BodyState>({
    activeTab: 'filter',
    isNewsOpen: false,
    didNewsSlideIn: false,
});

// Update specific properties
setState((prev) => ({
    ...prev,
    isNewsOpen: true,
}));
```
