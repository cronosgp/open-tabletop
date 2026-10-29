# Deathwatch Terminator Squad — 11th-edition local sheet audit

## Source identity

This profile matches Deathwatch Terminator Squad (`000003873`) in the Deathwatch App book (`000000035`), edition 11. The [Wahapedia 11e datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Deathwatch-Terminator-Squad) was checked on 28 October 2026. Fixed datasheet facts come from the verified local Data Export snapshot `20261021T130623Z`, retrieved 21 October 2026, specification revision `20260817b`. The parent manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the scoped Deathwatch slice manifest SHA-256 is `bb1f51192a559283a25ee27ff5d87cb25252f1e99d806d7dca5949e86d51f093`. The machine-readable audit records export filenames and hashes. This covers the standard army datasheet; Boarding Actions and other game modes are separate inventories.

## Integrated local scope

The unit has one Deathwatch Terminator Sergeant and four to nine Deathwatch Terminators. The source-priced unit sizes are five models for 190 points and ten for 380; third-plus copies cost 230 and 420 respectively. All models use M5, T6, Sv2+, W3, Ld6+, OC1, a 4+ invulnerable save and 40 mm bases. The profile admits up to three copies.

The default Power Fist and Storm Bolter package can be replaced per model with Storm Bolter and Chainfist, Storm Bolter and Power Weapon, Thunder Hammer and Storm Shield, or Twin Lightning Claws. Up to three regular Deathwatch Terminators (not the Sergeant) can replace a Storm Bolter with an Assault Cannon, Heavy Flamer, Plasma Cannon or Cyclone Missile Launcher; the Cyclone retains the Storm Bolter. Storm Shields cost 5 points each and grant the bearer +1 Wound; Cyclone Missile Launchers cost 10 points. Preparation choices are reversible, enforce the three-special-weapon cap and remove incompatible weapon profiles when a package replaces them.

Deep Strike and Combat Doctrines are enabled from the current unit ability catalog. Deathwatch Terminatus Assault re-rolls this unit's Charge rolls; after its Charge move, every engaged enemy unit takes a Battle-shock test at -1 if it has neither IMPERIUM nor CHAOS. Each target controller retains any eligible Leadership re-roll choice. This is a separate rule from the similarly named Terminator Assault Squad Sustained Hits ability. Teleport Homer uses the shared local token and Rapid Ingress path. The Storm Shield effect adds a wound to the bearer while preserving the datasheet's baseline 4+ invulnerable save.

The source-listed Leader targets are Captain, Chaplain and Librarian in Terminator Armour; Ancient in Terminator Armour is the Support target. All four endpoints are present in the current catalog.

## Local checks and limits

The focused sheet suite covers source identity and export hashes, profile data and costs, weapon profiles, 5/10-model construction, reversible loadout packages, prices and weapon limits, Storm Shield wounds, the distinct Terminatus Assault charge and post-charge Battle-shock flow, defender-owned re-roll decisions, charge continuation and save/restore, and source-listed attachment endpoints. The cross-sheet regression also checks Deathwatch Veterans, both shared Terminator squads, both Deathwing Terminator profiles, the Leader relation map, capabilities, the current unit ability catalog, construction catalog admission and contact movement.

Targeted offline verification passed 13/13 processes at `.tools/verification/20261028T224509102718Z/results.json` (SHA-256 `4A307EB51BD16972CC753AB91C8F6EDDA513D77D25F3D34DBDEEDBA260C8E380`; `network: false`, legacy starter staged, no cleanup diagnostics). Network validation, human playtesting, full-match certification and full Space Marine army legality remain open. See the [machine-readable source/hash audit](marine-deathwatch-terminator-squad-audit.json).
