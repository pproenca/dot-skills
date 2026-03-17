# Core Beliefs: Agent-First Operating Principles

This reference provides the template and content guidance for the
`docs/design-docs/core-beliefs.md` file that the harness creates in each repo.

Core beliefs are the design principles that shape how agents make decisions
in this specific codebase. They are not generic software principles — they
are beliefs about how to build effectively when agents are the primary authors.

## The Beliefs

### 1. Prefer Boring Technology

Technologies described as "boring" tend to be easier for agents to model.
Composability, API stability, and broad representation in training data all
make a technology more agent-legible. When choosing between a cutting-edge
library and a well-established one that does 80% of what you need, prefer
the established one.

**Why this matters for agents**: Agents reason about APIs by pattern-matching
against their training data. A library with thousands of Stack Overflow answers
and GitHub examples is one the agent can use correctly. A library released
last month is one the agent will hallucinate APIs for.

**Decision framework**:
- Is this technology well-documented and widely used?
- Are its APIs stable across versions?
- Can the agent find correct usage examples in its training data?
- Does it have predictable, composable behavior?

If the answer to most of these is "no," the technology is a legibility risk.

### 2. Build vs. Buy: The Agent Calculus

In traditional engineering, the calculus is simple: buy (use a library) unless
the library doesn't do what you need. With agents, the calculus shifts.

Sometimes it's cheaper to have the agent reimplement a subset of functionality
than to work around opaque upstream behavior. The reimplemented version is:
- Tightly integrated with your codebase's patterns (observability, error handling)
- 100% inspectable and modifiable by agents
- Tested exactly the way your codebase expects
- Free of unnecessary complexity from features you don't use

**When to reimplement**:
- The library is a thin wrapper around simple logic (concurrency helpers,
  retry utilities, data transformers)
- You need deep integration with your observability or error handling
- The library's API is unstable or poorly documented
- You only use 10–20% of the library's surface area

**When to use the library**:
- The library implements complex, well-tested logic (crypto, parsing, protocols)
- Reimplementing would take more than a day of agent time
- The library has a stable, well-documented API
- Multiple domains depend on it (standardization value)

### 3. Repository-Local Is the Only Real

From the agent's point of view, anything it can't access in-context while
running doesn't exist. Knowledge that lives in Google Docs, Slack threads,
or people's heads is invisible to the system.

This means:
- Decisions made in meetings must be encoded in docs/ or design-docs/
- Architecture discussions from Slack must become ARCHITECTURE.md updates
- Team conventions must become golden principles or enforcement rules
- External API docs must be copied into docs/references/ in agent-friendly format

The test: if a new agent run starts with zero context beyond the repository,
can it make correct decisions? If not, the missing context needs to be encoded.

### 4. Onboard the Agent Like a New Hire

Giving the agent context means organizing and exposing the right information
so it can reason over it, rather than overwhelming it with ad-hoc instructions.

Think about how you'd onboard a new teammate:
- Product principles (what are we building and why)
- Engineering norms (how we write code here)
- Team culture (what we care about, what we tolerate)
- Domain knowledge (how the business works)

All of this should be in the repo. The agent should absorb it the same way
a new hire would — by reading the docs, not by asking in Slack.

### 5. Constraints Enable Speed

In a human-first workflow, strict architectural rules feel pedantic. With
agents, they become multipliers. Once encoded, constraints apply everywhere
at once. An agent working within well-defined boundaries ships faster than
one guessing at boundaries that don't exist.

The right posture: enforce boundaries centrally, allow autonomy locally.
Care deeply about what can depend on what, how errors propagate, and where
data is validated. Within those boundaries, allow agents significant freedom
in how solutions are expressed.

The resulting code may not match human stylistic preferences, and that's okay.
As long as the output is correct, maintainable, and legible to future agent
runs, it meets the bar.

### 6. Failure Means Missing Capability, Not Missing Effort

When an agent produces bad output, the fix is almost never "try harder" or
"prompt better." It's a signal that something is missing from the environment:
a tool, a guardrail, a document, an abstraction.

The diagnostic question: **"What capability is missing, and how do we make it
both legible and enforceable for the agent?"**

Then build that capability — by having the agent write the fix.

## Writing Core Beliefs for a Specific Repo

When creating `docs/design-docs/core-beliefs.md` for a repo:

1. Start with the universal beliefs above, but adapt them to the repo's context
2. Add repo-specific beliefs discovered during assessment (e.g., "We use Zod for
   all runtime validation" or "We prefer server components over client components")
3. Include concrete examples from the actual codebase
4. Keep to 6–10 beliefs — more than that and they stop being memorable
5. Review and update beliefs when the team's understanding evolves

Each belief should answer: "If an agent is making a decision and could go
either way, which way should it go and why?"
