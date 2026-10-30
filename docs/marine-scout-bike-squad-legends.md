# Scout Bike Squad (Warhammer Legends) local datasheet audit

**Status (30 October 2026): source-bounded local profile ready for the project's supported preparation and match flow.** The exact source offers 3- and 6-model formations for 75 and 150 points. All three source copy-price tiers use the same prices. Unpriced unit sizes and illegal duplicate counts stay blocked.

## Source and game-mode legality

The profile is datasheet `000000137` in Wahapedia's 11th-edition Space Marines Legends book `000000356`. It uses the locally verified Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, retrieved at `2026-10-30T01:33:48.347556+00:00` and updated at `2026-10-28T23:48:19+03:00`. The parent manifest SHA-256 is `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`; the exact 28-identity Legends slice SHA-256 is `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c`. The [machine-readable audit](marine-scout-bike-squad-legends-audit.json) records the retrieval timestamp, all eight relevant CSV hashes, and the source-row counts. The exact Legends slice audit found zero scoped structural issues; the parent export still has 68 unrelated findings. Live-page validation is deferred to final integration under project policy.

The runtime labels this as a Warhammer Legends unit. The project permits it for home, store, club and campaign play; competitive events require organiser permission and any event-specific acceptance must be confirmed with the organiser. The local list gate permits two copies in Incursion and three in Strike Force. This is a datasheet and local construction check, not certification of an entire army list or an event pack.

## Represented datasheet

- A Scout Biker Sergeant and two to five Scout Bikers; every role has M12, T5, Sv4+, W3, Ld6+ and OC2, with no invulnerable save.
- Keywords: ADEPTUS ASTARTES, MOUNTED, IMPERIUM, EXPLOSIVES, SMOKE and RAVENWING. The runtime preserves the conditional Ravenwing context handling.
- Each model starts with Bolt Pistol, Combat Knife, Shotgun and Twin Boltgun.
- Any number of models, including the Sergeant, can replace the Twin Boltgun with a Grenade Launcher. The Sergeant can independently replace the Bolt Pistol with any of the eleven source-listed choices: Boltgun, Chainsword, Combi-weapon, Grav-pistol, Hand Flamer, Inferno Pistol, Plasma Pistol, Power Fist, Power Weapon, Storm Bolter or Thunder Hammer.
- All 20 source weapon profiles are represented, including both Grenade Launcher modes, all three Combi-weapon modes and both Plasma Pistol modes. The optional replacements add no points in the source.
- Abilities: Scouts 9", Combat Doctrines and Outflank. The shared ingress flow retains Outflank while the unit is in reserves; it permits setup within the opponent's deployment zone while preserving Strategic Reserves edge, coherency and enemy-distance checks.

The source specifies 75 × 25 mm oval bases. Current movement and placement geometry uses a labelled 75 mm bounding-circle proxy, which conservatively encloses the oval and can reject some physically legal positions. Exact oval clearance is not certified.

## Verification and limits

The dedicated suite checks source identity, retrieval timestamp and hashes; role characteristics, composition and all six priced entries; all 20 ranged/melee profiles; every weapon replacement; point and copy limits; model preparation; Scouts movement; and Outflank reserve ingress, edge clearance and enemy spacing. It also checks selected loadouts through Equipment and AttackPlan. The integrated report, exact command and SHA-256 are listed in the [verification history](verification/verification-results.md).

This closes the local source-bounded sheet scope for this Legends identity. It does not certify full army legality, exact oval geometry, live-page or event-pack equality, tournament acceptance, network play or human playtesting.
