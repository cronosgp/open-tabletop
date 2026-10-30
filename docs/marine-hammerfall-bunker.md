# Hammerfall Bunker (Warhammer Legends) local datasheet audit

**Status, 30 October 2026: source-bounded rules profile integrated; physical placement remains partial.** The current 11th-edition export contains the full Hammerfall Bunker datasheet. The local catalog admits one bunker at 175 points, its source weapons and replacement, and all listed datasheet abilities. The app's labelled 120 mm circular footprint is an interaction proxy only; it does not certify movement, overlap or clearance for the actual model.

## Source and game-mode use

This profile uses datasheet `000000097` in source book `000000356`, Space Marines (Warhammer Legends), 11th edition. Its source URL is [Hammerfall Bunker](https://wahapedia.ru/wh40k11ed/factions/space-marines/Hammerfall-Bunker). Facts are bound to the verified Wahapedia Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, retrieved `2026-10-30T01:33:48.347556+00:00`, export revision `2026-10-28T23:48:19+03:00`. Parent manifest SHA-256: `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`. The exact 28-identity Legends slice SHA-256 is `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5f565f2a1ba195928be3d3ceb5c`. The [machine-readable audit](marine-hammerfall-bunker-audit.json) records all eight subject-filtered CSV hashes. The subject slice has zero structural findings; the parent export retains 68 unrelated findings. Live-page/network validation remains deferred to final integration under project policy.

The app labels this as Warhammer Legends. The project permits it for home, store, club and campaign play; competitive events require the organiser's approval. Roster admission checks the source cost and the standard non-Battleline copy cap: up to two copies in Incursion and three in Strike Force. This is local profile admission, not certification of every army rule, mission pack or event list.

## Datasheet represented

- **Composition and cost:** one Hammerfall Bunker; 175 points in each of the source's first, second-plus and third-plus copy tiers.
- **Characteristics:** M 0", T12, Sv 2+, W14, Ld 6+, OC0, no invulnerable save. The source lists the base size as `Use model` without a measurable footprint.
- **Keywords:** ADEPTUS ASTARTES, VEHICLE, FORTIFICATION, FRAME, IMPERIUM.
- **Default loadout:** one Hammerfall Heavy Bolter Array and one Hammerfall Missile Launcher. The Heavy Bolter Array can be replaced by one Hammerfall Heavy Flamer Array during Army Preparation; the choice is reversible and does not change points.

| Weapon/profile | Range | Attacks | Skill | Strength | AP | Damage | Keywords |
|---|---:|---:|---:|---:|---:|---:|---|
| Hammerfall Heavy Bolter Array | 36" | 6 | BS 4+ | 5 | -1 | 2 | Sustained Hits 1, Rapid Fire 2, Twin-linked |
| Hammerfall Heavy Flamer Array | 12" | 6 | — | 5 | -1 | 1 | Twin-linked, Torrent, Blast 2 |
| Hammerfall Missile Launcher — Superfrag | 48" | 7 | BS 4+ | 5 | -1 | 1 | Blast 1 |
| Hammerfall Missile Launcher — Superkrak | 48" | 2 | BS 4+ | 10 | -2 | D3+3 | — |

## Rules connected to play

- **Combat Doctrines** attaches through the shared faction ability system.
- **Damaged 5** applies -1 to Hit at five wounds remaining or fewer through the shared attack modifier path.
- **Deadly Demise D6** is registered for the standard destruction flow.
- **Ceramite Cover** grants cover when the bunker prevents the attacking model from fully seeing its target. Local geometry checks use the disclosed circular proxy.
- **Defensive Array (once per phase, per unit)** permits this unit to use Fire Overwatch regardless of other uses that phase. The Hammerfall's use costs 0 CP, and the same bunker cannot use the ability more than once that phase.
- **Fortification:** an enemy engaged only with Fortification units can be selected as a ranged target. Those ranged attacks suffer -1 to Hit except Close-quarters attacks. A non-Battle-shocked enemy selected to Fall Back automatically passes its Hazard tests. These effects are connected to target selection, attack modifiers and the Fall Back resolution.

## Verification and remaining boundary

The dedicated `test_hammerfall_bunker` suite checks the source identity, snapshot and eight table hashes; all weapon profiles and options; source cost and copy caps; battle materialization; attack resolution; the Damaged threshold; cover and Fortification geometry; Fall Back Hazard auto-pass; and Fire Overwatch costs and per-phase use. The connected offline run and identity-export hash are recorded in the [machine-readable audit](marine-hammerfall-bunker-audit.json) and [verification history](verification/verification-results.md).

This sheet is locally playable with the project’s declared geometry proxy and Legends game-mode policy. Exact physical placement/clearance, live-page revalidation, event-specific approval and full army legality are not certified. Use the physical model's actual footprint when deciding tabletop placement.
