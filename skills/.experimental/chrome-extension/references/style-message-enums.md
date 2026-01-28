---
title: Message type enum naming
impact: HIGH
impactDescription: Directional message naming prevents confusion in cross-context communication
tags: naming, enums, messaging, browser-extension
---

# Message type enum naming

Name message type enums with direction indicator `MessageType[Source]to[Target]` and use kebab-case values with direction prefix.

## Context Abbreviations

| Abbreviation | Context |
|--------------|---------|
| `BG` | Background / Service Worker |
| `CS` | Content Script |
| `UI` | Popup / Options UI |
| `SW` | Service Worker (MV3) |

## Incorrect

```typescript
enum Messages {
    getData = 'getData',
    setTheme = 'setTheme',
}

enum MESSAGE_TYPE {
    GET_DATA = 'GET_DATA',
    SET_THEME = 'SET_THEME',
}
```

## Correct

```typescript
// Messages from UI to Background
enum MessageTypeUItoBG {
    GET_DATA = 'ui-bg-get-data',
    CHANGE_SETTINGS = 'ui-bg-change-settings',
    SET_THEME = 'ui-bg-set-theme',
    TOGGLE_ACTIVE_TAB = 'ui-bg-toggle-active-tab',
}

// Messages from Background to Content Script
enum MessageTypeBGtoCS {
    ADD_CSS_FILTER = 'bg-cs-add-css-filter',
    ADD_STATIC_THEME = 'bg-cs-add-static-theme',
    ADD_DYNAMIC_THEME = 'bg-cs-add-dynamic-theme',
    CLEAN_UP = 'bg-cs-clean-up',
}

// Messages from Content Script to Background
enum MessageTypeCStoBG {
    DOCUMENT_CONNECT = 'cs-bg-document-connect',
    DOCUMENT_READY = 'cs-bg-document-ready',
    FETCH = 'cs-bg-fetch',
}
```

## Usage Pattern

```typescript
interface Message {
    type: MessageTypeUItoBG | MessageTypeBGtoCS | MessageTypeCStoBG;
    data?: unknown;
}

function onMessage(message: Message): void {
    switch (message.type) {
        case MessageTypeUItoBG.GET_DATA:
            return handleGetData();
        case MessageTypeUItoBG.CHANGE_SETTINGS:
            return handleChangeSettings(message.data);
    }
}
```

## Why This Matters

- **Debugging**: Message type immediately tells you direction of communication
- **Type safety**: Each context only handles messages intended for it
- **Log clarity**: `bg-cs-add-theme` in logs is unambiguous
- **Prevents bugs**: Can't accidentally send wrong message to wrong context
