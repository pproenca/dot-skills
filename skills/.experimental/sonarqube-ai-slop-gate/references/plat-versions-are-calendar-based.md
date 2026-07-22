---
title: Pin calendar versions and plan the upgrade path through every LTA
tags: plat, versioning, lta, upgrades
---

## Pin calendar versions and plan the upgrade path through every LTA

The model's stored version knowledge is two years stale, so it reaches for tags like `sonarqube:9.9-community` or `sonarqube:10-lts` and calls the product "SonarQube Community Edition". None of those names are current. Up to 10.8 the scheme was `MAJOR.MINOR.PATCH`; it is now `YYYY.ReleaseNumber.PatchReleaseNumber`, with *"A new version of SonarQube Server is released every two months, with a new Long-Term Active (LTA) version (previously known as LTS) released every year."*

As of July 2026 the active versions are **2026.4, 2026.3, and 2026.1 LTA**, plus **2025.4 LTA**. The 2025.1 LTA is already inactive. The free product is **SonarQube Community Build**, on a separate monthly train with its own scheme (`26.7.0.124771`, July 2026) and **no LTA at all**.

The consequence that costs real time is the upgrade path, because it is not free-form. *"If there is at least one LTA version in your update path, you must first update to each intermediate LTA and then to your target version."* An instance sitting on 9.9 LTA cannot jump to 2026.1 — it must stop at 2025.1 LTA on the way. Discovering that mid-maintenance-window, with the database already migrating, is how a two-hour upgrade becomes a rollback.

```yaml
# Pin the LTA explicitly. `sonarqube:developer` floats to the newest release,
# which moves every two months and will upgrade the database out from under you
# on the next `docker compose pull`.
services:
  sonarqube:
    image: sonarqube:2026-lta-developer
```

Support windows follow from the same model: an LTA receives twelve months of vulnerability and blocker patches and *"is active for up to 18 months from its release date."* The newest release gets features, patches, and support; the one before it gets technical support only. Staying on an LTA and moving once a year is the low-maintenance path; tracking the two-month train means accepting a database migration six times a year.

One documentation note that saves a wasted fetch: `/latest/` is not a usable path prefix. The bare `https://docs.sonarsource.com/sonarqube-server/latest/` redirects to the current doc set, but deeper `/latest/<page>` URLs error rather than resolving. Use the **unversioned** path for current docs, or address a version explicitly (`/2026.3/<page>`). Appending `.md` to any documentation URL returns its markdown source, which is the most reliable way to read these pages.

Reference: [Release cycle model](https://docs.sonarsource.com/sonarqube-server/server-update-and-maintenance/update/release-cycle-model) · [Determine your update path](https://docs.sonarsource.com/sonarqube-server/server-update-and-maintenance/update/determine-path)
