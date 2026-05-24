#!/usr/bin/env python3
"""Estimate Categoria F (rental) net income and autonomous IRS (Art. 72 CIRS).

Purpose
    Compute net rental income (gross minus deductible expenses, Art. 41) and the
    autonomous tax using the verified Art. 72 rate ladder for income year 2025.
    Rates are quoted verbatim from Art. 72 as of May 2026.

Usage
    python3 rental-tax-estimate.py --gross 13200 --expenses 1800 \
        --use residential --term-years 2 [--permanent-housing] \
        [--rent-cut-5pct] [--year 2025]

Parameters
    --gross            Gross annual rent received, EUR.
    --expenses         Documented deductible expenses (conservation, condominio,
                       IMI, insurance), EUR. NOT mortgage interest or furniture.
    --use              residential | non-residential. Default: residential.
    --term-years       Signed contract term in years. Default: 0.
    --permanent-housing  Flag: lease is for habitacao permanente (required for the
                       duration reductions). Default: not set.
    --rent-cut-5pct    Flag: new contract rent is >=5% below the previous one
                       (extra -5pp, Art. 72 s.24). Default: not set.
    --year             Income year. Default: 2025. (For 2026+, the OE2026 10%
                       moderate-rent rate may apply -- not modelled here.)

Expected output
    Net income, the selected autonomous rate with the reason, and the estimated
    tax. Estimate only -- englobamento (progressive scale) may be cheaper for low
    total income; verify on Portal das Financas.
"""

import argparse

BASE_RESIDENTIAL = 25.0
NON_RESIDENTIAL = 28.0


def autonomous_rate(use, term_years, permanent_housing, rent_cut_5pct):
    """Return (rate_percent, reason) per Art. 72 for income year 2025."""
    if use == "non-residential":
        return NON_RESIDENTIAL, "non-residential lease (Art. 72): no reductions"

    rate = BASE_RESIDENTIAL
    reason = "residential base 25% (term < 5 years or not permanent housing)"

    if permanent_housing:
        if 5 <= term_years < 10:
            rate, reason = 15.0, "permanent housing 5-<10 years: -10pp"
        elif 10 <= term_years < 20:
            rate, reason = 10.0, "permanent housing 10-<20 years: -15pp"
        elif term_years >= 20:
            rate, reason = 5.0, "permanent housing >=20 years: -20pp"

    if rent_cut_5pct and rate < BASE_RESIDENTIAL:
        reduced = rate - 5.0
        if reduced < 5.0:
            # The combined reductions reach below the deepest published tier (5%).
            # The statute's floor interaction here is an edge case (e.g. a >=20yr
            # contract plus a rent cut); clamp to 5% and tell the user to verify.
            rate = 5.0
            reason += "; new rent >=5% below previous: extra -5pp (clamped at 5% floor -- verify)"
        else:
            rate = reduced
            reason += "; new rent >=5% below previous: extra -5pp"

    return rate, reason


def main():
    parser = argparse.ArgumentParser(description="Categoria F autonomous tax estimate (Art. 72)")
    parser.add_argument("--gross", type=float, required=True, help="Gross annual rent, EUR")
    parser.add_argument("--expenses", type=float, default=0.0, help="Documented deductible expenses, EUR")
    parser.add_argument("--use", choices=["residential", "non-residential"], default="residential")
    parser.add_argument("--term-years", type=float, default=0.0, help="Signed contract term, years")
    parser.add_argument("--permanent-housing", action="store_true")
    parser.add_argument("--rent-cut-5pct", action="store_true")
    parser.add_argument("--year", default="2025")
    args = parser.parse_args()

    net = max(args.gross - args.expenses, 0.0)
    rate, reason = autonomous_rate(args.use, args.term_years,
                                   args.permanent_housing, args.rent_cut_5pct)
    tax = net * rate / 100.0

    print(f"Categoria F estimate -- income year {args.year}")
    print(f"  gross rent:        EUR {args.gross:,.2f}")
    print(f"  deductible exp.:   EUR {args.expenses:,.2f}")
    print(f"  net income:        EUR {net:,.2f}")
    print(f"  autonomous rate:   {rate:.0f}%  ({reason})")
    print(f"  estimated tax:     EUR {tax:,.2f}")
    if args.gross - args.expenses < 0:
        print("  note: expenses exceed rent -> reportable loss, carry forward 6 years")
    print("  NOTE: estimate only. Compare with englobamento (Art. 68) for low "
          "income; verify on Portal das Financas.")


if __name__ == "__main__":
    main()
