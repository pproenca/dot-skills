---
title: Treat Main as a Plugin to the Application
impact: MEDIUM-HIGH
impactDescription: enables multiple configurations, simplifies testing
tags: bound, main, composition-root, plugin
---

## Treat Main as a Plugin to the Application

The Main component is the lowest-level, dirtiest component. It creates all factories, strategies, and global facilities, then hands control to high-level abstractions. Treat it as a plugin that can be swapped.

**Incorrect (Main mixed with application logic):**

```go
// main.go
func main() {
    db := connectDatabase()

    // Business logic in main
    http.HandleFunc("/orders", func(w http.ResponseWriter, r *http.Request) {
        var order Order
        json.NewDecoder(r.Body).Decode(&order)

        // Validation logic
        if order.Total < 0 {
            http.Error(w, "Invalid total", 400)
            return
        }

        // Direct database calls
        db.Exec("INSERT INTO orders ...")

        // Response formatting
        json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
    })

    http.ListenAndServe(":8080", nil)
}
// Cannot test without starting HTTP server
// Cannot run with different database
```

**Correct (Main as composition root):**

```go
// main.go - Production entry point
func main() {
    app := bootstrap(ProductionConfig{
        DatabaseURL: os.Getenv("DATABASE_URL"),
        Port:        os.Getenv("PORT"),
    })
    app.Run()
}

// bootstrap.go - Composition root
func bootstrap(config Config) *Application {
    // Create infrastructure
    db := postgres.NewConnection(config.DatabaseURL)

    // Create repositories (implement domain interfaces)
    orderRepo := postgres.NewOrderRepository(db)
    userRepo := postgres.NewUserRepository(db)

    // Create use cases (depend on interfaces)
    placeOrder := usecases.NewPlaceOrderUseCase(orderRepo)
    getOrders := usecases.NewGetOrdersUseCase(orderRepo)

    // Create controllers (call use cases)
    orderController := controllers.NewOrderController(placeOrder, getOrders)

    // Wire up HTTP routes
    router := http.NewRouter()
    router.POST("/orders", orderController.Create)
    router.GET("/orders", orderController.List)

    return &Application{
        Router: router,
        Port:   config.Port,
    }
}

// main_test.go - Test entry point
func TestMain(t *testing.T) {
    app := bootstrap(TestConfig{
        DatabaseURL: "memory://",  // In-memory for tests
        Port:        "0",          // Random port
    })
    // Test against app
}

// main_dev.go - Development entry point
func main() {
    app := bootstrap(DevConfig{
        DatabaseURL: "localhost:5432",
        Port:        "3000",
    })
    app.RunWithHotReload()
}
```

**Benefits:**
- Swap database, logging, configuration per environment
- Integration tests use real wiring with test doubles
- Dev/staging/prod share same composition logic

Reference: [Clean Architecture - The Main Component](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch26.xhtml)
