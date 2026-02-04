---
title: Use Gesture Handler for Complex Touch Interactions
impact: MEDIUM
impactDescription: enables swipe, pinch, and pan gestures
tags: ux, gestures, touch, interactions
---

## Use Gesture Handler for Complex Touch Interactions

Use `react-native-gesture-handler` for smooth, native-driven gestures like swipe-to-delete, pinch-to-zoom, and dragging.

**Incorrect (basic touch handling):**

```typescript
// onTouchStart/onTouchMove - jittery and limited
<View
  onTouchStart={handleStart}
  onTouchMove={handleMove}
  onTouchEnd={handleEnd}
/>
```

**Correct (Gesture Handler for swipe-to-delete):**

```typescript
import { GestureHandlerRootView, Swipeable } from 'react-native-gesture-handler';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import Animated from 'react-native-reanimated';

function SwipeableRow({ item, onDelete }: { item: Item; onDelete: () => void }) {
  const renderRightActions = () => (
    <Pressable style={styles.deleteButton} onPress={onDelete}>
      <Text style={styles.deleteText}>Delete</Text>
    </Pressable>
  );

  return (
    <Swipeable renderRightActions={renderRightActions} rightThreshold={40}>
      <View style={styles.row}>
        <Text>{item.title}</Text>
      </View>
    </Swipeable>
  );
}

export default function ListScreen() {
  const [items, setItems] = useState<Item[]>([]);

  const handleDelete = (id: string) => {
    setItems(items.filter(item => item.id !== id));
  };

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <FlashList
        data={items}
        renderItem={({ item }) => (
          <SwipeableRow item={item} onDelete={() => handleDelete(item.id)} />
        )}
        estimatedItemSize={60}
      />
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  row: { padding: 16, backgroundColor: '#fff', borderBottomWidth: 1, borderBottomColor: '#eee' },
  deleteButton: { backgroundColor: 'red', justifyContent: 'center', paddingHorizontal: 20 },
  deleteText: { color: '#fff', fontWeight: '600' },
});
```

**Note:** Wrap your root component with `GestureHandlerRootView` for gestures to work.

Reference: [react-native-gesture-handler - Expo Documentation](https://docs.expo.dev/versions/latest/sdk/gesture-handler/)
