---
title: Use Simple Data Structures Across Boundaries
impact: CRITICAL
impactDescription: prevents coupling between layers
tags: dep, boundaries, dto, data-transfer
---

## Use Simple Data Structures Across Boundaries

Data crossing architectural boundaries should be simple, isolated data structures. Never pass entities, database rows, or framework objects across boundaries.

**Incorrect (entity crosses boundary):**

```python
# domain/entities/user.py
class User:
    def __init__(self, id, email, password_hash, created_at):
        self.id = id
        self.email = email
        self.password_hash = password_hash  # Sensitive data
        self.created_at = created_at

# interface_adapters/controllers/user_controller.py
class UserController:
    def get_user(self, user_id):
        user = self.use_case.get_user(user_id)
        return jsonify(user.__dict__)  # Entity exposed to HTTP layer, leaks password_hash
```

**Correct (DTOs cross boundaries):**

```python
# application/dto/user_response.py
@dataclass
class UserResponse:
    id: str
    email: str
    member_since: str  # Formatted for presentation

# application/usecases/get_user.py
class GetUserUseCase:
    def execute(self, user_id: str) -> UserResponse:
        user = self.repository.find_by_id(user_id)
        return UserResponse(
            id=user.id,
            email=user.email,
            member_since=user.created_at.strftime("%B %Y")
        )

# interface_adapters/controllers/user_controller.py
class UserController:
    def get_user(self, user_id):
        response = self.use_case.execute(user_id)
        return jsonify(asdict(response))  # Only safe, formatted data
```

**When NOT to use this pattern:**
- Within the same architectural layer, entities can flow freely
- Performance-critical paths may need optimized data transfer

Reference: [Clean Architecture - Crossing Boundaries](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
