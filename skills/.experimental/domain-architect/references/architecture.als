// architecture.als — Formal model of the Harness layered domain architecture
// Verify with Alloy Analyzer 6: https://alloytools.org
//
// WHY A FORMAL MODEL?
//
// Build-time import scanning checks direct edges: "does file X import module Y?"
// A formal model checks REACHABILITY: "is there ANY path — direct or transitive —
// through which layer A can reach layer B?"
//
// This catches gaming: thin wrappers, re-exports through intermediate modules,
// type tunneling through generics. If a Config file re-exports Repo types,
// the import graph looks clean (Config → Repo is allowed). But the formal model
// detects that Service now TRANSITIVELY reaches Repo through Config — a violation
// of serviceRepoWall even though no individual import is forbidden.
//
// Two relations, not one:
//   compileDependsOn — what can be `import`ed (compile-time, SPM / harness-spec)
//   dataFlowsTo      — what data reaches at runtime (through Config closures)
//
// The key insight: Repo data reaches Service at runtime through Config closures
// wired by Runtime. But Service cannot import Repo. Both are true simultaneously.

// ─── Layers ────────────────────────────────────────────────────────────────────

abstract sig Layer {}

// Domain layers — each domain has a vertical slice through some or all of these
one sig Types, Config, Repo, Service, Runtime, UI extends Layer {}

// Cross-cutting layers — outside the domain boundary
one sig Utils, Providers extends Layer {}

// ─── Files ─────────────────────────────────────────────────────────────────────
// Model at the FILE level, not just layer level. This is what catches gaming.
// Layer-level rules say "Service cannot import Repo." File-level modeling says
// "no file classified as Service can reach any file classified as Repo through
// any chain of imports."

sig File {
  layer: one Layer,
  domain: lone Domain,        // lone = cross-cutting files have no domain
  imports: set File            // actual compile-time import edges (from codebase)
}

// ─── Domains ───────────────────────────────────────────────────────────────────

sig Domain {
  files: set File
}

// Domain files are consistent with the domain relation
fact domainConsistency {
  all d: Domain, f: d.files | f.domain = d
  all f: File | some f.domain implies f in f.domain.files
}

// ─── Allowed compile dependencies (the RULES) ─────────────────────────────────
// These define what's PERMITTED. The `imports` relation on File captures what
// ACTUALLY EXISTS. Violations = imports that exist but aren't permitted.

fun allowedLayerDeps[from: Layer]: set Layer {
  // Forward chain: Types → Config → Repo → Service → Runtime → UI
  (from = Types)     => none                                            else
  (from = Config)    => Types                                           else
  (from = Repo)      => Config + Types                                  else
  (from = Service)   => Config + Types + Providers                      else
  (from = Runtime)   => Layer                                           else
  (from = UI)        => Runtime + Service + Config + Types              else
  // Cross-cutting
  (from = Providers) => Utils + Types                                   else
  (from = Utils)     => none                                            else
  none
}

// THE WALL: Service can depend forward on Config and Types, but NOT on Repo.
// This is the defining constraint of the pattern. Service reaches Repo data
// at runtime through Config closures, never through compile-time imports.
// Note: `Service` is conspicuously absent from Repo's downstream — that's
// intentional and the entire reason Config exists as a separate layer.

// ─── Invariant 1: No illegal direct imports ────────────────────────────────────
// Every import edge must connect files whose layers are in the allowed set.

pred noIllegalDirectImports {
  all f: File, dep: f.imports |
    dep.layer in allowedLayerDeps[f.layer]
}

// ─── Invariant 2: No illegal TRANSITIVE reach (the anti-gaming invariant) ─────
// Even if every direct import is legal, a chain A → B → C might create a
// transitive path that violates the architecture. This is what catches:
//   - Re-export wrappers: Config file imports Repo, re-exports types
//   - Pass-through modules: Utils file wraps Repo, Service imports Utils
//   - Type tunneling: generics parameterized with Repo types through Config

// Transitive closure of imports
fun reaches[f: File]: set File {
  f.^imports  // reflexive-transitive closure: all files reachable through import chains
}

pred serviceRepoWall {
  // No Service file can reach ANY Repo file through any chain of imports
  no f: File | f.layer = Service and some (reaches[f] & layer.Repo)
}

pred configCannotReachImplementations {
  // No Config file can reach Service, Runtime, or UI files
  no f: File | f.layer = Config and some (reaches[f] & layer.(Service + Runtime + UI))
}

pred typesReachesNothing {
  // Types files have no imports at all
  all f: File | f.layer = Types implies no f.imports
}

pred runtimeIsLeaf {
  // No file outside Runtime imports a Runtime file
  no f: File | f.layer != Runtime and some (f.imports & layer.Runtime)
}

pred uiCannotReachRepo {
  // No UI file can reach any Repo file through any chain
  no f: File | f.layer = UI and some (reaches[f] & layer.Repo)
}

// ─── Invariant 3: Acyclicity ───────────────────────────────────────────────────
// The import graph must be a DAG. No file can reach itself through any chain.
// This catches mutual dependencies that individual import checks miss.

pred noCycles {
  no f: File | f in reaches[f]
}

// ─── Invariant 4: Domain completeness ──────────────────────────────────────────
// Every domain must own at least Config + Service + UI files.
// A domain without Config has no interface contract.
// A domain without Service has no business logic.
// A domain without UI has no user-facing capability.

pred domainsAreComplete {
  all d: Domain |
    some (d.files & layer.Config) and
    some (d.files & layer.Service) and
    some (d.files & layer.UI)
}

// ─── Invariant 5: Cross-domain isolation ───────────────────────────────────────
// Domains must not share Service or Repo files. Each domain's business logic
// and data access are private. Cross-domain communication goes through:
//   - Delegate actions (Service → parent → other Service)
//   - Shared Config interfaces (both domains depend on the same client)
//   - Shared Types (value types are universal vocabulary)

pred crossDomainIsolation {
  all disj d1, d2: Domain |
    no ((d1.files & layer.(Service + Repo)) & (d2.files & layer.(Service + Repo)))
}

// Cross-domain imports must go through Config or Types, never Service-to-Service
pred crossDomainImportsAreClean {
  all disj d1, d2: Domain |
    all f1: d1.files & layer.Service |
      all f2: f1.imports & d2.files |
        f2.layer in Config + Types
  // Service in domain A can import Config/Types from domain B, never Service/Repo
}

// ─── Invariant 6: Providers isolation ──────────────────────────────────────────
// Providers cannot access domain internals. They wrap external SDKs and expose
// typed interfaces. If a Provider imports Config or Service, it has domain
// knowledge — which means it's not cross-cutting, it's domain code misplaced.

pred providersCannotAccessDomains {
  all f: File | f.layer = Providers implies
    no (f.imports & layer.(Config + Service + Repo + Runtime + UI))
}

// ─── Data flow (runtime relation) ──────────────────────────────────────────────
// Distinct from compile dependencies. Data flows through Config closures
// that Runtime wires to Repo implementations.

pred dataFlows[from, to: Layer] {
  from -> to in allowedLayerDeps[from] -> to   // compile deps are a subset
  or
  (from = Repo and to = Service)               // Repo → Service through Config closures
  or
  (from = Providers and to = Service)          // Providers → Service through Config
}

// ─── Combined check ────────────────────────────────────────────────────────────
// All invariants must hold simultaneously

pred allInvariantsHold {
  noIllegalDirectImports
  serviceRepoWall
  configCannotReachImplementations
  typesReachesNothing
  runtimeIsLeaf
  uiCannotReachRepo
  noCycles
  domainsAreComplete
  crossDomainIsolation
  crossDomainImportsAreClean
  providersCannotAccessDomains
}

// ─── Assertions (for Alloy Analyzer to verify) ────────────────────────────────

// "If every direct import is legal, does serviceRepoWall automatically hold?"
// Answer: NO — this is why transitive checking matters.
// A Config file that imports Repo (allowed) and is imported by Service (allowed)
// creates a transitive path Service → Config → Repo that violates the wall.
assert directImportsImplyWall {
  noIllegalDirectImports implies serviceRepoWall
}
check directImportsImplyWall for 5 File, 2 Domain, 8 Layer

// Same for Config reaching implementations
assert directImportsImplyConfigIsolation {
  noIllegalDirectImports implies configCannotReachImplementations
}
check directImportsImplyConfigIsolation for 5 File, 2 Domain, 8 Layer

// "If all invariants hold, is the import graph acyclic?"
assert invariantsImplyAcyclicity {
  allInvariantsHold implies noCycles
}
check invariantsImplyAcyclicity for 5 File, 2 Domain, 8 Layer

// ─── Exploration commands ──────────────────────────────────────────────────────

// Find a valid 3-domain architecture
run validArchitecture {
  allInvariantsHold
  #Domain = 3
  #File >= 9  // at least 3 files per domain (Config, Service, UI)
} for 12 File, 3 Domain, 8 Layer

// Find a COUNTEREXAMPLE: legal direct imports but serviceRepoWall violated
// This demonstrates WHY transitive checking is needed.
// Expected: Alloy finds an instance where Config re-exports Repo to Service.
run gamingExample {
  noIllegalDirectImports
  not serviceRepoWall
} for 6 File, 1 Domain, 8 Layer

// Find a valid data flow where Repo data reaches Service
run repoDataReachesService {
  allInvariantsHold
  dataFlows[Repo, Service]
} for 6 File, 1 Domain, 8 Layer
