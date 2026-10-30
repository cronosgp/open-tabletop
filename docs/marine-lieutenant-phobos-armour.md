# Lieutenant in Phobos Armour — 11th edition scope

Source: [Wahapedia 11th-edition Lieutenant in Phobos Armour](https://wahapedia.ru/wh40k11ed/factions/space-marines/Lieutenant-In-Phobos-Armour), Space Marines App book `000000139`, datasheet `000002530`. The live page was checked on 28 October 2026; the page identifies Space Marines App 2.8.1 / October 2026. Datasheet facts were reconciled against verified local Data Export snapshot `20261021T130623Z` (specification revision `20260817b`, retrieved 2026-10-21T19:46:58Z; export timestamp 2026-10-21 16:06:23 GMT+3). The machine audit records the snapshot and 12 relevant CSV hashes.

## Profile and equipment

The datasheet is one model for 40 points on a 40 mm base: M8, T4, Sv3+, W4, Ld6+, OC1, with INFANTRY, CHARACTER, EXPLOSIVES, IMPERIUM, PHOBOS, SMOKE and ADEPTUS ASTARTES keywords.

The default Special-issue Bolt Pistol (12", A1, BS2+, S5, AP-2, D2; Precision and CLOSE-QUARTERS) can be replaced by one Master-crafted bolt carbine (24", A2, BS2+, S4, AP0, D2). Monomolecular Combat Blades remain equipped in either loadout (A6, WS2+, S5, AP-1, D1; Sustained Hits 1 and Precision). Both gun choices and the blades pass Equipment and AttackPlan checks. The focused test also swaps the gun back while the Lieutenant is attached.

## Rules and Leader links

The local ability map includes Deep Strike, Infiltrators, Scouts 6, Support, Combat Doctrines, Demi-company Commander and Tactical Precision. Tactical Precision adds Lethal Hits against targets without MONSTER or VEHICLE. Demi-company Commander can copy the doctrine selected by a friendly Captain using Strategic Acumen, once per turn per unit, through the start of the owner's next Command phase.

The Lieutenant can lead four shared-book squads: Eliminators, Incursors, Infiltrators and Reivers. The source also lists Spectrus Kill Team (Deathwatch App) and Wolf Scouts (Space Wolves App); these remain outside the common-book catalog. The paired Leader/Support regression checks all 153 common-book relations.

The current catalog materializes the profile for both players. Construction accepts one through three copies and rejects a fourth. When the Lieutenant joins a bodyguard, Deep Strike and Scouts remain model-specific: the whole attached unit receives neither reserve eligibility from Deep Strike nor a Scout move unless every model qualifies. The focused suite also checks the mixed-unit Infiltrators/Stealth boundary, mandatory Support reserve timing and the public-command doctrine response.

## Verification

The offline targeted run passed **5/5 processes**: import, Python checks, the Lieutenant in Phobos suite, the paired Infiltrator suite and all 153 Leader/Support links. It used `network: false`, `legacy_starter_staged: false` and reported no cleanup diagnostics. The exact run is `.tools/verification/20261028T013420957771Z/results.json`; the machine audit is [marine-lieutenant-phobos-armour-audit.json](marine-lieutenant-phobos-armour-audit.json).

This closes only the Lieutenant in Phobos Armour shared-book local scope. It does not certify Deathwatch or Space Wolves lists, full Chapter or army legality, network behavior, complete-match behavior or human playtesting. Network validation remains deferred to final integration.
