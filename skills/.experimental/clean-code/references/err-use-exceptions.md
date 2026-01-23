---
title: Use Exceptions Instead of Return Codes
impact: MEDIUM-HIGH
impactDescription: reduces nested conditionals by 50-80%
tags: err, exceptions, return-codes, separation
---

## Use Exceptions Instead of Return Codes

Exceptions separate error handling from the main logic. Return codes clutter the caller with error checking that obscures the algorithm. The caller can forget to check return codes.

**Incorrect (return codes obscure logic):**

```java
public int sendShutdown() {
    int status = device.getHandle(DEV1);
    if (status != DEVICE_SUCCESS) {
        return status;
    }

    status = device.pause(handle);
    if (status != DEVICE_SUCCESS) {
        device.release(handle);
        return status;
    }

    status = device.shutdown(handle);
    if (status != DEVICE_SUCCESS) {
        device.release(handle);
        return status;
    }

    device.release(handle);
    return DEVICE_SUCCESS;
}
```

**Correct (exceptions clarify intent):**

```java
public void sendShutdown() throws DeviceException {
    try {
        tryToShutDown();
    } catch (DeviceException e) {
        logger.log(e);
        throw e;
    }
}

private void tryToShutDown() throws DeviceException {
    DeviceHandle handle = device.getHandle(DEV1);
    try {
        device.pause(handle);
        device.shutdown(handle);
    } finally {
        device.release(handle);
    }
}
```

The business logic (get handle, pause, shutdown, release) is now clearly visible without being obscured by error handling.

Reference: [Clean Code, Chapter 7: Error Handling](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
