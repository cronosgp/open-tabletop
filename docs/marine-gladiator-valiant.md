# Gladiator Valiant — source-bounded local scope

This audit closes the shared-book 11th-edition local datasheet scope for the [Gladiator Valiant](https://wahapedia.ru/wh40k11ed/factions/space-marines/Gladiator-Valiant), book 000000139, datasheet 000001825. Datasheet facts were checked against the verified local Data Export snapshot. This does not certify whole-army legality or network behavior.

## Verified local source

Snapshot 20261021T130623Z, retrieved 2026-10-21T19:46:58Z; Last_update.csv records 2026-10-21 16:06:23 GMT+3; specification revision 20260817b; 23-file manifest SHA-256 169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf. The audit preserves the hashes of source tables used for identity, profile, composition, cost, options, weapons, keywords and abilities in [machine-readable evidence](marine-gladiator-valiant-audit.json). The runtime profile retains its earlier 2026-10-16T21:03:46+03:00 source stamp; this scope uses the separately identified 21 October snapshot without rewriting that provenance.

## Implemented and checked

- One model on a 100 mm circular base; M10, T10, Sv3+, W12, Ld6+, OC3 and no invulnerable save. The source keywords are ADEPTUS ASTARTES, FRAME, IMPERIUM, SMOKE and VEHICLE. The verified export has no equipment-option rows for this sheet.
- The fixed loadout and all five physical weapon instances are checked through Equipment and AttackPlan:
  - Defensive Array: 24 inches, A6, BS3+, S5, AP-1, D1, Rapid Fire 6.
  - Two Multi-meltas: each 18 inches, A2, BS3+, S10, AP-3, D3+2, Melta 3.
  - Twin Las-talon: 36 inches, A2, BS3+, S10, AP-3, D3+3, Twin-linked.
  - Armoured Hull: A3, WS4+, S6, AP0, D1.
- Priority Target Acquisition grants +1 Strength to every ranged weapon against an enemy within 12 inches. The test checks the measured 12-inch base-edge boundary, each weapon profile through AttackPlan, and the first point outside the range; melee remains unchanged.
- Damaged 4 applies -1 to hit at four remaining wounds and not at five. Deadly Demise D3 does not trigger on 5; on 6 it queues the exported mortal-wound packet for a nearby enemy unit. The shared Combat Doctrines faction rule remains covered separately from Valiant-specific abilities.
- Both players build from the consolidated current Marine catalog. Each of the first two copies costs 165 points, the third-plus tier costs 185, and construction admits three copies at 515 points while rejecting a fourth. The paired Leader/Support audit retains parity for all 153 source links; the Valiant has no listed Leader/Support link.

## Local validation

Focused offline verification passed **4/4 processes** (project import, Python checks, this datasheet suite and the 153-link relation suite) at .tools/verification/20261027T083654769142Z/results.json (network: false, legacy_starter_staged: false, no cleanup diagnostics):

~~~powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_gladiator_valiant --only test_space_marine_leader_links --timeout 300
~~~

## Limits

This closes only this source-bounded shared-book datasheet scope. It does not certify every army or Chapter interaction, Chapter-book variants, Forge World, Legends, Boarding Actions, network behavior, a complete match or human playtesting. Network validation remains deferred to final integration.
