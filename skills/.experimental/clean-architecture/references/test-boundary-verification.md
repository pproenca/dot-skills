---
title: Verify Architectural Boundaries with Tests
impact: LOW-MEDIUM
impactDescription: prevents boundary erosion, enforces dependency rules
tags: test, boundaries, architecture, enforcement
---

## Verify Architectural Boundaries with Tests

Use automated tests to enforce that dependency rules are followed. Architecture tests catch violations before they become entrenched patterns.

**Incorrect (no boundary verification):**

```java
// Over time, developers add shortcuts
// domain/Order.java
import org.springframework.stereotype.Component;  // Framework in domain!
import javax.persistence.Entity;                   // JPA in domain!

// application/CreateOrderUseCase.java
import com.stripe.Stripe;  // Direct payment vendor dependency!
import infrastructure.email.SendGridClient;  // Infrastructure in application!

// No tests catch these violations
// They accumulate until refactoring becomes impossible
```

**Correct (architecture tests enforce boundaries):**

```java
// Using ArchUnit (Java) or similar tools
@AnalyzeClasses(packages = "com.myapp")
class ArchitectureTest {

    @ArchTest
    static final ArchRule domain_should_not_depend_on_infrastructure =
        noClasses()
            .that().resideInAPackage("..domain..")
            .should().dependOnClassesThat()
            .resideInAPackage("..infrastructure..");

    @ArchTest
    static final ArchRule domain_should_not_use_frameworks =
        noClasses()
            .that().resideInAPackage("..domain..")
            .should().dependOnClassesThat()
            .resideInAnyPackage(
                "org.springframework..",
                "javax.persistence..",
                "jakarta.persistence.."
            );

    @ArchTest
    static final ArchRule usecases_should_not_access_controllers =
        noClasses()
            .that().resideInAPackage("..application..")
            .should().dependOnClassesThat()
            .resideInAPackage("..interface..");

    @ArchTest
    static final ArchRule dependencies_point_inward =
        layeredArchitecture()
            .consideringAllDependencies()
            .layer("Domain").definedBy("..domain..")
            .layer("Application").definedBy("..application..")
            .layer("Infrastructure").definedBy("..infrastructure..")
            .layer("Interface").definedBy("..interface..")
            .whereLayer("Domain").mayNotAccessAnyLayer()
            .whereLayer("Application").mayOnlyAccessLayers("Domain")
            .whereLayer("Infrastructure").mayOnlyAccessLayers("Domain", "Application")
            .whereLayer("Interface").mayOnlyAccessLayers("Domain", "Application");
}

// TypeScript equivalent using dependency-cruiser
// .dependency-cruiser.js
module.exports = {
  forbidden: [
    {
      name: 'domain-no-infra',
      from: { path: '^src/domain' },
      to: { path: '^src/infrastructure' }
    },
    {
      name: 'domain-no-frameworks',
      from: { path: '^src/domain' },
      to: { path: 'node_modules/(express|prisma|typeorm)' }
    }
  ]
};
```

**Run in CI:**
```yaml
# .github/workflows/ci.yml
- name: Check architecture
  run: |
    ./gradlew archTest  # Java with ArchUnit
    npx depcruise src   # TypeScript with dependency-cruiser
```

**Benefits:**
- Violations caught immediately in CI
- New developers can't accidentally break boundaries
- Architecture documentation that stays accurate

Reference: [ArchUnit](https://www.archunit.org/)
