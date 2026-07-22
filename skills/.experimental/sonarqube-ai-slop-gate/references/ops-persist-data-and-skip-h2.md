---
title: Protect the analysis history, because losing it resets every baseline
tags: ops, docker, database, persistence
---

## Protect the analysis history, because losing it resets every baseline

The reason to care about SonarQube's storage is not the usual one. Losing a dashboard is an inconvenience; losing the **analysis history** breaks the gate, because every new-code definition is computed relative to something in that history — a previous version, a date, a specific past analysis. Restore an instance without its history and "new code" means whatever the first analysis after the restore says it means. The gate keeps running and silently starts measuring against a baseline of nothing.

That makes the embedded H2 database a trap with a long fuse. `docker run -p 9000:9000 sonarqube:developer` starts a working instance in one command, and the documentation is clear that H2 *"is recommended for tests but not for production use"*. It works for months while history accumulates, and then the first upgrade arrives with no supported H2 migration path.

The same reasoning applies to the volumes: without them, replacing a container discards the Elasticsearch indices and any installed plugins.

```yaml
services:
  sonarqube:
    image: sonarqube:2026-lta-developer
    depends_on: [db]
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://db:5432/sonarqube
      SONAR_JDBC_USERNAME: sonarqube
      # The image entrypoint has no *_FILE / Docker-secret support — the
      # password must arrive as a plain environment variable.
      SONAR_JDBC_PASSWORD: ${SONAR_DB_PASSWORD:?set in .env}
    volumes:
      - sonarqube_data:/opt/sonarqube/data           # Elasticsearch indices
      - sonarqube_extensions:/opt/sonarqube/extensions  # plugins
      - sonarqube_logs:/opt/sonarqube/logs
      - sonarqube_temp:/opt/sonarqube/temp
    ports: ["9000:9000"]

  db:
    image: postgres:17
    environment:
      POSTGRES_USER: sonarqube
      POSTGRES_DB: sonarqube
      # Required — postgres refuses to initialize without it.
      POSTGRES_PASSWORD: ${SONAR_DB_PASSWORD:?set in .env}
    volumes:
      - postgresql_data:/var/lib/postgresql/data

volumes:
  sonarqube_data: {}
  sonarqube_extensions: {}
  sonarqube_logs: {}
  sonarqube_temp: {}
  postgresql_data: {}
```

Supported databases are PostgreSQL, Oracle, and Microsoft SQL Server. Only the database holds irreplaceable state — `sonarqube_data` can be rebuilt by reindexing — so it is the one that needs a backup policy, and the restore path is worth exercising before it is needed.

One related setting can destroy history while everything else is configured correctly: the housekeeping job (`sonar.dbcleaner.*`) purges old analyses on a schedule. A new code definition pinned to a **specific analysis** can therefore have its baseline deleted out from under it, at which point the definition silently stops resolving. Either avoid pinned-analysis baselines for long-lived projects, or align the housekeeping window with how long you intend the baseline to survive.

Reference: [Installing the database](https://docs.sonarsource.com/sonarqube-server/server-installation/installing-the-database) · [Set up and start the container](https://docs.sonarsource.com/sonarqube-server/server-installation/from-docker-image/set-up-and-start-container)
