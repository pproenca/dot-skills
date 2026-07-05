#!/usr/bin/env python3
"""End-to-end checks for the iOS SDK search helpers."""

from __future__ import annotations

import json
import subprocess
import sys
import unittest
from pathlib import Path


SKILL_DIR = Path(__file__).resolve().parents[1]
SEARCH = SKILL_DIR / "scripts" / "search_symbols.py"
PROBE = SKILL_DIR / "scripts" / "probe_symbol.py"


class IOSSearchSymbolsE2ETests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        try:
            subprocess.run(
                ["xcrun", "--sdk", "iphonesimulator", "--show-sdk-path"],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            )
        except (FileNotFoundError, subprocess.CalledProcessError) as exc:
            raise unittest.SkipTest(f"iPhone Simulator SDK is not available: {exc}") from exc

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

    def test_verified_search_reports_zoom_navigation_transition_available_on_ios(self) -> None:
        data = self.run_search(
            "ZoomNavigationTransition",
            "--module",
            "SwiftUI",
            "--limit",
            "3",
            "--verify-interfaces",
        )

        result = next(result for result in data["results"] if result["title"] == "ZoomNavigationTransition")
        self.assertIn("iOS 18.0", result["availability"])
        diagnostics = result["sourceDiagnostics"]
        self.assertTrue(diagnostics["found"])
        self.assertFalse(diagnostics["platformUnavailable"])
        self.assertIn("swiftinterface", diagnostics["sourceKinds"])

    def test_find_module_discovers_sdk_framework_modules_by_substring(self) -> None:
        data = self.run_search("--find-module", "vision")

        self.assertIn("Vision", data["moduleMatches"])
        self.assertTrue(all("vision" in module.lower() for module in data["moduleMatches"]))

    def test_explicit_module_search_drills_into_discovered_framework(self) -> None:
        data = self.run_search("VNRecognizeTextRequest", "--module", "Vision", "--limit", "8")

        self.assertIn("Vision", data["modules"])
        self.assertTrue(
            any(
                result["title"] == "VNRecognizeTextRequest" and result.get("rootModule") == "Vision"
                for result in data["results"]
            )
        )

    def test_probe_emits_verified_source_matches_for_ios_symbol(self) -> None:
        data = self.run_probe("GlassEffectTransition", "--module", "SwiftUICore", "--limit", "3")

        result = next(result for result in data["results"] if result["title"] == "GlassEffectTransition")
        diagnostics = result["sourceDiagnostics"]
        self.assertTrue(diagnostics["found"])
        self.assertFalse(diagnostics["platformUnavailable"])
        self.assertIn("swiftinterface", diagnostics["sourceKinds"])


if __name__ == "__main__":
    unittest.main()
