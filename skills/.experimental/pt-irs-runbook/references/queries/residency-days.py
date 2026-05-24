#!/usr/bin/env python3
"""Portuguese tax-residency day test (Art. 16 CIRS).

Purpose
    Determine whether the >183-day presence test is met. Art. 16 counts days of
    physical presence in Portugal in ANY rolling 12-month period that begins or
    ends in the income year -- not just the calendar year. This script counts the
    maximum presence in any 365-day window across the supplied intervals.

Usage
    python3 residency-days.py --interval 2025-01-10:2025-04-20 \
                              --interval 2025-06-01:2025-09-15 \
                              [--dwelling-on-dec31] [--year 2025]

Parameters
    --interval START:END   A presence interval, inclusive, ISO dates (YYYY-MM-DD).
                           Repeatable. Overlapping intervals are de-duplicated.
    --dwelling-on-dec31    Flag: taxpayer held a home in PT on 31 Dec suggesting
                           habitual residence (Art. 16(1)(b)). Default: not set.
    --year                 Income year for the report label. Default: 2025.

Expected output
    Total distinct days present, the maximum days in any rolling 12-month window,
    and a verdict: RESIDENT (day test), RESIDENT (habitual residence), or
    NON-RESIDENT (by these tests). Estimate only -- confirm status and any treaty
    tie-breaker on Portal das Financcas.
"""

import argparse
from datetime import date, timedelta


def parse_interval(text):
    start_str, end_str = text.split(":")
    start = date.fromisoformat(start_str)
    end = date.fromisoformat(end_str)
    if end < start:
        raise ValueError(f"interval end {end} precedes start {start}")
    return start, end


def present_days(intervals):
    """Return the sorted set of distinct dates covered by the intervals."""
    days = set()
    for start, end in intervals:
        current = start
        while current <= end:
            days.add(current)
            current += timedelta(days=1)
    return sorted(days)


def max_rolling_window(days, window_days=365):
    """Max count of present days within any window_days-length window."""
    if not days:
        return 0
    best = 0
    for i, anchor in enumerate(days):
        horizon = anchor + timedelta(days=window_days - 1)
        count = 0
        for d in days[i:]:
            if d > horizon:
                break
            count += 1
        best = max(best, count)
    return best


def main():
    parser = argparse.ArgumentParser(description="PT tax residency day test (Art. 16 CIRS)")
    parser.add_argument("--interval", action="append", default=[], metavar="START:END",
                        help="Presence interval START:END (YYYY-MM-DD), repeatable")
    parser.add_argument("--dwelling-on-dec31", action="store_true",
                        help="Held a home in PT on 31 Dec (habitual residence test)")
    parser.add_argument("--year", default="2025", help="Income year label")
    args = parser.parse_args()

    intervals = [parse_interval(t) for t in args.interval]
    days = present_days(intervals)
    total = len(days)
    rolling = max_rolling_window(days)

    print(f"PT tax-residency day test -- income year {args.year}")
    print(f"  distinct days present:            {total}")
    print(f"  max days in any 12-month window:  {rolling}")

    if rolling > 183:
        verdict = "RESIDENT (day test met: >183 days in a 12-month window)"
    elif args.dwelling_on_dec31:
        verdict = "RESIDENT (habitual residence: home held on 31 Dec)"
    else:
        verdict = "NON-RESIDENT (neither day test nor habitual-residence test met)"

    print(f"  verdict: {verdict}")
    print("  NOTE: estimate only. Dual residence -> apply the treaty tie-breaker; "
          "confirm on Portal das Financas.")


if __name__ == "__main__":
    main()
