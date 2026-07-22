# SonarQube Server (self-hosted)

**Version 0.1.0**  
community  
July 2026

---

## Abstract

Corrects the wrong defaults a capable model has when standing up self-hosted SonarQube Server as a continuous gate on AI-generated code, verified against docs.sonarsource.com in July 2026 against SonarQube Server 2026.3 (current LTA 2026.1). Covers the configurations that run green while measuring almost nothing — the fudge factor that skips duplication and coverage conditions below 20 new lines and is enabled by default, duplication that is never measured on test code, the absent new_cognitive_complexity metric, a sonar.host.url that now defaults to SonarQube Cloud rather than localhost, and shallow clones that silently degrade new-code attribution to analysis timestamps — alongside the AI Code Assurance machinery introduced in 10.7 (project flagging, gate qualification, the deprecated Copilot autodetection, the 2026.3 agentic profile) and the edition boundaries that decide whether a pull-request gate is possible at all.

---

## Table of Contents

1. [Edition & Version Reality](references/_sections.md#1-edition-&-version-reality)
   - 1.1 [Budget for Developer Edition before designing a pull-request gate](references/plat-community-build-cannot-see-pull-requests.md)
   - 1.2 [Check the edition each AI feature needs before promising it](references/plat-ai-features-are-edition-gated.md)
   - 1.3 [Pin calendar versions and plan the upgrade path through every LTA](references/plat-versions-are-calendar-based.md)
2. [AI Code Assurance](references/_sections.md#2-ai-code-assurance)
   - 2.1 [Label AI projects deliberately rather than relying on autodetection](references/aica-do-not-rely-on-autodetection.md)
   - 2.2 [Qualify a quality gate for AI Code Assurance explicitly](references/aica-qualify-the-gate-explicitly.md)
   - 2.3 [Set the AI-code flag through the Web API, not an analysis property](references/aica-flag-projects-through-the-api.md)
   - 2.4 [Treat the built-in AI gate as a floor and add the missing conditions](references/aica-the-builtin-ai-gate-is-lenient.md)
   - 2.5 [Use the Sonar agentic AI profile where it exists, Sonar way elsewhere](references/aica-use-the-agentic-profile.md)
3. [What the Gate Doesn't Measure](references/_sections.md#3-what-the-gate-doesn't-measure)
   - 3.1 [Activate the NOSONAR tracking rules, which Sonar way leaves off](references/blind-suppression-comments-turn-the-gate-green.md)
   - 3.2 [Disable the fudge factor or small commits bypass duplication and coverage](references/blind-fudge-factor-skips-small-changes.md)
   - 3.3 [Do not expect the duplication gate to see generated test code](references/blind-test-code-escapes-duplication.md)
   - 3.4 [Expect main to go red after a green pull request](references/blind-pull-requests-hide-file-level-issues.md)
   - 3.5 [Gate complexity through rule S3776, because no new-code metric exists](references/blind-no-new-code-complexity-metric.md)
   - 3.6 [Tune duplication thresholds per language, and skip the attempt on Java](references/blind-java-duplication-threshold-is-fixed.md)
4. [New Code & Blame](references/_sections.md#4-new-code-&-blame)
   - 4.1 [Check out full history or new code degrades to analysis timestamps](references/newcode-shallow-clones-break-blame.md)
   - 4.2 [Match the new code definition to the branching model](references/newcode-pick-the-definition-deliberately.md)
5. [Scanner Configuration](references/_sections.md#5-scanner-configuration)
   - 5.1 [Always set sonar.host.url, which now defaults to SonarQube Cloud](references/scan-host-url-defaults-to-the-cloud.md)
   - 5.2 [Authenticate CI with a project analysis token, not sonar.login](references/scan-use-project-analysis-tokens.md)
   - 5.3 [Declare sonar.tests explicitly, which has no default](references/scan-declare-test-sources.md)
   - 5.4 [Exclude with the narrowest property, not sonar.exclusions](references/scan-exclude-narrowly.md)
   - 5.5 [Import coverage reports, which SonarQube never generates itself](references/scan-import-coverage-reports.md)
   - 5.6 [Pass branch or pull request parameters, or everything lands on main](references/scan-name-the-branch.md)
   - 5.7 [Set sonar.qualitygate.wait or the pipeline passes on a red gate](references/scan-wait-for-the-quality-gate.md)
6. [Running the Server](references/_sections.md#6-running-the-server)
   - 6.1 [Protect the analysis history, because losing it resets every baseline](references/ops-persist-data-and-skip-h2.md)
   - 6.2 [Raise vm.max_map_count to 524288 on the host before first boot](references/ops-set-host-limits-before-first-boot.md)

---

## References

1. [https://docs.sonarsource.com/sonarqube-server/server-update-and-maintenance/update/release-cycle-model](https://docs.sonarsource.com/sonarqube-server/server-update-and-maintenance/update/release-cycle-model)
2. [https://docs.sonarsource.com/sonarqube-server/server-update-and-maintenance/update/determine-path](https://docs.sonarsource.com/sonarqube-server/server-update-and-maintenance/update/determine-path)
3. [https://docs.sonarsource.com/sonarqube-server/server-update-and-maintenance/release-notes](https://docs.sonarsource.com/sonarqube-server/server-update-and-maintenance/release-notes)
4. [https://docs.sonarsource.com/sonarqube-community-build/feature-comparison-table](https://docs.sonarsource.com/sonarqube-community-build/feature-comparison-table)
5. [https://docs.sonarsource.com/sonarqube-server/quality-standards-administration/ai-code-assurance/overview](https://docs.sonarsource.com/sonarqube-server/quality-standards-administration/ai-code-assurance/overview)
6. [https://docs.sonarsource.com/sonarqube-server/quality-standards-administration/ai-code-assurance/quality-gates-for-ai-code](https://docs.sonarsource.com/sonarqube-server/quality-standards-administration/ai-code-assurance/quality-gates-for-ai-code)
7. [https://docs.sonarsource.com/sonarqube-server/quality-standards-administration/ai-code-assurance/quality-profiles-for-ai-code](https://docs.sonarsource.com/sonarqube-server/quality-standards-administration/ai-code-assurance/quality-profiles-for-ai-code)
8. [https://docs.sonarsource.com/sonarqube-server/project-administration/ai-features/set-up-ai-code-assurance](https://docs.sonarsource.com/sonarqube-server/project-administration/ai-features/set-up-ai-code-assurance)
9. [https://docs.sonarsource.com/sonarqube-server/instance-administration/ai-features/autodetect-ai-code](https://docs.sonarsource.com/sonarqube-server/instance-administration/ai-features/autodetect-ai-code)
10. [https://docs.sonarsource.com/sonarqube-server/instance-administration/ai-features/enable-ai-codefix](https://docs.sonarsource.com/sonarqube-server/instance-administration/ai-features/enable-ai-codefix)
11. [https://docs.sonarsource.com/sonarqube-server/advanced-security/introduction](https://docs.sonarsource.com/sonarqube-server/advanced-security/introduction)
12. [https://docs.sonarsource.com/sonarqube-server/quality-standards-administration/managing-quality-gates/introduction-to-quality-gates](https://docs.sonarsource.com/sonarqube-server/quality-standards-administration/managing-quality-gates/introduction-to-quality-gates)
13. [https://docs.sonarsource.com/sonarqube-server/user-guide/code-metrics/metrics-definition](https://docs.sonarsource.com/sonarqube-server/user-guide/code-metrics/metrics-definition)
14. [https://docs.sonarsource.com/sonarqube-server/user-guide/about-new-code](https://docs.sonarsource.com/sonarqube-server/user-guide/about-new-code)
15. [https://docs.sonarsource.com/sonarqube-server/user-guide/managing-tokens](https://docs.sonarsource.com/sonarqube-server/user-guide/managing-tokens)
16. [https://docs.sonarsource.com/sonarqube-server/project-administration/adjusting-analysis/configuring-new-code-calculation](https://docs.sonarsource.com/sonarqube-server/project-administration/adjusting-analysis/configuring-new-code-calculation)
17. [https://docs.sonarsource.com/sonarqube-server/project-administration/adjusting-analysis/setting-analysis-scope/excluding-files-based-on-patterns](https://docs.sonarsource.com/sonarqube-server/project-administration/adjusting-analysis/setting-analysis-scope/excluding-files-based-on-patterns)
18. [https://docs.sonarsource.com/sonarqube-server/project-administration/adjusting-analysis/setting-analysis-scope/exclude-from-coverage-duplication](https://docs.sonarsource.com/sonarqube-server/project-administration/adjusting-analysis/setting-analysis-scope/exclude-from-coverage-duplication)
19. [https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/analysis-parameters/parameters-not-settable-in-ui](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/analysis-parameters/parameters-not-settable-in-ui)
20. [https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/scm-integration](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/scm-integration)
21. [https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/scanners/scanner-environment/verifying-code-checkout-step](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/scanners/scanner-environment/verifying-code-checkout-step)
22. [https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/scanners/sonarscanner](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/scanners/sonarscanner)
23. [https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/setting-up-the-branch-analysis](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/setting-up-the-branch-analysis)
24. [https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/setting-up-the-pull-request-analysis](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/setting-up-the-pull-request-analysis)
25. [https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/test-coverage/test-coverage-parameters](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/test-coverage/test-coverage-parameters)
26. [https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/test-coverage/java-test-coverage](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/test-coverage/java-test-coverage)
27. [https://docs.sonarsource.com/sonarqube-server/server-installation/from-docker-image/set-up-and-start-container](https://docs.sonarsource.com/sonarqube-server/server-installation/from-docker-image/set-up-and-start-container)
28. [https://docs.sonarsource.com/sonarqube-server/server-installation/pre-installation/linux](https://docs.sonarsource.com/sonarqube-server/server-installation/pre-installation/linux)
29. [https://docs.sonarsource.com/sonarqube-server/server-installation/server-host-requirements](https://docs.sonarsource.com/sonarqube-server/server-installation/server-host-requirements)
30. [https://www.sonarsource.com/plans-and-pricing/sonarqube/](https://www.sonarsource.com/plans-and-pricing/sonarqube/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |