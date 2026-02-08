---
title: Replace Destination-Based NavigationLink with Value-Based
impact: HIGH
impactDescription: decouples navigation trigger from destination view, enables deep linking
tags: nav, navigationlink, value, deep-linking, decoupling
---

## Replace Destination-Based NavigationLink with Value-Based

Destination-based NavigationLinks embed the destination view directly inside the link, tightly coupling the trigger to the view it presents. This means each link must know exactly which view to construct, preventing the destination from being defined in a single location and making programmatic or deep-link navigation impossible. Value-based NavigationLinks emit a Hashable value that a separate `.navigationDestination(for:)` modifier resolves, so the destination is defined once and any code path -- user tap, deep link, or push notification -- can navigate by appending the same value.

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
        // Cannot navigate to a song programmatically
        // Destination is duplicated if used elsewhere
    }
}
```

**Correct (value-based link decoupled from destination):**

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
        // Any code path can navigate: path.append(song)
    }
}
```

Reference: [NavigationLink](https://developer.apple.com/documentation/swiftui/navigationlink)
