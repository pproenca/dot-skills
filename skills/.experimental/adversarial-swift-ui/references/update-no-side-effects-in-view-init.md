---
title: Keep view initializers to property assignment only
tags: update, view-init, side-effects, task-modifier
---

## Keep view initializers to property assignment only

The wrong default is treating a view's `init()` as a lifecycle hook — starting a sync, spawning a `Task`, scheduling a timer, or registering for notifications there. View initialization is a high-frequency event decoupled from display: SwiftUI creates new view values constantly to decide whether a body re-evaluation is needed, so any logic in `init()` executes repeatedly. A sibling `TextField` alone makes the parent re-evaluate per keystroke, initializing the child struct — and firing its side effect — for every character typed, stacking redundant tasks that compete with each other.

**Evidence of violation:** a view `init` containing anything beyond assigning parameters to stored properties — a side-effecting method call (`provider.startSync()`), `Task { }`, `Timer.scheduledTimer`, `NotificationCenter` registration, a fetch or decode call — or a stored property default value whose expression performs such a call rather than plainly constructing the value. PASS: memberwise or assignment-only initializers, with the work moved to `.task` or `.task(id:)`, which ties it to the view's presence in the hierarchy rather than the struct's lifecycle. N/A: the view declares no custom `init` and no side-effecting property defaults.

**Incorrect (a new sync starts on every parent re-evaluation — here, every keystroke):**

```swift
import SwiftUI

struct FieldTripView: View {
    @State private var notes = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                WeatherView()
                
                // ... field trip subviews ...
                
                TextField("Field notes...", text: $notes)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()
        }
    }
}

struct WeatherView: View {
    @State private var provider = WeatherProvider()
    
    init() {
        // ⚠️ Called repeatedly when parent view updates
        provider.startSync()
    }
    
    var body: some View {
        Text("Current weather: \(provider.temperature)")
    }
}

@Observable
class WeatherProvider {
    var temperature: String = "Loading..."
    
    func startSync() {
        Task {
            // ... current weather loading ...
        }
    }
}
```

**Correct (work runs once per lifetime in the hierarchy, tied to the id, and is cancellable):**

```swift
import SwiftUI

struct SpeciesDetailView: View {
    let speciesID: UUID
    @State private var speciesInfo: SpeciesProfile?

    var body: some View {
        ScrollView {
            if let speciesInfo {
                SpeciesProfileView(profile: speciesInfo)
            } else {
                ProgressView()
            }
        }
        .task(id: speciesID) {
            if speciesInfo?.id != speciesID {
                speciesInfo = await ConservationRegistry.fetchProfile(for: speciesID)
            }
        }
    }
}

// Supporting types stubbed so the example compiles standalone.
struct SpeciesProfile: Identifiable {
    var id: UUID
    var summary: String
}

struct SpeciesProfileView: View {
    let profile: SpeciesProfile

    var body: some View {
        Text(profile.summary)
    }
}

enum ConservationRegistry {
    static func fetchProfile(for id: UUID) async -> SpeciesProfile {
        SpeciesProfile(id: id, summary: "")
    }
}
```
