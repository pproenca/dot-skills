# Expo React Native

**Version 0.1.0**  
Expo  
February 2026

> **Note:** This document is for agents and LLMs working on Expo React Native codebases.
> Humans may also find it useful, but guidance here is optimized for automation
> and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization guide for Expo React Native applications, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (app startup, list virtualization) to incremental (platform optimizations). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [App Startup & Bundle Size](#1-app-startup-bundle-size) — **CRITICAL**
   - 1.1 [Control Splash Screen Visibility](#11-control-splash-screen-visibility)
   - 1.2 [Enable Hermes JavaScript Engine](#12-enable-hermes-javascript-engine)
   - 1.3 [Preload Critical Assets During Splash](#13-preload-critical-assets-during-splash)
   - 1.4 [Remove Console Logs in Production](#14-remove-console-logs-in-production)
   - 1.5 [Use Async Routes for Code Splitting](#15-use-async-routes-for-code-splitting)
   - 1.6 [Use Direct Imports Instead of Barrel Files](#16-use-direct-imports-instead-of-barrel-files)
2. [List Virtualization](#2-list-virtualization) — **CRITICAL**
   - 2.1 [Memoize List Item Components](#21-memoize-list-item-components)
   - 2.2 [Provide Accurate estimatedItemSize](#22-provide-accurate-estimateditemsize)
   - 2.3 [Provide getItemLayout for Fixed Heights](#23-provide-getitemlayout-for-fixed-heights)
   - 2.4 [Stabilize renderItem with useCallback](#24-stabilize-renderitem-with-usecallback)
   - 2.5 [Use FlashList Instead of FlatList](#25-use-flashlist-instead-of-flatlist)
   - 2.6 [Use getItemType for Mixed Lists](#26-use-getitemtype-for-mixed-lists)
3. [Re-render Optimization](#3-re-render-optimization) — **HIGH**
   - 3.1 [Derive State Instead of Syncing](#31-derive-state-instead-of-syncing)
   - 3.2 [Memoize Expensive Computations with useMemo](#32-memoize-expensive-computations-with-usememo)
   - 3.3 [Split Context by Update Frequency](#33-split-context-by-update-frequency)
   - 3.4 [Stabilize Callbacks with useCallback](#34-stabilize-callbacks-with-usecallback)
   - 3.5 [Use Functional setState Updates](#35-use-functional-setstate-updates)
   - 3.6 [Use Lazy State Initialization](#36-use-lazy-state-initialization)
4. [Animation Performance](#4-animation-performance) — **HIGH**
   - 4.1 [Animate Transform Instead of Dimensions](#41-animate-transform-instead-of-dimensions)
   - 4.2 [Defer Heavy Work During Animations](#42-defer-heavy-work-during-animations)
   - 4.3 [Enable Native Driver for Animations](#43-enable-native-driver-for-animations)
   - 4.4 [Use LayoutAnimation for Simple Transitions](#44-use-layoutanimation-for-simple-transitions)
   - 4.5 [Use Reanimated for Complex Animations](#45-use-reanimated-for-complex-animations)
5. [Image & Asset Loading](#5-image-asset-loading) — **MEDIUM-HIGH**
   - 5.1 [Prefetch Images Before Display](#51-prefetch-images-before-display)
   - 5.2 [Request Appropriately Sized Images](#52-request-appropriately-sized-images)
   - 5.3 [Use expo-image for Image Loading](#53-use-expo-image-for-image-loading)
   - 5.4 [Use recyclingKey in FlashList Images](#54-use-recyclingkey-in-flashlist-images)
   - 5.5 [Use WebP Format for Images](#55-use-webp-format-for-images)
6. [Memory Management](#6-memory-management) — **MEDIUM**
   - 6.1 [Abort Fetch Requests on Unmount](#61-abort-fetch-requests-on-unmount)
   - 6.2 [Avoid Inline Objects and Arrays in Props](#62-avoid-inline-objects-and-arrays-in-props)
   - 6.3 [Clean Up Subscriptions in useEffect](#63-clean-up-subscriptions-in-useeffect)
   - 6.4 [Clear Timers on Unmount](#64-clear-timers-on-unmount)
   - 6.5 [Limit List Data in Memory](#65-limit-list-data-in-memory)
7. [Async & Data Fetching](#7-async-data-fetching) — **MEDIUM**
   - 7.1 [Batch Related API Calls](#71-batch-related-api-calls)
   - 7.2 [Cache API Responses Locally](#72-cache-api-responses-locally)
   - 7.3 [Defer await Until Value Needed](#73-defer-await-until-value-needed)
   - 7.4 [Fetch Independent Data in Parallel](#74-fetch-independent-data-in-parallel)
   - 7.5 [Refetch Data on Screen Focus](#75-refetch-data-on-screen-focus)
8. [Platform Optimizations](#8-platform-optimizations) — **LOW-MEDIUM**
   - 8.1 [Enable ProGuard for Android Release](#81-enable-proguard-for-android-release)
   - 8.2 [Optimize iOS Text Rendering](#82-optimize-ios-text-rendering)
   - 8.3 [Reduce Android Overdraw](#83-reduce-android-overdraw)
   - 8.4 [Use Platform-Specific Optimizations Conditionally](#84-use-platform-specific-optimizations-conditionally)

---

## 1. App Startup & Bundle Size

**Impact: CRITICAL**

Startup time determines first impression. Large bundles delay Time to Interactive. Hermes and bundle optimization can reduce startup by 40%.

### 1.1 Control Splash Screen Visibility

**Impact: CRITICAL (prevents white flash, enables asset preloading)**

Use `expo-splash-screen` to manually control when the splash screen hides. This allows you to preload critical assets and data before showing the app, preventing white flashes and incomplete UI states.

**Incorrect (splash hides before app is ready):**

```typescript
// App.tsx
export default function App() {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    fetchCurrentUser().then(setUser);
  }, []);

  // User sees loading spinner after splash disappears
  if (!user) return <LoadingSpinner />;

  return <MainApp user={user} />;
}
```

**Correct (splash stays until app is ready):**

```typescript
// App.tsx
import * as SplashScreen from 'expo-splash-screen';

SplashScreen.preventAutoHideAsync();

export default function App() {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    async function prepare() {
      const userData = await fetchCurrentUser();
      setUser(userData);
      await SplashScreen.hideAsync();
    }
    prepare();
  }, []);

  if (!user) return null;  // Splash still visible

  return <MainApp user={user} />;
}
```

**Important:** Call `preventAutoHideAsync()` in module scope (outside components) to ensure it runs before the splash screen auto-hides.

Reference: [Expo SplashScreen](https://docs.expo.dev/versions/latest/sdk/splash-screen/)

### 1.2 Enable Hermes JavaScript Engine

**Impact: CRITICAL (40% faster startup, 30% less memory)**

Hermes is a JavaScript engine optimized for React Native that compiles JavaScript to bytecode ahead of time. This eliminates runtime compilation overhead, resulting in faster startup times and reduced memory usage.

**Incorrect (using JavaScriptCore, slower startup):**

```json
{
  "expo": {
    "jsEngine": "jsc"
  }
}
```

**Correct (using Hermes, optimized for mobile):**

```json
{
  "expo": {
    "jsEngine": "hermes"
  }
}
```

**Note:** Hermes is the default engine in Expo SDK 48+ and React Native 0.70+. Verify your app is using it by checking for `HermesInternal` in the JavaScript runtime.

**Benefits:**
- 40% faster app startup on average
- 30% reduction in memory usage
- Smaller app size (bytecode is more compact than JavaScript)

Reference: [Using Hermes](https://reactnative.dev/docs/hermes)

### 1.3 Preload Critical Assets During Splash

**Impact: CRITICAL (eliminates asset loading flicker)**

Load critical images and fonts while the splash screen is visible. This prevents UI flicker from missing assets and ensures a smooth transition from splash to app.

**Incorrect (assets load after app renders):**

```typescript
// App.tsx
export default function App() {
  return (
    <View>
      {/* Image flickers in after component mounts */}
      <Image source={require('./assets/logo.png')} />
      <Text style={{ fontFamily: 'Inter' }}>Welcome</Text>
    </View>
  );
}
```

**Correct (assets preloaded during splash):**

```typescript
// App.tsx
import * as SplashScreen from 'expo-splash-screen';
import { Asset } from 'expo-asset';
import * as Font from 'expo-font';

SplashScreen.preventAutoHideAsync();

export default function App() {
  const [assetsLoaded, setAssetsLoaded] = useState(false);

  useEffect(() => {
    async function loadAssets() {
      await Promise.all([
        Asset.loadAsync([
          require('./assets/logo.png'),
          require('./assets/background.png'),
        ]),
        Font.loadAsync({
          'Inter': require('./assets/fonts/Inter.ttf'),
        }),
      ]);
      setAssetsLoaded(true);
      await SplashScreen.hideAsync();
    }
    loadAssets();
  }, []);

  if (!assetsLoaded) return null;

  return <MainApp />;
}
```

**Benefits:**
- Zero asset-loading flicker
- Fonts available on first render
- Perceived instant app startup

Reference: [Expo Asset](https://docs.expo.dev/versions/latest/sdk/asset/)

### 1.4 Remove Console Logs in Production

**Impact: CRITICAL (eliminates JS thread bottleneck)**

Console.log statements cause JavaScript thread bottlenecks in production builds. Each log serializes data and sends it across the bridge, blocking execution. Use a Babel plugin to automatically strip console statements from production bundles.

**Incorrect (console.log in production code):**

```typescript
// api/users.ts
export async function fetchUsers(): Promise<User[]> {
  const response = await fetch('/api/users');
  const users = await response.json();
  console.log('Fetched users:', users);  // Blocks JS thread in production
  return users;
}
```

**Correct (Babel strips console in production):**

```javascript
// babel.config.js
module.exports = function (api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    env: {
      production: {
        plugins: ['transform-remove-console'],
      },
    },
  };
};
```

Install the plugin: `npm install babel-plugin-transform-remove-console --save-dev`

**When to keep console statements:**
- Use `console.error` for critical errors you need in crash reports
- Wrap debug logs in `__DEV__` checks instead of relying solely on Babel

Reference: [React Native Performance](https://reactnative.dev/docs/performance)

### 1.5 Use Async Routes for Code Splitting

**Impact: CRITICAL (30-50% smaller initial bundle)**

Expo Router supports async routes that split your bundle by route. Only the code needed for the current screen loads initially, deferring the rest until navigation. This dramatically reduces initial bundle size and startup time.

**Incorrect (all routes in initial bundle):**

```typescript
// app/_layout.tsx
import { Stack } from 'expo-router';

// All screen code loads at startup, even if never visited
export default function Layout() {
  return (
    <Stack>
      <Stack.Screen name="index" />
      <Stack.Screen name="settings" />
      <Stack.Screen name="profile" />
      <Stack.Screen name="admin" />  {/* Heavy admin code loaded for all users */}
    </Stack>
  );
}
```

**Correct (enable async routes in Metro config):**

```javascript
// metro.config.js
const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

config.transformer = {
  ...config.transformer,
  asyncRequireModulePath: require.resolve('expo-router/async-require'),
};

module.exports = config;
```

```json
// app.json
{
  "expo": {
    "experiments": {
      "asyncRoutes": true
    }
  }
}
```

**How it works:**
- Each route file becomes a separate bundle chunk
- Chunks load on-demand when user navigates to that route
- Initial bundle contains only the entry route

Reference: [Expo Router Async Routes](https://docs.expo.dev/router/reference/async-routes/)

### 1.6 Use Direct Imports Instead of Barrel Files

**Impact: CRITICAL (reduces bundle by 100KB-1MB per library)**

Metro bundler doesn't tree-shake effectively. Importing from barrel files (index.js) pulls in entire libraries. Always import directly from the specific module path to include only what you need.

**Incorrect (imports entire lodash library):**

```typescript
// utils/data.ts
import { debounce, throttle } from 'lodash';
// Bundles all 600KB of lodash even though you use 2 functions

export const debouncedSearch = debounce(searchUsers, 300);
export const throttledScroll = throttle(handleScroll, 100);
```

**Correct (imports only used functions):**

```typescript
// utils/data.ts
import debounce from 'lodash/debounce';
import throttle from 'lodash/throttle';
// Bundles only ~2KB for the two functions

export const debouncedSearch = debounce(searchUsers, 300);
export const throttledScroll = throttle(handleScroll, 100);
```

**Common libraries requiring cherry-picking:**

| Library | Bad Import | Good Import |
|---------|------------|-------------|
| lodash | `from 'lodash'` | `from 'lodash/debounce'` |
| date-fns | `from 'date-fns'` | `from 'date-fns/format'` |
| @expo/vector-icons | `from '@expo/vector-icons'` | `from '@expo/vector-icons/Ionicons'` |

**Alternative:** Use `babel-plugin-lodash` or `babel-plugin-date-fns` for automatic transforms.

Reference: [Callstack Bundle Optimization](https://www.callstack.com/blog/optimize-react-native-apps-javascript-bundle)

---

## 2. List Virtualization

**Impact: CRITICAL**

Lists are the #1 performance killer in mobile apps. FlashList achieves 5-10× better FPS than FlatList on Android through view recycling.

### 2.1 Memoize List Item Components

**Impact: CRITICAL (prevents re-render of unchanged items)**

Wrap list item components in `React.memo()` to prevent re-rendering when their props haven't changed. Without memoization, all visible items re-render whenever the parent component updates.

**Incorrect (item re-renders on every list update):**

```typescript
// components/ProductCard.tsx
interface ProductCardProps {
  product: Product;
  onPress: (id: string) => void;
}

export function ProductCard({ product, onPress }: ProductCardProps) {
  return (
    <Pressable onPress={() => onPress(product.id)}>
      <Image source={{ uri: product.imageUrl }} style={styles.image} />
      <Text>{product.name}</Text>
      <Text>${product.price}</Text>
    </Pressable>
  );
}
// Every card re-renders when any card changes
```

**Correct (memoized item only re-renders on prop change):**

```typescript
// components/ProductCard.tsx
interface ProductCardProps {
  product: Product;
  onPress: (id: string) => void;
}

export const ProductCard = memo(function ProductCard({
  product,
  onPress,
}: ProductCardProps) {
  return (
    <Pressable onPress={() => onPress(product.id)}>
      <Image source={{ uri: product.imageUrl }} style={styles.image} />
      <Text>{product.name}</Text>
      <Text>${product.price}</Text>
    </Pressable>
  );
});
// Only re-renders if product or onPress reference changes
```

**Important:** Ensure `onPress` is stable (use `useCallback`) or memo won't help since the function reference changes every render.

Reference: [React.memo](https://react.dev/reference/react/memo)

### 2.2 Provide Accurate estimatedItemSize

**Impact: CRITICAL (prevents blank cells during fast scroll)**

FlashList uses `estimatedItemSize` to calculate how many items to render initially and during scroll. An inaccurate estimate causes blank cells or excessive memory usage. Measure your actual item height and provide it.

**Incorrect (default or guessed estimate):**

```typescript
// screens/MessageList.tsx
export function MessageList({ messages }: Props) {
  return (
    <FlashList
      data={messages}
      renderItem={({ item }) => <MessageBubble message={item} />}
      estimatedItemSize={50}  // Wrong: actual messages are ~150px tall
    />
    // Blank cells appear during fast scrolling
  );
}
```

**Correct (measured average height):**

```typescript
// screens/MessageList.tsx
export function MessageList({ messages }: Props) {
  return (
    <FlashList
      data={messages}
      renderItem={({ item }) => <MessageBubble message={item} />}
      estimatedItemSize={150}  // Measured from actual rendered items
    />
    // Smooth scrolling with no blank cells
  );
}
```

**How to measure:**
1. Add `onLayout` to your list item temporarily
2. Log the `event.nativeEvent.layout.height`
3. Average across multiple items
4. Use the median value for varied-height lists

**For mixed content:** Use the average height. FlashList v2 removes the need for estimates entirely.

Reference: [FlashList estimatedItemSize](https://shopify.github.io/flash-list/docs/fundamentals/performant-components)

### 2.3 Provide getItemLayout for Fixed Heights

**Impact: CRITICAL (eliminates async layout calculation)**

When all list items have the same height, provide `getItemLayout` to skip asynchronous measurement. FlatList/FlashList can instantly calculate scroll position without rendering off-screen items.

**Incorrect (FlatList measures each item):**

```typescript
// screens/NotificationList.tsx
const ITEM_HEIGHT = 72;

export function NotificationList({ notifications }: Props) {
  return (
    <FlatList
      data={notifications}
      renderItem={({ item }) => (
        <NotificationRow notification={item} style={{ height: ITEM_HEIGHT }} />
      )}
      keyExtractor={(item) => item.id}
    />
    // FlatList renders items to measure them, causing scroll jank
  );
}
```

**Correct (skip measurement with getItemLayout):**

```typescript
// screens/NotificationList.tsx
const ITEM_HEIGHT = 72;

export function NotificationList({ notifications }: Props) {
  const getItemLayout = useCallback(
    (_: any, index: number) => ({
      length: ITEM_HEIGHT,
      offset: ITEM_HEIGHT * index,
      index,
    }),
    []
  );

  return (
    <FlatList
      data={notifications}
      renderItem={({ item }) => (
        <NotificationRow notification={item} style={{ height: ITEM_HEIGHT }} />
      )}
      keyExtractor={(item) => item.id}
      getItemLayout={getItemLayout}
    />
    // Instant scroll position calculation, no measurement needed
  );
}
```

**When NOT to use:** Items with dynamic heights (text wrapping, images). Use FlashList with `estimatedItemSize` instead.

Reference: [Optimizing FlatList](https://reactnative.dev/docs/optimizing-flatlist-configuration)

### 2.4 Stabilize renderItem with useCallback

**Impact: CRITICAL (prevents full list re-render on parent update)**

Defining `renderItem` inline creates a new function on every render, causing FlashList/FlatList to think the renderer changed and re-render all visible items. Extract and memoize the render function.

**Incorrect (inline renderItem recreated every render):**

```typescript
// screens/ContactList.tsx
export function ContactList({ contacts }: Props) {
  const [searchQuery, setSearchQuery] = useState('');

  return (
    <>
      <SearchInput value={searchQuery} onChangeText={setSearchQuery} />
      <FlashList
        data={filteredContacts}
        renderItem={({ item }) => (
          <ContactRow contact={item} />
        )}  // New function on every keystroke = all rows re-render
        estimatedItemSize={60}
      />
    </>
  );
}
```

**Correct (stable renderItem with useCallback):**

```typescript
// screens/ContactList.tsx
export function ContactList({ contacts }: Props) {
  const [searchQuery, setSearchQuery] = useState('');

  const renderContact = useCallback(
    ({ item }: { item: Contact }) => <ContactRow contact={item} />,
    []
  );

  return (
    <>
      <SearchInput value={searchQuery} onChangeText={setSearchQuery} />
      <FlashList
        data={filteredContacts}
        renderItem={renderContact}
        estimatedItemSize={60}
      />
    </>
  );
}
```

**Important:** If `renderItem` uses callbacks like `onPress`, include them in the dependency array or use functional updates to avoid stale closures.

Reference: [Optimizing FlatList](https://reactnative.dev/docs/optimizing-flatlist-configuration)

### 2.5 Use FlashList Instead of FlatList

**Impact: CRITICAL (5-10× better FPS on Android)**

FlashList uses view recycling instead of creating new views for each item. This dramatically reduces memory allocation and improves scroll performance, especially on low-end Android devices where FlatList struggles.

**Incorrect (FlatList recreates views on scroll):**

```typescript
// screens/ProductList.tsx
import { FlatList } from 'react-native';

export function ProductList({ products }: Props) {
  return (
    <FlatList
      data={products}
      renderItem={({ item }) => <ProductCard product={item} />}
      keyExtractor={(item) => item.id}
    />
    // Each scroll creates/destroys views, causing jank on Android
  );
}
```

**Correct (FlashList recycles views):**

```typescript
// screens/ProductList.tsx
import { FlashList } from '@shopify/flash-list';

export function ProductList({ products }: Props) {
  return (
    <FlashList
      data={products}
      renderItem={({ item }) => <ProductCard product={item} />}
      keyExtractor={(item) => item.id}
      estimatedItemSize={120}
    />
    // Same views recycled, smooth 60 FPS scrolling
  );
}
```

**Migration:** FlashList is API-compatible with FlatList. Change the import and add `estimatedItemSize`.

**Performance gains:**
- 5× faster UI thread FPS on low-end Android
- 10× faster JS thread FPS
- 32% less CPU usage

Reference: [FlashList](https://shopify.github.io/flash-list/)

### 2.6 Use getItemType for Mixed Lists

**Impact: CRITICAL (50% better recycling efficiency)**

When a list contains different component types (headers, items, ads), FlashList can only recycle views of the same type. Provide `getItemType` to help FlashList maintain separate recycling pools for each type.

**Incorrect (no type differentiation):**

```typescript
// screens/Feed.tsx
type FeedItem = { type: 'post' | 'ad' | 'header'; data: any };

export function Feed({ items }: { items: FeedItem[] }) {
  return (
    <FlashList
      data={items}
      renderItem={({ item }) => {
        if (item.type === 'header') return <SectionHeader data={item.data} />;
        if (item.type === 'ad') return <AdBanner data={item.data} />;
        return <PostCard data={item.data} />;
      }}
      estimatedItemSize={200}
    />
    // FlashList can't recycle: header view becomes post view = layout thrashing
  );
}
```

**Correct (typed recycling pools):**

```typescript
// screens/Feed.tsx
type FeedItem = { type: 'post' | 'ad' | 'header'; data: any };

export function Feed({ items }: { items: FeedItem[] }) {
  return (
    <FlashList
      data={items}
      renderItem={({ item }) => {
        if (item.type === 'header') return <SectionHeader data={item.data} />;
        if (item.type === 'ad') return <AdBanner data={item.data} />;
        return <PostCard data={item.data} />;
      }}
      getItemType={(item) => item.type}
      estimatedItemSize={200}
    />
    // Posts recycle into posts, headers into headers
  );
}
```

**Result:** Each type maintains its own recycling pool, preventing expensive layout recalculations when items of different heights are recycled.

Reference: [FlashList getItemType](https://shopify.github.io/flash-list/docs/fundamentals/performant-components)

---

## 3. Re-render Optimization

**Impact: HIGH**

Unnecessary re-renders cascade through component trees, blocking the JS thread and causing dropped frames during interactions.

### 3.1 Derive State Instead of Syncing

**Impact: HIGH (eliminates redundant state and sync bugs)**

When one value can be computed from another, derive it during render instead of storing it in separate state. Synced state causes extra renders and can get out of sync.

**Incorrect (synced state, double render):**

```typescript
// screens/ProductDetails.tsx
export function ProductDetails({ product }: Props) {
  const [quantity, setQuantity] = useState(1);
  const [totalPrice, setTotalPrice] = useState(product.price);

  useEffect(() => {
    setTotalPrice(product.price * quantity);  // Causes second render
  }, [product.price, quantity]);

  return (
    <View>
      <QuantityPicker value={quantity} onChange={setQuantity} />
      <Text>Total: ${totalPrice}</Text>
    </View>
  );
}
```

**Correct (derived value, single render):**

```typescript
// screens/ProductDetails.tsx
export function ProductDetails({ product }: Props) {
  const [quantity, setQuantity] = useState(1);
  const totalPrice = product.price * quantity;  // Computed during render

  return (
    <View>
      <QuantityPicker value={quantity} onChange={setQuantity} />
      <Text>Total: ${totalPrice}</Text>
    </View>
  );
}
```

**When to derive:**
- Filtered/sorted lists from source data
- Computed totals, averages, counts
- Boolean flags based on other state
- Formatted display values

**When to use useMemo:** Wrap in `useMemo` if the derivation is expensive and deps rarely change.

Reference: [Choosing the State Structure](https://react.dev/learn/choosing-the-state-structure#avoid-redundant-state)

### 3.2 Memoize Expensive Computations with useMemo

**Impact: HIGH (prevents recalculation on every render)**

Use `useMemo` to cache the result of expensive computations. Without memoization, computations run on every render, even when inputs haven't changed, blocking the JS thread.

**Incorrect (filters/sorts on every render):**

```typescript
// screens/TransactionList.tsx
export function TransactionList({ transactions, filter }: Props) {
  const [searchQuery, setSearchQuery] = useState('');

  // Runs on EVERY render, including unrelated state changes
  const filteredTransactions = transactions
    .filter((t) => t.category === filter)
    .filter((t) => t.description.includes(searchQuery))
    .sort((a, b) => b.date.getTime() - a.date.getTime());

  return <FlashList data={filteredTransactions} /* ... */ />;
}
```

**Correct (memoized until dependencies change):**

```typescript
// screens/TransactionList.tsx
export function TransactionList({ transactions, filter }: Props) {
  const [searchQuery, setSearchQuery] = useState('');

  const filteredTransactions = useMemo(() => {
    return transactions
      .filter((t) => t.category === filter)
      .filter((t) => t.description.includes(searchQuery))
      .sort((a, b) => b.date.getTime() - a.date.getTime());
  }, [transactions, filter, searchQuery]);

  return <FlashList data={filteredTransactions} /* ... */ />;
}
```

**When to use useMemo:**
- Array filtering/sorting with 100+ items
- Complex object transformations
- Heavy calculations (date parsing, formatting)

**When NOT to use:** Simple operations or operations that always depend on changing values.

Reference: [useMemo](https://react.dev/reference/react/useMemo)

### 3.3 Split Context by Update Frequency

**Impact: HIGH (prevents cascading re-renders across app)**

A single context with frequently-changing values causes all consumers to re-render. Split context into separate providers based on update frequency to limit re-render scope.

**Incorrect (one context, all consumers re-render):**

```typescript
// contexts/AppContext.tsx
const AppContext = createContext<{
  user: User;
  theme: Theme;
  notifications: Notification[];  // Updates frequently
} | null>(null);

export function AppProvider({ children }: Props) {
  const [user, setUser] = useState<User | null>(null);
  const [theme, setTheme] = useState<Theme>('light');
  const [notifications, setNotifications] = useState<Notification[]>([]);

  return (
    <AppContext.Provider value={{ user, theme, notifications }}>
      {children}
    </AppContext.Provider>
  );
}
// Every component using user or theme re-renders on new notification
```

**Correct (split by update frequency):**

```typescript
// contexts/UserContext.tsx - rarely changes
const UserContext = createContext<User | null>(null);

// contexts/ThemeContext.tsx - rarely changes
const ThemeContext = createContext<Theme>('light');

// contexts/NotificationsContext.tsx - changes frequently
const NotificationsContext = createContext<Notification[]>([]);

// App.tsx
export function AppProvider({ children }: Props) {
  const [user, setUser] = useState<User | null>(null);
  const [theme, setTheme] = useState<Theme>('light');
  const [notifications, setNotifications] = useState<Notification[]>([]);

  return (
    <UserContext.Provider value={user}>
      <ThemeContext.Provider value={theme}>
        <NotificationsContext.Provider value={notifications}>
          {children}
        </NotificationsContext.Provider>
      </ThemeContext.Provider>
    </UserContext.Provider>
  );
}
// Only notification consumers re-render on new notification
```

**Alternative:** Use state management libraries like Zustand or Jotai that allow selective subscriptions.

Reference: [React Context](https://react.dev/learn/passing-data-deeply-with-context)

### 3.4 Stabilize Callbacks with useCallback

**Impact: HIGH (prevents child re-renders from new function refs)**

Functions defined inside components get new references on every render. When passed as props to memoized children, this breaks memoization. Use `useCallback` to maintain stable function references.

**Incorrect (new callback reference breaks child memo):**

```typescript
// screens/UserSettings.tsx
export function UserSettings({ userId }: Props) {
  const [notifications, setNotifications] = useState(true);

  // New function created every render
  const handleSave = async () => {
    await saveSettings(userId, { notifications });
  };

  return (
    <>
      <Toggle value={notifications} onValueChange={setNotifications} />
      <SaveButton onPress={handleSave} />  {/* Re-renders on toggle */}
    </>
  );
}

const SaveButton = memo(({ onPress }: { onPress: () => void }) => (
  <Pressable onPress={onPress}><Text>Save</Text></Pressable>
));
```

**Correct (stable callback preserves child memo):**

```typescript
// screens/UserSettings.tsx
export function UserSettings({ userId }: Props) {
  const [notifications, setNotifications] = useState(true);

  const handleSave = useCallback(async () => {
    await saveSettings(userId, { notifications });
  }, [userId, notifications]);

  return (
    <>
      <Toggle value={notifications} onValueChange={setNotifications} />
      <SaveButton onPress={handleSave} />  {/* Only re-renders when deps change */}
    </>
  );
}

const SaveButton = memo(({ onPress }: { onPress: () => void }) => (
  <Pressable onPress={onPress}><Text>Save</Text></Pressable>
));
```

**Note:** `useCallback` only helps when the callback is passed to a memoized component. Without `memo` on the child, it re-renders anyway.

Reference: [useCallback](https://react.dev/reference/react/useCallback)

### 3.5 Use Functional setState Updates

**Impact: HIGH (eliminates state dependency from callbacks)**

When updating state based on the current value, use the functional form of setState. This eliminates the need to include state in callback dependencies, allowing truly stable callbacks.

**Incorrect (state in dependency array recreates callback):**

```typescript
// screens/Counter.tsx
export function Counter() {
  const [count, setCount] = useState(0);

  // Recreated every time count changes
  const increment = useCallback(() => {
    setCount(count + 1);
  }, [count]);

  return (
    <MemoizedButton onPress={increment} />  // Re-renders on every count change
  );
}
```

**Correct (functional update, empty deps):**

```typescript
// screens/Counter.tsx
export function Counter() {
  const [count, setCount] = useState(0);

  // Never recreated - truly stable callback
  const increment = useCallback(() => {
    setCount((c) => c + 1);
  }, []);

  return (
    <MemoizedButton onPress={increment} />  // Never re-renders from callback change
  );
}
```

**Pattern applies to:**
- Incrementing/decrementing numbers
- Toggling booleans: `setValue(v => !v)`
- Adding to arrays: `setItems(items => [...items, newItem])`
- Updating object properties: `setUser(u => ({ ...u, name }))`

Reference: [useState functional updates](https://react.dev/reference/react/useState#updating-state-based-on-the-previous-state)

### 3.6 Use Lazy State Initialization

**Impact: HIGH (prevents expensive init on every render)**

When initial state requires expensive computation, pass a function to `useState` instead of calling the computation directly. React only calls the initializer once, but direct calls run on every render.

**Incorrect (expensive init runs every render):**

```typescript
// screens/Dashboard.tsx
function parseStoredPreferences(): Preferences {
  const stored = localStorage.getItem('prefs');
  return stored ? JSON.parse(stored) : getDefaultPreferences();
}

export function Dashboard() {
  // parseStoredPreferences() called EVERY render, result discarded after first
  const [preferences, setPreferences] = useState(parseStoredPreferences());

  return <PreferencesPanel prefs={preferences} />;
}
```

**Correct (lazy init runs only once):**

```typescript
// screens/Dashboard.tsx
function parseStoredPreferences(): Preferences {
  const stored = localStorage.getItem('prefs');
  return stored ? JSON.parse(stored) : getDefaultPreferences();
}

export function Dashboard() {
  // Function reference passed - called only on mount
  const [preferences, setPreferences] = useState(parseStoredPreferences);

  return <PreferencesPanel prefs={preferences} />;
}
```

**Note the difference:**
- `useState(parseStoredPreferences())` - calls function, passes result
- `useState(parseStoredPreferences)` - passes function, React calls once

**Common use cases:**
- Parsing stored data (AsyncStorage, SecureStore)
- Creating initial data structures
- Complex default calculations

Reference: [useState lazy initialization](https://react.dev/reference/react/useState#avoiding-recreating-the-initial-state)

---

## 4. Animation Performance

**Impact: HIGH**

60 FPS requires animations on the UI thread. Bridge crossings cause janky animations. Reanimated and native driver are essential.

### 4.1 Animate Transform Instead of Dimensions

**Impact: HIGH (eliminates 60× layout recalculations per second)**

Animating `width` and `height` triggers layout recalculation on every frame. Use `transform: [{ scale }]` instead, which is GPU-accelerated and doesn't affect layout.

**Incorrect (animating dimensions, causes reflow):**

```typescript
// components/PulsingButton.tsx
export function PulsingButton({ onPress, children }: Props) {
  const size = useRef(new Animated.Value(100)).current;

  useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(size, { toValue: 110, duration: 500, useNativeDriver: false }),
        Animated.timing(size, { toValue: 100, duration: 500, useNativeDriver: false }),
      ])
    ).start();
  }, []);

  return (
    <Animated.View style={{ width: size, height: size }}>
      <Pressable onPress={onPress}>{children}</Pressable>
    </Animated.View>
  );
}
// Layout recalculated 60× per second, affects surrounding elements
```

**Correct (animating transform, GPU-accelerated):**

```typescript
// components/PulsingButton.tsx
export function PulsingButton({ onPress, children }: Props) {
  const scale = useRef(new Animated.Value(1)).current;

  useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(scale, { toValue: 1.1, duration: 500, useNativeDriver: true }),
        Animated.timing(scale, { toValue: 1, duration: 500, useNativeDriver: true }),
      ])
    ).start();
  }, []);

  return (
    <Animated.View style={{ transform: [{ scale }] }}>
      <Pressable onPress={onPress}>{children}</Pressable>
    </Animated.View>
  );
}
// GPU-accelerated, no layout impact, native driver compatible
```

**Transform properties (all native driver compatible):**
- `scale`, `scaleX`, `scaleY`
- `translateX`, `translateY`
- `rotate`, `rotateX`, `rotateY`

Reference: [React Native Animations](https://reactnative.dev/docs/animations)

### 4.2 Defer Heavy Work During Animations

**Impact: HIGH (prevents dropped frames during transitions)**

Heavy JavaScript execution during animations causes dropped frames. Use `InteractionManager.runAfterInteractions()` to defer expensive work until animations complete.

**Incorrect (heavy work during navigation animation):**

```typescript
// screens/ProfileScreen.tsx
export function ProfileScreen({ userId }: Props) {
  const [profile, setProfile] = useState<Profile | null>(null);

  useEffect(() => {
    // Runs immediately, blocks JS thread during screen transition
    fetchProfile(userId).then(setProfile);
    loadAnalytics(userId);
    preloadImages(userId);
  }, [userId]);

  return profile ? <ProfileView profile={profile} /> : <Loading />;
}
// Navigation animation stutters as JS thread is blocked
```

**Correct (defer until animation completes):**

```typescript
// screens/ProfileScreen.tsx
import { InteractionManager } from 'react-native';

export function ProfileScreen({ userId }: Props) {
  const [profile, setProfile] = useState<Profile | null>(null);

  useEffect(() => {
    const task = InteractionManager.runAfterInteractions(() => {
      fetchProfile(userId).then(setProfile);
      loadAnalytics(userId);
      preloadImages(userId);
    });

    return () => task.cancel();
  }, [userId]);

  return profile ? <ProfileView profile={profile} /> : <Loading />;
}
// Navigation animation completes smoothly, then data loads
```

**When to defer:**
- Screen mount data fetching
- Heavy list rendering
- Image processing
- Analytics/logging

**Trade-off:** Users see loading state slightly longer, but transitions are smooth.

Reference: [InteractionManager](https://reactnative.dev/docs/interactionmanager)

### 4.3 Enable Native Driver for Animations

**Impact: HIGH (consistent 60 FPS vs 15-30 FPS under JS load)**

The Animated API runs on the JS thread by default, causing jank when the thread is busy. Enable `useNativeDriver: true` to run animations entirely on the UI thread, achieving smooth 60 FPS regardless of JS load.

**Incorrect (JS thread animation, drops frames under load):**

```typescript
// components/FadeInView.tsx
export function FadeInView({ children }: Props) {
  const opacity = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(opacity, {
      toValue: 1,
      duration: 300,
      useNativeDriver: false,  // Runs on JS thread
    }).start();
  }, []);

  return <Animated.View style={{ opacity }}>{children}</Animated.View>;
}
```

**Correct (native thread animation, always 60 FPS):**

```typescript
// components/FadeInView.tsx
export function FadeInView({ children }: Props) {
  const opacity = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(opacity, {
      toValue: 1,
      duration: 300,
      useNativeDriver: true,  // Runs on UI thread
    }).start();
  }, []);

  return <Animated.View style={{ opacity }}>{children}</Animated.View>;
}
```

**Native driver limitations:**
- Only supports non-layout properties: `transform`, `opacity`
- Cannot animate `width`, `height`, `backgroundColor`
- Use Reanimated for layout property animations

Reference: [React Native Animations](https://reactnative.dev/docs/animations#using-the-native-driver)

### 4.4 Use LayoutAnimation for Simple Transitions

**Impact: HIGH (50% less code, native 60 FPS)**

For simple layout changes (showing/hiding, resizing), use `LayoutAnimation` instead of managing animation state. It automatically animates all layout changes in the next render using native animations.

**Incorrect (manual animation state management):**

```typescript
// components/ExpandableSection.tsx
export function ExpandableSection({ title, children }: Props) {
  const [expanded, setExpanded] = useState(false);
  const height = useRef(new Animated.Value(0)).current;

  const toggle = () => {
    setExpanded(!expanded);
    Animated.timing(height, {
      toValue: expanded ? 0 : 200,
      duration: 300,
      useNativeDriver: false,
    }).start();
  };

  return (
    <View>
      <Pressable onPress={toggle}><Text>{title}</Text></Pressable>
      <Animated.View style={{ height, overflow: 'hidden' }}>
        {children}
      </Animated.View>
    </View>
  );
}
```

**Correct (LayoutAnimation handles it):**

```typescript
// components/ExpandableSection.tsx
import { LayoutAnimation, UIManager, Platform } from 'react-native';

if (Platform.OS === 'android') {
  UIManager.setLayoutAnimationEnabledExperimental?.(true);
}

export function ExpandableSection({ title, children }: Props) {
  const [expanded, setExpanded] = useState(false);

  const toggle = () => {
    LayoutAnimation.configureNext(LayoutAnimation.Presets.easeInEaseOut);
    setExpanded(!expanded);
  };

  return (
    <View>
      <Pressable onPress={toggle}><Text>{title}</Text></Pressable>
      {expanded && children}
    </View>
  );
}
// Native animation applied automatically to layout change
```

**When to use LayoutAnimation:**
- Showing/hiding elements
- List item insertions/deletions
- Simple size changes

**When NOT to use:** Gesture-driven or interruptible animations.

Reference: [LayoutAnimation](https://reactnative.dev/docs/layoutanimation)

### 4.5 Use Reanimated for Complex Animations

**Impact: HIGH (60-120 FPS for all properties vs 15-30 FPS)**

React Native Reanimated runs animation logic on the UI thread using worklets, bypassing the JS bridge entirely. This enables smooth 60-120 FPS animations for any property, including layout properties the native driver doesn't support.

**Incorrect (Animated API with layout, causes jank):**

```typescript
// components/ExpandingCard.tsx
export function ExpandingCard({ expanded }: Props) {
  const height = useRef(new Animated.Value(100)).current;

  useEffect(() => {
    Animated.timing(height, {
      toValue: expanded ? 300 : 100,
      duration: 300,
      useNativeDriver: false,  // Required for height, but janky
    }).start();
  }, [expanded]);

  return <Animated.View style={{ height }} />;
}
```

**Correct (Reanimated with worklets):**

```typescript
// components/ExpandingCard.tsx
import Animated, { useAnimatedStyle, withTiming } from 'react-native-reanimated';

export function ExpandingCard({ expanded }: Props) {
  const animatedStyle = useAnimatedStyle(() => ({
    height: withTiming(expanded ? 300 : 100, { duration: 300 }),
  }));

  return <Animated.View style={animatedStyle} />;
}
// Runs entirely on UI thread, smooth 60+ FPS
```

**Reanimated advantages:**
- Animates any style property (height, width, backgroundColor)
- Worklets execute on UI thread
- Gesture-driven animations with react-native-gesture-handler
- Supports 120 FPS on ProMotion displays

Reference: [React Native Reanimated](https://docs.swmansion.com/react-native-reanimated/)

---

## 5. Image & Asset Loading

**Impact: MEDIUM-HIGH**

Images are the largest payload in most apps. Poor caching causes network waterfalls. expo-image provides automatic optimization and caching.

### 5.1 Prefetch Images Before Display

**Impact: MEDIUM-HIGH (0ms display delay vs 200-500ms on demand)**

Use `Image.prefetch()` to download images before they're needed. This enables instant display when the user navigates to a screen or scrolls to new content.

**Incorrect (images load when component mounts):**

```typescript
// screens/ProductDetails.tsx
export function ProductDetails({ productId }: Props) {
  const { data: product } = useQuery(['product', productId], fetchProduct);

  // Images start loading after component renders
  return (
    <ScrollView>
      {product?.images.map((img) => (
        <Image key={img.id} source={{ uri: img.url }} style={styles.image} />
      ))}
    </ScrollView>
  );
}
// User sees loading placeholders, then images pop in
```

**Correct (prefetch on hover/focus):**

```typescript
// components/ProductCard.tsx
import { Image } from 'expo-image';

export function ProductCard({ product, onPress }: Props) {
  const prefetchImages = useCallback(() => {
    product.images.forEach((img) => {
      Image.prefetch(img.url);
    });
  }, [product.images]);

  return (
    <Pressable
      onPress={onPress}
      onHoverIn={prefetchImages}
      onPressIn={prefetchImages}
    >
      <Image source={{ uri: product.thumbnailUrl }} style={styles.thumbnail} />
      <Text>{product.name}</Text>
    </Pressable>
  );
}
// Images already cached when user opens details
```

**Alternative:** Prefetch during list scroll using `onViewableItemsChanged`.

Reference: [expo-image prefetch](https://docs.expo.dev/versions/latest/sdk/image/#imageprefetch)

### 5.2 Request Appropriately Sized Images

**Impact: MEDIUM-HIGH (50-90% bandwidth reduction)**

Loading full-resolution images for thumbnail displays wastes bandwidth and memory. Request images sized for their display dimensions using CDN resize parameters.

**Incorrect (full-size image for thumbnail):**

```typescript
// components/ProductCard.tsx
export function ProductCard({ product }: Props) {
  return (
    <View style={styles.card}>
      {/* 100×100 display, but downloading 2000×2000 original */}
      <Image
        source={{ uri: product.imageUrl }}
        style={{ width: 100, height: 100 }}
      />
      <Text>{product.name}</Text>
    </View>
  );
}
// Downloads 2MB image, displays at 100px, wastes bandwidth
```

**Correct (request thumbnail-sized image):**

```typescript
// utils/images.ts
export function getResizedImageUrl(url: string, width: number): string {
  // Cloudinary example
  return url.replace('/upload/', `/upload/w_${width},c_fill,f_auto/`);
  // Or imgix: `${url}?w=${width}&auto=format`
}

// components/ProductCard.tsx
export function ProductCard({ product }: Props) {
  const thumbnailUrl = getResizedImageUrl(product.imageUrl, 200);  // 2× for Retina

  return (
    <View style={styles.card}>
      <Image
        source={{ uri: thumbnailUrl }}
        style={{ width: 100, height: 100 }}
      />
      <Text>{product.name}</Text>
    </View>
  );
}
// Downloads 20KB thumbnail instead of 2MB original
```

**CDN resize services:** Cloudinary, imgix, Cloudflare Images, ImageKit

Reference: [Image Optimization](https://docs.imgix.com/en-US/getting-started/tutorials/responsive-design/rendering-images-in-react-native-faster-with-imgix)

### 5.3 Use expo-image for Image Loading

**Impact: MEDIUM-HIGH (automatic caching, placeholder support)**

expo-image provides built-in disk and memory caching, BlurHash placeholders, and automatic downscaling. It outperforms the standard Image component in both performance and developer experience.

**Incorrect (React Native Image, no caching):**

```typescript
// components/Avatar.tsx
import { Image } from 'react-native';

export function Avatar({ user }: Props) {
  return (
    <Image
      source={{ uri: user.avatarUrl }}
      style={styles.avatar}
    />
    // No caching, reloads on every mount
    // Flickers when source changes
  );
}
```

**Correct (expo-image with caching and placeholder):**

```typescript
// components/Avatar.tsx
import { Image } from 'expo-image';

export function Avatar({ user }: Props) {
  return (
    <Image
      source={{ uri: user.avatarUrl }}
      placeholder={user.avatarBlurhash}
      contentFit="cover"
      transition={200}
      style={styles.avatar}
    />
    // Automatic disk/memory caching
    // BlurHash shows while loading
    // Smooth transition when loaded
  );
}
```

**Key props:**
- `placeholder` - BlurHash or ThumbHash while loading
- `transition` - Fade duration in ms
- `cachePolicy` - Control caching behavior
- `recyclingKey` - For FlashList view recycling

Reference: [expo-image](https://docs.expo.dev/versions/latest/sdk/image/)

### 5.4 Use recyclingKey in FlashList Images

**Impact: MEDIUM-HIGH (prevents stale image display in recycled cells)**

FlashList recycles views, which can cause the previous image to flash before the new one loads. Use `recyclingKey` to ensure images update immediately when cells are recycled.

**Incorrect (stale images flash in recycled cells):**

```typescript
// components/ProductCard.tsx
export function ProductCard({ product }: Props) {
  return (
    <View style={styles.card}>
      <Image
        source={{ uri: product.imageUrl }}
        style={styles.image}
      />
      <Text>{product.name}</Text>
    </View>
  );
}
// When scrolling fast, old product image shows briefly before new one loads
```

**Correct (recyclingKey prevents stale images):**

```typescript
// components/ProductCard.tsx
import { Image } from 'expo-image';

export function ProductCard({ product }: Props) {
  return (
    <View style={styles.card}>
      <Image
        source={{ uri: product.imageUrl }}
        recyclingKey={product.id}
        placeholder={product.blurhash}
        style={styles.image}
      />
      <Text>{product.name}</Text>
    </View>
  );
}
// Image clears immediately when cell is recycled, shows placeholder
```

**How it works:**
- `recyclingKey` tells expo-image when the source has changed
- When key changes, image immediately shows placeholder instead of stale content
- Combined with BlurHash, provides smooth visual experience

Reference: [expo-image recyclingKey](https://docs.expo.dev/versions/latest/sdk/image/#recyclingkey)

### 5.5 Use WebP Format for Images

**Impact: MEDIUM-HIGH (25-35% smaller than JPEG at same quality)**

WebP provides superior compression compared to JPEG and PNG while maintaining quality. Serve WebP images to reduce bandwidth and improve load times.

**Incorrect (using JPEG/PNG):**

```typescript
// assets/images.ts
export const images = {
  hero: require('./hero.jpg'),      // 450KB
  product: require('./product.png'), // 280KB
  background: require('./bg.jpg'),   // 320KB
};
// Total: 1050KB
```

**Correct (using WebP):**

```typescript
// assets/images.ts
export const images = {
  hero: require('./hero.webp'),      // 290KB (35% smaller)
  product: require('./product.webp'), // 180KB (36% smaller)
  background: require('./bg.webp'),   // 210KB (34% smaller)
};
// Total: 680KB (35% reduction)
```

**Converting existing images:**

```bash
# Using cwebp (install via Homebrew)
cwebp -q 80 input.jpg -o output.webp

# Batch convert with expo-optimize
npx expo-optimize ./assets
```

**For remote images:** Request WebP from CDN with `f_auto` or `auto=format` parameter.

**Compatibility:** WebP is supported on iOS 14+ and all Android versions. For older iOS, provide JPEG fallback.

Reference: [expo-optimize](https://www.npmjs.com/package/expo-optimize)

---

## 6. Memory Management

**Impact: MEDIUM**

Memory leaks compound over time. Mobile apps stay in memory longer than web. Uncleaned subscriptions and timers cause crashes.

### 6.1 Abort Fetch Requests on Unmount

**Impact: MEDIUM (prevents memory leaks from pending requests)**

Pending fetch requests continue even after unmount. When they resolve, attempting to update state on an unmounted component causes memory leaks. Use AbortController to cancel requests.

**Incorrect (fetch continues after unmount):**

```typescript
// screens/UserProfile.tsx
export function UserProfile({ userId }: Props) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    fetch(`/api/users/${userId}`)
      .then((res) => res.json())
      .then(setUser);  // May run after unmount
  }, [userId]);

  return user ? <ProfileView user={user} /> : <Loading />;
}
// If user navigates away during fetch, response still processed
```

**Correct (abort request on unmount):**

```typescript
// screens/UserProfile.tsx
export function UserProfile({ userId }: Props) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    const controller = new AbortController();

    fetch(`/api/users/${userId}`, { signal: controller.signal })
      .then((res) => res.json())
      .then(setUser)
      .catch((err) => {
        if (err.name !== 'AbortError') throw err;
      });

    return () => {
      controller.abort();
    };
  }, [userId]);

  return user ? <ProfileView user={user} /> : <Loading />;
}
// Request cancelled when component unmounts or userId changes
```

**With async/await:**

```typescript
useEffect(() => {
  const controller = new AbortController();

  async function loadUser() {
    try {
      const res = await fetch(`/api/users/${userId}`, { signal: controller.signal });
      const data = await res.json();
      setUser(data);
    } catch (err) {
      if (err.name !== 'AbortError') throw err;
    }
  }

  loadUser();
  return () => controller.abort();
}, [userId]);
```

Reference: [AbortController](https://developer.mozilla.org/en-US/docs/Web/API/AbortController)

### 6.2 Avoid Inline Objects and Arrays in Props

**Impact: MEDIUM (prevents unnecessary re-renders from new references)**

Inline objects and arrays create new references on every render. When passed as props to memoized components, this defeats memoization and causes unnecessary re-renders.

**Incorrect (new object reference every render):**

```typescript
// screens/SettingsScreen.tsx
export function SettingsScreen() {
  const [darkMode, setDarkMode] = useState(false);

  return (
    <View>
      <Toggle value={darkMode} onChange={setDarkMode} />
      <UserAvatar
        style={{ width: 50, height: 50 }}  // New object every render
        source={{ uri: user.avatarUrl }}   // New object every render
      />
    </View>
  );
}
// UserAvatar re-renders on every darkMode toggle
```

**Correct (stable object references):**

```typescript
// screens/SettingsScreen.tsx
const avatarStyle = { width: 50, height: 50 };

export function SettingsScreen() {
  const [darkMode, setDarkMode] = useState(false);

  const avatarSource = useMemo(
    () => ({ uri: user.avatarUrl }),
    [user.avatarUrl]
  );

  return (
    <View>
      <Toggle value={darkMode} onChange={setDarkMode} />
      <UserAvatar style={avatarStyle} source={avatarSource} />
    </View>
  );
}
// UserAvatar only re-renders when avatarUrl changes
```

**Patterns for stable references:**
- Static styles: Define outside component
- Dynamic values: Use `useMemo`
- Empty arrays: Use module-level `const EMPTY_ARRAY = []`

Reference: [Avoiding Recreating Objects](https://react.dev/reference/react/useMemo#skipping-re-rendering-of-components)

### 6.3 Clean Up Subscriptions in useEffect

**Impact: MEDIUM (prevents memory leaks from orphaned listeners)**

Subscriptions to events, WebSockets, or external services must be cleaned up when the component unmounts. Without cleanup, the subscription continues running and accumulates memory.

**Incorrect (subscription never cleaned up):**

```typescript
// hooks/useNotifications.ts
export function useNotifications() {
  const [notifications, setNotifications] = useState<Notification[]>([]);

  useEffect(() => {
    const subscription = Notifications.addNotificationReceivedListener(
      (notification) => {
        setNotifications((prev) => [...prev, notification]);
      }
    );
    // No cleanup - listener keeps running after unmount
  }, []);

  return notifications;
}
// Each mount adds a new listener, none removed
```

**Correct (cleanup on unmount):**

```typescript
// hooks/useNotifications.ts
export function useNotifications() {
  const [notifications, setNotifications] = useState<Notification[]>([]);

  useEffect(() => {
    const subscription = Notifications.addNotificationReceivedListener(
      (notification) => {
        setNotifications((prev) => [...prev, notification]);
      }
    );

    return () => {
      subscription.remove();
    };
  }, []);

  return notifications;
}
// Listener properly removed when component unmounts
```

**Common subscriptions needing cleanup:**
- Event listeners (keyboard, app state, linking)
- WebSocket connections
- Firebase/Supabase real-time subscriptions
- Notification listeners

Reference: [useEffect cleanup](https://react.dev/learn/synchronizing-with-effects#how-to-handle-the-effect-firing-twice-in-development)

### 6.4 Clear Timers on Unmount

**Impact: MEDIUM (prevents memory leaks and setState errors)**

Timers (setTimeout, setInterval) continue running after unmount. If the callback updates state, it causes "Can't perform state update on unmounted component" errors and memory leaks.

**Incorrect (timer not cleared):**

```typescript
// components/Toast.tsx
export function Toast({ message, duration = 3000 }: Props) {
  const [visible, setVisible] = useState(true);

  useEffect(() => {
    setTimeout(() => {
      setVisible(false);  // Runs even if component unmounted
    }, duration);
  }, [duration]);

  if (!visible) return null;
  return <View style={styles.toast}><Text>{message}</Text></View>;
}
// If user navigates away quickly, setState called on unmounted component
```

**Correct (timer cleared on unmount):**

```typescript
// components/Toast.tsx
export function Toast({ message, duration = 3000 }: Props) {
  const [visible, setVisible] = useState(true);

  useEffect(() => {
    const timeoutId = setTimeout(() => {
      setVisible(false);
    }, duration);

    return () => {
      clearTimeout(timeoutId);
    };
  }, [duration]);

  if (!visible) return null;
  return <View style={styles.toast}><Text>{message}</Text></View>;
}
// Timer cancelled if component unmounts early
```

**For setInterval:**

```typescript
useEffect(() => {
  const intervalId = setInterval(pollForUpdates, 5000);
  return () => clearInterval(intervalId);
}, []);
```

Reference: [React Native Memory Leak Prevention](https://instamobile.io/blog/react-native-memory-leak-fixes/)

### 6.5 Limit List Data in Memory

**Impact: MEDIUM (prevents out-of-memory crashes)**

Storing thousands of items in state consumes significant memory. Implement pagination or windowing to keep only visible data plus a buffer in memory.

**Incorrect (loading all data into memory):**

```typescript
// screens/MessageHistory.tsx
export function MessageHistory({ conversationId }: Props) {
  const [messages, setMessages] = useState<Message[]>([]);

  useEffect(() => {
    // Loads ALL messages - could be 10,000+ items
    fetchAllMessages(conversationId).then(setMessages);
  }, [conversationId]);

  return (
    <FlashList
      data={messages}  // 10,000 items in memory
      renderItem={({ item }) => <MessageBubble message={item} />}
      estimatedItemSize={80}
    />
  );
}
// Memory grows unbounded, crashes on low-end devices
```

**Correct (paginated with cleanup):**

```typescript
// screens/MessageHistory.tsx
const PAGE_SIZE = 50;

export function MessageHistory({ conversationId }: Props) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [cursor, setCursor] = useState<string | null>(null);

  const loadMore = useCallback(async () => {
    const newMessages = await fetchMessages(conversationId, cursor, PAGE_SIZE);
    setMessages((prev) => {
      const combined = [...prev, ...newMessages];
      // Keep max 200 messages in memory
      return combined.slice(-200);
    });
    setCursor(newMessages[newMessages.length - 1]?.id ?? null);
  }, [conversationId, cursor]);

  return (
    <FlashList
      data={messages}
      renderItem={({ item }) => <MessageBubble message={item} />}
      onEndReached={loadMore}
      estimatedItemSize={80}
    />
  );
}
// Memory capped at ~200 items, older items garbage collected
```

**For infinite lists:** Consider using a library like `react-query` with `useInfiniteQuery` that handles pagination automatically.

Reference: [FlatList Performance](https://reactnative.dev/docs/optimizing-flatlist-configuration)

---

## 7. Async & Data Fetching

**Impact: MEDIUM**

Sequential awaits create network waterfalls. AbortController prevents memory leaks on unmount. Parallel fetching reduces load times.

### 7.1 Batch Related API Calls

**Impact: MEDIUM (reduces N requests to 1)**

Making individual API calls for each item creates N network requests. Batch items into a single call when your API supports it to dramatically reduce latency.

**Incorrect (N requests for N items):**

```typescript
// screens/FriendsActivity.tsx
export function FriendsActivity({ friendIds }: Props) {
  const [activities, setActivities] = useState<Activity[]>([]);

  useEffect(() => {
    async function loadActivities() {
      // 10 friends = 10 API calls = 10 round trips
      const results = await Promise.all(
        friendIds.map((id) => fetchActivity(id))
      );
      setActivities(results.flat());
    }
    loadActivities();
  }, [friendIds]);

  return <ActivityFeed activities={activities} />;
}
// 10 requests × 100ms each = 1000ms (even with parallelization)
```

**Correct (1 batched request):**

```typescript
// screens/FriendsActivity.tsx
export function FriendsActivity({ friendIds }: Props) {
  const [activities, setActivities] = useState<Activity[]>([]);

  useEffect(() => {
    async function loadActivities() {
      // Single API call with all IDs
      const results = await fetchActivities(friendIds);
      setActivities(results);
    }
    loadActivities();
  }, [friendIds]);

  return <ActivityFeed activities={activities} />;
}
// 1 request × 150ms = 150ms (85% faster)
```

**API design pattern:**

```typescript
// Instead of: GET /activity/:userId (called N times)
// Use: POST /activities/batch with { userIds: string[] }
```

**Client-side batching:** Libraries like `dataloader` can automatically batch calls within a time window.

Reference: [DataLoader](https://github.com/graphql/dataloader)

### 7.2 Cache API Responses Locally

**Impact: MEDIUM (eliminates redundant network requests)**

Repeated API calls for the same data waste bandwidth and slow down the app. Use a caching library to store and reuse responses.

**Incorrect (fetch on every mount):**

```typescript
// screens/ProductDetails.tsx
export function ProductDetails({ productId }: Props) {
  const [product, setProduct] = useState<Product | null>(null);

  useEffect(() => {
    fetchProduct(productId).then(setProduct);
  }, [productId]);

  // User navigates away and back: fetches again
  return product ? <ProductView product={product} /> : <Loading />;
}
// Same product fetched every time user visits this screen
```

**Correct (cached with TanStack Query):**

```typescript
// screens/ProductDetails.tsx
import { useQuery } from '@tanstack/react-query';

export function ProductDetails({ productId }: Props) {
  const { data: product, isLoading } = useQuery({
    queryKey: ['product', productId],
    queryFn: () => fetchProduct(productId),
    staleTime: 5 * 60 * 1000,  // Consider fresh for 5 minutes
  });

  // Instant display on return visit, background refetch if stale
  return product ? <ProductView product={product} /> : <Loading />;
}
// Cached response shown immediately, refetches in background
```

**Benefits of caching libraries:**
- Automatic deduplication of in-flight requests
- Background refetching when data is stale
- Optimistic updates for mutations
- Request retry on failure

Reference: [TanStack Query](https://tanstack.com/query/latest)

### 7.3 Defer await Until Value Needed

**Impact: MEDIUM (20-50% faster by overlapping async work)**

Start promises immediately but defer `await` until you actually need the value. This allows intermediate synchronous code to run while the promise is pending.

**Incorrect (await blocks immediately):**

```typescript
// screens/CheckoutScreen.tsx
export async function processCheckout(cartId: string, userId: string) {
  const cart = await fetchCart(cartId);  // Blocks here

  // Sync validation could run while cart fetches
  const shippingValid = validateShippingAddress(userId);
  if (!shippingValid) throw new Error('Invalid shipping');

  const inventory = await checkInventory(cart.items);  // Blocks here
  return { cart, inventory };
}
```

**Correct (start early, await late):**

```typescript
// screens/CheckoutScreen.tsx
export async function processCheckout(cartId: string, userId: string) {
  // Start both fetches immediately
  const cartPromise = fetchCart(cartId);
  const inventoryCheck = async () => {
    const cart = await cartPromise;
    return checkInventory(cart.items);
  };

  // Sync validation runs while cart fetches
  const shippingValid = validateShippingAddress(userId);
  if (!shippingValid) throw new Error('Invalid shipping');

  // Now await only when we need the values
  const [cart, inventory] = await Promise.all([
    cartPromise,
    inventoryCheck(),
  ]);

  return { cart, inventory };
}
```

**Key insight:** The promise starts executing when called, not when awaited. Use this to overlap network and computation.

Reference: [Async/Await Best Practices](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Promises)

### 7.4 Fetch Independent Data in Parallel

**Impact: MEDIUM (2-5× faster screen load time)**

Sequential awaits create network waterfalls where each request waits for the previous to complete. Use `Promise.all()` for independent requests to run them concurrently.

**Incorrect (sequential requests, 3 round trips):**

```typescript
// screens/Dashboard.tsx
export function Dashboard({ userId }: Props) {
  const [data, setData] = useState<DashboardData | null>(null);

  useEffect(() => {
    async function loadData() {
      const user = await fetchUser(userId);
      const orders = await fetchOrders(userId);
      const notifications = await fetchNotifications(userId);
      setData({ user, orders, notifications });
    }
    loadData();
  }, [userId]);

  return data ? <DashboardView data={data} /> : <Loading />;
}
// Total time: user + orders + notifications (e.g., 300 + 400 + 200 = 900ms)
```

**Correct (parallel requests, 1 round trip):**

```typescript
// screens/Dashboard.tsx
export function Dashboard({ userId }: Props) {
  const [data, setData] = useState<DashboardData | null>(null);

  useEffect(() => {
    async function loadData() {
      const [user, orders, notifications] = await Promise.all([
        fetchUser(userId),
        fetchOrders(userId),
        fetchNotifications(userId),
      ]);
      setData({ user, orders, notifications });
    }
    loadData();
  }, [userId]);

  return data ? <DashboardView data={data} /> : <Loading />;
}
// Total time: max(user, orders, notifications) (e.g., 400ms)
```

**When NOT to parallelize:** When requests depend on each other (e.g., need user.id for orders).

Reference: [Promise.all](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all)

### 7.5 Refetch Data on Screen Focus

**Impact: MEDIUM (prevents stale data after hours in background)**

Mobile apps stay in background for extended periods. Refetch important data when the screen becomes focused to ensure users see current information.

**Incorrect (data stale after background):**

```typescript
// screens/NotificationsScreen.tsx
export function NotificationsScreen() {
  const [notifications, setNotifications] = useState<Notification[]>([]);

  useEffect(() => {
    fetchNotifications().then(setNotifications);
  }, []);

  // User backgrounds app, returns hours later, sees stale notifications
  return <NotificationList notifications={notifications} />;
}
```

**Correct (refetch on screen focus):**

```typescript
// screens/NotificationsScreen.tsx
import { useFocusEffect } from '@react-navigation/native';

export function NotificationsScreen() {
  const [notifications, setNotifications] = useState<Notification[]>([]);

  useFocusEffect(
    useCallback(() => {
      fetchNotifications().then(setNotifications);
    }, [])
  );

  // Fresh data loaded every time screen becomes visible
  return <NotificationList notifications={notifications} />;
}
```

**With TanStack Query (automatic):**

```typescript
import { useQuery } from '@tanstack/react-query';
import { useFocusEffect } from '@react-navigation/native';

export function NotificationsScreen() {
  const { data: notifications, refetch } = useQuery({
    queryKey: ['notifications'],
    queryFn: fetchNotifications,
  });

  useFocusEffect(useCallback(() => { refetch(); }, [refetch]));

  return <NotificationList notifications={notifications ?? []} />;
}
```

**Note:** Balance freshness with performance. Not every screen needs refetch on focus.

Reference: [useFocusEffect](https://reactnavigation.org/docs/use-focus-effect/)

---

## 8. Platform Optimizations

**Impact: LOW-MEDIUM**

iOS and Android have different performance characteristics. Platform-specific optimizations extract maximum performance from each OS.

### 8.1 Enable ProGuard for Android Release

**Impact: LOW-MEDIUM (10-20% smaller APK size)**

ProGuard shrinks, obfuscates, and optimizes Android code. It removes unused Java/Kotlin code from your APK, reducing size and improving load time.

**Incorrect (ProGuard disabled):**

```groovy
// android/app/build.gradle
android {
    buildTypes {
        release {
            minifyEnabled false
            shrinkResources false
        }
    }
}
// Full APK includes all library code, even unused
```

**Correct (ProGuard enabled):**

```groovy
// android/app/build.gradle
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

```proguard
# android/app/proguard-rules.pro
# Keep React Native
-keep class com.facebook.react.** { *; }
-keep class com.facebook.hermes.** { *; }

# Keep your app's models
-keep class com.yourapp.models.** { *; }

# Common rules for libraries
-dontwarn okio.**
-dontwarn javax.annotation.**
```

**Benefits:**
- 10-20% smaller APK
- Code obfuscation for security
- Dead code elimination

**Note:** Test thoroughly after enabling—ProGuard can break reflection-based code.

Reference: [Enable Proguard](https://reactnative.dev/docs/signed-apk-android#enabling-proguard-to-reduce-the-size-of-the-apk-optional)

### 8.2 Optimize iOS Text Rendering

**Impact: LOW-MEDIUM (faster text layout on iOS)**

iOS Text components can be expensive to render, especially with custom fonts or complex layouts. Use `allowFontScaling={false}` for fixed-size text and avoid unnecessary text nesting.

**Incorrect (nested Text, slow layout):**

```typescript
// components/PriceDisplay.tsx
export function PriceDisplay({ price, currency }: Props) {
  return (
    <View>
      <Text style={styles.price}>
        <Text style={styles.currency}>{currency}</Text>
        <Text style={styles.amount}>{price.toFixed(2)}</Text>
        <Text style={styles.decimal}>.{(price % 1).toFixed(2).slice(2)}</Text>
      </Text>
    </View>
  );
}
// Nested Text requires multiple layout passes
```

**Correct (flat structure, optimized):**

```typescript
// components/PriceDisplay.tsx
export function PriceDisplay({ price, currency }: Props) {
  const formattedPrice = `${currency}${price.toFixed(2)}`;

  return (
    <Text
      style={styles.price}
      allowFontScaling={false}  // Skip accessibility scaling calculation
      numberOfLines={1}         // Single line, skip line break calculation
    >
      {formattedPrice}
    </Text>
  );
}
// Single Text node, minimal layout calculation
```

**When to use `allowFontScaling={false}`:**
- Icons and logos
- Fixed-size UI elements
- Performance-critical list items

**Note:** Don't disable font scaling for body text—accessibility matters.

Reference: [Text Component](https://reactnative.dev/docs/text)

### 8.3 Reduce Android Overdraw

**Impact: LOW-MEDIUM (20-30% rendering improvement on Android)**

Overdraw occurs when the same pixel is drawn multiple times per frame. On Android, excessive overdraw significantly impacts performance. Remove unnecessary backgrounds and flatten view hierarchies.

**Incorrect (multiple overlapping backgrounds):**

```typescript
// components/ProductCard.tsx
export function ProductCard({ product }: Props) {
  return (
    <View style={{ backgroundColor: 'white' }}>
      <View style={{ backgroundColor: 'white', padding: 16 }}>
        <View style={{ backgroundColor: '#f5f5f5', borderRadius: 8 }}>
          <Image source={{ uri: product.image }} style={styles.image} />
        </View>
        <View style={{ backgroundColor: 'white' }}>
          <Text>{product.name}</Text>
        </View>
      </View>
    </View>
  );
}
// Same pixels painted 3-4 times per frame
```

**Correct (single background, flat hierarchy):**

```typescript
// components/ProductCard.tsx
export function ProductCard({ product }: Props) {
  return (
    <View style={styles.card}>
      <Image source={{ uri: product.image }} style={styles.image} />
      <Text style={styles.name}>{product.name}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: 'white',
    padding: 16,
    borderRadius: 8,
  },
  image: { /* ... */ },
  name: { /* ... */ },
});
// Each pixel painted only once
```

**Debug overdraw on Android:**
1. Developer Options > Debug GPU Overdraw
2. Blue = 1× overdraw, Green = 2×, Pink = 3×, Red = 4×
3. Target: mostly blue with minimal green

Reference: [Android Overdraw](https://developer.android.com/topic/performance/rendering/overdraw)

### 8.4 Use Platform-Specific Optimizations Conditionally

**Impact: LOW-MEDIUM (2-3× better performance on target platform)**

iOS and Android have different performance characteristics. Apply platform-specific optimizations where they matter most.

**Incorrect (same approach for both platforms):**

```typescript
// components/AnimatedCard.tsx
import { Animated } from 'react-native';

export function AnimatedCard({ children, visible }: Props) {
  const opacity = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(opacity, {
      toValue: visible ? 1 : 0,
      duration: 300,
      // Can't use native driver with shadow on Android
      useNativeDriver: true,
    }).start();
  }, [visible]);

  return (
    <Animated.View style={[styles.card, { opacity }]}>
      {children}
    </Animated.View>
  );
}
```

**Correct (platform-optimized):**

```typescript
// components/AnimatedCard.tsx
import { Platform, Animated } from 'react-native';
import Reanimated, { useAnimatedStyle, withTiming } from 'react-native-reanimated';

export function AnimatedCard({ children, visible }: Props) {
  // iOS: Use Animated API (lightweight for simple opacity)
  // Android: Use Reanimated (better performance with shadows)
  const AnimatedContainer = Platform.select({
    ios: AnimatedContainerIOS,
    android: AnimatedContainerAndroid,
  })!;

  return <AnimatedContainer visible={visible}>{children}</AnimatedContainer>;
}

function AnimatedContainerIOS({ children, visible }: Props) {
  const opacity = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    Animated.timing(opacity, {
      toValue: visible ? 1 : 0,
      duration: 300,
      useNativeDriver: true,
    }).start();
  }, [visible]);
  return <Animated.View style={{ opacity }}>{children}</Animated.View>;
}

function AnimatedContainerAndroid({ children, visible }: Props) {
  const style = useAnimatedStyle(() => ({
    opacity: withTiming(visible ? 1 : 0, { duration: 300 }),
  }));
  return <Reanimated.View style={style}>{children}</Reanimated.View>;
}
```

**Common platform differences:**
- Shadow rendering (expensive on Android)
- List scrolling (FlashList critical on Android)
- Font rendering (iOS more efficient)

Reference: [Platform Module](https://reactnative.dev/docs/platform-specific-code)

---

## References

1. [https://reactnative.dev/docs/performance](https://reactnative.dev/docs/performance)
2. [https://expo.dev/blog/best-practices-for-reducing-lag-in-expo-apps](https://expo.dev/blog/best-practices-for-reducing-lag-in-expo-apps)
3. [https://shopify.github.io/flash-list/](https://shopify.github.io/flash-list/)
4. [https://docs.swmansion.com/react-native-reanimated/docs/guides/performance/](https://docs.swmansion.com/react-native-reanimated/docs/guides/performance/)
5. [https://www.callstack.com/ebooks/the-ultimate-guide-to-react-native-optimization](https://www.callstack.com/ebooks/the-ultimate-guide-to-react-native-optimization)
6. [https://reactnative.dev/docs/hermes](https://reactnative.dev/docs/hermes)
7. [https://docs.expo.dev/versions/latest/sdk/image/](https://docs.expo.dev/versions/latest/sdk/image/)
8. [https://docs.expo.dev/versions/latest/sdk/splash-screen/](https://docs.expo.dev/versions/latest/sdk/splash-screen/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |