---
title: Use SQLite for Complex Local Data
impact: HIGH
impactDescription: enables offline-first apps with relational queries
tags: data, sqlite, storage, offline
---

## Use SQLite for Complex Local Data

Use `expo-sqlite` for complex data that needs queries, relationships, or offline support. It persists across app restarts.

**Incorrect (AsyncStorage for relational data):**

```typescript
// Storing complex data as JSON strings - no queries possible
await AsyncStorage.setItem('users', JSON.stringify(users));
await AsyncStorage.setItem('posts', JSON.stringify(posts));
// Can't query "posts by user" without loading everything
```

**Correct (SQLite with proper schema):**

```typescript
import * as SQLite from 'expo-sqlite';

// Open database (creates if doesn't exist)
const db = await SQLite.openDatabaseAsync('myapp.db');

// Create tables
await db.execAsync(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE
  );
  CREATE TABLE IF NOT EXISTS posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    title TEXT NOT NULL,
    body TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
  );
`);

// Insert data
async function createPost(userId: number, title: string, body: string) {
  const result = await db.runAsync(
    'INSERT INTO posts (user_id, title, body) VALUES (?, ?, ?)',
    [userId, title, body]
  );
  return result.lastInsertRowId;
}

// Query data
async function getPostsByUser(userId: number) {
  return await db.getAllAsync<{ id: number; title: string; body: string }>(
    'SELECT id, title, body FROM posts WHERE user_id = ? ORDER BY created_at DESC',
    [userId]
  );
}

// Use in component
export default function UserPostsScreen() {
  const { userId } = useLocalSearchParams<{ userId: string }>();
  const [posts, setPosts] = useState<Post[]>([]);

  useEffect(() => {
    getPostsByUser(Number(userId)).then(setPosts);
  }, [userId]);

  return <FlashList data={posts} ... />;
}
```

**Alternative:** Use `expo-sqlite/kv-store` as a drop-in AsyncStorage replacement with synchronous APIs.

Reference: [SQLite - Expo Documentation](https://docs.expo.dev/versions/latest/sdk/sqlite/)
