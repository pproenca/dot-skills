---
title: Wrap Third-Party APIs
impact: HIGH
impactDescription: reduces dependency change points from N call sites to 1 wrapper
tags: bound, boundary, wrapper, third-party, dependency
---

## Wrap Third-Party APIs

When you use a third-party API, wrap it in a class you control. This minimizes your dependency on the third party, makes testing easier, and gives you a single place to change when the API evolves.

**Incorrect (direct dependency scattered across codebase):**

```java
// Every caller depends on ACMEPort directly
public class SensorReader {
    public void readSensors() {
        try {
            ACMEPort port = new ACMEPort(12);
            port.open();
            // ...
        } catch (ACMEDeviceException e) {
            logger.log("Device exception", e);
        } catch (ACMEConfigException e) {
            logger.log("Config exception", e);
        } catch (ACMECommunicationException e) {
            logger.log("Communication exception", e);
        }
    }
}
// If ACME changes their API, every file that uses it must change
```

**Correct (wrapped behind your own interface):**

```java
public class LocalPort {
    private ACMEPort innerPort;

    public LocalPort(int portNumber) {
        innerPort = new ACMEPort(portNumber);
    }

    public void open() {
        try {
            innerPort.open();
        } catch (ACMEDeviceException | ACMEConfigException | ACMECommunicationException e) {
            throw new PortException(e);
        }
    }
}

// Callers depend only on your wrapper
public class SensorReader {
    public void readSensors() {
        try {
            LocalPort port = new LocalPort(12);
            port.open();
            // ...
        } catch (PortException e) {
            logger.log("Port error", e);
        }
    }
}
```

**Benefits:**
- One place to change when the third-party API changes
- Easier to mock in tests (mock `LocalPort`, not the vendor library)
- Freedom to switch vendors without rewriting the entire codebase
- Consistent exception hierarchy under your control

**When NOT to wrap:**
- Stable, widely-used standard library APIs (e.g., `java.util.List`, `String`) do not need wrapping.
- If the wrapper would be a 1:1 passthrough with no value added, it's premature. Wait until you have a concrete reason (testing, migration, or simplification).

Reference: [Clean Code, Chapter 8: Boundaries](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
