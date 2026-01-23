---
title: Use Mappers to Translate Between Layers
impact: MEDIUM
impactDescription: decouples domain from persistence and presentation models
tags: adapt, mapper, translation, layers
---

## Use Mappers to Translate Between Layers

Mappers translate between domain entities and external representations (database rows, API responses, DTOs). Each layer has its own model; mappers bridge them.

**Incorrect (domain entity used everywhere):**

```typescript
// Domain entity directly serialized to JSON and stored in DB
class User {
  id: string
  email: string
  passwordHash: string  // Exposed in API response!
  createdAt: Date
  lastLogin: Date
  preferences: UserPreferences
  roles: Role[]

  toJSON() {
    return { ...this }  // Leaks everything
  }
}

// Controller returns entity directly
app.get('/users/:id', (req, res) => {
  const user = userRepo.findById(req.params.id)
  res.json(user)  // passwordHash in response!
})

// ORM couples domain to database schema
@Entity()
class User {
  @PrimaryColumn() id: string
  @Column() email: string
  // Domain entity is now a database entity
}
```

**Correct (dedicated models per layer with mappers):**

```typescript
// domain/User.ts - Pure domain entity
class User {
  constructor(
    readonly id: UserId,
    private email: Email,
    private passwordHash: PasswordHash,
    private roles: Set<Role>
  ) {}

  hasRole(role: Role): boolean {
    return this.roles.has(role)
  }
}

// infrastructure/persistence/UserEntity.ts - Database model
interface UserRow {
  id: string
  email: string
  password_hash: string
  roles: string  // JSON array in DB
  created_at: string
  updated_at: string
}

// infrastructure/persistence/UserMapper.ts
class UserMapper {
  toDomain(row: UserRow): User {
    return new User(
      new UserId(row.id),
      Email.create(row.email),
      new PasswordHash(row.password_hash),
      new Set(JSON.parse(row.roles))
    )
  }

  toPersistence(user: User): UserRow {
    return {
      id: user.id.value,
      email: user.email.value,
      password_hash: user.passwordHash.value,
      roles: JSON.stringify([...user.roles]),
      updated_at: new Date().toISOString()
    }
  }
}

// interface/dto/UserResponse.ts - API response model
interface UserResponse {
  id: string
  email: string
  roles: string[]
  // No passwordHash!
}

// interface/mappers/UserResponseMapper.ts
class UserResponseMapper {
  toResponse(user: User): UserResponse {
    return {
      id: user.id.value,
      email: user.email.value,
      roles: [...user.roles]
    }
  }
}
```

**Benefits:**
- Database schema changes don't affect domain
- API can evolve independently of domain model
- Sensitive data never accidentally exposed

Reference: [Data Mapper Pattern](https://martinfowler.com/eaaCatalog/dataMapper.html)
