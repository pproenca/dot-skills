---
title: CSS class patterns
impact: MEDIUM
impactDescription: BEM-inspired naming creates predictable, maintainable CSS
tags: patterns, css, styling, bem
---

# CSS class patterns

Use BEM-inspired class naming with double underscores for elements and double dashes for modifiers.

## BEM Convention

| Type | Separator | Example |
|------|-----------|---------|
| Block | - | `slider`, `settings-list` |
| Element | `__` | `slider__track`, `slider__thumb` |
| Modifier | `--` | `slider--active`, `button--primary` |

## Incorrect

```tsx
// CamelCase classes
<div class="sliderTrack sliderTrackActive">

// Inconsistent separators
<div class="slider_track slider-active">

// String concatenation for conditionals
<button class={`button ${isActive ? 'button-active' : ''}`}>
```

## Correct

```tsx
// BEM naming
<div class="slider">
    <div class="slider__track">
        <div class="slider__fill" />
        <div class="slider__thumb" />
    </div>
</div>

// Conditional classes with object syntax
<button class={{
    'button': true,
    'button--primary': isPrimary,
    'button--disabled': isDisabled,
}}>

// Element with modifier
<div class={{
    'slider__track': true,
    'slider__track--active': isActive,
}}>
```

## CSS Structure

```css
/* Block */
.slider {
    position: relative;
    width: 100%;
}

/* Element */
.slider__track {
    height: 4px;
    background: var(--color-track);
}

.slider__thumb {
    width: 16px;
    height: 16px;
    border-radius: 50%;
}

/* Modifier */
.slider--disabled {
    opacity: 0.5;
    pointer-events: none;
}

.slider__thumb--active {
    transform: scale(1.2);
}
```

## Class Merge Utility

```typescript
// Utility to merge base class with additional classes
function mergeClass(base: string, additional?: string): string {
    return additional ? `${base} ${additional}` : base;
}

// Usage
function Button(props: ButtonProps): JSX.Element {
    const cls = mergeClass('button', props.class);
    return <button class={cls}>{props.children}</button>;
}
```

## Why This Matters

- **Predictability**: Class names follow a pattern you can rely on
- **Specificity**: BEM keeps specificity flat (single class selectors)
- **Scoping**: Element classes are visually scoped to their block
- **Searchability**: Easy to find all related styles
