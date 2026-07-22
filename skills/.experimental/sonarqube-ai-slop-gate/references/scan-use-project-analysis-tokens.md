---
title: Authenticate CI with a project analysis token, not sonar.login
tags: scan, tokens, authentication, security
---

## Authenticate CI with a project analysis token, not sonar.login

Supplying `SONAR_TOKEN` from CI secrets is the easy part, and it is not where this goes wrong. The mistake is **which token** — and the UI's default choice is the worst of the three.

Generating a **user token** is the path of least resistance because it is what the account settings page offers. A user token *"Allow[s] you to perform, via the Web API, any action the user can do via the UI"* — so a token leaked from a build log grants whatever that human can do across the entire instance, including administration if they have it, and including projects unrelated to the pipeline that leaked it. It also breaks when the person leaves the company, which turns a routine offboarding into a fleet-wide CI outage.

The right credential for CI is a **project analysis token**, scoped to the single project it was generated for. The docs recommend it *"for security reasons"*: a leak exposes one project's analysis rather than an account. A **global analysis token** exists for cases where one pipeline analyzes many projects, and requires the Global Execute Analysis permission — use it only when per-project tokens are genuinely impractical, since it re-creates most of the blast radius.

```yaml
# Supply the token via environment, never as a command-line argument — argv is
# visible in process listings and frequently echoed into build logs.
env:
  SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}        # project analysis token
  SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
```

One scanner-specific exception to note: the `SONAR_TOKEN` environment variable is *"not supported by SonarScanner for .NET"*, which needs the token passed as a parameter. That is the one case where it lands in argv, so mask it explicitly in the CI provider.

The legacy spelling is also worth recognising in an existing pipeline: `sonar.token` *"replaces `sonar.login` and `sonar.password` properties which are deprecated"*, and a project still analyzed that way carries a permanent warning banner, since *"A user warning appears on the project interface if you activate this parameter."*

On expiry, Server behaviour differs from Cloud. You *"select an expiration for your token or choose No expiration"* — there is no documented default value, and the fixed 7/30/60/90-day picker and 60-day-inactivity removal belong to SonarQube Cloud, not Server. From Enterprise edition an administrator can enforce a maximum token lifetime, which removes the "No expiration" option instance-wide. Setting an expiry is worth doing even without that enforcement, provided the rotation is automated; an expired token fails the build with a clear authentication error, which is a better failure than a credential that lives forever.

Reference: [Managing tokens](https://docs.sonarsource.com/sonarqube-server/user-guide/managing-tokens) · [Analysis parameters](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/analysis-parameters/parameters-not-settable-in-ui)
