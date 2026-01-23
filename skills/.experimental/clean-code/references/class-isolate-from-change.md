---
title: Isolate Classes from Change
impact: MEDIUM
impactDescription: enables testing and reduces coupling
tags: class, dip, interfaces, coupling
---

## Isolate Classes from Change

Depend on abstractions, not concretions. Classes should depend on interfaces rather than concrete implementations. This enables testing and reduces the impact of change.

**Incorrect (depends on concrete implementation):**

```java
public class Portfolio {
    private NYSEStockExchange exchange;

    public Portfolio(NYSEStockExchange exchange) {
        this.exchange = exchange;
    }

    public Money value() {
        Money total = Money.ZERO;
        for (String symbol : holdings.keySet()) {
            // Cannot test without real stock exchange connection
            total = total.plus(exchange.currentPrice(symbol)
                                .times(holdings.get(symbol)));
        }
        return total;
    }
}
```

**Correct (depends on abstraction):**

```java
public interface StockExchange {
    Money currentPrice(String symbol);
}

public class Portfolio {
    private StockExchange exchange;

    public Portfolio(StockExchange exchange) {
        this.exchange = exchange;
    }

    public Money value() {
        Money total = Money.ZERO;
        for (String symbol : holdings.keySet()) {
            total = total.plus(exchange.currentPrice(symbol)
                                .times(holdings.get(symbol)));
        }
        return total;
    }
}

// Production
Portfolio portfolio = new Portfolio(new NYSEStockExchange());

// Testing
@Test
public void portfolioValueShouldSumAllHoldings() {
    StockExchange mockExchange = mock(StockExchange.class);
    when(mockExchange.currentPrice("AAPL")).thenReturn(Money.dollars(150));

    Portfolio portfolio = new Portfolio(mockExchange);
    portfolio.add("AAPL", 10);

    assertEquals(Money.dollars(1500), portfolio.value());
}
```

**Dependency Inversion Principle (DIP):** High-level modules should not depend on low-level modules. Both should depend on abstractions.

Reference: [Clean Code, Chapter 10: Classes](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
