---
title: Never cage Dynamic Type text in fixed frames
tags: layout, dynamic-type, truncation, text
---

## Never cage Dynamic Type text in fixed frames

The wrong default is pinning text-bearing views to fixed heights — `.frame(height: 20)` on a label, a hard-coded row height, `lineLimit(1)` on content the user actually needs to read. The layout looks tidy at the default size and clips or truncates the moment a user raises their text size, which is exactly the audience that most needs the words. Let text size itself, allow wrapping, and reserve line limits for genuinely truncatable previews.

**Evidence of violation:** `.frame(height:)` (or a `.frame` fixing both dimensions) applied directly to a `Text` or to a stack whose immediate children include `Text`; or `.lineLimit(1)` on primary content — a title, body copy, or a value the user must read in full — with no adjacent `.minimumScaleFactor`. PASS: text sized intrinsically; `.fixedSize(horizontal: false, vertical: true)` where a container would otherwise compress it; `.lineLimit` on preview or summary text whose truncation is the design (a message-list preview line, a card teaser) — the reviewer must cite that preview role from the surrounding view; absent that evidence, fail closed. N/A: no fixed frames or line limits on text in the target.

**Incorrect (the height cage clips the second line at accessibility sizes):**

```swift
import SwiftUI

struct SeedPacketRow: View {
    let packet: SeedPacket

    var body: some View {
        VStack(alignment: .leading) {
            Text(packet.commonName)
                .font(.headline)
            Text(packet.sowingInstructions)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(height: 18) // ⚠️ clips as soon as Dynamic Type grows
        }
    }
}
```

**Correct (the row grows with the text it holds):**

```swift
import SwiftUI

struct SeedPacketRow: View {
    let packet: SeedPacket

    var body: some View {
        VStack(alignment: .leading) {
            Text(packet.commonName)
                .font(.headline)
            Text(packet.sowingInstructions)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
```

Reference: [Human Interface Guidelines — Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
