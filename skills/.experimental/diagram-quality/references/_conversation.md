---
title: Conversation Mechanics
impact: HIGH
impactDescription: Prevents wasted human attention from wrong tool calls and empty messages
tags: conv, versioning, aliasing, naming, feedback, agent-uml
---

# Conversation Mechanics

The agent-uml canvas is a conversation medium. Every `diagram_upsert` call pushes a new version to the timeline and optionally posts a message to the chat panel. Every `design_feedback` call reads what the human said (chat messages) or pointed at (element annotations). Wrong decisions here — pushing a version when you should have asked a question, or posting an empty message when you should have explained a structural change — waste the human's attention and stall convergence.

These 5 decision tables map situations to the right tool call with the right parameters.

---

## Table 1: Alias Discipline Per Element Type

Every element must have an explicit `as Alias` to be clickable on the canvas. This table shows the exact syntax for each diagram type.

| Diagram Type | Element | Syntax | Example |
|---|---|---|---|
| component | Component | `[Display Name] as Alias` | `[API Gateway] as APIGateway` |
| component | Actor | `actor "Display Name" as Alias` | `actor "End User" as EndUser` |
| component | Interface | `interface "Display Name" as Alias` | `interface "REST API" as RestAPI` |
| component | Database | `database "Display Name" as Alias` | `database "User DB" as UserDB` |
| component | Boundary | `package "Display Name" as Alias {}` | `package "Backend" as Backend {}` |
| class | Class | `class "Display Name" as Alias` | `class "User Service" as UserService` |
| class | Interface | `interface "Display Name" as Alias` | `interface "Repository" as Repository` |
| class | Enum | `enum "Display Name" as Alias` | `enum "OrderStatus" as OrderStatus` |
| class | Abstract | `abstract class "Display Name" as Alias` | `abstract class "Base Handler" as BaseHandler` |
| sequence | Participant | `participant "Display Name" as Alias` | `participant "Auth Service" as AuthService` |
| sequence | Actor | `actor "Display Name" as Alias` | `actor "Client" as Client` |
| sequence | Boundary | `boundary "Display Name" as Alias` | `boundary "API Layer" as APILayer` |
| sequence | Control | `control "Display Name" as Alias` | `control "Orchestrator" as Orchestrator` |
| sequence | Entity | `entity "Display Name" as Alias` | `entity "Order" as Order` |
| activity | Partition | `partition "Display Name" as Alias {}` | `partition "Validation" as Validation {}` |
| state | State | `state "Display Name" as Alias` | `state "Processing" as Processing` |

**Rule:** If the display name is a single word identical to the alias, you still write the alias explicitly: `class UserService as UserService`. Relying on implicit naming is fragile across PlantUML versions.

---

## Table 2: Cross-Diagram Naming Consistency

When the same concept appears in multiple diagrams, the alias must be identical or systematically derived. This enables the human to trace an annotation on one diagram to its counterpart in another.

| Situation | Alias Rule | Example |
|---|---|---|
| Same component in component + sequence diagrams | Identical alias | `AuthService` in both |
| Class that implements a component's interface | Component alias + suffix | Component: `PaymentService`, Class: `PaymentServiceImpl` |
| Sequence participant that represents a class | Identical alias to the class | Class: `OrderService`, Participant: `OrderService` |
| Boundary/package containing multiple classes | Shared prefix | Package: `UserDomain`, Classes: `UserService`, `UserRepo` |
| External system referenced across diagrams | Identical alias everywhere | `StripeAPI` in component, sequence, and activity |
| Database referenced in component + sequence | Identical alias | `OrderDB` in both |
| Actor in component + sequence | Identical alias | `EndUser` in both |

**Anti-pattern:** Using `PaySvc` in the component diagram and `PaymentService` in the sequence diagram. When the human annotates `PaySvc`, Claude must know it maps to `PaymentService` — but why make either party do that translation? Use one alias.

---

## Table 3: What Each Diagram Type Shows and Excludes

Each diagram type in the `diagram_upsert` type enum has a specific scope. Including out-of-scope detail clutters the canvas and dilutes feedback.

| Type | Shows | Excludes | Typical Design Phase |
|---|---|---|---|
| `component` | System boundaries, containers/services, external dependencies, communication protocols, data stores | Internal class structure, method signatures, field types | First: establish system-level architecture |
| `class` | Domain model for ONE bounded context, relationships (inheritance, composition, dependency), key methods/fields, interfaces | Infrastructure concerns, other bounded contexts, deployment details | After component: detail one container's internals |
| `sequence` | Interaction flow for ONE use case, message order, async boundaries, return values, alt/opt/loop fragments | Classes/methods not involved in this flow, error handling for unrelated paths | After class: animate a specific scenario |
| `activity` | Business process flow, decision points, parallel forks/joins, swimlanes/partitions | Technical implementation, class structure, API details | When modeling workflows or business rules |
| `state` | Lifecycle of ONE entity, transitions with guards, entry/exit actions, nested states | Other entities, infrastructure, the code that implements transitions | When modeling entity lifecycle |

**Rule:** If you catch yourself adding an element that belongs to a different diagram type, stop. Create a separate diagram instead of overloading the current one.

---

## Table 4: When to Push a New Version vs. Ask a Question

This table maps feedback signals from `design_feedback` to the correct next tool call. The signal type determines whether you call `diagram_upsert` (push a visual change) or `design_feedback` with `reply` only (respond without changing the diagram).

| Signal | Tool Call | Action | Message Content |
|---|---|---|---|
| **Annotation on specific element** | `diagram_upsert` | Targeted fix to the annotated element | "Fixed [Element]: [what changed]. Does the relationship to [adjacent element] still hold?" |
| **Chat: "X should be Y"** (rename/move) | `diagram_upsert` | Structural change — rename, move, or reconnect | "Renamed/moved [X] → [Y]. This also affects [downstream dependency] — I updated that too." |
| **Chat: "what about X?"** (question) | `design_feedback` with `reply` | Probe before drawing — clarify scope/intent | "Good question. X could live in [A] or [B] depending on [tradeoff]. Which fits your architecture better?" |
| **Chat: "this doesn't feel right"** (vague) | `design_feedback` with `reply` | Ask which element or boundary feels wrong | "Can you click on the element or area that feels off? Or is it the overall decomposition that needs rethinking?" |
| **Chat: "looks good" / "continue"** | `diagram_upsert` (new type) | Advance to next methodology step | "Moving to [next diagram type] to detail [specific aspect]. Starting with [scope]." |
| **Annotation + chat together** | `diagram_upsert` | Address annotation first, acknowledge broader point | "Fixed [annotated element]. Regarding your chat point about [topic] — [brief response or question]." |
| **120s timeout (no feedback)** | `design_feedback` with `reply` | Announce you're advancing; don't proceed silently | "No feedback received — I'll move forward with [next step]. Let me know if you'd like to revisit the current diagram." |

**Key principle:** Every `diagram_upsert` call gets a `message` that (a) explains what changed and (b) asks a focusing question about the *next* decision. Never describe what's already visible — the human can see the diagram. Never post an empty explanation.

---

## Table 5: Message Parameter Content

The `message` parameter on `diagram_upsert` appears in the canvas chat panel as a Claude message. It's the primary conversational tool. These patterns maximize signal per message.

| Context | Good Message Pattern | Bad Message Pattern | Why |
|---|---|---|---|
| **First diagram in session** | "Starting with the component view. I've placed [N] services based on [rationale]. Is [boundary decision] right, or should [alternative]?" | "Here's the component diagram." | The human can see it's a component diagram. Ask about a decision they need to make. |
| **After structural change** | "Moved the auth check from Gateway to a dedicated AuthService. This means [consequence]. Does [downstream service] still call Gateway directly?" | "I updated the diagram based on your feedback." | Name what changed, state the consequence, ask about the ripple effect. |
| **After annotation fix** | "Changed [Element] from [old] to [new] as you annotated. This affects [related element] — I kept it as-is for now. Should it change too?" | "Fixed the annotation." | Connect the fix to its dependencies. |
| **Advancing to new diagram type** | "Here's the sequence for [use case]. I assumed [specific assumption] — is that right?" | "Here's the sequence diagram." | State your assumptions so the human can correct them before you build on them. |
| **When design has competing options** | "[Option A] keeps services independent but adds a message queue. [Option B] is simpler but couples [X] to [Y]. I drew Option A — switch to B?" | "I chose this approach." | Present the tradeoff. Let the human pick. |
