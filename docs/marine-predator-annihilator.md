# Predator Annihilator (Warhammer Legends)

## Source and local status

Predator Annihilator is Legends datasheet `000002714`, from current 11th-edition source book `000000356`. This profile uses the verified local Wahapedia Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`; the source slice and selected table hashes are recorded in the [machine-readable audit](marine-predator-annihilator-audit.json).

The profile is admitted for casual/home, store, club and campaign play under the project's Legends policy. Competitive events require the organiser's permission. The local profile prices use the Wahapedia export; live-page and event-pack rechecks are deferred to final network integration. The source lists no base diameter, so the simulation labels its 60 mm circular footprint as a proxy.

## Implemented sheet scope

- One model, M10, T10, Sv3+, W11, Ld6+ and OC3; keywords ADEPTUS ASTARTES, VEHICLE, FRAME, IMPERIUM and SMOKE.
- First and second copies cost 135 points; third copies cost 145. The roster gate allows at most three in Strike Force and applies the standard two-copy Incursion limit.
- Default weapons are two Lascannons, one Predator Twin Lascannon and Armoured Tracks. The two sponson Lascannons can be replaced together by two Heavy Bolters. Hunter-killer Missile and Storm Bolter are separate optional additions, and both may be selected together. All choices are public preparation actions and can be reversed.
- Combat Doctrines, Deadly Demise D3 and Damaged 4 use the shared rules paths. Annihilator lets this unit re-roll Damage rolls for ranged attacks against MONSTER or VEHICLE units. The roll can be chosen in the normal damage-allocation window; it does not apply to melee or other targets.

## Evidence and limits

Focused offline verification covers the source identity and export provenance, characteristics, keywords, points and copy limits, every weapon profile and legal loadout, public loadout choices, and Annihilator's target and ranged-only gates through the attack and damage-reroll flows. Regression coverage also exercises the shared damage-reroll behavior used by Gladiator Lancer, Eradicator Squad and Vindicator.

This is a local source-bounded profile. It does not certify the unspecified physical footprint, live page equality, current tournament-pack prices, event organiser acceptance, every combined roster interaction, a full match or human playtesting. See the [extended Space Marine inventory](data/space-marine-extended-inventory.md) for current overall readiness.
