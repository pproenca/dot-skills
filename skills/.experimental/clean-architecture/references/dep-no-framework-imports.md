---
title: Avoid Framework Imports in Inner Layers
impact: CRITICAL
impactDescription: prevents framework lock-in, enables 10× faster unit tests
tags: dep, frameworks, imports, isolation
---

## Avoid Framework Imports in Inner Layers

Entities and use cases must never import framework-specific types. Framework dependencies in inner layers create tight coupling that makes testing slow and migration impossible.

**Incorrect (use case imports framework types):**

```csharp
// Application/UseCases/ProcessPaymentUseCase.cs
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;
using Newtonsoft.Json;

public class ProcessPaymentUseCase
{
    private readonly DbContext _context;  // EF Core dependency
    private readonly IHttpContextAccessor _http;  // ASP.NET dependency

    public async Task Execute(PaymentRequest request)
    {
        var userId = _http.HttpContext.User.Identity.Name;
        var payment = JsonConvert.DeserializeObject<Payment>(request.Data);
        _context.Payments.Add(payment);
        await _context.SaveChangesAsync();
    }
}
```

**Correct (use case depends only on abstractions):**

```csharp
// Application/UseCases/ProcessPaymentUseCase.cs
// No framework imports

public class ProcessPaymentUseCase
{
    private readonly IPaymentRepository _payments;
    private readonly ICurrentUserProvider _currentUser;

    public async Task Execute(PaymentCommand command)
    {
        var userId = _currentUser.GetUserId();
        var payment = new Payment(command.Amount, command.Currency, userId);
        await _payments.Save(payment);
    }
}

// Infrastructure/Persistence/EfPaymentRepository.cs
using Microsoft.EntityFrameworkCore;

public class EfPaymentRepository : IPaymentRepository
{
    private readonly DbContext _context;
    // Framework usage isolated to infrastructure
}
```

**Benefits:**
- Use case tests run without framework bootstrapping
- Framework can be upgraded or replaced independently
- Business logic remains readable without framework noise

Reference: [Clean Architecture - Frameworks are Details](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
