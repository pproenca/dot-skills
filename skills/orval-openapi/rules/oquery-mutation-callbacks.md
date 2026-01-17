---
title: Use Generated Mutation Options Types
impact: MEDIUM
impactDescription: enables type-safe onSuccess/onError callbacks
tags: query, react-query, mutation, callbacks
---

## Use Generated Mutation Options Types

Use the generated mutation options types for type-safe callbacks. This ensures your onSuccess data and onError error are properly typed.

**Incorrect (untyped callbacks):**

```typescript
const createUser = useCreateUser({
  onSuccess: (data) => {
    // data is typed as unknown or any
    console.log(data.id);  // No autocomplete, no type checking
  },
  onError: (error) => {
    // error is unknown
    toast.error(error.message);  // TypeScript error
  },
});
```

**Correct (using generated types):**

```typescript
import { useCreateUser, type CreateUserMutationResult } from '@/api/users';

const createUser = useCreateUser({
  onSuccess: (data) => {
    // data is properly typed as User
    console.log(data.id);  // Autocomplete works
    toast.success(`Created user ${data.email}`);
  },
  onError: (error) => {
    // error is typed as ErrorType<ApiError>
    const message = error.response?.data?.message ?? 'Creation failed';
    toast.error(message);
  },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: getGetUsersQueryKey() });
  },
});
```

**With optimistic updates:**

```typescript
const updateUser = useUpdateUser({
  onMutate: async (variables) => {
    // variables is typed as UpdateUserBody
    await queryClient.cancelQueries({ queryKey: getGetUserQueryKey(variables.id) });

    const previousUser = queryClient.getQueryData<User>(
      getGetUserQueryKey(variables.id)
    );

    queryClient.setQueryData(getGetUserQueryKey(variables.id), {
      ...previousUser,
      ...variables,
    });

    return { previousUser };
  },
  onError: (error, variables, context) => {
    // Rollback on error
    if (context?.previousUser) {
      queryClient.setQueryData(
        getGetUserQueryKey(variables.id),
        context.previousUser
      );
    }
  },
});
```

Reference: [TanStack Mutations](https://tanstack.com/query/latest/docs/framework/react/guides/mutations)
