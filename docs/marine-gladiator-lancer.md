# Gladiator Lancer — source-bounded local scope

This audit closes the shared-book 11th-edition local datasheet scope for the [Gladiator Lancer](https://wahapedia.ru/wh40k11ed/factions/space-marines/Gladiator-Lancer), book `000000139`, datasheet `000002705`. Datasheet facts were checked against the verified local Data Export snapshot. This does not certify whole-army legality or network behavior.

## Verified local source

Snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`; `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; specification revision `20260817b`; 23-file manifest SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The audit preserves the hashes of the source tables used for composition, cost, options, weapons, keywords and abilities in [machine-readable evidence](marine-gladiator-lancer-audit.json). The runtime profile retains its earlier `2026-10-16T21:03:46+03:00` source stamp; this scope uses the separately identified 21 October snapshot without rewriting that provenance.

## Implemented and checked

- One model on a 100 mm circular base; M10, T10, Sv3+, W12, Ld6+, OC3 and no invulnerable save. The source keywords are `ADEPTUS ASTARTES`, `FRAME`, `IMPERIUM`, `SMOKE` and `VEHICLE`. The verified export has no equipment-option rows for this sheet.
- The fixed loadout and every weapon profile are routed through `Equipment` and `AttackPlan`:
  - Defensive Array: 24 inches, A6, BS3+, S5, AP-1, D1, Rapid Fire 6.
  - Laser Destroyer: 72 inches, A2, BS3+, S14, AP-3, D6+3, Heavy.
  - Armoured Hull: A3, WS4+, S6, AP0, D1.
- `Aquilon Optics` is checked against both `MONSTER` and `VEHICLE` targets. The public attack flow exposes the optional hit and wound re-rolls and Aquilon's damage re-roll; the opponent cannot submit the owner's choice. Ordinary targets and melee attacks do not receive the effect.
- `Damaged 4` applies -1 to hit at four remaining wounds and not at five. `Deadly Demise D3` does not trigger on 5; on 6 it queues the exported mortal-wound packet for a nearby enemy unit. The shared Combat Doctrines faction rule remains covered separately from Lancer-specific abilities.
- Both players build from the consolidated current Marine catalog. Each of the first two copies costs 160 points, the third-plus tier costs 180, and construction admits three copies at 500 points while rejecting a fourth. The paired Leader/Support audit retains parity for all 153 source links; the Lancer has no listed Leader/Support link.

## Local validation

Focused offline verification passed **4/4 processes** (project import, Python checks, this datasheet suite and the 153-link relation suite) at `.tools/verification/20261027T082732292887Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics):

~~~powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_gladiator_lancer --only test_space_marine_leader_links --timeout 300
~~~

## Limits

This closes only this source-bounded shared-book datasheet scope. It does not certify every army or Chapter interaction, Chapter-book variants, Forge World, Legends, Boarding Actions, network behavior, a complete match or human playtesting. Network validation remains deferred to final integration.
