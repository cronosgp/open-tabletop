# Deathwatch Veterans — 11th-edition local sheet audit

## Source identity

This profile matches Deathwatch Veterans (`000002783`) in the Deathwatch App book (`000000035`), edition 11. The source page is [Deathwatch Veterans — Wahapedia 11e](https://wahapedia.ru/wh40k11ed/factions/space-marines/Deathwatch-Veterans), checked on 28 October 2026. Fixed datasheet facts use the verified local Data Export snapshot `20261021T130623Z`, retrieved 21 October 2026, specification revision `20260817b`. The parent manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the scoped Deathwatch slice manifest SHA-256 is `2ea710d11525e1ac9bb5d38cd5ea4b20f8dbcc36d615cd7c4f485cdf3f77ba58`. The machine-readable audit records filenames and hashes. This is the standard 11e army datasheet scope; Boarding Actions and other modes are separate inventories.

## Integrated local scope

The unit has one Watch Sergeant and four to nine Deathwatch Veterans, with source-priced sizes of five models for 115 points and ten models for 220. All models use M6, T5, Sv3+, W2, Ld6+, OC2 and 32 mm bases. The faction and datasheet keywords include ADEPTUS ASTARTES, DEATHWATCH, BATTLELINE, INFANTRY, IMPERIUM, EXPLOSIVES and KILL TEAM.

The local profile contains the Boltgun; all three Combi-weapon modes; Deathwatch Shotgun; both Infernus Heavy Bolter modes; Stalker-pattern Boltgun; Frag Cannon; Black Shield Blades; Heavy Thunder Hammer; Knives and Fists; Power Weapon; and Xenophase Blade. The source assigns D3+2 Damage without Melta to Damnatus, Melta 2 to Purgatus, and Torrent plus Blast 1 to Infernus. Preparation supports the Sergeant's independent ranged and melee choices. Veteran choices retain source replacement packages, revert cleanly, have zero additional points, and enforce the per-five-model caps, the single Black Shield Blades limit, and the combined Storm Shield limit.

Death to the Alien applies to ranged and melee attacks: Hit rolls of 1 are re-rolled against targets with IMPERIUM or CHAOS; otherwise all Hit rolls are re-rolled. Each model equipped with either listed Storm Shield package alone gains a 4+ invulnerable save. The source lists Captain, Chaplain, Librarian, Watch Captain Artemis and Watch Master as Leaders, and Ancient, Apothecary, Judiciar and Lieutenant as Support. Watch Master and Watch Captain Artemis are integrated and available as attachment choices; Artemis's source-bounded scope is recorded in her separate [datasheet audit](marine-watch-captain-artemis.md).

## Local checks and limits

The focused suite covers source identity/provenance, fixed characteristics, weapon profiles, catalog materialization for both players and both sizes, legal and reversible equipment, scaled caps, zero-cost choices, model-specific Storm Shields, Death to the Alien against both target-keyword branches in ranged and melee plans, and source-listed Leader/Support endpoints. A Captain attachment also checks that the attached model receives the unit ability. The common Leader/Support relation suite remains passing.

Targeted offline verification passed six processes, including import and Python checks plus `test_deathwatch_veterans`, `test_space_marine_leader_links`, `test_capabilities` and `test_implemented_catalog`, at `.tools/verification/20261028T221637986914Z/results.json`. Network validation, full Deathwatch/Chapter roster legality, full-match certification and human playtesting remain open. See the [machine-readable source/hash audit](marine-deathwatch-veterans-audit.json).
