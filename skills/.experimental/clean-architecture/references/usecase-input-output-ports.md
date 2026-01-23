---
title: Define Input and Output Ports for Use Cases
impact: HIGH
impactDescription: decouples use cases from delivery mechanism
tags: usecase, ports, input, output, boundaries
---

## Define Input and Output Ports for Use Cases

Use cases should define their own input (request) and output (response) data structures. These ports isolate the use case from the delivery mechanism (HTTP, CLI, queue).

**Incorrect (use case coupled to HTTP):**

```csharp
public class RegisterUserUseCase
{
    public IActionResult Execute(HttpRequest request)  // Coupled to ASP.NET
    {
        var email = request.Form["email"];
        var password = request.Form["password"];

        if (string.IsNullOrEmpty(email))
            return new BadRequestResult();  // HTTP-specific response

        var user = new User(email, password);
        _repository.Save(user);

        return new OkObjectResult(new { id = user.Id });  // JSON response
    }
}
```

**Correct (use case with defined ports):**

```csharp
// application/ports/input/RegisterUserCommand.cs
public record RegisterUserCommand(
    string Email,
    string Password,
    string Name
);

// application/ports/output/RegisterUserResult.cs
public record RegisterUserResult(
    string UserId,
    string Email,
    DateTime CreatedAt
);

// application/usecases/RegisterUserUseCase.cs
public class RegisterUserUseCase
{
    private readonly IUserRepository _repository;
    private readonly IPasswordHasher _hasher;

    public RegisterUserResult Execute(RegisterUserCommand command)
    {
        if (string.IsNullOrEmpty(command.Email))
            throw new ValidationException("Email required");

        var hashedPassword = _hasher.Hash(command.Password);
        var user = new User(command.Email, hashedPassword, command.Name);
        _repository.Save(user);

        return new RegisterUserResult(
            user.Id.Value,
            user.Email.Value,
            user.CreatedAt
        );
    }
}

// interface_adapters/controllers/UserController.cs
[ApiController]
public class UserController : ControllerBase
{
    [HttpPost]
    public IActionResult Register([FromBody] RegisterRequest request)
    {
        var command = new RegisterUserCommand(
            request.Email,
            request.Password,
            request.Name
        );

        var result = _useCase.Execute(command);

        return Ok(new { userId = result.UserId });
    }
}
```

**Benefits:**
- Same use case callable from HTTP, CLI, message queue, tests
- Request/response format changes don't affect use case
- Use case testable without HTTP infrastructure

Reference: [Clean Architecture - Input/Output Ports](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
