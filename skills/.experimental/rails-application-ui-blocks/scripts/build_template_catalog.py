#!/usr/bin/env python3
"""Build a canonical catalog for premium Rails UI blocks."""

from __future__ import annotations

import argparse
import json
import re
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

STOPWORDS = {"and", "with", "without", "in", "on", "for", "to", "of", "by", "a", "an", "the"}

DOMAIN_RULES = {
    "application-shells": (
        "Use for top-level page layout decisions such as sidebar, stacked, or multi-column shells.",
        "Avoid for isolated components; prefer focused block families when only a subsection changes.",
    ),
    "data-display": (
        "Use for read-only metrics, calendars, and structured key-value content.",
        "Avoid when the primary goal is data entry or complex inline editing.",
    ),
    "elements": (
        "Use for micro-components like buttons, badges, avatars, and dropdown controls.",
        "Avoid as full-page scaffolding; pair with layout or shell blocks first.",
    ),
    "feedback": (
        "Use for alerts and empty states to communicate status, warnings, or no-data moments.",
        "Avoid as a substitute for core content regions or navigation.",
    ),
    "forms": (
        "Use for form controls, form layout patterns, and authentication-oriented form composition.",
        "Avoid when interaction is read-only; use data-display or lists instead.",
    ),
    "headings": (
        "Use for page, section, and card heading patterns with actions and metadata.",
        "Avoid when no heading structure is needed or content is purely decorative.",
    ),
    "layout": (
        "Use for structural wrappers (cards, containers, dividers, list containers, media objects).",
        "Avoid when semantic content blocks are needed first; pick lists/forms/data-display before wrappers.",
    ),
    "lists": (
        "Use for repeated dataset rendering such as tables, feeds, stacked lists, and grid lists.",
        "Avoid when one-off content is better represented as cards or form sections.",
    ),
    "navigation": (
        "Use for user movement and context controls (tabs, navbars, breadcrumbs, pagination).",
        "Avoid for primary content display or domain-specific business widgets.",
    ),
    "overlays": (
        "Use for modals, drawers, and transient notifications that sit above base content.",
        "Avoid for persistent layout sections; overlays should be temporary and dismissible.",
    ),
    "page-examples": (
        "Use as end-to-end reference blueprints when starting a new page or major refactor.",
        "Avoid direct copy-paste without adapting routes, semantics, and existing component boundaries.",
    ),
}

COLLECTION_ALIASES = {
    "sign-in-and-registration": ["auth forms", "authentication", "login forms", "registration forms"],
    "command-palettes": ["quick actions", "search command", "command menu"],
    "modal-dialogs": ["modal", "dialog"],
    "navbars": ["top navigation", "top nav"],
    "sidebar-navigation": ["side navigation", "side nav"],
    "vertical-navigation": ["vertical nav"],
    "empty-states": ["no data state", "zero state"],
    "stats": ["kpi", "metrics"],
    "description-lists": ["key value", "details list"],
    "stacked-lists": ["list rows", "vertical list"],
    "grid-lists": ["card grid", "tile list"],
}


def normalize_collection(raw_collection: str) -> str:
    normalized = re.sub(r"-\d+$", "", raw_collection)
    normalized = re.sub(r"\d+-(components|examples)$", "", normalized)
    normalized = re.sub(r"-+$", "", normalized)
    return normalized


def normalize_variant(filename_stem: str) -> str:
    variant = filename_stem.split("--", 1)[0]
    variant = re.sub(r"-\d+$", "", variant)
    return variant


def tokenize_slug(value: str) -> list[str]:
    words = [part for part in value.split("-") if part]
    filtered = [word for word in words if word not in STOPWORDS]
    return filtered or words


def dedupe(values: list[str]) -> list[str]:
    seen = set()
    result = []
    for value in values:
        if value and value not in seen:
            seen.add(value)
            result.append(value)
    return result


def source_priority(path: str) -> tuple[int, int, str]:
    raw_collection = Path(path).parts[3]
    normalized = normalize_collection(raw_collection)
    if raw_collection == normalized:
        score = 0
    elif raw_collection.endswith("-002"):
        score = 1
    elif re.search(r"\d+-(components|examples)$", raw_collection):
        score = 2
    else:
        score = 3
    return score, len(raw_collection), raw_collection


def build_aliases(domain: str, collection: str, variant: str) -> list[str]:
    variant_phrase = variant.replace("-", " ")
    collection_phrase = collection.replace("-", " ")
    domain_phrase = domain.replace("-", " ")
    aliases = [
        variant_phrase,
        f"{collection_phrase} {variant_phrase}",
        f"{domain_phrase} {collection_phrase} {variant_phrase}",
    ]
    aliases.extend(COLLECTION_ALIASES.get(collection, []))
    return dedupe(aliases)


def build_tags(domain: str, collection: str, variant: str) -> list[str]:
    tags = [domain, collection]
    tags.extend(tokenize_slug(collection))
    tags.extend(tokenize_slug(variant))
    return dedupe(tags)


def discover_repo_root(start: Path) -> Path:
    for parent in [start, *start.parents]:
        if (parent / "templates" / "application-ui").exists():
            return parent
    return start


def parse_arguments() -> argparse.Namespace:
    script_path = Path(__file__).resolve()
    guessed_root = discover_repo_root(script_path)
    default_output = script_path.parent.parent / "references" / "template-catalog.json"

    parser = argparse.ArgumentParser(description="Build canonical template catalog.")
    parser.add_argument(
        "--root",
        type=Path,
        default=guessed_root,
        help="Repository root that contains templates/application-ui.",
    )
    parser.add_argument(
        "--templates-dir",
        default="templates/application-ui",
        help="Template directory relative to --root.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=default_output,
        help="Output JSON path. Relative paths are resolved from --root.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_arguments()
    root = args.root.resolve()
    templates_dir = (root / args.templates_dir).resolve()
    output = args.output
    if not output.is_absolute():
        output = (root / output).resolve()

    if not templates_dir.exists():
        raise SystemExit(f"Templates directory not found: {templates_dir}")

    grouped_paths: dict[str, list[str]] = defaultdict(list)
    entries_meta: dict[str, dict[str, str]] = {}

    html_paths = sorted(path for path in templates_dir.rglob("*.html") if path.is_file())
    for html_path in html_paths:
        relative = html_path.relative_to(root).as_posix()
        parts = Path(relative).parts
        if len(parts) < 5:
            continue

        domain = parts[2]
        raw_collection = parts[3]
        collection = normalize_collection(raw_collection)
        variant = normalize_variant(Path(parts[-1]).stem)
        block_id = f"ui.{domain}.{collection}.{variant}"

        grouped_paths[block_id].append(relative)
        entries_meta[block_id] = {
            "domain": domain,
            "collection": collection,
            "variant": variant,
        }

    items = []
    for block_id in sorted(grouped_paths.keys()):
        metadata = entries_meta[block_id]
        all_paths = sorted(grouped_paths[block_id], key=source_priority)
        source_path = all_paths[0]
        alternate_paths = all_paths[1:]

        domain = metadata["domain"]
        collection = metadata["collection"]
        variant = metadata["variant"]
        use_when, avoid_when = DOMAIN_RULES.get(
            domain,
            (
                "Use when this block fits the current UI region and interaction goal.",
                "Avoid when introducing this block would conflict with current semantics or behavior.",
            ),
        )

        items.append(
            {
                "id": block_id,
                "domain": domain,
                "collection": collection,
                "variant": variant,
                "source_path": source_path,
                "alternate_source_paths": alternate_paths,
                "aliases": build_aliases(domain, collection, variant),
                "tags": build_tags(domain, collection, variant),
                "use_when": use_when,
                "avoid_when": avoid_when,
            }
        )

    payload = {
        "version": "1.0",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source_root": str(templates_dir.relative_to(root).as_posix()),
        "total_source_files": len(html_paths),
        "total_catalog_items": len(items),
        "items": items,
    }

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(payload, indent=2) + "\n")
    print(f"Catalog written to {output}")
    print(f"Source files: {payload['total_source_files']}")
    print(f"Catalog items: {payload['total_catalog_items']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
