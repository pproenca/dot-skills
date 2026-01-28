---
title: Extension adapter interface pattern
impact: HIGH
impactDescription: Typed interfaces decouple UI from background implementation details
tags: patterns, interfaces, architecture, messaging
---

# Extension adapter interface pattern

Define adapter interfaces for communication between extension contexts. This decouples UI components from background implementation.

## Incorrect

```typescript
// Direct chrome API calls in UI components
function PopupBody(): JSX.Element {
    const handleClick = async () => {
        const tabs = await chrome.tabs.query({ active: true });
        await chrome.storage.local.set({ enabled: true });
        chrome.runtime.sendMessage({ type: 'toggle' });
    };
}

// Untyped message passing
function sendMessage(msg: any): void {
    chrome.runtime.sendMessage(msg);
}
```

## Correct

```typescript
// Define the adapter interface
export interface ExtensionAdapter {
    // Data retrieval
    collect(): Promise<ExtensionData>;
    getActiveTabInfo(): Promise<TabInfo>;

    // Settings
    changeSettings(settings: Partial<UserSettings>): void;
    setTheme(theme: Partial<Theme>): void;

    // Actions
    toggleActiveTab(): void;
    markNewsAsRead(ids: string[]): void;
}

// Implement adapter in background context
function createBackgroundAdapter(): ExtensionAdapter {
    return {
        collect: () => Extension.collect(),
        getActiveTabInfo: () => TabManager.getActiveTabInfo(),
        changeSettings: (settings) => UserStorage.changeSettings(settings),
        setTheme: (theme) => UserStorage.setTheme(theme),
        toggleActiveTab: () => Extension.toggleActiveTab(),
        markNewsAsRead: (ids) => NewsManager.markAsRead(ids),
    };
}

// Use adapter in UI components
interface PopupProps {
    adapter: ExtensionAdapter;
}

function PopupBody({ adapter }: PopupProps): JSX.Element {
    const handleToggle = () => {
        adapter.toggleActiveTab();
    };

    return <Button onClick={handleToggle}>Toggle</Button>;
}
```

## Messenger Pattern for Remote Adapter

```typescript
// In popup (UI context)
function createUIAdapter(): ExtensionAdapter {
    return {
        collect: () => Messenger.sendAndWait(MessageTypeUItoBG.GET_DATA),
        changeSettings: (settings) => Messenger.send({
            type: MessageTypeUItoBG.CHANGE_SETTINGS,
            data: settings,
        }),
        toggleActiveTab: () => Messenger.send({
            type: MessageTypeUItoBG.TOGGLE_ACTIVE_TAB,
        }),
    };
}
```

## Benefits

- **Testability**: UI components can use mock adapters in tests
- **Type safety**: All operations are typed
- **Decoupling**: UI doesn't know about chrome APIs or message passing
- **Flexibility**: Can swap implementation (e.g., for different browsers)
