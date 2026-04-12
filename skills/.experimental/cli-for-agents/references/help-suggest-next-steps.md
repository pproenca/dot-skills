---
title: Suggest What to Run Next in Help and Success Output
impact: HIGH
impactDescription: prevents round-trips to top-level help for related commands
tags: help, composition, workflow, see-also
---

## Suggest What to Run Next in Help and Success Output

Agents chain commands to complete tasks. A help or success message that ends with "See also: mycli deploy list" or "Next: mycli deploy verify --id dep_abc123" saves the agent from having to discover related commands by grepping the top-level help. Every success line and every help page should hint at the most likely next action. This is the single cheapest thing you can add to improve agent workflow quality.

**Incorrect (help and success output are dead-ends):**

```text
$ mycli deploy --env staging --tag v1.2.3
Deploying...
Done.

$ mycli deploy --help
Usage: mycli deploy [options]

Options:
  --env <env>    environment
  --tag <tag>    tag

Examples:
  mycli deploy --env staging --tag v1.2.3
```

**Correct (success output and help both suggest next actions):**

```text
$ mycli deploy --env staging --tag v1.2.3
deployed v1.2.3 to staging
url:       https://staging.myapp.com
deploy_id: dep_abc123
duration:  34s

Next:
  mycli deploy verify --id dep_abc123     verify the deploy
  mycli logs --service myapp --tail 100   tail service logs
  mycli deploy rollback --id dep_abc123   roll back if needed

$ mycli deploy --help
...
Examples:
  mycli deploy --env staging --tag v1.2.3

See also:
  mycli deploy list           list recent deploys
  mycli deploy rollback       roll back the last deploy
  mycli deploy verify         verify deploy health
```

**Benefits:**
- Agents discover related commands without reading top-level help
- Success output doubles as a workflow tutorial
- The first command the agent runs teaches it two or three more

Reference: [clig.dev — Suggest commands to run next](https://clig.dev/#help)
