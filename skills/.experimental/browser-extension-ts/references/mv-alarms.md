---
title: Alarms for scheduled tasks
impact: CRITICAL
impactDescription: setTimeout/setInterval don't survive service worker termination
tags: manifest-v3, alarms, scheduling
---

# Alarms for scheduled tasks

Use `chrome.alarms` API instead of `setTimeout`/`setInterval` for scheduled tasks. Service workers are terminated after ~5 minutes of inactivity, killing any pending timers.

## Incorrect

```typescript
// These timers are lost when service worker terminates
setTimeout(() => {
    checkForUpdates();
}, 60000);

setInterval(() => {
    syncSettings();
}, 300000);

// Recursive timeout pattern also fails
function scheduleNext(): void {
    setTimeout(() => {
        doWork();
        scheduleNext();
    }, 60000);
}
```

## Correct

```typescript
// manifest.json
{
    "permissions": ["alarms"
}

// Create alarms during installation
chrome.runtime.onInstalled.addListener(() => {
    // One-time alarm (minimum 1 minute in production)
    chrome.alarms.create('initial-setup', {
        delayInMinutes: 1,
    });

    // Recurring alarm
    chrome.alarms.create('sync-settings', {
        periodInMinutes: 5,
    });

    // Alarm at specific time
    chrome.alarms.create('auto-enable', {
        when: getNextSunset(),  // timestamp in ms
    });
});

// Handle all alarms in one listener
chrome.alarms.onAlarm.addListener((alarm) => {
    switch (alarm.name) {
        case 'initial-setup':
            handleInitialSetup();
            break;
        case 'sync-settings':
            syncSettings();
            break;
        case 'auto-enable':
            enableDarkMode();
            rescheduleAutoEnable();
            break;
    }
});

// Reschedule dynamic alarms
async function rescheduleAutoEnable(): Promise<void> {
    const settings = await Extension.getSettings();
    const nextTime = calculateNextActivation(settings.automation);

    await chrome.alarms.clear('auto-enable');
    chrome.alarms.create('auto-enable', { when: nextTime });
}
```

## Alarm Management

```typescript
// Check if alarm exists before creating
async function ensureAlarm(name: string, options: chrome.alarms.AlarmCreateInfo): Promise<void> {
    const existing = await chrome.alarms.get(name);
    if (!existing) {
        chrome.alarms.create(name, options);
    }
}

// Clear all extension alarms on disable
async function clearAllAlarms(): Promise<void> {
    await chrome.alarms.clearAll();
}

// Get alarm info for debugging
async function debugAlarms(): Promise<void> {
    const alarms = await chrome.alarms.getAll();
    alarms.forEach((alarm) => {
        console.log(`Alarm "${alarm.name}": next at ${new Date(alarm.scheduledTime)}`);
    });
}
```

## Short Delays Pattern

For delays under 1 minute, you can still use `setTimeout` but must handle service worker wake-up:

```typescript
// For short delays within active operations
function debounce<T extends (...args: unknown[]) => void>(
    fn: T,
    delay: number
): T {
    let timeoutId: ReturnType<typeof setTimeout>;

    return ((...args: Parameters<T>) => {
        clearTimeout(timeoutId);
        timeoutId = setTimeout(() => fn(...args), delay);
    }) as T;
}

// But persist the intent for critical short delays
async function scheduleShortDelay(action: string, delayMs: number): Promise<void> {
    const runAt = Date.now() + delayMs;
    await chrome.storage.session.set({ pendingAction: { action, runAt } });

    // Service worker may die here, but on wake-up:
    setTimeout(() => executePendingAction(), delayMs);
}

// Check for pending actions on wake-up
chrome.runtime.onStartup.addListener(async () => {
    const { pendingAction } = await chrome.storage.session.get('pendingAction');
    if (pendingAction && Date.now() >= pendingAction.runAt) {
        await executePendingAction();
    }
});
```

## Why This Matters

- **Reliability**: Alarms persist across service worker restarts
- **Battery efficiency**: Chrome batches alarms to minimize wake-ups
- **Minimum interval**: 1 minute in production, 30 seconds for development
- **No drift**: Alarms don't accumulate timing errors like setInterval
