---
title: Choose Overlay vs Modal Correctly
impact: LOW
impactDescription: prevents z-index conflicts and ensures correct accessibility announcements
tags: adv, overlay, modal, accessibility, navigation
---

## Choose Overlay vs Modal Correctly

RNE's Overlay component is designed for dialogs and partial-screen content, while React Native's Modal is better for full-screen takeovers. Using Overlay for full-screen content causes z-index conflicts with navigation headers and improper accessibility announcements. Choose the right tool for each interaction pattern.

**Incorrect (using Overlay for full-screen takeover):**

```tsx
import { Overlay } from '@rneui/themed';

// Bad: Overlay for full-screen content causes issues
const FullScreenMenu = ({ visible, onClose }) => (
  <Overlay
    isVisible={visible}
    onBackdropPress={onClose}
    // Full screen overlay fights with navigation z-index
    fullScreen
    overlayStyle={{
      width: '100%',
      height: '100%',
      margin: 0,
      padding: 0,
    }}
  >
    <View style={{ flex: 1 }}>
      <Text>Full screen content</Text>
      {/* Header may appear above this overlay incorrectly */}
    </View>
  </Overlay>
);

// Bad: Modal for small dialog is overkill
const ConfirmDialog = ({ visible, onConfirm, onCancel }) => (
  <Modal visible={visible} animationType="slide">
    <View style={styles.dialogContainer}>
      <Text>Are you sure?</Text>
      <Button title="Yes" onPress={onConfirm} />
      <Button title="No" onPress={onCancel} />
    </View>
  </Modal>
);
```

**Correct (Overlay for dialogs, Modal for full screens):**

```tsx
import { Modal } from 'react-native';
import { Overlay, Button } from '@rneui/themed';

// Good: Overlay for dialogs and partial-screen content
const ConfirmDialog = ({ visible, onConfirm, onCancel }) => (
  <Overlay
    isVisible={visible}
    onBackdropPress={onCancel}
    overlayStyle={{
      width: '80%',
      borderRadius: 12,
      padding: 20,
    }}
    // Proper accessibility for dialogs
    accessibilityViewIsModal
  >
    <Text style={{ marginBottom: 20 }}>Are you sure?</Text>
    <Button title="Confirm" onPress={onConfirm} />
    <Button title="Cancel" type="outline" onPress={onCancel} />
  </Overlay>
);

// Good: Modal for full-screen takeovers
const FullScreenMenu = ({ visible, onClose }) => (
  <Modal
    visible={visible}
    animationType="slide"
    presentationStyle="fullScreen"
    onRequestClose={onClose}
  >
    <SafeAreaView style={{ flex: 1 }}>
      <View style={{ flex: 1 }}>
        <Button title="Close" onPress={onClose} />
        <Text>Full screen content with proper z-index</Text>
      </View>
    </SafeAreaView>
  </Modal>
);
```

Reference: [React Native Elements Overlay](https://reactnativeelements.com/docs/components/overlay)
