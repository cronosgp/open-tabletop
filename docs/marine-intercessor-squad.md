# Intercessor Squad — local e11 profile

The current Intercessor Squad profile is loaded from the project’s Wahapedia 11th-edition data export, book `000000139`, datasheet `000001157`, export revision `2026-10-16T21:03:46+03:00`. The local profile records M6, T5, Sv3+, W2, Ld6+, OC2, 32 mm bases, and the source keywords Infantry, Battleline, Explosives, Imperium, Tacticus and Adeptus Astartes.

Construction offers 5 models for 85 points or 10 for 170. A default model has a Bolt Pistol, Bolt Rifle and Knives and Fists. The Bolt Rifle exposes Focused Fire (24 inches, A1, BS3+, S6, AP-1, D2, Heavy, Rapid Fire 1) and Saturation (24 inches, A2, BS3+, S5, AP-1, D1, Assault, Rapid Fire 1).

During preparation, the Sergeant can separately replace Knives and Fists with a Chainsword, Power Fist, Power Weapon or Thunder Hammer, and replace the Bolt Rifle with a Chainsword, Hand Flamer, Plasma Pistol or Power Weapon. The Bolt Pistol remains equipped. Each five models permit one non-Sergeant Intercessor to add a Grenade Launcher; the launcher has Frag and Krak profiles. The exported optional weapon profiles are available to the combat resolver.

Bolter Discipline adds 1 to ranged Hit rolls in the unit’s own Shooting phase when the attacking unit or its selected target is in objective range. Tactical Mainstay allows the unit to start actions while Engaged or Battle-shocked and to shoot without that action itself making it ineligible; independent action requirements still apply.

`tests/test_intercessor_current.gd` covers the exported profile and points, construction admission, the Sergeant’s two independent weapon choices, the Grenade Launcher limit for five and ten models, and the ability assignments. The local CSV comparison is recorded in [the fixed-data report](wahapedia-fixed-data-review.md); it finds no numeric, keyword, composition, price or weapon-trait differences for this sheet. Local regression checks are recorded in [verification results](verification-results.md). No network validation has been run. This admission does not certify all Leader links, full roster legality or the full faction.
