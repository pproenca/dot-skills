---
title: Separate Container and Presentational Concerns
impact: MEDIUM
impactDescription: Enables design system reuse; keeps business logic testable
tags: comp, container, presentational, separation
---

## Separate Container and Presentational Concerns

Distinguish between components that manage data/state (containers) and components that render UI (presentational). Presentational components are reusable and easy to test; containers coordinate business logic.

**Incorrect (mixed concerns):**

```typescript
// Component does everything - hard to reuse or test
function UserCard() {
  const [user, setUser] = useState<User | null>(null);
  const [isEditing, setIsEditing] = useState(false);

  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);

  const handleSave = async (data: UserData) => {
    await updateUser(userId, data);
    setUser({ ...user, ...data });
    setIsEditing(false);
  };

  if (!user) return <Loading />;

  return (
    <div className="card">
      {isEditing ? (
        <UserForm user={user} onSave={handleSave} />
      ) : (
        <>
          <Avatar src={user.avatar} />
          <h2>{user.name}</h2>
          <p>{user.email}</p>
          <button onClick={() => setIsEditing(true)}>Edit</button>
        </>
      )}
    </div>
  );
}
```

**Correct (separated concerns):**

```typescript
// Presentational - pure rendering, easy to test and reuse
interface UserCardProps {
  user: User;
  onEdit: () => void;
}

function UserCard({ user, onEdit }: UserCardProps) {
  return (
    <div className="card">
      <Avatar src={user.avatar} />
      <h2>{user.name}</h2>
      <p>{user.email}</p>
      <button onClick={onEdit}>Edit</button>
    </div>
  );
}

// Container - manages data and state
function UserCardContainer({ userId }: { userId: string }) {
  const { data: user, isLoading } = useUser(userId);
  const [isEditing, setIsEditing] = useState(false);
  const updateMutation = useUpdateUser();

  if (isLoading) return <UserCardSkeleton />;

  if (isEditing) {
    return (
      <UserForm
        user={user}
        onSave={(data) => {
          updateMutation.mutate({ userId, data });
          setIsEditing(false);
        }}
        onCancel={() => setIsEditing(false)}
      />
    );
  }

  return <UserCard user={user} onEdit={() => setIsEditing(true)} />;
}
```

**Benefits:**
- UserCard can be used in Storybook, tests, anywhere
- Business logic is concentrated in container
- Presentational components are pure functions of props

Reference: [React Patterns - Container/Presentational](https://reactpatterns.com/)
