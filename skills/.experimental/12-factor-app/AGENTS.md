# Cloud-Native Applications

**Version 0.1.0**  
Twelve-Factor Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

The Twelve-Factor App methodology for building modern, scalable software-as-a-service applications. Contains 51 rules across 12 categories covering codebase management, dependency isolation, configuration, backing services, build/release/run separation, stateless processes, port binding, concurrency, disposability, dev/prod parity, logging, and admin processes. Each rule provides actionable guidance for AI agents to generate cloud-native, deployment-ready code.

---

## Table of Contents

1. [Codebase & Version Control](references/_sections.md#1-codebase-&-version-control) — **CRITICAL**
   - 1.1 [Enforce One-to-One Correlation Between Codebase and Application](references/code-one-app-one-repo.md) — CRITICAL (prevents coupling, enables independent deployment)
   - 1.2 [Factor Shared Code Into Libraries Managed by Dependency Manager](references/code-shared-as-libraries.md) — HIGH (enables code reuse without coupling, allows independent versioning)
   - 1.3 [Maintain One Codebase Per Application in Version Control](references/code-single-codebase.md) — CRITICAL (enables consistent deployments, prevents configuration drift)
   - 1.4 [Use Deploys Not Branches to Represent Environments](references/code-deploys-not-branches.md) — HIGH (prevents environment-specific code paths, simplifies merging)
2. [Dependencies](references/_sections.md#2-dependencies) — **CRITICAL**
   - 2.1 [Declare All Dependencies Explicitly in a Manifest File](references/dep-explicit-declaration.md) — CRITICAL (enables reproducible builds, prevents "works on my machine" issues)
   - 2.2 [Isolate Dependencies to Prevent System Package Leakage](references/dep-isolate-execution.md) — CRITICAL (prevents version conflicts, ensures consistent behavior across environments)
   - 2.3 [Never Rely on Implicit System Tools Being Available](references/dep-no-system-tools.md) — HIGH (ensures portability, prevents deployment failures)
   - 2.4 [Use Lockfiles for Deterministic Dependency Resolution](references/dep-deterministic-builds.md) — HIGH (guarantees identical builds, prevents "it worked yesterday" bugs)
3. [Configuration](references/_sections.md#3-configuration) — **CRITICAL**
   - 3.1 [Never Commit Secrets or Credentials to Version Control](references/config-never-commit-secrets.md) — CRITICAL (prevents security breaches, credentials in git history are nearly impossible to fully remove)
   - 3.2 [Store Configuration in Environment Variables](references/config-use-env-vars.md) — CRITICAL (language-agnostic, impossible to accidentally commit, easy to change per deploy)
   - 3.3 [Strictly Separate Configuration from Code](references/config-separate-from-code.md) — CRITICAL (enables deployment to any environment without code changes)
   - 3.4 [Treat Environment Variables as Granular Controls Not Grouped Environments](references/config-no-env-groups.md) — HIGH (scales to unlimited deploys, prevents combinatorial explosion)
   - 3.5 [Validate Required Configuration at Application Startup](references/config-validate-on-startup.md) — HIGH (fast failure prevents silent misconfiguration, improves debugging)
4. [Backing Services](references/_sections.md#4-backing-services) — **HIGH**
   - 4.1 [Design Services to Be Detachable and Attachable Without Code Changes](references/svc-detach-attach-without-code.md) — HIGH (enables zero-downtime migrations, disaster recovery, and scaling)
   - 4.2 [Make No Distinction Between Local and Third-Party Services](references/svc-no-local-vs-remote.md) — HIGH (ensures code portability, enables seamless service migration)
   - 4.3 [Reference All Backing Services via Connection URLs in Config](references/svc-connection-strings.md) — HIGH (standardized format, easy to swap services, works across all platforms)
   - 4.4 [Treat Backing Services as Attached Resources](references/svc-as-attached-resources.md) — HIGH (enables swapping services without code changes, improves resilience)
5. [Build, Release, Run](references/_sections.md#5-build,-release,-run) — **HIGH**
   - 5.1 [Create Immutable Releases with Unique Identifiers](references/build-immutable-releases.md) — HIGH (enables reliable rollbacks, audit trails, and deployment tracking)
   - 5.2 [Generate One Build Artifact Per Commit Deploy Same Artifact Everywhere](references/build-artifact-per-commit.md) — MEDIUM-HIGH (guarantees staging tests what production runs, eliminates build inconsistency)
   - 5.3 [Never Modify Code at Runtime - Changes Require New Release](references/build-no-runtime-changes.md) — HIGH (prevents configuration drift, ensures reproducibility)
   - 5.4 [Push Complexity Into Build Stage Keep Run Stage Minimal](references/build-complexity-in-build.md) — HIGH (reduces runtime failures, faster recovery from crashes)
   - 5.5 [Strictly Separate Build, Release, and Run Stages](references/build-separate-stages.md) — HIGH (enables rollbacks, prevents runtime modifications, improves reliability)
6. [Processes & State](references/_sections.md#6-processes-&-state) — **HIGH**
   - 6.1 [Design Processes to Share Nothing with Each Other](references/proc-share-nothing.md) — HIGH (enables independent scaling, prevents cascade failures)
   - 6.2 [Execute the Application as Stateless Processes](references/proc-stateless-processes.md) — HIGH (enables horizontal scaling, ensures resilience to process crashes)
   - 6.3 [Never Assume Local Filesystem Persists Between Requests](references/proc-no-local-filesystem.md) — HIGH (prevents data loss on restart, enables containerized deployment)
   - 6.4 [Never Use Sticky Sessions - Store Session Data in Backing Services](references/proc-no-sticky-sessions.md) — HIGH (enables load balancer flexibility, prevents single-point-of-failure)
   - 6.5 [Perform Asset Compilation and Bundling at Build Time Not Runtime](references/proc-compile-at-build.md) — MEDIUM-HIGH (ensures fast startup, prevents runtime compilation failures)
7. [Concurrency & Scaling](references/_sections.md#7-concurrency-&-scaling) — **HIGH**
   - 7.1 [Assign Workloads to Appropriate Process Types](references/scale-process-types.md) — HIGH (optimizes resource usage, enables targeted scaling)
   - 7.2 [Define Process Formation as Declarative Configuration](references/scale-process-formation.md) — MEDIUM-HIGH (enables reproducible deployments, infrastructure as code)
   - 7.3 [Design for Horizontal Scaling Over Vertical Scaling](references/scale-horizontal-not-vertical.md) — HIGH (enables cost-effective scaling, eliminates single points of failure)
   - 7.4 [Never Daemonize or Write PID Files Let Process Manager Handle It](references/scale-no-daemonize.md) — HIGH (enables process manager control, proper signal handling, crash recovery)
   - 7.5 [Scale Out via the Process Model with Multiple Process Types](references/scale-process-model.md) — HIGH (enables horizontal scaling, matches workload diversity to process types)
8. [Disposability](references/_sections.md#8-disposability) — **HIGH**
   - 8.1 [Design for Crash-Only Software That Recovers from Sudden Death](references/disp-crash-only.md) — HIGH (ensures resilience to hardware failures, prevents data loss)
   - 8.2 [Design Processes to Be Disposable Started or Stopped at Any Moment](references/disp-disposable-processes.md) — HIGH (enables rapid deployment, elastic scaling, and fault tolerance)
   - 8.3 [Implement Graceful Shutdown on SIGTERM](references/disp-graceful-shutdown.md) — HIGH (prevents request failures during deploys, ensures data integrity)
   - 8.4 [Make Operations Idempotent to Safely Retry After Failures](references/disp-idempotent-operations.md) — HIGH (enables automatic retry, prevents duplicate processing)
   - 8.5 [Minimize Startup Time to Enable Rapid Scaling and Recovery](references/disp-fast-startup.md) — HIGH (enables autoscaling responsiveness, faster deployments, quicker crash recovery)
9. [Port Binding](references/_sections.md#9-port-binding) — **MEDIUM**
   - 9.1 [Export Services via Port Binding Using PORT Environment Variable](references/port-export-via-binding.md) — MEDIUM (enables platform-managed port assignment, essential for container orchestration)
   - 9.2 [Make the Application Completely Self-Contained with Embedded Server](references/port-self-contained.md) — MEDIUM (simplifies deployment, removes webserver injection dependency)
   - 9.3 [Use Port Binding to Export Any Protocol Not Just HTTP](references/port-any-protocol.md) — MEDIUM (enables microservices to be backing services for each other)
10. [Dev/Prod Parity](references/_sections.md#10-dev/prod-parity) — **MEDIUM**
   - 10.1 [Deploy Frequently to Minimize the Time Gap](references/parity-deploy-frequently.md) — MEDIUM (reduces risk per deploy, accelerates feedback loops)
   - 10.2 [Involve Developers in Deployment to Minimize Personnel Gap](references/parity-developers-deploy.md) — MEDIUM (faster issue resolution, better understanding of production behavior)
   - 10.3 [Minimize Gaps Between Development and Production Environments](references/parity-minimize-gaps.md) — MEDIUM (prevents "works on my machine" bugs, enables continuous deployment)
   - 10.4 [Use the Same Type and Version of Backing Services in All Environments](references/parity-same-backing-services.md) — MEDIUM (eliminates environment-specific bugs, ensures production behavior in development)
11. [Logging](references/_sections.md#11-logging) — **MEDIUM**
   - 11.1 [Never Route or Store Logs from Within the Application](references/log-no-routing.md) — MEDIUM (simplifies app code, enables flexible log infrastructure)
   - 11.2 [Treat Logs as Event Streams Not Files](references/log-event-streams.md) — MEDIUM (enables log aggregation, real-time analysis, cloud-native deployment)
   - 11.3 [Use Structured Logging for Machine-Readable Event Streams](references/log-structured-format.md) — MEDIUM (enables field-based querying, aggregation, and automated alerting)
   - 11.4 [Write Logs Unbuffered to Stdout for Real-Time Streaming](references/log-unbuffered-stdout.md) — MEDIUM (enables real-time log viewing, prevents log loss on crash)
12. [Admin Processes](references/_sections.md#12-admin-processes) — **MEDIUM**
   - 12.1 [Provide REPL Access for Debugging and Data Inspection](references/admin-repl-access.md) — MEDIUM (enables interactive debugging, safe data investigation)
   - 12.2 [Run Admin Processes Against a Release with Same Codebase and Config](references/admin-same-environment.md) — MEDIUM (prevents synchronization issues, ensures correct behavior)
   - 12.3 [Run Admin Tasks as One-Off Processes Not Special Scripts](references/admin-one-off-processes.md) — MEDIUM (ensures consistency, enables auditability, prevents configuration drift)

---

## References

1. [https://12factor.net/](https://12factor.net/)
2. [https://github.com/twelve-factor/twelve-factor](https://github.com/twelve-factor/twelve-factor)
3. [https://www.heroku.com/](https://www.heroku.com/)
4. [https://kubernetes.io/docs/concepts/](https://kubernetes.io/docs/concepts/)
5. [https://www.docker.com/](https://www.docker.com/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |