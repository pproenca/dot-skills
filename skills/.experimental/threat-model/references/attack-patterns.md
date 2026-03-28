# Attack Patterns by Technology Domain

Reference guide for common attack surface patterns. Use this as a starting point when enumerating surfaces — not as a checklist. The actual surfaces in the threat model should be derived from the codebase, not copied from this list.

## CLI Tools & Filesystem Operations

### Path traversal
**What to look for**: User-supplied strings used in path construction without normalization or containment checks.
- Bundle IDs, filenames, or identifiers concatenated into paths (e.g., `/tmp/tool-name/\(userInput)`)
- `../` sequences not stripped from filenames read from manifests, configs, or user input
- Output directories that accept arbitrary paths (`--output ../../etc/`)

**Grep patterns**: `\(bundleID\)`, `\(filename\)`, `appendingPathComponent`, `join(path`, `/tmp/` + variable

### Predictable temporary files
**What to look for**: Fixed paths under `/tmp` or `NSTemporaryDirectory()` without unique naming or exclusive creation.
- Hardcoded paths like `/tmp/tool-output.json` or `/tmp/tool-name/`
- `removeItem` followed by `createDirectory` at the same path (race window)
- No `O_EXCL`, `mkstemp`, `mkdtemp`, or UUID-based naming

**Grep patterns**: `/tmp/`, `NSTemporaryDirectory`, `removeItem.*createDirectory`, `FileManager.default.createDirectory`

### Symlink attacks
**What to look for**: File operations at predictable paths without symlink verification.
- Writing to paths that could be symlinks without checking `resourceValues(forKeys: [.isSymbolicLinkKey])`
- Deleting and recreating directories in world-writable locations
- Copying files from untrusted locations without verifying link status

### Destructive operations
**What to look for**: CLI subcommands that delete, erase, or overwrite without confirmation.
- `FileManager.removeItem` on user-supplied paths
- Device erase/reset commands callable without confirmation
- Uninstall operations that don't verify ownership

## Web & HTML Generation

### XSS in generated HTML
**What to look for**: Untrusted data embedded in HTML without context-appropriate escaping.
- JSON serialized into `<script>` tags — `</script>` sequences in values can break out
- String interpolation into `innerHTML`, `outerHTML`, or HTML attributes
- Escaping that covers `<>&` but not quotes (attribute breakout)
- Markdown renderers with raw HTML enabled (e.g., `marked.parse()` without sanitizer)

**Grep patterns**: `innerHTML`, `outerHTML`, `const R=`, `<script>`, `marked.parse`, `dangerouslySetInnerHTML`

### SSRF
**What to look for**: URLs constructed from user/operator input used in server-side HTTP requests.
- Config values like `NGINX_URL` or `SERVICE_URL` used in `Net::HTTP`, `fetch()`, or `curl`
- Diagnostics/health-check endpoints that proxy to internal URLs
- Redirect URLs from user input

### Missing authentication
**What to look for**: CRUD endpoints or mutation operations without auth middleware.
- Rails controllers without `before_action :authenticate`
- Express routes without auth middleware
- API endpoints that rely on network segmentation instead of auth
- `config.hosts.clear` or similar host validation disabling

### Default credentials
**What to look for**: Hardcoded passwords, API keys, or secret values in config or setup scripts.
- Docker compose files with fixed `SECRET_KEY_BASE` or API keys
- Setup scripts that create admin users with known passwords
- Demo/seed scripts that expose credential patterns

## Native Code & Memory Safety

### Buffer/bounds issues
**What to look for**: Unsafe pointer operations, unchecked sizes, or missing bounds validation in C/C++/ObjC.
- `load(fromByteOffset:)` or `withUnsafeBytes` without bounds checking against data size
- Loop counters from untrusted data (e.g., Mach-O `ncmds`) without validation
- `String(cString:)` on potentially unterminated buffers
- `realloc` or allocation based on untrusted size values without upper bounds

**Grep patterns**: `withUnsafeBytes`, `load(fromByteOffset`, `String(cString`, `realloc`, `malloc`

### Use-after-free / lifetime issues
**What to look for**: Resources used after their owning scope has ended, especially across async boundaries.
- Callbacks or closures that capture pointers to stack-allocated or session-scoped objects
- Timeout paths that return early while background work continues using freed resources
- `dispatch_async` or `Task.detached` using a session/context that the caller destroys on return

### dlopen / dynamic loading
**What to look for**: Framework or library loading from paths derived from environment or tools.
- `dlopen` with paths built from `xcode-select -p` or similar — empty/relative output creates hijack opportunity
- Plugin loading from user-writable directories
- No validation that loaded library is signed or from expected location

## Injection Attacks

### Command/expression injection
**What to look for**: Untrusted input interpolated into commands, queries, or expressions.
- String interpolation into shell commands, LLDB expressions, SQL queries
- User-supplied values in `Process.arguments` or `NSTask` without escaping
- Template strings that embed user data into executable contexts

**Grep patterns**: `Process(`, `NSTask`, `system(`, `popen(`, `exec(`, `eval(`, `expression --`

### SQL injection
**What to look for**: String concatenation in SQL queries (less common with ORMs but check raw queries).
- Direct string interpolation in SQLite or ActiveRecord `where` clauses
- Prepared statements that build the SQL string before preparing

## Mobile & iOS

### Keychain / credential persistence
**What to look for**: Credential lifecycle issues around sign-in, sign-out, and device sharing.
- Cached profile data not cleared on sign-out (PII leakage to next user)
- Token age/expiry checks that fail open (allowing continued access after revocation)
- Biometric locks that unlock when biometrics unavailable (fail-open)

### Data persistence across sessions
**What to look for**: Local storage (SwiftData, CoreData, UserDefaults) not scoped to authenticated user.
- Cached data visible to the next user after sign-out
- Background refresh that continues after auth revocation
- Local stores that don't validate current session before returning data

### App attestation / integrity
**What to look for**: Removal or weakening of client integrity checks.
- App Attestation or SafetyNet integration removed during refactors
- Attestation made optional without compensating server-side enforcement

## Dependencies & Supply Chain

### Unpinned dependencies
**What to look for**: Dependencies on branches instead of tags/commits.
- `branch: "main"` or `branch: "master"` in Package.swift, Gemfile, package.json
- `curl | bash` installation without checksum verification
- Git submodules at HEAD without pinned commits

### Asset integrity
**What to look for**: Packaged scripts, templates, or config files that execute with tool privileges.
- LLDB scripts, build scripts, or migration files in user-writable locations
- Assets loaded at runtime without signature or checksum verification
- Config files in untrusted project directories (`.tool-name/config.json` in a cloned repo)

## Data Serialization & Parsing

### Unbounded parsing
**What to look for**: JSON/XML/protobuf parsing without size limits on untrusted input.
- `JSONSerialization` or `cJSON_Parse` on payloads without checking `Content-Length` or buffer size
- Recursive tree parsing without depth limits (stack overflow on deep trees)
- Decompression without output size bounds (zip bombs, gzip ISIZE manipulation)

**Grep patterns**: `JSONSerialization`, `cJSON_Parse`, `JSONDecoder`, `Decompression`, `gunzip`

### Non-finite numeric values
**What to look for**: Float/Double values from untrusted sources used without NaN/Inf checks.
- `Double→Int` conversions that trap on non-finite values (Swift fatal error)
- NaN propagation through calculations that produce invalid JSON or corrupt state
- CSS/coordinate values from untrusted UI data without range validation

## Information Disclosure

### Sensitive data in logs/output
**What to look for**: Context identifiers, tokens, or PII in logs, WAL files, or status endpoints.
- Access logs including `context_key`, user IDs, or session tokens
- WAL files or event logs in world-readable directories
- Status/diagnostics endpoints returning internal telemetry without auth
- Environment variable overrides logged to disk (may contain secrets)
