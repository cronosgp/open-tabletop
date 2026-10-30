# Nephilim Jetfighter (Dark Angels App)

**Status:** source-bounded local scope passed on 28 October 2026. This closes the fixed profile, loadout, checked datasheet abilities, Aircraft interactions exercised by the paired suites, and local catalog admission. It does not certify complete Dark Angels or Space Marines army legality.

## Source identity

- [Wahapedia 11th-edition Nephilim Jetfighter](https://wahapedia.ru/wh40k11ed/factions/space-marines/Nephilim-Jetfighter), Dark Angels App datasheet `000000239`, book `000000023`.
- The current page was checked on 28 October 2026 against Dark Angels App revision 2.8.1 (October 2026). Fixed facts come from verified local Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, export revision `20260817b`; source row stamp `2026-10-21 16:06:23 GMT+3`.
- The machine-readable audit records the snapshot hashes and two-sheet scoped slice. Its subjects have no structural validation errors. The parent export has 68 errors outside this slice; those are not claimed as passed. Raw data remains outside Git.

## Profile and loadout

- One model, 200 points, up to three copies in this local catalog. T8, Sv3+, 5+ invulnerable save, W11, Ld6+ and OC0. The source's dash for Movement is preserved as the local Aircraft movement profile.
- The source base is a 120 × 92 mm oval. Runtime placement uses a labelled 60 mm bounding-circle proxy; exact oval-edge distance and placement are outside this scope.
- Fixed ranged weapons: **Avenger Mega Bolter** (36", A10, BS3+, S5, AP-1, D2, Sustained Hits 1); **Blacksword Missiles** (36", A2, BS3+, S8, AP-2, D3+2, Anti-Fly 2+); and **Twin Heavy Bolter** (36", A3, BS3+, S5, AP-1, D2, Twin-linked, Rapid Fire 2, Sustained Hits 1). It carries Armoured Hull (A3, WS4+, S6, AP0, D1).
- During preparation, Twin Heavy Bolter can be replaced by **Nephilim Lascannons** (48", A2, BS3+, S12, AP-3, D3+3). The public choice is reversible and owner-checked.
- The profile preserves ADEPTUS ASTARTES, DARK ANGELS, VEHICLE, AIRCRAFT, RAVENWING, FLY and IMPERIUM.

## Rules in the checked scope

- **Aircraft:** mandatory Strategic Reserves placement, own Movement-phase ingress from the battlefield edge, return to Strategic Reserves at the end of the opponent's turn, and the post-ingress reserve cutoff are exercised. Rapid Ingress excludes this Aircraft. Swept movement can pass through an Aircraft base but cannot finish overlapping it.
- **Charge and Fight:** Aircraft cannot declare a Charge; only FLY models may charge or make melee attacks against an Aircraft; an Aircraft can make melee attacks only against FLY targets. Its geometric engagement does not prevent a ground-only opponent from selecting Normal or Advance movement, and a non-FLY melee/contact selection skips the Aircraft.
- **Damaged 3:** -1 to Hit applies at 1–3 remaining wounds and ends above that threshold.
- **Lightning-fast Manoeuvres:** ranged attacks subtract 1 from the Wound roll at both lower and higher Strength; melee attacks are unchanged.
- **Deadly Demise D3** and **Combat Doctrines** are registered with their exported parameters. The paired suite does not trigger this Aircraft's destruction roll or exercise doctrine effects.

## Local verification and limits

The focused command `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_nephilim_jetfighter --only test_ravenwing_dark_talon --timeout 300` passed **4/4 processes** at `.tools/verification/20261028T130615559370Z/results.json` (SHA-256 `08537FEBF4151D7AB8F7E91638DEEB1DB8E7E05928375BB5F6819A2E761771B2`; `network: false`, no legacy starter staged, no cleanup diagnostics). The Nephilim suite checks the source IDs, profile/weapon data, points and copy cap, Lascannon setup/restoration, ability parameters, Aircraft reserve/movement/combat interactions, and construction admission.

This suite does not exercise Aircraft-specific Deadly Demise triggering, Combat Doctrine effects, Plunging Fire targeting, complete matches, exact oval-base geometry, network behavior, human playtesting or full army legality. Forge World, Legends, Boarding Actions and alternate modes are outside this sheet-specific result; network validation remains deferred to final integration. See the [machine-readable audit](marine-nephilim-jetfighter-audit.json).
