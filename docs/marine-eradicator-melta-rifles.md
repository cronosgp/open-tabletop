# Eradicator Squad with Melta Rifles — source-bounded local scope

This audit closes the shared-book 11th-edition local datasheet scope for [Eradicator Squad with Melta Rifles](https://wahapedia.ru/wh40k11ed/factions/space-marines/Eradicator-Squad-with-Melta-Rifles), book `000000139`, datasheet `000004249`. Facts were checked against the verified local Wahapedia Data Export snapshot. This result does not certify whole-army legality or network behavior.

## Verified local source

Snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`; `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; specification revision `20260817b`; 23-file manifest SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. Relevant file hashes are recorded in the [machine-readable audit](marine-eradicator-melta-rifles-audit.json). The runtime profile keeps its original `2026-10-16T21:03:46+03:00` export stamp; this scope records the separately verified 21 October snapshot without rewriting that provenance.

## Implemented and checked

- A unit has one Eradicator Sergeant and two to five Eradicators. Three models cost 100 points and six cost 200; the third and later copies cost 120 and 220. Models use 40 mm bases and M5, T6, Sv3+, W3, Ld6+, OC1, with no invulnerable save. The keywords are `ADEPTUS ASTARTES`, `EXPLOSIVES`, `GRAVIS`, `IMPERIUM` and `INFANTRY`.
- Each model starts with a Melta Rifle, Bolt Pistol and Ceramite Fists. The standard and Hunter profiles for the Melta Rifle, Bolt Pistol and Ceramite Fists are checked through `Equipment` and `AttackPlan`; the Hunter profile is restricted to MONSTER or VEHICLE targets.
- For each three Eradicator models, one Melta Rifle can be replaced by a Multi-melta. Both Multi-melta profiles are checked. Preparation lets the player select a specific model, shows its current weapon, offers a short equipment label, allows restoration, and enforces the per-three-model limit without mutation on invalid or wrong-owner commands.
- Melta 2 and Melta 3 add their value to Damage when the target is within half the weapon's range at target selection. The exact half-range boundary is tested; the runtime uses the existing geometry epsilon to avoid losing the inclusive boundary to floating-point rounding.
- Total Obliteration permits one re-roll of a ranged Damage roll for the unit. The test exercises the optional Damage re-roll through the public command route, preserves the Melta-adjusted damage expression, and checks that the ability does not grant the same re-roll to melee attacks.
- The five source Leader links are Captain in Gravis Armour, Iron Father Feirros, Marneus Calgar, Tor Garadon and Vulkan He’stan. Apothecary Biologis remains a separate Support link. Both player rosters materialize from the consolidated current Marine catalog. Checked 1,000-point Incursion admission accepts two copies and rejects a third.

## Local validation

Focused offline verification passed **6/6 processes** at `.tools/verification/20261028T044209175152Z/results.json` (project import, Python checks, this datasheet suite, the Heavy Bolter Eradicator suite, all 153 Leader/Support relations and conditional weapon traits; `network: false`, no legacy starter staged, no cleanup diagnostics):

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_eradicator_melta_rifles --only test_eradicator_heavy_bolters --only test_space_marine_leader_links --only test_marine_conditional_weapon_traits --timeout 300
```

The existing army-preparation panel was captured from a live Godot run at `.tools/eradicator-melta-rifles-after.png` (1600×1000). The staged fixture shows the Sergeant, current Melta Rifle and reversible Multi-melta choice; it is UI evidence, not a completed match or small-window coverage claim.

## Limits

This closes only the shared-book Eradicator Melta Rifle datasheet scope. Incursion is the checked roster mode and caps this non-BATTLELINE sheet at two copies; Strike Force admission is not implemented even though third-plus prices remain in the catalog. Chapter-book variants, Forge World, Legends, Boarding Actions, complete faction/army legality, network behavior, full-match certification and human playtesting remain outside this result. Network validation is deferred to final integration.
