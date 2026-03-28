# Fix Patterns by Vulnerability Class

Standard fix approaches for common vulnerability types. Match the finding to a pattern, then adapt to the specific codebase's conventions.

## Input Validation — Untrusted Identifiers

**Vulnerability**: User-supplied identifiers (PIDs, bundle IDs, UDIDs) used without verifying they belong to the expected domain.

**Fix pattern**: Validate the identifier against an allowlist of valid values before use.

```
// Before: trusts raw --pid
let resolvedPID = pid

// After: validates PID is a running simulator app
let running = try await getRunningSimulatorApps()
guard running.values.contains(pid) else {
    throw Error.pidNotSimulatorApp(pid)
}
```

**Key decisions**:
- Validate at the entry point (CLI command handler), not deep in the service layer
- When multiple commands share the same validation, extract a shared helper
- Add a specific error type for rejected identifiers with clear feedback

## Path Traversal — Unsanitized Path Components

**Vulnerability**: User-supplied strings (filenames, bundle IDs, domain names) concatenated into filesystem paths without sanitization.

**Fix pattern**: Validate the component contains no path separators or traversal sequences, or normalize and contain the resolved path within an allowed root.

```swift
// Option A: Reject invalid components
guard !component.contains("/") && !component.contains("..") else {
    throw Error.invalidPathComponent(component)
}

// Option B: Normalize and contain within root
let resolved = URL(fileURLWithPath: root)
    .appendingPathComponent(component).standardized
guard resolved.path.hasPrefix(root.path) else {
    throw Error.pathEscapesRoot(component)
}
```

**Key decisions**:
- Prefer Option A (reject) for identifiers that should never contain path separators (bundle IDs, UDIDs, preference domains)
- Use Option B (normalize and contain) for user-supplied paths that may legitimately be nested
- Apply at the trust boundary where the untrusted string enters path construction

## Predictable Temporary Files — Symlink Races

**Vulnerability**: Writing to fixed paths under `/tmp` without unique naming or symlink protection, enabling symlink attacks on multi-user systems.

**Fix pattern**: Use unique per-run directories with restrictive permissions.

```swift
// Before: predictable path
let outputPath = "/tmp/tool-name/output.json"

// After: unique temp directory
let tempDir = FileManager.default.temporaryDirectory
    .appendingPathComponent(UUID().uuidString)
try FileManager.default.createDirectory(at: tempDir,
    withIntermediateDirectories: true,
    attributes: [.posixPermissions: 0o700])
let outputPath = tempDir.appendingPathComponent("output.json")
// Clean up after use
defer { try? FileManager.default.removeItem(at: tempDir) }
```

**When multiple temp files share a pattern**: Create a single secure temp directory helper and use it everywhere. This is the centralization principle — one fix, multiple call sites.

```swift
func secureTemporaryDirectory(prefix: String) throws -> URL {
    let dir = FileManager.default.temporaryDirectory
        .appendingPathComponent("\(prefix)-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: dir,
        withIntermediateDirectories: true,
        attributes: [.posixPermissions: 0o700])
    return dir
}
```

## XSS in Generated HTML — Unsafe Embedding

**Vulnerability**: Untrusted data embedded in HTML without context-appropriate escaping.

**Fix patterns by context**:

### Script tag embedding
```html
<!-- Before: JSON in executable script tag -->
<script>const R = UNSAFE_JSON;</script>

<!-- After: JSON in data tag, parsed separately -->
<script type="application/json" id="report-data">ESCAPED_JSON</script>
<script>const R = JSON.parse(document.getElementById('report-data').textContent);</script>
```

Additionally, escape `</script>` sequences in the JSON payload:
```swift
let safe = jsonString.replacingOccurrences(of: "</script>", with: "<\\/script>")
```

### HTML attribute injection
```swift
// Before: only escapes < > &
func esc(_ s: String) -> String {
    s.replacingOccurrences(of: "&", with: "&amp;")
     .replacingOccurrences(of: "<", with: "&lt;")
     .replacingOccurrences(of: ">", with: "&gt;")
}

// After: also escapes quotes for attribute contexts
func esc(_ s: String) -> String {
    s.replacingOccurrences(of: "&", with: "&amp;")
     .replacingOccurrences(of: "<", with: "&lt;")
     .replacingOccurrences(of: ">", with: "&gt;")
     .replacingOccurrences(of: "\"", with: "&quot;")
     .replacingOccurrences(of: "'", with: "&#x27;")
}
```

### innerHTML injection
```javascript
// Before: innerHTML with untrusted data
element.innerHTML = untrustedLabel;

// After: textContent for text, or sanitize for rich content
element.textContent = untrustedLabel;
// Or if HTML rendering is needed:
element.innerHTML = DOMPurify.sanitize(untrustedContent);
```

## Unbounded Allocation — Resource Exhaustion

**Vulnerability**: Allocating memory based on untrusted size values without upper bounds.

**Fix pattern**: Enforce a maximum size before allocation.

```c
// Before: trusts payload size
size_t bufSize = untrusted_size;
void *buf = malloc(bufSize);

// After: cap at reasonable maximum
#define MAX_PAYLOAD_SIZE (5 * 1024 * 1024) // 5 MB
if (untrusted_size > MAX_PAYLOAD_SIZE) {
    *error_text = strdup("Payload exceeds maximum allowed size");
    return NULL;
}
void *buf = malloc(untrusted_size);
```

**For decompression**: Cap the output buffer size independently of the input's declared size.

```swift
// Before: trusts gzip ISIZE
let outputSize = Int(isize)
var buffer = [UInt8](repeating: 0, count: outputSize)

// After: cap decompressed size
let maxDecompressed = 50 * 1024 * 1024 // 50 MB
let outputSize = min(Int(isize), maxDecompressed)
guard outputSize <= maxDecompressed else {
    throw DecompressionError.payloadTooLarge(declared: Int(isize), max: maxDecompressed)
}
```

**Key decisions**:
- Choose the cap based on realistic maximum sizes for the data type
- Document the cap constant with a comment explaining the rationale
- Fail with a clear error message, not a silent truncation

## Use-After-Free — Resource Lifetime

**Vulnerability**: Resources used after their owning scope has ended, especially across async boundaries.

**Fix pattern**: Add reference counting or ensure async work holds the resource alive.

```c
// Before: session freed while async block may still use it
dispatch_async(queue, ^{
    use(session);  // session may be freed by caller
});
destroy(session);

// After: atomic refcount ensures session lives until all users are done
struct Session {
    _Atomic uint32_t refCount;
    _Atomic bool destroyRequested;
};

static void retain(Session *s) {
    atomic_fetch_add(&s->refCount, 1);
}

static void release(Session *s) {
    if (atomic_fetch_sub(&s->refCount, 1) == 1 && s->destroyRequested) {
        // Last reference + destroy requested: actually free
        free(s);
    }
}

// Async work retains before dispatch, releases on all exit paths
retain(session);
dispatch_async(queue, ^{
    use(session);
    release(session);  // releases on every exit path
});
// Destroy becomes deferred
void destroy(Session *s) {
    s->destroyRequested = true;
    release(s);
}
```

**Key decisions**:
- Use `_Atomic` types and appropriate memory ordering (`memory_order_acq_rel` for the decrement)
- Release on EVERY exit path from the async block (including early returns and error paths)
- Destroy marks the intention; actual cleanup happens when the last reference is released

## Command/Expression Injection — Unescaped Interpolation

**Vulnerability**: Untrusted input interpolated into shell commands, LLDB expressions, or SQL queries.

**Fix pattern**: Escape the input for the target context, or use parameterized invocation.

```swift
// Before: raw interpolation into LLDB expression
let expr = "po [(NSString *)\"\\(outputPath)\" writeToFile:...]"

// After: escape for ObjC string literal context
let escaped = outputPath
    .replacingOccurrences(of: "\\", with: "\\\\")
    .replacingOccurrences(of: "\"", with: "\\\"")
let expr = "po [(NSString *)\"\\(escaped)\" writeToFile:...]"
```

For shell commands, prefer passing arguments as array elements rather than string interpolation:
```swift
// Before: string interpolation
Process.run("/bin/sh", arguments: ["-c", "tool --input \(userInput)"])

// After: argument array (no shell interpretation)
Process.run("/usr/bin/tool", arguments: ["--input", userInput])
```

## Missing Authentication — Exposed Endpoints

**Vulnerability**: CRUD or mutation endpoints accessible without authentication.

**Fix pattern**: Add authentication middleware. When adding auth is a larger change, the immediate fix is to restrict access by network binding.

```ruby
# Before: open endpoint
class FlagsController < ApplicationController
  def update
    # mutates flags
  end
end

# After: require authentication
class FlagsController < ApplicationController
  before_action :authenticate_admin!
  def update
    # mutates flags
  end
end
```

When full auth is not yet implemented, document this as an analysis-only finding with the recommendation and the network-restriction workaround.

## Recursive Processing — Stack Overflow

**Vulnerability**: Recursive traversal of untrusted tree structures without depth limits.

**Fix pattern**: Add a depth parameter with a maximum, or convert to iterative traversal with an explicit stack.

```swift
// Before: unbounded recursion
func flatten(_ node: Node) -> [Node] {
    [node] + node.children.flatMap { flatten($0) }
}

// After: depth-limited recursion
func flatten(_ node: Node, depth: Int = 0, maxDepth: Int = 200) -> [Node] {
    guard depth < maxDepth else { return [node] }
    return [node] + node.children.flatMap { flatten($0, depth: depth + 1, maxDepth: maxDepth) }
}
```

## Non-Finite Numeric Values — Trap on Conversion

**Vulnerability**: Float/Double values from untrusted sources cause fatal traps when converted to Int.

**Fix pattern**: Guard against non-finite values before conversion.

```swift
// Before: traps on NaN/Inf
let zIndex = Int(zPosition)

// After: safe conversion with default
let zIndex = zPosition.isFinite ? Int(clamping: zPosition) : 0
```

For JSON serialization, filter non-finite values before encoding:
```swift
guard value.isFinite else {
    return .number(0) // or skip the field entirely
}
```
