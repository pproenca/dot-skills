---
title: Attach the underlying error when wrapping into a domain error
tags: err, error-wrapping, catch, diagnostics
---

## Attach the underlying error when wrapping into a domain error

The wrong default in a `catch` block that maps errors into a domain type is throwing a bare case — `throw DataProcessingError.dataFetchFailed` — and discarding the error that was caught. The original diagnosis (a `URLError` code, a `DecodingError` coding path, an errno) is destroyed at the wrap site, so production debugging dead-ends at the vague domain case with no way to recover what actually failed. Wrapping is correct; wrapping without the payload is the bug.

**Evidence of violation:** a `catch` block that throws a new error whose case or type carries no associated value or property holding the caught `error`, and that neither logs nor records the original before rethrowing. PASS: every wrap site attaches the underlying error (an `underlyingError:` associated value, a stored property, or the original `NSError`) or visibly logs it before throwing the domain case; deliberate sanitization at a trust boundary passes only when an explicit comment or a log of the original accompanies it. N/A: the target contains no `catch` block that throws a different error than it caught.

**Incorrect (payload-free domain cases destroy the underlying error):**

```swift
import Foundation

enum DataProcessingError: Error {
    case dataFetchFailed
    case dataParsingFailed
}

func fetchData() async throws -> Data { Data() }
func parseData(_ data: Data) throws -> [String] { [] }

func processDataTask() async throws -> [String] {
    do {
        let data = try await fetchData()
        return try parseData(data)
    } catch {
        let error = error as NSError
        switch error.domain {
        case "Network":
            throw DataProcessingError.dataFetchFailed
        case "Parser":
            throw DataProcessingError.dataParsingFailed
        default:
            throw error
        }
    }
}
```

**Correct (each domain case carries the underlying error):**

```swift
import Foundation

enum DataProcessingError: Error {
    case dataFetchFailed(underlyingError: Error)
    case dataParsingFailed(underlyingError: Error)
}

func fetchData() async throws -> Data { Data() }
func parseData(_ data: Data) throws -> [String] { [] }

func processDataTask() async throws -> [String] {
    do {
        let data = try await fetchData()
        return try parseData(data)
    } catch {
        let error = error as NSError
        switch error.domain {
        case "Network":
            throw DataProcessingError
                .dataFetchFailed(underlyingError: error)
        case "Parser":
            throw DataProcessingError
                .dataParsingFailed(underlyingError: error)
        default:
            throw error
        }
    }
}
```
