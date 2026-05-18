---
title: Use ShareLink for System Share — Not a Custom Sheet
impact: HIGH
impactDescription: enables the full iOS share sheet (AirDrop, system apps, extensions) — custom sheets only show what you wire up
tags: nav, shareLink, share-sheet, ios
---

## Use ShareLink for System Share — Not a Custom Sheet

`ShareLink` opens the iOS system share sheet — the canonical surface for sharing URLs, files, and text. The system populates it with AirDrop targets, installed app extensions, copy-to-clipboard, and AirPlay. Building a custom share sheet with `BottomSheet` and a list of buttons can only cover what you hardcode and misses every third-party share extension the user has installed. Use `ShareLink` whenever the share target is a URL or file the system can dispatch.

**Incorrect (custom share sheet — misses AirDrop, system extensions):**

```tsx
import { Host, BottomSheet, Group, Button, VStack } from '@expo/ui/swift-ui';

<Host matchContents>
  <BottomSheet isPresented={open} onIsPresentedChange={setOpen}>
    <Group>
      <VStack>
        <Button label="Copy link" onPress={() => copyToClipboard(itemUrl)} />
        <Button label="Email" onPress={() => openMail(itemUrl)} />
        <Button label="Message" onPress={() => openMessages(itemUrl)} />
      </VStack>
    </Group>
  </BottomSheet>
</Host>
```

**Correct (ShareLink — full system share sheet, every installed extension):**

```tsx
import { Host, ShareLink } from '@expo/ui/swift-ui';

<Host matchContents>
  <ShareLink
    item="https://app.example.com/listing/abc123"
    subject="Lakeside cottage — 3 nights in June"
    preview={{ title: 'Lakeside cottage', image: 'https://app.example.com/img/abc123.jpg' }}
  />
</Host>
```

**Alternative (async item resolution — resolves the URL only when the user taps share):**

```tsx
<ShareLink
  getItemAsync={async () => api.createShareableLink(listingId)}
  preview={{ title: 'Lakeside cottage', image: thumbnailUrl }}
/>
```

Reference: [@expo/ui ShareLink source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/ShareLink/index.tsx)
