---
title: Apply Configuration in Correct Precedence Order
impact: MEDIUM
impactDescription: matches user expectations for override behavior
tags: config, precedence, environment, flags
---

## Apply Configuration in Correct Precedence Order

Apply configuration from multiple sources in a consistent, predictable order. Command-line flags should override everything else.

**Incorrect (unpredictable precedence):**

```c
// Loads config randomly, flags might not override
void load_config(void) {
    apply_flags();           // First?
    load_user_config();      // Could override flags?
    apply_env_vars();        // Unclear precedence
    load_system_config();    // Final say?
}
```

**Correct (well-defined precedence, highest to lowest):**

```c
typedef struct {
    int verbose;
    int port;
    char *output;
} Config;

Config load_config(int argc, char *argv[]) {
    Config config = {0};

    // 1. Built-in defaults (lowest priority)
    config.verbose = 0;
    config.port = 8080;
    config.output = "stdout";

    // 2. System config (/etc/mytool/config)
    load_config_file(&config, "/etc/mytool/config");

    // 3. User config (~/.config/mytool/config)
    char user_config[PATH_MAX];
    snprintf(user_config, sizeof(user_config),
             "%s/.config/mytool/config", getenv("HOME"));
    load_config_file(&config, user_config);

    // 4. Project config (./.mytool.yaml)
    load_config_file(&config, ".mytool.yaml");

    // 5. Environment variables
    const char *env_port = getenv("MYTOOL_PORT");
    if (env_port) config.port = atoi(env_port);

    // 6. Command-line flags (highest priority)
    parse_args(&config, argc, argv);

    return config;
}
```

**Precedence order (highest to lowest):**

| Priority | Source | Example |
|----------|--------|---------|
| 1 | Command-line flags | `--port=9000` |
| 2 | Environment variables | `MYTOOL_PORT=9000` |
| 3 | Project config | `./.mytool.yaml` |
| 4 | User config | `~/.config/mytool/config` |
| 5 | System config | `/etc/mytool/config` |
| 6 | Built-in defaults | Hardcoded values |

Reference: [The Twelve-Factor App - Config](https://12factor.net/config)
