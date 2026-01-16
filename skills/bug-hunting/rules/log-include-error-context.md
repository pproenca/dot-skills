---
title: Include Full Context in Error Logs
impact: HIGH
impactDescription: enables debugging without reproduction
tags: log, errors, context, stack-traces
---

## Include Full Context in Error Logs

Error logs should contain everything needed to understand and debug the issue: stack trace, input values, system state, and identifiers. A good error log enables debugging without needing to reproduce the issue.

**Incorrect (minimal error context):**

```typescript
async function processUserUpload(userId: string, file: File) {
  try {
    await uploadService.process(file)
  } catch (error) {
    logger.error('Upload failed')  // What failed? For whom? Why?
    // or
    logger.error(error.message)    // "Network error" - not actionable
    throw error
  }
}

// Log: "Upload failed" or "Network error"
// Debugging: Need to reproduce to understand what happened
```

**Correct (full error context):**

```typescript
async function processUserUpload(userId: string, file: File) {
  const uploadId = generateUploadId()

  try {
    logger.info('upload_started', {
      uploadId,
      userId,
      fileName: file.name,
      fileSize: file.size,
      mimeType: file.type,
    })

    await uploadService.process(file)

  } catch (error) {
    logger.error('upload_failed', {
      uploadId,
      userId,
      fileName: file.name,
      fileSize: file.size,
      mimeType: file.type,
      errorType: error.name,
      errorMessage: error.message,
      errorCode: error.code,
      stackTrace: error.stack,
      // System state
      memoryUsage: process.memoryUsage().heapUsed,
      uploadServiceStatus: await uploadService.healthCheck(),
    })
    throw error
  }
}

// Log: Complete picture of what happened, when, and why
// Debugging: Often solvable without reproduction
```

**Error context checklist:**
- [ ] Unique identifier (correlation/request ID)
- [ ] User/tenant identifier
- [ ] Input values that triggered the error
- [ ] Full stack trace
- [ ] Error code/type for categorization
- [ ] Relevant system state (memory, connections, queue depth)

Reference: [OpenObserve - Microservices Observability](https://openobserve.ai/blog/microservices-observability-logs-metrics-traces/)
