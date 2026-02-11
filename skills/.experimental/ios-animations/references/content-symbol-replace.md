---
title: Animate Symbol Replacement with contentTransition
impact: MEDIUM
impactDescription: smooth symbol morph communicates state change; instant swap looks like a rendering glitch
tags: content, symbolEffect, replace, contentTransition, sfSymbols
---

## Animate Symbol Replacement with contentTransition

When an SF Symbol toggles between two states — play/pause, heart/heart.fill, bookmark/bookmark.fill — the transition between them should feel like a morph, not a swap. Without a content transition, the symbol simply pops from one to the other, which at best looks unpolished and at worst looks like a rendering glitch. `.contentTransition(.symbolEffect(.replace))` tells SwiftUI to animate the replacement with a smooth crossfade or directional morph that maintains the spatial position of the symbol.

This works because SF Symbols are vector-based and SwiftUI can interpolate between their paths. The `.replace` effect has directional variants — `.downUp`, `.offUp`, `.upUp` — that control the direction the old symbol exits and the new symbol enters.

**Incorrect (conditional symbol name with no transition — icon pops):**

```swift
struct PlaybackButton: View {
    @State private var isPlaying = false

    var body: some View {
        Button {
            isPlaying.toggle()
        } label: {
            // The symbol name changes but there is no transition.
            // The icon pops from play to pause instantly, looking
            // like a broken state change rather than a smooth toggle.
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.title)
                .foregroundStyle(.primary)
                .frame(width: 60, height: 60)
                .background(.ultraThinMaterial, in: Circle())
        }
    }
}
```

**Correct (.symbolEffect(.replace) morphs between symbols):**

```swift
struct PlaybackButton: View {
    @State private var isPlaying = false

    var body: some View {
        Button {
            withAnimation {
                isPlaying.toggle()
            }
        } label: {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.title)
                .foregroundStyle(.primary)
                // Smoothly morphs from play to pause and back.
                // The symbol cross-fades in place, maintaining spatial stability.
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 60, height: 60)
                .background(.ultraThinMaterial, in: Circle())
        }
    }
}
```

**Directional variants for contextual meaning:**

```swift
struct VolumeControl: View {
    @State private var isMuted = false

    var body: some View {
        Button {
            withAnimation {
                isMuted.toggle()
            }
        } label: {
            // .downUp: old symbol exits downward, new enters from above
            // Gives a "pushing down" feel appropriate for muting
            Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                .font(.title2)
                .contentTransition(.symbolEffect(.replace.downUp))
                .frame(width: 44, height: 44)
        }
    }
}

struct BookmarkToggle: View {
    @State private var isBookmarked = false

    var body: some View {
        Button {
            withAnimation {
                isBookmarked.toggle()
            }
        } label: {
            // .offUp: old symbol fades out, new slides up from below
            // Natural "adding" gesture for bookmarking
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                .font(.title3)
                .foregroundStyle(isBookmarked ? .yellow : .secondary)
                .contentTransition(.symbolEffect(.replace.offUp))
                .frame(width: 44, height: 44)
        }
    }
}
```

**Complete toolbar example with multiple toggling symbols:**

```swift
struct MediaToolbar: View {
    @State private var isPlaying = false
    @State private var isFavorite = false
    @State private var repeatMode: RepeatMode = .off

    var body: some View {
        HStack(spacing: 32) {
            Button {
                withAnimation {
                    repeatMode = repeatMode.next
                }
            } label: {
                Image(systemName: repeatMode.symbolName)
                    .foregroundStyle(repeatMode == .off ? .secondary : .primary)
                    .contentTransition(.symbolEffect(.replace))
            }

            Button {
                withAnimation {
                    isPlaying.toggle()
                }
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.title)
                    .contentTransition(.symbolEffect(.replace))
            }

            Button {
                withAnimation {
                    isFavorite.toggle()
                }
            } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(isFavorite ? .red : .secondary)
                    .contentTransition(.symbolEffect(.replace.downUp))
            }
        }
        .font(.title3)
        .padding()
    }
}

enum RepeatMode: CaseIterable {
    case off, all, one

    var symbolName: String {
        switch self {
        case .off: return "repeat"
        case .all: return "repeat"
        case .one: return "repeat.1"
        }
    }

    var next: RepeatMode {
        let all = RepeatMode.allCases
        let idx = all.firstIndex(of: self)!
        return all[(idx + 1) % all.count]
    }
}
```

**Replace direction variants:**

| Variant | Old symbol | New symbol | Best for |
|---------|-----------|------------|----------|
| `.replace` (default) | Fades out | Fades in | General toggles |
| `.replace.downUp` | Exits downward | Enters from above | Mute, disable, decrease |
| `.replace.upUp` | Exits upward | Enters from below | Enable, increase, level up |
| `.replace.offUp` | Fades out | Slides up | Add, bookmark, favorite |

**Note:** `.contentTransition(.symbolEffect(.replace))` requires the `Image` to use SF Symbols. It will not animate between custom image assets — use standard `.transition` for those.

Reference: [WWDC 2023 — Animate symbols in your app](https://developer.apple.com/wwdc23/10197)
