---
title: Prefer Exceptions to Error Codes
impact: HIGH
impactDescription: reduces error handling code by 60-80%
tags: func, exceptions, error-codes, separation
---

## Prefer Exceptions to Error Codes

Returning error codes from command functions violates command query separation. It forces callers to deal with the error immediately. Exceptions allow error handling to be separated from the happy path.

**Incorrect (error codes clutter the logic):**

```java
if (deletePage(page) == E_OK) {
    if (registry.deleteReference(page.name) == E_OK) {
        if (configKeys.deleteKey(page.name.makeKey()) == E_OK) {
            logger.log("page deleted");
        } else {
            logger.log("configKey not deleted");
        }
    } else {
        logger.log("deleteReference from registry failed");
    }
} else {
    logger.log("delete failed");
    return E_ERROR;
}
```

**Correct (exceptions separate concerns):**

```java
public void delete(Page page) {
    try {
        deletePageAndAllReferences(page);
    } catch (Exception e) {
        logError(e);
    }
}

private void deletePageAndAllReferences(Page page) throws Exception {
    deletePage(page);
    registry.deleteReference(page.name);
    configKeys.deleteKey(page.name.makeKey());
}

private void logError(Exception e) {
    logger.log(e.getMessage());
}
```

**Benefits:**
- Happy path is clear and uncluttered
- Error handling is consolidated
- Try/catch blocks can be extracted into their own functions

**Note:** Extract try/catch blocks into their own functions. Error handling is one thing; functions that handle errors should do nothing else.

Reference: [Clean Code, Chapter 3: Functions](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
