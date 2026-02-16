---
title: Use Presentation Detents for Contextual Sheet Sizing
impact: HIGH
impactDescription: enables Maps-style bottom sheets, reduces visual disruption
tags: modal, detents, bottom-sheet, presentation, ios16
---

## Use Presentation Detents for Contextual Sheet Sizing

Presentation detents (.medium, .large, .fraction, .height, and custom) control how tall a sheet appears. Using .medium provides a half-height peek that keeps the parent view visible, reducing context switching. Supporting multiple detents gives users control to expand or collapse as needed, matching the Maps-style interaction pattern users already understand. Sheet presentation must be driven by coordinator-owned state so the coordinator remains the single source of truth for what is on screen.

**Incorrect (always using default full-height sheet for short content):**

```swift
struct LocationPickerView: View {
    @State private var showNearby = false

    var body: some View {
        Map(coordinateRegion: $region)
            .onTapGesture { showNearby = true }
            // BAD: Default sheet covers the full screen, completely hiding the map.
            // Users lose spatial context — they can't see the map while browsing
            // the list of nearby places. This forces unnecessary back-and-forth.
            .sheet(isPresented: $showNearby) {
                NearbyPlacesListView(region: region)
            }
    }
}
```

**Correct (coordinator-driven sheet with detents and drag indicator):**

```swift
enum SheetRoute: Identifiable {
    case nearbyPlaces

    var id: String {
        switch self {
        case .nearbyPlaces: "nearbyPlaces"
        }
    }
}

@Observable @MainActor
final class LocationPickerCoordinator {
    var presentedSheet: SheetRoute?
    var selectedDetent: PresentationDetent = .medium

    func presentNearbyPlaces() {
        presentedSheet = .nearbyPlaces
    }
}

@Equatable
struct LocationPickerView: View {
    @Environment(LocationPickerCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator

        Map(coordinateRegion: $region)
            .onTapGesture { coordinator.presentNearbyPlaces() }
            .sheet(item: $coordinator.presentedSheet) { route in
                switch route {
                case .nearbyPlaces:
                    NearbyPlacesListView(region: region)
                        // GOOD: .medium shows a half-height peek so the map stays visible.
                        // Users can drag to .large for the full list when they want detail.
                        // .fraction(0.25) provides a minimal collapsed state showing
                        // just the search bar and top result.
                        .presentationDetents(
                            [.fraction(0.25), .medium, .large],
                            selection: $coordinator.selectedDetent
                        )
                        // GOOD: Drag indicator signals that the sheet is resizable.
                        // Without it, users may not discover the detent behavior.
                        .presentationDragIndicator(.visible)
                        // Keep the map interactive behind the sheet on iOS 16.4+.
                        .presentationBackgroundInteraction(
                            .enabled(upThrough: .medium)
                        )
                }
            }
    }
}
```
