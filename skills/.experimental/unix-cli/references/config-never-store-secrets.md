---
title: Never Store Secrets in Config Files or Environment
impact: MEDIUM
impactDescription: prevents credential exposure in logs and process lists
tags: config, security, secrets, credentials
---

## Never Store Secrets in Config Files or Environment

Config files get committed to version control. Environment variables appear in process listings and logs. Use dedicated secret storage mechanisms.

**Incorrect (secrets in config or environment):**

```yaml
# config.yaml - might get committed to git
database:
  host: db.example.com
  password: SuperSecret123  # Exposed in version control!

api:
  key: sk-abc123xyz  # API key in plain text
```

```bash
# Secrets visible in process listing
$ ps aux | grep mytool
user  1234  mytool --api-key=sk-abc123
```

**Correct (use secure secret sources):**

```c
#include <stdlib.h>

// Read from file with restricted permissions
char *read_secret_file(const char *path) {
    struct stat st;
    if (stat(path, &st) < 0) return NULL;

    // Warn if file permissions are too open
    if (st.st_mode & (S_IRGRP | S_IROTH)) {
        fprintf(stderr, "Warning: %s is readable by others\n", path);
    }

    FILE *f = fopen(path, "r");
    // ... read secret
}

// Get secret from multiple sources
char *get_api_key(void) {
    // 1. File reference in config
    const char *file = config_get("api.key_file");
    if (file) return read_secret_file(file);

    // 2. Named pipe or socket
    const char *pipe = getenv("MYTOOL_API_KEY_PIPE");
    if (pipe) return read_from_pipe(pipe);

    // 3. System keyring (macOS Keychain, GNOME Keyring, etc.)
    char *secret = keyring_get("mytool", "api_key");
    if (secret) return secret;

    fprintf(stderr, "No API key configured\n");
    return NULL;
}
```

```yaml
# config.yaml - references file, not value
database:
  host: db.example.com
  password_file: /run/secrets/db_password  # Docker secret or similar

api:
  key_file: ~/.config/mytool/api_key  # Mode 0600
```

**Secure secret sources:**
- Dedicated files with `chmod 600`
- OS keychain/credential manager
- Docker/Kubernetes secrets
- Environment files not in version control (`.env` in `.gitignore`)

Reference: [The Twelve-Factor App - Config](https://12factor.net/config)
