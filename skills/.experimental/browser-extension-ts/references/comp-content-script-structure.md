---
title: Content script structure
impact: HIGH
impactDescription: Proper content script organization ensures safe DOM manipulation and cleanup
tags: patterns, content-scripts, architecture
---

# Content script structure

Organize content scripts with clear initialization, message handling, and cleanup phases. Always handle the extension context invalidation.

## Incorrect

```typescript
// Immediate execution without structure
const theme = document.createElement('style');
document.head.appendChild(theme);

chrome.runtime.onMessage.addListener((msg) => {
    if (msg.type === 'update') {
        theme.textContent = msg.css;
    }
});
```

## Correct

```typescript
// src/inject/index.ts
import { createOrUpdateStyle, removeStyle } from './style-manager';
import type { Message, Theme } from '../definitions';

let isExtensionActive = true;

function onMessage(message: Message): void {
    if (!isExtensionActive) return;

    switch (message.type) {
        case MessageTypeBGtoCS.ADD_CSS_FILTER:
            createOrUpdateStyle(message.data);
            break;
        case MessageTypeBGtoCS.CLEAN_UP:
            cleanup();
            break;
    }
}

function cleanup(): void {
    removeStyle();
    isExtensionActive = false;
}

function init(): void {
    // Check if already injected (multiple injection protection)
    if (document.documentElement.dataset.darkreaderInjected) {
        return;
    }
    document.documentElement.dataset.darkreaderInjected = 'true';

    try {
        chrome.runtime.onMessage.addListener(onMessage);

        // Notify background that content script is ready
        chrome.runtime.sendMessage({
            type: MessageTypeCStoBG.DOCUMENT_CONNECT,
            data: { url: location.href },
        });
    } catch (e) {
        // Extension context invalidated
        cleanup();
    }
}

// Wait for DOM to be ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
} else {
    init();
}
```

## Style Manager Module

```typescript
// src/inject/style-manager.ts
const STYLE_ID = 'dark-reader-style';

let styleElement: HTMLStyleElement | null = null;

export function createOrUpdateStyle(css: string): void {
    if (!styleElement) {
        styleElement = document.createElement('style');
        styleElement.id = STYLE_ID;
        styleElement.type = 'text/css';
        (document.head || document.documentElement).appendChild(styleElement);
    }
    styleElement.textContent = css;
}

export function removeStyle(): void {
    if (styleElement) {
        styleElement.remove();
        styleElement = null;
    }
}
```

## Key Principles

1. **Multiple injection protection**: Check if already injected via data attribute
2. **Cleanup function**: Always have a way to fully remove injected content
3. **Context check**: Guard message handlers against stale extension context
4. **DOM readiness**: Wait for DOM before manipulating it
