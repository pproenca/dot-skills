# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Codebase & Version Control (code)

**Impact:** CRITICAL
**Description:** One codebase tracked in revision control, many deploys. The foundation for consistent deployments and team collaboration.

## 2. Dependencies (dep)

**Impact:** CRITICAL
**Description:** Explicitly declare and isolate all dependencies. Never rely on implicit system-wide packages or tools.

## 3. Configuration (config)

**Impact:** CRITICAL
**Description:** Store configuration in environment variables. Strict separation of config from code enables deployment flexibility.

## 4. Backing Services (svc)

**Impact:** HIGH
**Description:** Treat backing services as attached resources. Access databases, caches, and queues via URLs stored in configuration.

## 5. Build, Release, Run (build)

**Impact:** HIGH
**Description:** Strictly separate build, release, and run stages. Each release is immutable and uniquely identified.

## 6. Processes & State (proc)

**Impact:** HIGH
**Description:** Execute the app as stateless processes. Store persistent data in backing services, never in local filesystem or memory.

## 7. Concurrency & Scaling (scale)

**Impact:** HIGH
**Description:** Scale out via the process model. Assign workloads to process types and let the execution environment manage processes.

## 8. Disposability (disp)

**Impact:** HIGH
**Description:** Maximize robustness with fast startup and graceful shutdown. Processes are disposable and can be started or stopped at will.

## 9. Port Binding (port)

**Impact:** MEDIUM
**Description:** Export services via port binding. The app is self-contained and does not rely on runtime injection of a webserver.

## 10. Dev/Prod Parity (parity)

**Impact:** MEDIUM
**Description:** Keep development, staging, and production as similar as possible. Minimize gaps in time, personnel, and tools.

## 11. Logging (log)

**Impact:** MEDIUM
**Description:** Treat logs as event streams. Write unbuffered to stdout, let the execution environment handle routing and storage.

## 12. Admin Processes (admin)

**Impact:** MEDIUM
**Description:** Run admin/management tasks as one-off processes. Use the same codebase, config, and environment as regular processes.
