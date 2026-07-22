---
title: Always set sonar.host.url, which now defaults to SonarQube Cloud
tags: scan, host-url, configuration, self-hosted
---

## Always set sonar.host.url, which now defaults to SonarQube Cloud

Long-standing knowledge says an unset `sonar.host.url` falls back to `http://localhost:9000`, which makes omitting it look harmless — worst case the scanner cannot connect and the build fails loudly. That default changed, and the new one fails in the opposite direction.

On **SonarScanner CLI v6.0+, Maven v5.0+, Gradle v6.0+, .NET v7.0+, NPM v4.0+, and Python**, the default is now **`https://sonarcloud.io`**. Older scanners still default to `http://localhost:9000`.

For a self-hosted deployment this is the highest-consequence omission in the whole configuration surface. A pipeline missing the property does not fail to reach your server — it authenticates against Sonar's SaaS. Depending on the token supplied, the outcome is either a confusing authentication error against a service nobody meant to contact, or, where a SonarQube Cloud token is present in the environment, a successful analysis that uploads the source tree to a hosted instance outside the organisation's control. Neither reads as a misconfigured URL in the log.

```properties
# sonar-project.properties — mandatory for self-hosted. Without it, modern
# scanners target https://sonarcloud.io, not localhost.
sonar.projectKey=checkout-service
sonar.host.url=https://sonarqube.internal.example.com
sonar.sources=src
sonar.tests=src/test
```

The property is documented as mandatory, and treating it as such is the correct posture even where a default would happen to be right. Supply it as `SONAR_HOST_URL` in CI so it is set once per runner rather than per repository, and keep it in the properties file for local scanner runs.

Worth auditing existing pipelines for on any upgrade: a scanner that was pinned below these versions and worked without the property will change behaviour the moment it floats to a newer major, with no configuration change to point at. `SonarSource/sonarqube-scan-action` and the equivalent plugins update their embedded scanner independently of anything in your repository.

Reference: [Analysis parameters](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/analysis-parameters/parameters-not-settable-in-ui)
