---
title: Separate Error Handling from Business Logic
impact: MEDIUM
impactDescription: reduces function complexity by 30-50%
tags: error, separation, clean-code, try-catch
---

## Separate Error Handling from Business Logic

Functions should do one thing. Mixing error handling with business logic obscures both. Extract error handling to wrapper functions or middleware.

**Incorrect (error handling mixed with logic):**

```typescript
async function createUserAccount(data: UserData): Promise<User | null> {
  try {
    // Validation mixed with error handling
    try {
      validateEmail(data.email)
    } catch (e) {
      logger.error('Invalid email', { email: data.email, error: e })
      notifyAdmin('Invalid email attempt', data)
      return null
    }

    // Business logic mixed with error handling
    const existingUser = await userRepository.findByEmail(data.email)
    if (existingUser) {
      try {
        await sendDuplicateAccountEmail(data.email)
      } catch (emailError) {
        logger.warn('Failed to send duplicate email', { error: emailError })
        // Continue anyway
      }
      return null
    }

    try {
      const user = await userRepository.create(data)
      try {
        await sendWelcomeEmail(user)
      } catch (welcomeError) {
        logger.warn('Welcome email failed', { userId: user.id })
      }
      return user
    } catch (createError) {
      logger.error('User creation failed', { error: createError })
      throw createError
    }
  } catch (error) {
    logger.error('Unexpected error', { error })
    return null
  }
}
```

**Correct (separated concerns):**

```typescript
// Pure business logic - no error handling
async function createUserAccount(data: UserData): Promise<User> {
  validateUserData(data)

  const existingUser = await userRepository.findByEmail(data.email)
  if (existingUser) {
    throw new DuplicateUserError(data.email)
  }

  const user = await userRepository.create(data)
  await notificationService.sendWelcomeEmail(user)

  return user
}

// Validation in its own function
function validateUserData(data: UserData): void {
  if (!isValidEmail(data.email)) {
    throw new ValidationError('Invalid email format')
  }
  if (!data.password || data.password.length < 8) {
    throw new ValidationError('Password must be at least 8 characters')
  }
}

// Error handling wrapper
async function handleCreateUserAccount(data: UserData): Promise<User | null> {
  try {
    return await createUserAccount(data)
  } catch (error) {
    return handleUserCreationError(error, data)
  }
}

function handleUserCreationError(error: Error, data: UserData): null {
  if (error instanceof ValidationError) {
    logger.warn('Validation failed', { email: data.email, error: error.message })
  } else if (error instanceof DuplicateUserError) {
    logger.info('Duplicate user attempt', { email: data.email })
    sendDuplicateAccountEmail(data.email).catch(e =>
      logger.warn('Failed to send duplicate email', { error: e })
    )
  } else {
    logger.error('User creation failed', { error })
  }
  return null
}
```

**Benefits:**
- Business logic is clear and testable
- Error handling is consistent and centralized
- Easy to modify error handling without touching business logic

Reference: [Clean Code - Error Handling](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
