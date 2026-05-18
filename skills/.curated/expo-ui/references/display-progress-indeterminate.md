---
title: Pass value=undefined to ProgressView for Indeterminate Spinner
impact: MEDIUM-HIGH
impactDescription: enables the system indeterminate spinner — passing 0 shows a frozen-at-zero progress bar
tags: display, progressView, indeterminate, spinner
---

## Pass value=undefined to ProgressView for Indeterminate Spinner

`ProgressView` has two distinct modes: determinate (when `value` is a number 0–1, renders as a progress bar) and indeterminate (when `value` is `undefined`, renders as a system spinner). Passing `0` puts it in determinate mode at 0% — a frozen progress bar that misrepresents "I don't know how long this takes". Use `undefined` for unknown-duration work like network calls or initial data loads.

**Incorrect (value=0 — renders a frozen progress bar, not a spinner):**

```tsx
import { Host, ProgressView, Text } from '@expo/ui/swift-ui';

const [loading, setLoading] = useState(true);

<Host matchContents>
  {loading && (
    <ProgressView value={0}>
      <Text>Loading reservations…</Text>
    </ProgressView>
  )}
</Host>
```

**Correct (no value — system spinner):**

```tsx
import { Host, ProgressView, Text } from '@expo/ui/swift-ui';

const [loading, setLoading] = useState(true);

<Host matchContents>
  {loading && (
    <ProgressView>
      <Text>Loading reservations…</Text>
    </ProgressView>
  )}
</Host>
```

**Alternative (determinate progress when totalBytes is known):**

```tsx
<ProgressView value={uploadedBytes / totalBytes}>
  <Text>Uploading photos — {Math.round((uploadedBytes / totalBytes) * 100)}%</Text>
</ProgressView>
```

Reference: [@expo/ui ProgressView source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/ProgressView/index.tsx)
