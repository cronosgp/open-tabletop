# Vanguard Veteran Squad (Warhammer Legends)

## Source and local status

This is the non-Jump Pack Vanguard Veteran Squad, Warhammer Legends datasheet `000001154` in current 11th-edition source book `000000356`. Its local profile was built from the verified Wahapedia Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`; the identity, source hashes and bounded implementation are recorded in the [machine-readable audit](marine-vanguard-veteran-squad-audit.json).

The profile is admitted for casual/home, store, club and campaign play under the project's Legends policy. A competitive event requires the organiser's permission. The live Wahapedia page check is deferred to final network integration; this local result does not claim that check passed.

## Implemented sheet scope

- Five Veterans including the Sergeant cost 120 points; ten cost 240. Only those priced sizes are selectable, and the runtime enforces the three-copy roster limit.
- Every model uses M6, T5, Sv3+, W2, Ld6+ and OC1, with the exact source-listed 32 mm base and ADEPTUS ASTARTES, IMPERIUM, INFANTRY and EXPLOSIVES keywords.
- Default equipment is a Bolt Pistol and Heirloom Weapon. Per model, the Bolt Pistol can be replaced by a Storm Shield, Grav-pistol, Hand Flamer, Inferno Pistol or Plasma Pistol. The public preparation flow applies and can reverse each choice. A Storm Shield replaces the pistol, gives only its bearer a 4+ invulnerable save, and exposes the source-listed shield weapon profile.
- Scouts 6 and Combat Doctrines are active. Vanguard Assault grants Lethal Hits to this unit's melee attacks after it makes a Charge move, through the end of the turn. It is implemented separately from the Jump Pack datasheet's Vanguard Assault bonus of +1 Attack.
- The weapon profiles preserve their source characteristics and weapon keywords. Unsupported equipment or model counts are rejected at admission.

## Evidence and limits

The Legends source slice has 28 identities and zero scoped structural findings. The dedicated VVS test and connected targeted regression passed locally. Those checks cover source provenance, roster admission and copy limit, model count/stats/base/keywords, all model-level choices, bearer-only shield protection, weapon characteristics, Scouts and the charge-triggered melee effect.

This is a source-bounded local datasheet scope, not certification of every army-wide restriction, every combined rules interaction, a complete match, physical model footprint beyond the source-listed base, human playtesting, or live page/network validation. See the [extended Marine inventory](data/space-marine-extended-inventory.md) for the separate Legends and standard-datasheet readiness counts.
