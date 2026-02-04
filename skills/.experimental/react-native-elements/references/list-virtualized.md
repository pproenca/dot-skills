---
title: Use FlatList Over ScrollView for Lists
impact: HIGH
impactDescription: Virtualization saves memory and enables smooth 60fps scrolling for any list with 50+ items
tags: list, performance, flatlist, scrollview, virtualization
---

## Use FlatList Over ScrollView for Lists

ScrollView renders all children immediately, keeping every item in memory regardless of visibility. For lists with 50+ items, this causes severe memory pressure and janky scrolling. FlatList virtualizes rendering, only mounting items near the viewport, enabling smooth 60fps performance even with thousands of items.

**Incorrect (ScrollView with map() for 50+ items):**

```tsx
import { ListItem, Avatar } from '@rneui/themed';
import { ScrollView, View } from 'react-native';

// Bad: All 500 items rendered and kept in memory simultaneously
// Causes memory spikes, slow initial render, janky scrolling
const ProductCatalog = ({ products }) => {
  return (
    <ScrollView>
      {/* Bad: map() renders everything at once */}
      {products.map((product) => (
        <ListItem key={product.id}>
          <Avatar source={{ uri: product.image }} />
          <ListItem.Content>
            <ListItem.Title>{product.name}</ListItem.Title>
            <ListItem.Subtitle>${product.price}</ListItem.Subtitle>
          </ListItem.Content>
          <ListItem.Chevron />
        </ListItem>
      ))}
    </ScrollView>
  );
};

// Also bad: Nested ScrollViews with lists
const Dashboard = () => {
  return (
    <ScrollView>
      <Text>Recent Orders</Text>
      {/* Bad: Inner ScrollView defeats virtualization */}
      <ScrollView>
        {orders.map((order) => (
          <ListItem key={order.id}>
            <ListItem.Title>{order.title}</ListItem.Title>
          </ListItem>
        ))}
      </ScrollView>
    </ScrollView>
  );
};
```

**Correct (FlatList with virtualization for any dynamic list):**

```tsx
import { ListItem, Avatar } from '@rneui/themed';
import { FlatList, View } from 'react-native';
import { useCallback } from 'react';

// Good: FlatList only renders visible items + buffer
// Handles 500 or 50,000 items with consistent performance
const ProductCatalog = ({ products }) => {
  const renderProduct = useCallback(({ item }) => (
    <ListItem>
      <Avatar source={{ uri: item.image }} />
      <ListItem.Content>
        <ListItem.Title>{item.name}</ListItem.Title>
        <ListItem.Subtitle>${item.price}</ListItem.Subtitle>
      </ListItem.Content>
      <ListItem.Chevron />
    </ListItem>
  ), []);

  return (
    <FlatList
      data={products}
      renderItem={renderProduct}
      keyExtractor={(item) => item.id}
      // Additional optimization props
      initialNumToRender={10}
      maxToRenderPerBatch={10}
      windowSize={11}
    />
  );
};

// Good: Use SectionList for grouped data or FlatList with ListHeaderComponent
const Dashboard = ({ orders, headerContent }) => {
  const renderOrder = useCallback(({ item }) => (
    <ListItem>
      <ListItem.Content>
        <ListItem.Title>{item.title}</ListItem.Title>
      </ListItem.Content>
    </ListItem>
  ), []);

  return (
    <FlatList
      data={orders}
      renderItem={renderOrder}
      keyExtractor={(item) => item.id}
      // Good: Header scrolls with list, no nested ScrollView
      ListHeaderComponent={headerContent}
    />
  );
};
```

Reference: [React Native FlatList Optimization](https://reactnative.dev/docs/optimizing-flatlist-configuration)
