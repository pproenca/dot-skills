---
title: Define Exceptions by Caller Needs
impact: MEDIUM
impactDescription: reduces catch blocks by 3-5× per call site
tags: err, wrapper, classification, design
---

## Define Exceptions by Caller Needs

Define exception classes based on how they are caught, not on their source or type. Often a single exception class is sufficient for a particular area of code. Wrap third-party API exceptions.

**Incorrect (catching many exception types):**

```java
// Caller must handle many different exceptions
try {
    port.open();
} catch (DeviceResponseException e) {
    reportPortError(e);
    logger.log("Device response problem", e);
} catch (ATM1212UnlockedException e) {
    reportPortError(e);
    logger.log("Unlock exception", e);
} catch (GMXError e) {
    reportPortError(e);
    logger.log("Device response exception", e);
} finally {
    // ...
}
```

**Correct (unified exception handling):**

```java
// Wrapper class translates exceptions
public class LocalPort {
    private ACMEPort innerPort;

    public void open() throws PortDeviceFailure {
        try {
            innerPort.open();
        } catch (DeviceResponseException e) {
            throw new PortDeviceFailure(e);
        } catch (ATM1212UnlockedException e) {
            throw new PortDeviceFailure(e);
        } catch (GMXError e) {
            throw new PortDeviceFailure(e);
        }
    }
}

// Clean caller code
try {
    port.open();
} catch (PortDeviceFailure e) {
    reportPortError(e);
    logger.log(e.getMessage(), e);
}
```

**Benefits of wrapping:**
- Minimizes dependencies on third-party APIs
- Easier to mock for testing
- Easier to switch implementations later
- Single exception type per area simplifies catching

Reference: [Clean Code, Chapter 7: Error Handling](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
