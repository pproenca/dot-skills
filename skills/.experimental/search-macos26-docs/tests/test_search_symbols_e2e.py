#!/usr/bin/env python3
"""End-to-end checks for the macOS SDK search helpers."""

from __future__ import annotations

import json
import subprocess
import sys
import unittest
from pathlib import Path


SKILL_DIR = Path(__file__).resolve().parents[1]
SEARCH = SKILL_DIR / "scripts" / "search_symbols.py"
PROBE = SKILL_DIR / "scripts" / "probe_symbol.py"


class MacOSSearchSymbolsE2ETests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        try:
            subprocess.run(
                ["xcrun", "--sdk", "macosx", "--show-sdk-path"],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            )
        except (FileNotFoundError, subprocess.CalledProcessError) as exc:
            raise unittest.SkipTest(f"macOS SDK is not available: {exc}") from exc

    def run_search(self, *args: str) -> dict:
        result = subprocess.run(
            [sys.executable, str(SEARCH), *args, "--json", "--no-doc"],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        return json.loads(result.stdout)

    def run_probe(self, *args: str) -> dict:
        result = subprocess.run(
            [sys.executable, str(PROBE), *args, "--json", "--no-doc"],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        return json.loads(result.stdout)

    def test_source_only_verification_finds_macos_unavailable_zoom_transition(self) -> None:
        data = self.run_search(
            "ZoomNavigationTransition",
            "--module",
            "SwiftUI",
            "--limit",
            "3",
            "--verify-interfaces",
        )

        diagnostics = data["sourceOnlyDiagnostics"]
        self.assertTrue(diagnostics["found"])
        self.assertTrue(diagnostics["platformUnavailable"])
        self.assertIn("swiftinterface", diagnostics["sourceKinds"])
        self.assertTrue(
            any("ZoomNavigationTransition" in match["text"] for match in data["sourceOnlyMatches"])
        )

    def test_find_module_discovers_sdk_framework_modules_by_substring(self) -> None:
        data = self.run_search("--find-module", "metal")

        self.assertIn("MetalKit", data["moduleMatches"])
        self.assertTrue(all("metal" in module.lower() for module in data["moduleMatches"]))

    def test_explicit_module_search_drills_into_discovered_framework(self) -> None:
        data = self.run_search("MTKView", "--module", "MetalKit", "--limit", "8")

        self.assertIn("MetalKit", data["modules"])
        self.assertTrue(
            any(result["title"] == "MTKView" and result.get("rootModule") == "MetalKit" for result in data["results"])
        )

    def test_probe_verifies_objective_c_backed_appkit_symbol_sources(self) -> None:
        data = self.run_probe("clockAndCalendar", "--module", "AppKit", "--limit", "5")

        self.assertTrue(data["results"])
        result = data["results"][0]
        self.assertEqual(result["title"], "NSDatePicker.Style.clockAndCalendar")
        diagnostics = result["sourceDiagnostics"]
        self.assertTrue(diagnostics["found"])
        self.assertTrue(set(diagnostics["sourceKinds"]) & {"header", "apinotes"})


if __name__ == "__main__":
    unittest.main()
