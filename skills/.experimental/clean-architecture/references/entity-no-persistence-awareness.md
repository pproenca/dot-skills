---
title: Entities Must Not Know How They Are Persisted
impact: CRITICAL
impactDescription: enables database migration without domain changes
tags: entity, persistence, database, ignorance
---

## Entities Must Not Know How They Are Persisted

Entities should have no awareness of databases, ORMs, or storage mechanisms. Persistence is an infrastructure detail that must not leak into the domain.

**Incorrect (entity aware of persistence):**

```java
// domain/entities/Product.java
@Entity
@Table(name = "products")
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "product_name", nullable = false)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private Category category;

    @Version
    private Long version;

    // Entity is coupled to JPA, cannot exist without Hibernate
}
```

**Correct (persistence-ignorant entity):**

```java
// domain/entities/Product.java
public class Product {
    private final ProductId id;
    private String name;
    private CategoryId categoryId;
    private Money price;

    public Product(ProductId id, String name, CategoryId categoryId, Money price) {
        this.id = id;
        this.name = validateName(name);
        this.categoryId = categoryId;
        this.price = price;
    }

    public void updatePrice(Money newPrice, PricingPolicy policy) {
        if (!policy.allowsPrice(newPrice)) {
            throw new InvalidPriceException(newPrice);
        }
        this.price = newPrice;
    }

    private String validateName(String name) {
        if (name == null || name.isBlank()) {
            throw new InvalidProductNameException();
        }
        return name.trim();
    }
}

// infrastructure/persistence/jpa/JpaProductEntity.java
@Entity
@Table(name = "products")
class JpaProductEntity {
    @Id private Long id;
    @Column private String name;
    // ORM mapping isolated to infrastructure
}

// infrastructure/persistence/jpa/ProductMapper.java
class ProductMapper {
    Product toDomain(JpaProductEntity entity) { /* ... */ }
    JpaProductEntity toJpa(Product product) { /* ... */ }
}
```

**Benefits:**
- Switch from SQL to NoSQL without touching domain
- Entity tests don't require database setup
- Domain model expresses business concepts, not database schema

Reference: [Clean Architecture - Database is a Detail](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch30.xhtml)
