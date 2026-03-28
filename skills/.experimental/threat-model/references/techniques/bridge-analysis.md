# Cross-Language Bridge Analysis

The hardest bugs live at language boundaries. When Swift calls C, when Ruby talks to C through Redis, when JavaScript calls WebAssembly — type systems, memory models, and error handling conventions change. This technique systematically analyzes these boundaries.

## Why This Matters

agent-sim's most critical finding (use-after-free in CoreSimBridge) exists because Swift's ARC lifetime management doesn't extend into the C bridge layer. The timeout path in Swift returns and deallocates the session, while a `dispatch_async` block in C still holds a raw pointer to it. No single-language analysis would find this — it requires understanding both sides of the bridge.

Similarly, ab-nginx's shared-memory layout between C (NGINX module) and Ruby (Rails control plane via Redis) means a schema change on one side can corrupt the other. The trust boundary is implicit in the data format, not in an API contract.

## The Technique

### Step 1: Identify All Bridge Boundaries

Grep for bridge indicators:

| Bridge Type | Indicators |
|------------|-----------|
| Swift ↔ C/ObjC | `@objc`, `import <BridgeName.h>`, `withUnsafePointer`, `UnsafeMutablePointer`, bridging headers |
| Swift ↔ C via module map | `module.modulemap`, `.systemLibrary`, `clang module` |
| Rust ↔ C | `extern "C"`, `#[no_mangle]`, `unsafe { }`, `*const`, `*mut` |
| Python ↔ C | `ctypes`, `cffi`, `PyObject*`, Cython `.pyx` |
| Node.js ↔ C++ | `napi_`, `N-API`, `node-addon-api`, `.node` binary modules |
| JVM ↔ C | `native` keyword, `JNI_OnLoad`, `System.loadLibrary` |
| Any ↔ shared memory | `mmap`, `shm_open`, shared memory zones, memory-mapped files |
| Any ↔ IPC | Redis pub/sub, Unix sockets, named pipes, D-Bus |

For each bridge, record:
- Which two languages/runtimes are connected
- Which side initiates calls (caller vs callee)
- What data types cross the boundary
- Where the bridge code lives (file paths)

### Step 2: Analyze Type Crossings

At each bridge boundary, check what types cross and whether there's a mismatch:

| Check | What to Look For | Risk |
|-------|-----------------|------|
| Integer width | Swift `Int` (64-bit) vs C `int` (32-bit) | Truncation, overflow |
| Nullability | Swift optionals vs C nullable pointers | Null dereference |
| String encoding | Swift String (UTF-8) vs C `char*` (unknown encoding) | Encoding confusion, buffer overread |
| Array bounds | Swift Array (bounds-checked) vs C pointer (unchecked) | Buffer overflow |
| Enum representation | Swift enum (tagged union) vs C int (raw value) | Invalid state |
| Floating point | Different precision or NaN handling across languages | Trap, corruption |
| Boolean | Swift Bool vs C `BOOL` (signed char on ObjC) | Surprising truth values |

**For each type crossing, verify:**
1. Is there explicit conversion with range checking?
2. What happens on failure? (trap, silent truncation, undefined behavior)
3. Are error codes mapped correctly between languages?

### Step 3: Analyze Memory Ownership

The most dangerous bridge bugs are lifetime mismatches. Check:

**Who allocates, who frees?**
```
Caller (Swift) allocates → passes pointer to callee (C) → who frees?
  - If caller frees after call returns: safe IF callee doesn't store the pointer
  - If callee stores the pointer: use-after-free when caller deallocates
  - If callee frees: double-free if caller also frees
```

**Ownership transfer patterns:**
| Pattern | Risk | Check |
|---------|------|-------|
| Caller allocates, callee uses synchronously | Low | Verify callee doesn't store pointer |
| Caller allocates, callee stores reference | HIGH | Verify lifetime alignment |
| Callee allocates, returns to caller | Medium | Verify caller knows to free |
| Shared allocation with reference counting | Medium | Verify atomic refcount, no races |
| `strdup`/copy at boundary | Low | Verify both sides free their copy |

**agent-sim example:**
```
ASCoreSimSessionCreate() → allocates session struct
  ↓
_ResolveDeviceSet() → dispatches async block that captures session pointer
  ↓
Timeout fires → ASCoreSimSessionDestroy() frees session
  ↓
Async block still running → uses freed session → USE-AFTER-FREE
```

The fix was atomic reference counting (`_RetainSession` / `_ReleaseSession`) so the session lives until all users release it.

### Step 4: Analyze Error Handling Across Boundaries

Errors don't translate cleanly across language boundaries:

| Check | What to Look For |
|-------|-----------------|
| Error code mapping | Does the bridge map C errno/NULL to Swift throws/Optional? |
| Exception propagation | Can an ObjC exception propagate into Swift (which doesn't catch ObjC exceptions)? |
| Partial failure | If a multi-step bridge operation fails midway, is the caller left in a consistent state? |
| Timeout handling | If the caller times out, does the callee know to stop? Or does it continue using shared state? |
| Resource cleanup on error | On error, are all allocated resources freed on BOTH sides of the bridge? |

### Step 5: Analyze Async Boundaries

When async operations cross bridge boundaries, lifetime and ordering guarantees can break:

| Pattern | Risk |
|---------|------|
| Caller dispatches async work on callee side, then destroys context | Use-after-free in async block |
| Callee signals completion via callback, caller has moved on | Callback into freed/invalid state |
| Shared mutable state accessed from both sides without synchronization | Data race, corruption |
| Timeout on caller side doesn't cancel work on callee side | Resource leak, stale work |

### Step 6: Check Dynamic Loading

For bridges that load code dynamically (`dlopen`, `LoadLibrary`, `System.loadLibrary`):

1. **Path validation**: Is the library path fully qualified? Can an empty/relative result from `xcode-select -p` cause loading from attacker-controlled location?
2. **Symbol verification**: After loading, are expected symbols verified before use?
3. **Version compatibility**: Can a wrong-version library be loaded that has incompatible struct layouts?
4. **Unload safety**: If the library is `dlclose`d, are all pointers to its symbols invalidated?

## Output Format for Bridge Findings

```
BRIDGE: {Caller Language} → {Callee Language} via {mechanism}
Files: {bridge source files}
Types crossing: {list of types that cross the boundary}
Ownership model: {who allocates, who frees, lifetime management}

Findings:
1. {Type mismatch / lifetime issue / error handling gap}
   Risk: {what can go wrong}
   Severity: {rating}
2. ...
```

## Common Pitfalls

- **Don't assume both sides have the same error model.** Swift throws, C returns NULL, ObjC throws NSException — these are three different mechanisms.
- **ARC doesn't cross into C.** A Swift object passed as `UnsafeRawPointer` to C has no ARC protection on the C side. If C stores the pointer and Swift releases the object, it's use-after-free.
- **Thread safety assumptions differ.** Swift actors have isolation guarantees. C code called from Swift has none unless explicitly synchronized.
- **Struct layout is not guaranteed.** Don't assume a Swift struct and a C struct with the same fields have the same memory layout unless explicitly bridged via `@frozen` or `#pragma pack`.
