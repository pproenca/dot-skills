#!/usr/bin/env bash
# run-metric.sh <path> — invoke the configured candidate metric on <path> and print its number.
# Handy for checking your metric adapter before running the full harness.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/load-config.sh
source "$HERE/lib/load-config.sh"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <path>" >&2
  exit 1
fi

value="$(metric_of "$1")" || exit 1
echo "$value"
