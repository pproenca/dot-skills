---
title: Follow XDG Base Directory Specification
impact: MEDIUM
impactDescription: prevents config file sprawl in home directory
tags: config, xdg, directories, standards
---

## Follow XDG Base Directory Specification

Store configuration in XDG directories (`~/.config/appname/`) instead of dotfiles in home. This keeps home directories clean and enables per-user and system-wide configurations.

**Incorrect (dotfile in home directory):**

```c
const char *get_config_path(void) {
    static char path[PATH_MAX];
    snprintf(path, sizeof(path), "%s/.mytoolrc", getenv("HOME"));
    return path;
}
```

```bash
$ ls -la ~
.bashrc
.gitconfig
.mytoolrc        # Yet another dotfile
.anothertool
.toolconfig
# Home directory cluttered with dotfiles
```

**Correct (XDG-compliant paths):**

```c
#include <stdlib.h>

const char *get_config_dir(void) {
    const char *xdg = getenv("XDG_CONFIG_HOME");
    if (xdg && xdg[0]) {
        return xdg;
    }
    static char path[PATH_MAX];
    snprintf(path, sizeof(path), "%s/.config", getenv("HOME"));
    return path;
}

const char *get_config_path(void) {
    static char path[PATH_MAX];
    snprintf(path, sizeof(path), "%s/mytool/config.yaml",
             get_config_dir());
    return path;
}

const char *get_data_dir(void) {
    const char *xdg = getenv("XDG_DATA_HOME");
    if (xdg && xdg[0]) {
        return xdg;
    }
    static char path[PATH_MAX];
    snprintf(path, sizeof(path), "%s/.local/share", getenv("HOME"));
    return path;
}
```

```bash
$ ls ~/.config/mytool/
config.yaml
$ ls ~/.local/share/mytool/
cache.db
history
```

**XDG directories:**

| Purpose | Environment Variable | Default |
|---------|---------------------|---------|
| Config | `XDG_CONFIG_HOME` | `~/.config` |
| Data | `XDG_DATA_HOME` | `~/.local/share` |
| Cache | `XDG_CACHE_HOME` | `~/.cache` |
| State | `XDG_STATE_HOME` | `~/.local/state` |

Reference: [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
