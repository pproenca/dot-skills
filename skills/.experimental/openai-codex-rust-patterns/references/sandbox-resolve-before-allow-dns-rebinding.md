---
title: Resolve hostnames and reject private IPs before allowing egress
impact: HIGH
impactDescription: defeats DNS-rebinding bypass of a string-based egress allowlist
tags: sandbox, network, dns-rebinding, egress
---

## Resolve hostnames and reject private IPs before allowing egress

A network allowlist enforced by string-matching the hostname is trivially bypassed: an attacker registers `evil.example.com`, points its A record at `127.0.0.1` (or a metadata endpoint like `169.254.169.254`), and the literal-string check happily allows it. Codex's egress proxy treats string checks as insufficient — when local binding is disabled it does a best-effort DNS lookup with a timeout and blocks the request if **any** resolved IP is non-public, *even when the host is on the allowlist*.

**Incorrect (string allowlist, rebinding walks right through):**

```rust
// "localhost"/"127.0.0.1" literals blocked, but evil.example.com -> 127.0.0.1 is allowed
if is_allowlisted(host_str) && host_str != "localhost" {
    return Decision::Allowed;
}
```

**Correct (classify the literal, then resolve and classify the IPs):**

```rust
// network-proxy/src/runtime.rs — when local binding is off
let local_literal = if is_loopback_host(&host) {
    true
} else if let Ok(ip) = host_no_scope.parse::<IpAddr>() {
    is_non_public_ip(ip) // 127/8, 10/8, 169.254/16, ::1, link-local, ...
} else {
    false
};

if local_literal {
    if !is_explicit_local_allowlisted(&allowed_domains, &host) {
        return Ok(Blocked(NotAllowedLocal));
    }
} else if host_resolves_to_non_public_ip(host_str, port, DNS_LOOKUP_TIMEOUT, resolve).await {
    return Ok(Blocked(NotAllowedLocal)); // rebinding caught here, allowlist or not
}
```

The two-step check matters: an IP *literal* is classified directly, but a *hostname* must be resolved first, because the danger lives in what it resolves to, not how it is spelled. `is_non_public_ip` leans on stdlib classifiers (`is_loopback`, `is_private`, `is_link_local`) plus CIDR fallbacks for ranges stdlib doesn't cover yet (CGNAT, TEST-NET).

Reference: `codex-rs/network-proxy/src/runtime.rs:385`, `codex-rs/network-proxy/src/policy.rs:51`.
