---
title: Replace Destination-Based NavigationLink with Coordinator Route
impact: HIGH
impactDescription: decouples navigation trigger from destination, enables deep linking and testability
tags: nav, navigationlink, coordinator, value, deep-linking
---

## Replace Destination-Based NavigationLink with Coordinator Route

Destination-based NavigationLinks embed the destination view directly, tightly coupling trigger to presentation. Value-based links emit a Hashable value, but the destination should be resolved at the coordinator's NavigationStack root — not on the child view. Views request navigation through the coordinator; the coordinator maps routes to views in a single location.

**Incorrect (destination view coupled directly to the link):**

```swift
struct PlaylistView: View {
    let songs: [Song]

    var body: some View {
        List(songs) { song in
            NavigationLink(destination: SongDetailView(song: song)) {
                SongRow(song: song)
            }
        }
        .navigationTitle("Playlist")
    }
}
```

**Also incorrect (value-based link but destination on child view):**

```swift
struct PlaylistView: View {
    let songs: [Song]

    var body: some View {
        List(songs) { song in
            NavigationLink(value: song) {
                SongRow(song: song)
            }
        }
        .navigationTitle("Playlist")
        .navigationDestination(for: Song.self) { song in
            SongDetailView(song: song)
        }
        // Destination registered on child — will duplicate if this view appears
        // in multiple navigation contexts
    }
}
```

**Correct (coordinator owns routing, destinations at stack root):**

```swift
enum MusicRoute: Hashable {
    case song(Song)
    case album(Album)
}

@Observable
final class MusicCoordinator {
    var path = NavigationPath()

    func navigate(to route: MusicRoute) {
        path.append(route)
    }
}

struct MusicFlowView: View {
    @State private var coordinator = MusicCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            PlaylistView()
                .navigationDestination(for: MusicRoute.self) { route in
                    switch route {
                    case .song(let song):
                        SongDetailView(song: song)
                    case .album(let album):
                        AlbumDetailView(album: album)
                    }
                }
        }
        .environment(coordinator)
    }
}

struct PlaylistView: View {
    @Environment(MusicCoordinator.self) private var coordinator
    let songs: [Song]

    var body: some View {
        List(songs) { song in
            Button { coordinator.navigate(to: .song(song)) } label: {
                SongRow(song: song)
            }
        }
        .navigationTitle("Playlist")
    }
}
```

Reference: [Advanced iOS App Architecture (4th Ed.)](https://www.kodeco.com/books/advanced-ios-app-architecture)
