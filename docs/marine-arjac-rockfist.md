# Arjac Rockfist

## Scope

This record covers Space Wolves App datasheet `000000317` in the standard 11th-edition army context. Datasheet facts come from the verified Wahapedia 11e Data Export snapshot `20261029T003124Z`, updated `2026-10-28T23:48:19+03:00`. The subject-scoped slice has zero structural findings; the parent export has 68 unrelated findings that remain open. Source hashes and snapshot provenance are in the [machine-readable audit](marine-arjac-rockfist-audit.json).

## Source-bounded profile

Arjac is a unique, one-model Epic Hero: 105 points on a 50 mm base; M6, T6, Sv2+, 4+ invulnerable save, W6, Ld6+, OC1. His fixed loadout is Foehammer. The ranged profile is 9", A1, BS2+, S10, AP-2, D3 with Assault and Anti-Monster/Vehicle 3+. The melee profile is A5, WS2+, S10, AP-2, D3 with Anti-Monster/Vehicle 3+ and Precision. The exported keywords are Adeptus Astartes, Character, Epic Hero, Imperium, Infantry, Space Wolves and Terminator.

The runtime connects all three source-listed Leader targets: Terminator Squad, Terminator Assault Squad and Wolf Guard Terminators. Champion of the Kingsguard gives Arjac's model Hit and Wound re-rolls of 1 against CHARACTER units; attached bodyguards do not receive those model-only re-rolls. Anvil of Endurance can retain any destroyed model in his attached unit on an unmodified 4+, with 1 wound, when the unit has not been selected to fight in that Fight phase. The retained model is removed when the unit fights or at phase end, whichever comes first.

## Verification and limits

The focused offline suite passed 3/3 processes. The connected offline regression passed 15/15 processes, covering current-catalog admission, all Arjac Leader targets, Wolf Guard and Terminator attachment paths, model-only attacks, Anvil retention, shared Fight-phase retention effects, Ancient Support links, capabilities, roster validation and Combat Doctrines. Exact commands and report hashes are in the [verification log](verification/verification-results.md#arjac-rockfist-source-bounded-local-scope--29-october-2026).

This closes Arjac's local datasheet scope. Network/page comparison and human playtesting are deferred to final integration; Chapter restrictions and full army legality remain uncertified.
