# Storm Speeder Hailstrike — source-bounded local scope

This audit closes the common-book 11th-edition local datasheet scope for the [Storm Speeder Hailstrike](https://wahapedia.ru/wh40k11ed/factions/space-marines/Storm-Speeder-Hailstrike), book `000000139`, datasheet `000000124`. It does not certify whole-army legality or network behavior.

## Verified source

Datasheet facts use the verified Wahapedia 11e Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, export timestamp `2026-10-21 16:06:23 GMT+3`, specification revision `20260817b`. The 23-file manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The [machine-readable scope evidence](space-marines-profile-evidence.json) records the SHA-256 hashes of the manifest and relevant source tables. The live Space Marines page was observed on 27 October 2026 as App 2.8.1; the runtime profile keeps its original 16 October export stamp.

The snapshot has one model on a 90 mm base; M14, T9, Sv3+, W11, Ld6+, OC3 and no invulnerable save. It costs 110 points for each of the first two copies and 120 for the third-plus tier. The export has no equipment-option rows or Leader/Support rows for this sheet.

## Implemented and checked

- The fixed loadout is Fragstorm Grenade Launchers (18", A6, BS3+, S4, AP-1, D1, Blast 2, Ignores Cover), Ironhail Heavy Stubber Array (36", A6, BS3+, S4, AP-1, D1, Rapid Fire 6, Ignores Cover), Onslaught Gatling Cannon (24", A8, BS3+, S5, AP-1, D1, Ignores Cover, Devastating Wounds against eligible non-MONSTER/non-VEHICLE targets) and Armoured Impact (A3, WS4+, S6, AP0, D1). Every profile and trait is checked through `Equipment` and `AttackPlan`.
- **Hailstrike** lets the owner mark an enemy unit hit after the Speeder shoots. Until the phase ends, friendly ADEPTUS ASTARTES ranged attacks against that target gain Ignores Cover. The suite checks the hit-qualified public choice, correct owner, allied ranged effect, unrelated/enemy/melee exclusions and phase expiry.
- Construction uses the current catalog for both players, checks the two price tiers, and admits three copies while rejecting a fourth. Deep Strike, Damaged 4 and Deadly Demise D3 are present; the common vehicle abilities use their existing shared paths.

## Local validation and limits

The focused offline run passed **7/7 processes**: project import, Python checks, all four sheets in this vehicle batch and the 153-link Leader/Support regression. Result: `.tools/verification/20261027T104505989012Z/results.json` (SHA-256 `c9cca944e5b3db70e96e4c72f517da23bae1a119bbb9ac2a4e2f4d7e6eb12237`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics).

This closes only the common-book Hailstrike local scope. Chapter variants, full faction/army legality, network validation, complete-match certification and human playtesting remain outside this result.
