---
title: Abstract Logging Behind Domain Interfaces
impact: MEDIUM
impactDescription: prevents logging framework coupling, enables structured logging
tags: frame, logging, abstraction, cross-cutting
---

## Abstract Logging Behind Domain Interfaces

Logging frameworks are infrastructure details. Define logging interfaces in the application layer; implement them in infrastructure. This enables switching loggers and keeps domain pure.

**Incorrect (logging framework in domain/application):**

```go
package usecases

import (
    "github.com/sirupsen/logrus"  // Framework dependency
)

type CreateOrderUseCase struct {
    repo   OrderRepository
    logger *logrus.Logger  // Concrete logger
}

func (uc *CreateOrderUseCase) Execute(cmd CreateOrderCommand) (*Order, error) {
    uc.logger.WithFields(logrus.Fields{
        "customer_id": cmd.CustomerID,
        "item_count":  len(cmd.Items),
    }).Info("Creating order")

    order, err := uc.repo.Create(cmd)
    if err != nil {
        uc.logger.WithError(err).Error("Failed to create order")
        return nil, err
    }

    uc.logger.WithField("order_id", order.ID).Info("Order created")
    return order, nil
}

// Switching from logrus to zap requires changing all use cases
```

**Correct (logging behind interface):**

```go
// application/ports/logger.go
package ports

type Logger interface {
    Info(msg string, fields ...Field)
    Error(msg string, err error, fields ...Field)
    Debug(msg string, fields ...Field)
}

type Field struct {
    Key   string
    Value interface{}
}

func F(key string, value interface{}) Field {
    return Field{Key: key, Value: value}
}

// application/usecases/create_order.go
package usecases

import "myapp/application/ports"

type CreateOrderUseCase struct {
    repo   OrderRepository
    logger ports.Logger
}

func (uc *CreateOrderUseCase) Execute(cmd CreateOrderCommand) (*Order, error) {
    uc.logger.Info("Creating order",
        ports.F("customer_id", cmd.CustomerID),
        ports.F("item_count", len(cmd.Items)),
    )

    order, err := uc.repo.Create(cmd)
    if err != nil {
        uc.logger.Error("Failed to create order", err,
            ports.F("customer_id", cmd.CustomerID),
        )
        return nil, err
    }

    uc.logger.Info("Order created", ports.F("order_id", order.ID))
    return order, nil
}

// infrastructure/logging/logrus_logger.go
package logging

import (
    "github.com/sirupsen/logrus"
    "myapp/application/ports"
)

type LogrusLogger struct {
    logger *logrus.Logger
}

func (l *LogrusLogger) Info(msg string, fields ...ports.Field) {
    l.logger.WithFields(toLogrusFields(fields)).Info(msg)
}

func toLogrusFields(fields []ports.Field) logrus.Fields {
    result := logrus.Fields{}
    for _, f := range fields {
        result[f.Key] = f.Value
    }
    return result
}

// infrastructure/logging/zap_logger.go - Alternative implementation
// Switch without touching use cases
```

**Benefits:**
- Application code doesn't import logging frameworks
- Easy to switch logging backends
- Test logging by asserting on mock logger calls

Reference: [Clean Architecture - Frameworks are Details](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
