# Ravenwing Darkshroud (Dark Angels App)

**Status:** source-bounded local scope passed on 28 October 2026. The check closes the declared profile, weapon, datasheet-ability and admission scope; it does not certify Dark Angels roster legality or full Space Marines army legality.

## Source identity

- [Wahapedia 11th-edition Ravenwing Darkshroud](https://wahapedia.ru/wh40k11ed/factions/space-marines/Ravenwing-Darkshroud), Dark Angels App datasheet `000000238`, book `000000023`.
- The current Space Marines page lists App revision 2.8.1 (October 2026). The fixed facts come from verified local Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, export revision `20260817b`; the datasheet row is stamped `2026-10-21 16:06:23 GMT+3`.
- Source filenames and hashes are recorded in [the machine-readable audit](marine-ravenwing-darkshroud-audit.json). Raw export data remains outside Git.

## Profile and loadout

- One model, 80 points, up to three copies in the local catalog. M14, T8, Sv3+, 5+ invulnerable save, W10, Ld6+, OC3.
- The source calls its base a **Large Flying Base** but gives no dimensions. Runtime geometry uses a clearly provisional 60 mm circular proxy; distances and placement that depend on the footprint are not exact-source geometry.
- Fixed weapons: Heavy Bolter (36", A3, BS3+, S5, AP-1, D2; Rapid Fire 2, Sustained Hits 1) and Armoured Hull (A3, WS4+, S6, AP0, D1). Before deployment, the Heavy Bolter can be replaced by an Assault Cannon (24", A6, BS3+, S6, AP-2, D1; Sustained Hits 1).
- The profile preserves the ADEPTUS ASTARTES and DARK ANGELS faction keywords and the IMPERIUM, RAVENWING, FRAME, VEHICLE, SPEEDER and FLY keywords.

## Rules in the checked scope

- Deep Strike, Deadly Demise D3 and Combat Doctrines are registered to their shared current runtime paths. This sheet-specific suite checks registration and the D3 parameter; shared ingress, destruction and doctrine effects are separate rule paths.
- Lone Operative uses the datasheet's 15-inch target-selection boundary; the shared ranged-target planner now reads the source-specific range.
- **Icon of Old Caliban:** a friendly Dark Angels unit within 6 inches has Stealth. The local aura respects player ownership, explicit Dark Angels keywords or the selected Dark Angels Chapter context for generic Adeptus Astartes profiles, and uses base-edge distance.
- The Army Workshop exposes the source Heavy Bolter replacement as an owner-checked, reversible setup choice. Both ranged profiles resolve legal targets through the attack planner.

## Local verification and limits

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_ravenwing_darkshroud --timeout 300` passed 3/3 processes at `.tools/verification/20261028T102401179066Z/results.json` (SHA-256 `0d4d71661e6877363c66824094b99693b681374687aadd15e2485ceffe266614`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The suite checks the pinned source IDs and fixed data, catalog price/copy cap, ability registration, Dark Angels aura eligibility and range, 12-to-15-inch Lone Operative targeting, both weapon targets through AttackPlan, and public setup selection/ownership/restoration.

This suite does not exercise Darkshroud-specific Deep Strike ingress, Deadly Demise trigger resolution, Combat Doctrine effects or Chapter detachment interactions. Whole-army roster restrictions, complete-match behavior, network validation, exact flying-base geometry and human playtesting are also outside this sheet-specific result. Network validation remains deferred to final integration.
