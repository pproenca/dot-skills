---
title: Keep view initializers to property assignment only
tags: update, view-init, side-effects, task-modifier
---

## Keep view initializers to property assignment only

The wrong default is treating a view's `init()` as a lifecycle hook — starting a sync, spawning a `Task`, scheduling a timer, or registering for notifications there. View initialization is a high-frequency event decoupled from display: SwiftUI creates new view values constantly to decide whether a body re-evaluation is needed, so any logic in `init()` executes repeatedly. A sibling `TextField` alone makes the parent re-evaluate per keystroke, creating a new redundant task for every character typed.

**Evidence of violation:** a view `init` containing anything beyond assigning parameters to stored properties — a side-effecting method call (`provider.startSync()`), `Task { }`, `Timer.scheduledTimer`, `NotificationCenter` registration, or a fetch/decode call. PASS: memberwise or assignment-only initializers, with the work moved to `.task` or `.task(id:)`, which ties it to the view's presence in the hierarchy rather than the struct's lifecycle. N/A: the view declares no custom `init`.

**Incorrect (a new sync starts on every parent re-evaluation):**

```swift
import SwiftUI

@Observable
final class WeatherProvider {
    var temperature = "Loading..."
    func startSync() { /* spawns a network task */ }
}

struct SummitWeatherView: View {
    @State private var provider = WeatherProvider()

    init() {
        provider.startSync()
    }

    var body: some View {
        Text("Current: \(provider.temperature)")
    }
}
```

**Correct (work runs once per lifetime in the hierarchy, and is cancellable):**

```swift
import SwiftUI

@Observable
final class WeatherProvider {
    var temperature = "Loading..."
    func sync() async { /* awaits the network */ }
}

struct SummitWeatherView: View {
    @State private var provider = WeatherProvider()

    var body: some View {
        Text("Current: \(provider.temperature)")
            .task {
                await provider.sync()
            }
    }
}
```

Reference: *The SwiftUI Way* (Natalia Panferova, Nil Coalescing, 2026), “Minimizing view initialization costs”.
