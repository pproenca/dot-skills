#!/usr/bin/env python3
"""Estimate the taxable real-estate capital gain (Categoria G, Art. 10/43/50 CIRS).

Purpose
    Compute the gain on a property disposal and the taxable base. For income year
    2025 the taxable portion is 50% of the gain for BOTH residents and
    non-residents (the pre-2023 100%-at-28% non-resident rule is gone). The taxable
    50% is then englobado at the progressive Art. 68 scale -- this script does NOT
    apply the progressive rate (use the official simulator for that).

Usage
    python3 property-capital-gain.py --sale 300000 --acquisition 165000 \
        --coefficient 1.33 --acq-costs 9000 --sale-costs 12000 \
        --improvements 25000 [--reinvested-fraction 0.0] [--year 2025]

Parameters
    --sale                 Realisation (sale) value, EUR.
    --acquisition          Original acquisition value, EUR.
    --coefficient          Inflation coefficient for the acquisition year (current
                           Portaria). Default: 1.0 (no correction).
    --acq-costs            Acquisition costs (IMT, stamp duty, notary), EUR.
    --sale-costs           Disposal costs (agent commission, energy cert), EUR.
    --improvements         Capital improvements in the last 12 years, EUR.
    --reinvested-fraction  Fraction (0..1) of an own-permanent-home gain exempt via
                           reinvestment (Art. 10 s.5). Default: 0.0.
    --year                 Income year. Default: 2025.

Expected output
    The gross gain, the reinvestment-exempt portion, and the taxable base (50% of
    the non-exempt gain). Estimate only -- the taxable base is taxed at the
    progressive scale; verify on Portal das Financas.
"""

import argparse

INCLUSION = 0.50  # taxable portion of a real-estate gain (residents and non-residents)


def main():
    parser = argparse.ArgumentParser(description="Real-estate capital gain estimate (Cat G)")
    parser.add_argument("--sale", type=float, required=True, help="Realisation value, EUR")
    parser.add_argument("--acquisition", type=float, required=True, help="Acquisition value, EUR")
    parser.add_argument("--coefficient", type=float, default=1.0, help="Inflation coefficient")
    parser.add_argument("--acq-costs", type=float, default=0.0, help="Acquisition costs, EUR")
    parser.add_argument("--sale-costs", type=float, default=0.0, help="Disposal costs, EUR")
    parser.add_argument("--improvements", type=float, default=0.0, help="Improvements (12y), EUR")
    parser.add_argument("--reinvested-fraction", type=float, default=0.0,
                        help="Exempt fraction via reinvestment, 0..1")
    parser.add_argument("--year", default="2025")
    args = parser.parse_args()

    fraction = min(max(args.reinvested_fraction, 0.0), 1.0)
    corrected_acquisition = args.acquisition * args.coefficient
    gain = (args.sale - args.sale_costs) - corrected_acquisition - args.acq_costs - args.improvements

    exempt = max(gain, 0.0) * fraction if gain > 0 else 0.0
    net_gain = gain - exempt
    taxable_base = net_gain * INCLUSION if net_gain > 0 else net_gain  # losses pass through fully

    print(f"Real-estate capital gain estimate -- income year {args.year}")
    print(f"  corrected acquisition (x{args.coefficient}): EUR {corrected_acquisition:,.2f}")
    print(f"  gross gain:               EUR {gain:,.2f}")
    if fraction > 0:
        print(f"  reinvestment-exempt:      EUR {exempt:,.2f} ({fraction*100:.0f}%)")
    print(f"  taxable base (50% incl.): EUR {taxable_base:,.2f}")
    if gain <= 0:
        print("  note: no gain -> loss may offset other Cat G results / carry forward")
    print("  NOTE: taxable base is taxed at the PROGRESSIVE Art. 68 scale (englobamento), "
          "not a flat rate. Estimate only; verify on Portal das Financas.")


if __name__ == "__main__":
    main()
