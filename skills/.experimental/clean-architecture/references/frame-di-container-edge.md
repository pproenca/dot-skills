---
title: Dependency Injection Containers Live at the Edge
impact: MEDIUM
impactDescription: prevents DI container coupling throughout codebase
tags: frame, dependency-injection, container, composition
---

## Dependency Injection Containers Live at the Edge

DI containers are infrastructure. Use them at composition root (main/startup) to wire dependencies, but don't let them invade domain or application code.

**Incorrect (DI container throughout codebase):**

```csharp
// Domain depends on DI container
using Microsoft.Extensions.DependencyInjection;

public class Order
{
    public void Process()
    {
        // Service locator anti-pattern
        var emailService = ServiceLocator.Current.GetService<IEmailService>();
        var logger = ServiceLocator.Current.GetService<ILogger>();

        // ...
    }
}

// Application layer decorated with DI attributes
public class CreateOrderUseCase
{
    [Inject]
    public IOrderRepository Orders { get; set; }

    [Inject]
    public IPaymentGateway Payments { get; set; }

    // Properties injected by container - hidden dependencies
}

// Switching DI containers requires touching domain code
```

**Correct (DI container only at composition root):**

```csharp
// Domain - no DI container knowledge
public class Order
{
    public void Process(IEmailService email, ILogger logger)
    {
        // Dependencies passed explicitly
    }
}

// Application - constructor injection, no container knowledge
public class CreateOrderUseCase
{
    private readonly IOrderRepository _orders;
    private readonly IPaymentGateway _payments;

    // Plain constructor - works with any DI container or manual wiring
    public CreateOrderUseCase(
        IOrderRepository orders,
        IPaymentGateway payments)
    {
        _orders = orders;
        _payments = payments;
    }
}

// Composition root - only place that knows about DI container
// Program.cs or Startup.cs
public class CompositionRoot
{
    public static IServiceProvider ConfigureServices()
    {
        var services = new ServiceCollection();

        // Infrastructure
        services.AddScoped<IOrderRepository, PostgresOrderRepository>();
        services.AddScoped<IPaymentGateway, StripePaymentGateway>();
        services.AddScoped<IEmailService, SendGridEmailService>();

        // Application
        services.AddScoped<CreateOrderUseCase>();
        services.AddScoped<GetOrdersUseCase>();

        // Interface
        services.AddScoped<OrderController>();

        return services.BuildServiceProvider();
    }
}

// For tests - manual wiring without container
[Test]
public void CreatesOrder()
{
    var orders = new InMemoryOrderRepository();
    var payments = new FakePaymentGateway();
    var useCase = new CreateOrderUseCase(orders, payments);

    useCase.Execute(command);

    Assert.That(orders.All(), Has.Count.EqualTo(1));
}
```

**Benefits:**
- Domain and application code portable across DI containers
- Tests don't need DI container setup
- Dependencies explicit in constructors

Reference: [Composition Root Pattern](https://blog.ploeh.dk/2011/07/28/CompositionRoot/)
