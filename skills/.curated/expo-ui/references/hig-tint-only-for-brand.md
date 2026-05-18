---
title: Reserve tint Modifier for Brand Surfaces — Keep Semantic System Colors
impact: CRITICAL
impactDescription: preserves the system's destructive-red and accessibility colour contracts
tags: hig, tint, color, accessibility, semantic
---

## Reserve tint Modifier for Brand Surfaces — Keep Semantic System Colors

System colors (red for destructive, green for affirmative) carry semantic meaning users have learned: red = stop, dangerous, irreversible. Overriding `.tint()` to a brand red repurposes that signal for non-destructive actions and confuses users — particularly those using Increase Contrast or VoiceOver where colour is a primary cue. Apply brand tint only on neutral surfaces (a primary CTA, an accent indicator), never on a destructive control.

**Incorrect (brand-red tint on a non-destructive button — collides with destructive semantics):**

```tsx
import { Host, Button } from '@expo/ui/swift-ui';
import { tint } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <Button label="Subscribe" onPress={subscribe} modifiers={[tint('#E53935')]} />
</Host>
```

**Correct (brand tint on a primary CTA — neutral semantic):**

```tsx
import { Host, Button } from '@expo/ui/swift-ui';
import { tint, buttonStyle, controlSize } from '@expo/ui/swift-ui/modifiers';

<Host matchContents>
  <Button
    label="Subscribe"
    onPress={subscribe}
    modifiers={[tint('#0A84FF'), buttonStyle('borderedProminent'), controlSize('large')]}
  />
</Host>
```

**Alternative (destructive action uses the role — no tint needed):**

```tsx
<Button role="destructive" label="Delete subscription" onPress={cancel} />
```

**When NOT to use this pattern:**

- Recording indicators, urgent alerts, and other contexts where red is the *correct* semantic. Use the system red color rather than a custom hex.

Reference: [Color | HIG](https://developer.apple.com/design/human-interface-guidelines/color)
