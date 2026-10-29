# Storm Speeder Hammerstrike — source-bounded local scope

This audit closes the common-book 11th-edition local datasheet scope for the [Storm Speeder Hammerstrike](https://wahapedia.ru/wh40k11ed/factions/space-marines/Storm-Speeder-Hammerstrike), book `000000139`, datasheet `000000114`. It does not certify whole-army legality or network behavior.

## Verified source

Datasheet facts use the verified Wahapedia 11e Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, export timestamp `2026-10-21 16:06:23 GMT+3`, specification revision `20260817b`. The 23-file manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The [machine-readable scope evidence](space-marines-profile-evidence.json) records the SHA-256 hashes of the manifest and relevant source tables. The live Space Marines page was observed on 27 October 2026 as App 2.8.1; the runtime profile keeps its original 16 October export stamp.

The snapshot has one model on a 90 mm base; M14, T9, Sv3+, W11, Ld6+, OC3 and no invulnerable save. It costs 140 points for each of the first two copies and 150 for the third-plus tier. The export has no equipment-option rows or Leader/Support rows for this sheet.

## Implemented and checked

- The fixed loadout is Hammerstrike Missile Launcher (36", A2, BS3+, S10, AP-3, D3+2), Krakstorm Grenade Launchers (18", A2, BS3+, S9, AP-1, D2), Melta Destroyer (18", A3, BS3+, S10, AP-3, D3+2, Melta 3) and Armoured Impact (A3, WS4+, S6, AP0, D1). Each profile and its traits is checked through `Equipment` and `AttackPlan`.
- **Hammerstrike** gives ranged attacks Sustained Hits 1 against an enemy unit within a terrain area. The suite checks a target base overlapping the terrain boundary, the prepared attack result, the outside-area boundary and the melee exclusion.
- Construction uses the current catalog for both players, checks first/second and third-plus prices, and admits three copies while rejecting a fourth. Deep Strike, Damaged 4 and Deadly Demise D3 are present; the Damaged 4 threshold is checked. The shared Deadly Demise trigger and allocation sequence is covered by other vehicle-scope tests.

## Local validation and limits

The focused offline run passed **7/7 processes**: project import, Python checks, all four sheets in this vehicle batch and the 153-link Leader/Support regression. Result: `.tools/verification/20261027T104505989012Z/results.json` (SHA-256 `c9cca944e5b3db70e96e4c72f517da23bae1a119bbb9ac2a4e2f4d7e6eb12237`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics).

This closes only the common-book Hammerstrike local scope. Chapter variants, full faction/army legality, network validation, complete-match certification and human playtesting remain outside this result.
