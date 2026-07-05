#!/usr/bin/env python3
"""Search cached iOS SDK symbol graph documentation."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Any


DEFAULT_MODULES = ["SwiftUI", "SwiftUICore"]
DEFAULT_SDK = "iphonesimulator"
DEFAULT_TARGET = "arm64-apple-ios-simulator"
PLATFORM_DOMAIN = "iOS"


def script_dir() -> Path:
    return Path(__file__).resolve().parent


def run(args: list[str], *, capture: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        args,
        check=True,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
    )


def sdk_path(sdk: str) -> Path:
    result = run(["xcrun", "--sdk", sdk, "--show-sdk-path"], capture=True)
    return Path(result.stdout.strip())


def default_cache_root() -> Path:
    override = os.environ.get("CODEX_IOS26_DOCS_CACHE")
    if override:
        return Path(override).expanduser()
    return Path.home() / ".cache" / "codex" / "search-ios26-docs"


def module_cache(root: Path, sdk: Path, target: str, module: str) -> Path:
    return root / sdk.name / target / module


def ordered_unique(values: list[str]) -> list[str]:
    seen: set[str] = set()
    ordered: list[str] = []
    for value in values:
        if value in seen:
            continue
        seen.add(value)
        ordered.append(value)
    return ordered


def ensure_cache(root: Path, sdk_name: str, sdk: Path, target: str, modules: list[str], force: bool) -> None:
    missing = [m for m in modules if not any(module_cache(root, sdk, target, m).glob("*.symbols.json"))]
    if not missing and not force:
        return

    cmd = [
        sys.executable,
        str(script_dir() / "build_cache.py"),
        "--sdk",
        sdk_name,
        "--target",
        target,
        "--cache-dir",
        str(root),
    ]
    for module in modules:
        cmd.extend(["--module", module])
    if force:
        cmd.append("--force")
    run(cmd, capture=True)


def text_from_fragments(fragments: list[dict[str, Any]] | None) -> str:
    if not fragments:
        return ""
    return "".join(str(f.get("spelling", "")) for f in fragments)


def doc_text(symbol: dict[str, Any]) -> str:
    doc = symbol.get("docComment") or {}
    lines = doc.get("lines") or []
    return re.sub(r"\s+", " ", " ".join(str(line.get("text", "")) for line in lines)).strip()


def availability_text(items: list[dict[str, Any]] | None) -> str:
    if not items:
        return ""
    parts: list[str] = []
    for item in items:
        domain = item.get("domain")
        if not domain:
            continue
        if item.get("isUnconditionallyUnavailable"):
            parts.append(f"{domain} unavailable")
            continue
        introduced = item.get("introduced")
        deprecated = item.get("deprecated")
        renamed = item.get("renamed")
        value = domain
        if introduced:
            value += " " + version_text(introduced)
        if deprecated:
            value += " deprecated " + version_text(deprecated)
        if renamed:
            value += f" renamed {renamed}"
        parts.append(value)
    return ", ".join(parts)


def version_text(version: dict[str, Any]) -> str:
    pieces = [str(version.get("major", 0))]
    if "minor" in version:
        pieces.append(str(version.get("minor", 0)))
    if "patch" in version:
        pieces.append(str(version.get("patch", 0)))
    return ".".join(pieces)


def introduced_at_least(symbol: dict[str, Any], domain: str, major: int) -> bool:
    for item in symbol.get("availability") or []:
        if str(item.get("domain", "")).lower() != domain.lower():
            continue
        introduced = item.get("introduced")
        return bool(introduced and int(introduced.get("major", -1)) >= major)
    return False


def parse_introduced(value: str) -> tuple[str, int]:
    if ":" not in value:
        raise argparse.ArgumentTypeError("use DOMAIN:MAJOR, for example iOS:26")
    domain, major = value.split(":", 1)
    if not domain or not major.isdigit():
        raise argparse.ArgumentTypeError("use DOMAIN:MAJOR, for example iOS:26")
    return domain, int(major)


def framework_dirs(sdk: Path, module: str) -> list[Path]:
    dirs: list[Path] = []
    for base in (
        sdk / "System" / "Library" / "Frameworks",
        sdk / "System" / "Library" / "PrivateFrameworks",
    ):
        candidate = base / f"{module}.framework"
        if candidate.exists():
            dirs.append(candidate)
    return dirs


def framework_roots(sdk: Path) -> list[Path]:
    return [
        sdk / "System" / "Library" / "Frameworks",
        sdk / "System" / "Library" / "PrivateFrameworks",
    ]


def available_modules(sdk: Path) -> list[str]:
    modules: set[str] = set()
    for root in framework_roots(sdk):
        if not root.exists():
            continue
        for framework in root.glob("*.framework"):
            module = framework.name.removesuffix(".framework")
            if (framework / "Modules").exists() or (framework / "Headers").exists():
                modules.add(module)
    return sorted(modules, key=str.lower)


def matching_modules(sdk: Path, patterns: list[str]) -> list[str]:
    modules = available_modules(sdk)
    if not patterns:
        return modules
    lowered = [pattern.lower() for pattern in patterns]
    return [
        module
        for module in modules
        if any(pattern in module.lower() for pattern in lowered)
    ]


def source_sort_key(path: Path) -> tuple[int, int, str]:
    suffix_order = 3
    if path.suffix == ".swiftinterface":
        suffix_order = 0
    elif path.suffix == ".h":
        suffix_order = 1
    elif path.suffix == ".apinotes":
        suffix_order = 2
    name = path.name
    arch_order = 2
    if "arm64" in name:
        arch_order = 0
    elif "x86_64" in name:
        arch_order = 1
    return (suffix_order, arch_order, str(path))


def module_source_files(sdk: Path, module: str) -> list[Path]:
    files: list[Path] = []
    for framework in framework_dirs(sdk, module):
        swiftmodule = framework / "Modules" / f"{module}.swiftmodule"
        if swiftmodule.exists():
            files.extend(swiftmodule.glob("*.swiftinterface"))
        headers = framework / "Headers"
        if headers.exists():
            files.extend(headers.rglob("*.h"))
            files.extend(headers.rglob("*.apinotes"))
        files.extend(framework.glob("*.apinotes"))
    return sorted(files, key=source_sort_key)


def source_kind(path: Path) -> str:
    if path.suffix == ".swiftinterface":
        return "swiftinterface"
    if path.suffix == ".h":
        return "header"
    if path.suffix == ".apinotes":
        return "apinotes"
    return path.suffix.lstrip(".") or "source"


def source_modules(symbol: dict[str, Any]) -> list[str]:
    modules: list[str] = []
    for value in (symbol.get("_rootModule"), symbol.get("_graphModule")):
        if not value:
            continue
        for part in str(value).split("@"):
            if part and part not in modules:
                modules.append(part)
    return modules


def title_base(title: str) -> str:
    return title.split("(", 1)[0].split("<", 1)[0].strip()


def title_regex(title: str) -> re.Pattern[str] | None:
    base = title_base(title)
    if not base:
        return None
    if "(" not in title:
        return re.compile(rf"\b{re.escape(base)}\b")
    labels = re.findall(r"([A-Za-z_][A-Za-z0-9_]*)\s*:", title)
    pieces = [rf"\b{re.escape(base)}\s*\("]
    for label in labels:
        pieces.append(rf".*{re.escape(label)}\b[^,)]*:")
    return re.compile("".join(pieces))


def source_patterns(symbol: dict[str, Any]) -> list[re.Pattern[str]]:
    names = symbol.get("names") or {}
    title = str(names.get("title") or "")
    path_parts = [str(part) for part in symbol.get("pathComponents") or []]
    declaration = text_from_fragments(symbol.get("declarationFragments"))
    raw_patterns: list[str] = []
    if title:
        raw_patterns.append(title)
        if "(" not in title:
            raw_patterns.append(title_base(title))
    if path_parts:
        raw_patterns.append(path_parts[-1])
    if declaration:
        raw_patterns.append(declaration)

    patterns: list[re.Pattern[str]] = []
    if title:
        regex = title_regex(title)
        if regex:
            patterns.append(regex)
    for raw in ordered_unique([p for p in raw_patterns if p]):
        if len(raw) > 140:
            continue
        patterns.append(re.compile(re.escape(raw)))
    return patterns


def read_lines(path: Path) -> list[str]:
    try:
        return path.read_text(errors="replace").splitlines()
    except OSError:
        return []


def find_source_matches(
    symbol: dict[str, Any],
    sdk: Path,
    *,
    limit: int,
    context_lines: int,
) -> list[dict[str, Any]]:
    patterns = source_patterns(symbol)
    if not patterns:
        return []
    return find_matches_in_modules(patterns, sdk, source_modules(symbol), limit=limit, context_lines=context_lines)


def find_matches_in_modules(
    patterns: list[re.Pattern[str]],
    sdk: Path,
    modules: list[str],
    *,
    limit: int,
    context_lines: int,
) -> list[dict[str, Any]]:
    matches: list[dict[str, Any]] = []
    seen: set[tuple[str, int]] = set()
    for module in modules:
        for source in module_source_files(sdk, module):
            lines = read_lines(source)
            if not lines:
                continue
            for index, line in enumerate(lines, start=1):
                if not any(pattern.search(line) for pattern in patterns):
                    continue
                key = (str(source), index)
                if key in seen:
                    continue
                seen.add(key)
                start = max(1, index - context_lines)
                end = min(len(lines), index + context_lines)
                matches.append(
                    {
                        "module": module,
                        "sourceKind": source_kind(source),
                        "path": str(source),
                        "line": index,
                        "text": line.strip(),
                        "contextStart": start,
                        "context": [
                            {"line": line_number, "text": lines[line_number - 1].strip()}
                            for line_number in range(start, end + 1)
                        ],
                    }
                )
                if len(matches) >= limit:
                    return matches
    return matches


def query_source_patterns(query: list[str]) -> list[re.Pattern[str]]:
    phrase = " ".join(query).strip()
    patterns: list[re.Pattern[str]] = []
    if phrase:
        patterns.append(re.compile(re.escape(phrase), re.IGNORECASE))
    if len(query) > 1:
        ordered_terms = [re.escape(term) for term in query if term]
        if ordered_terms:
            patterns.append(re.compile(r".*".join(ordered_terms), re.IGNORECASE))
    for term in query:
        if len(term) >= 4:
            patterns.append(re.compile(re.escape(term), re.IGNORECASE))
    return patterns


def find_query_source_matches(
    query: list[str],
    sdk: Path,
    modules: list[str],
    *,
    limit: int,
    context_lines: int,
) -> list[dict[str, Any]]:
    return find_matches_in_modules(
        query_source_patterns(query),
        sdk,
        modules,
        limit=limit,
        context_lines=context_lines,
    )


def source_diagnostics(matches: list[dict[str, Any]], platform_domain: str) -> dict[str, Any]:
    context = "\n".join(
        line["text"]
        for match in matches
        for line in match.get("context", [])
    )
    lower_context = context.lower()
    platform_unavailable = bool(
        re.search(rf"@available\(\s*{re.escape(platform_domain)}\s*,\s*unavailable", context, re.IGNORECASE)
    )
    unavailable = "unavailable" in lower_context or "api_unavailable" in lower_context
    deprecated = "deprecated" in lower_context or "api_deprecated" in lower_context
    renamed = "renamed" in lower_context or "swift_private" in lower_context
    notes: list[str] = []
    if not matches:
        notes.append("No matching swiftinterface, header, or apinotes declaration found for the top source patterns.")
    if platform_unavailable:
        notes.append(f"Matched SDK source marks this symbol unavailable on {platform_domain}.")
    elif matches:
        notes.append("Matched SDK source declaration text.")
    return {
        "found": bool(matches),
        "sourceKinds": sorted({str(match.get("sourceKind")) for match in matches}),
        "platformUnavailable": platform_unavailable,
        "unavailable": unavailable,
        "deprecated": deprecated,
        "renamed": renamed,
        "notes": notes,
    }


def load_symbols(root: Path, sdk: Path, target: str, modules: list[str]) -> list[dict[str, Any]]:
    loaded: list[dict[str, Any]] = []
    for module in modules:
        for graph in sorted(module_cache(root, sdk, target, module).glob("*.symbols.json")):
            try:
                data = json.loads(graph.read_text())
            except json.JSONDecodeError:
                continue
            graph_module = graph.name.split(".symbols.json", 1)[0]
            for symbol in data.get("symbols") or []:
                symbol["_graphModule"] = graph_module
                symbol["_rootModule"] = module
                loaded.append(symbol)
    return loaded


def score_symbol(symbol: dict[str, Any], terms: list[str], phrase: str) -> int:
    title = str((symbol.get("names") or {}).get("title", ""))
    path = ".".join(str(p) for p in symbol.get("pathComponents") or [])
    declaration = text_from_fragments(symbol.get("declarationFragments"))
    doc = doc_text(symbol)
    haystacks = {
        "title": title.lower(),
        "path": path.lower(),
        "declaration": declaration.lower(),
        "doc": doc.lower(),
    }
    score = 0
    lower_phrase = phrase.lower()
    if haystacks["title"] == lower_phrase:
        score += 500
    if lower_phrase in haystacks["path"]:
        score += 180
    if lower_phrase in haystacks["title"]:
        score += 140
    if lower_phrase in haystacks["declaration"]:
        score += 70
    if lower_phrase in haystacks["doc"]:
        score += 35
    for term in terms:
        if term in haystacks["title"]:
            score += 60
        if term in haystacks["path"]:
            score += 45
        if term in haystacks["declaration"]:
            score += 25
        if term in haystacks["doc"]:
            score += 8
    return score


def compact_result(
    symbol: dict[str, Any],
    score: int,
    doc_chars: int,
    sdk: Path,
    *,
    verify_sources: bool,
    source_limit: int,
    source_context_lines: int,
) -> dict[str, Any]:
    names = symbol.get("names") or {}
    kind = symbol.get("kind") or {}
    doc = doc_text(symbol)
    if doc_chars >= 0 and len(doc) > doc_chars:
        doc = doc[:doc_chars].rstrip() + "..."
    item = {
        "score": score,
        "module": symbol.get("_graphModule"),
        "rootModule": symbol.get("_rootModule"),
        "kind": kind.get("displayName") or kind.get("identifier"),
        "title": names.get("title"),
        "path": ".".join(str(p) for p in symbol.get("pathComponents") or []),
        "declaration": text_from_fragments(symbol.get("declarationFragments")),
        "availability": availability_text(symbol.get("availability")),
        "doc": doc,
        "identifier": (symbol.get("identifier") or {}).get("precise"),
    }
    if verify_sources:
        matches = find_source_matches(symbol, sdk, limit=source_limit, context_lines=source_context_lines)
        item["sourceMatches"] = matches
        item["sourceDiagnostics"] = source_diagnostics(matches, PLATFORM_DOMAIN)
    return item


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("query", nargs="*", help="Search terms.")
    parser.add_argument("--sdk", default=DEFAULT_SDK, help=f"xcrun SDK name, default: {DEFAULT_SDK}")
    parser.add_argument("--target", default=DEFAULT_TARGET, help=f"Swift target triple, default: {DEFAULT_TARGET}")
    parser.add_argument("--module", action="append", dest="modules", help="Module cache to search. May be repeated.")
    parser.add_argument("--list-modules", action="store_true", help="List importable framework module names from the SDK and exit.")
    parser.add_argument("--find-module", action="append", dest="module_patterns", help="List SDK modules whose names contain this substring and exit. May be repeated.")
    parser.add_argument("--cache-dir", default=None, help="Override cache root.")
    parser.add_argument("--limit", type=int, default=20, help="Maximum results.")
    parser.add_argument("--kind", default=None, help="Case-insensitive kind substring, for example 'Method'.")
    parser.add_argument("--ios26", action="store_true", help="Only include symbols introduced in iOS 26 or later.")
    parser.add_argument("--introduced", type=parse_introduced, help="Only include symbols introduced in DOMAIN:MAJOR or later.")
    parser.add_argument(
        "--verify-interfaces",
        action="store_true",
        help="Attach matching swiftinterface/header/apinotes snippets and availability diagnostics to each shown result.",
    )
    parser.add_argument("--source-limit", type=int, default=4, help="Maximum source snippets per verified result.")
    parser.add_argument("--source-context-lines", type=int, default=4, help="Context lines around each source snippet.")
    parser.add_argument("--force", action="store_true", help="Rebuild selected module caches before searching.")
    parser.add_argument("--json", action="store_true", help="Emit JSON results.")
    parser.add_argument("--no-doc", action="store_true", help="Do not print doc snippets.")
    parser.add_argument("--no-dedupe", action="store_true", help="Keep repeated extension results with identical docs.")
    parser.add_argument("--doc-chars", type=int, default=500, help="Maximum doc snippet characters; use -1 for full docs.")
    args = parser.parse_args()
    if not args.query and not args.list_modules and not args.module_patterns:
        parser.error("query is required unless --list-modules or --find-module is used")
    return args


def main() -> int:
    args = parse_args()
    modules = args.modules or DEFAULT_MODULES
    sdk = sdk_path(args.sdk)
    root = Path(args.cache_dir).expanduser() if args.cache_dir else default_cache_root()

    if args.list_modules or args.module_patterns:
        module_matches = matching_modules(sdk, args.module_patterns or [])
        if args.json:
            print(
                json.dumps(
                    {
                        "sdk": str(sdk),
                        "target": args.target,
                        "moduleMatches": module_matches,
                    },
                    indent=2,
                )
            )
            return 0
        print(f"sdk: {sdk.name}")
        print(f"target: {args.target}")
        print(f"module matches: {len(module_matches)}")
        for module in module_matches:
            print(module)
        return 0

    ensure_cache(root, args.sdk, sdk, args.target, modules, args.force)

    introduced_filter = args.introduced
    if args.ios26:
        introduced_filter = ("iOS", 26)

    phrase = " ".join(args.query)
    terms = [term.lower() for term in args.query]
    results: list[tuple[int, dict[str, Any]]] = []
    for symbol in load_symbols(root, sdk, args.target, modules):
        if args.kind:
            kind = str((symbol.get("kind") or {}).get("displayName") or (symbol.get("kind") or {}).get("identifier") or "")
            if args.kind.lower() not in kind.lower():
                continue
        if introduced_filter and not introduced_at_least(symbol, introduced_filter[0], introduced_filter[1]):
            continue
        score = score_symbol(symbol, terms, phrase)
        if score > 0:
            results.append((score, symbol))

    results.sort(
        key=lambda item: (
            -item[0],
            str((item[1].get("names") or {}).get("title", "")),
            ".".join(str(p) for p in item[1].get("pathComponents") or []),
        )
    )
    selected: list[tuple[int, dict[str, Any]]] = []
    seen: set[tuple[str, str, str, str]] = set()
    for score, symbol in results:
        if not args.no_dedupe:
            key = (
                str((symbol.get("names") or {}).get("title", "")),
                text_from_fragments(symbol.get("declarationFragments")),
                availability_text(symbol.get("availability")),
                doc_text(symbol),
            )
            if key in seen:
                continue
            seen.add(key)
        selected.append((score, symbol))
        if len(selected) >= args.limit:
            break

    compact = [
        compact_result(
            symbol,
            score,
            -1 if args.no_doc else args.doc_chars,
            sdk,
            verify_sources=args.verify_interfaces,
            source_limit=args.source_limit,
            source_context_lines=args.source_context_lines,
        )
        for score, symbol in selected
    ]
    if args.no_doc:
        for item in compact:
            item["doc"] = ""

    source_only_matches: list[dict[str, Any]] = []
    source_only_diagnostics: dict[str, Any] | None = None
    if args.verify_interfaces:
        source_only_matches = find_query_source_matches(
            args.query,
            sdk,
            modules,
            limit=args.source_limit,
            context_lines=args.source_context_lines,
        )
        source_only_diagnostics = source_diagnostics(source_only_matches, PLATFORM_DOMAIN)

    if args.json:
        print(
            json.dumps(
                {
                    "sdk": str(sdk),
                    "target": args.target,
                    "modules": modules,
                    "results": compact,
                    "sourceOnlyMatches": source_only_matches,
                    "sourceOnlyDiagnostics": source_only_diagnostics,
                },
                indent=2,
            )
        )
        return 0

    print(f"sdk: {sdk.name}")
    print(f"target: {args.target}")
    print(f"modules: {', '.join(modules)}")
    print(f"matches: {len(results)} raw, {len(compact)} shown")
    if not compact:
        print("negative finding: no symbol graph matches for this query in the selected modules")
    if args.verify_interfaces and source_only_diagnostics:
        print(
            "source-only diagnostics: "
            f"found={source_only_diagnostics.get('found')} "
            f"kinds={','.join(source_only_diagnostics.get('sourceKinds') or []) or '-'} "
            f"platformUnavailable={source_only_diagnostics.get('platformUnavailable')} "
            f"deprecated={source_only_diagnostics.get('deprecated')}"
        )
        for note in source_only_diagnostics.get("notes") or []:
            print(f"source-only note: {note}")
        for match in source_only_matches:
            print(f"source-only: {match['sourceKind']} {match['path']}:{match['line']}: {match['text']}")
    for index, item in enumerate(compact, start=1):
        print()
        print(f"[{index}] {item['module']} {item['kind']} {item['title']}  score={item['score']}")
        print(f"path: {item['path']}")
        if item["availability"]:
            print(f"availability: {item['availability']}")
        if item["declaration"]:
            print(f"declaration: {item['declaration']}")
        if item["doc"]:
            print(f"doc: {item['doc']}")
        if args.verify_interfaces:
            diagnostics = item.get("sourceDiagnostics") or {}
            notes = diagnostics.get("notes") or []
            print(
                "source diagnostics: "
                f"found={diagnostics.get('found')} "
                f"kinds={','.join(diagnostics.get('sourceKinds') or []) or '-'} "
                f"platformUnavailable={diagnostics.get('platformUnavailable')} "
                f"deprecated={diagnostics.get('deprecated')}"
            )
            for note in notes:
                print(f"source note: {note}")
            for match in item.get("sourceMatches") or []:
                print(f"source: {match['sourceKind']} {match['path']}:{match['line']}: {match['text']}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except subprocess.CalledProcessError as exc:
        if exc.stdout:
            print(exc.stdout, file=sys.stderr)
        if exc.stderr:
            print(exc.stderr, file=sys.stderr)
        print(f"command failed: {' '.join(exc.cmd)}", file=sys.stderr)
        raise SystemExit(exc.returncode)
