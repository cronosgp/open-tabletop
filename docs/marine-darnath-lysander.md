# Darnath Lysander

Darnath Lysander is admitted from the local Wahapedia 11th-edition export for the shared Space Marines book: book `000000139`, datasheet `000002105`, export timestamp `2026-10-16T21:03:46+03:00`. The source profile is 160 points for one model, with a 50 mm base, the extracted characteristics and Fist of Dorn (5 attacks, WS 2+, Strength 10, AP -3, Damage 3, Devastating Wounds and Cleave 1). Imperial Fists and Adeptus Astartes are faction identity tags, not global chapter implementations.

The runtime implements the source-listed Deep Strike and Leader abilities; the two Leader targets are Terminator Squad and Terminator Assault Squad. Rampart can be activated once per battle per army in the start-of-phase decision window and gives Lysander a 2+ invulnerable save until that phase ends. Icon of Obstinacy subtracts 1 from hit rolls for attacks targeting his unit.

`tests/test_darnath_lysander.gd` checks the extracted profile, points, both Leader links, Warlord/Transhuman Strategist, phase-start timing and duration for Rampart, its once-per-battle limit, and Icon of Obstinacy for ranged and melee attacks. Network validation remains deferred to final integration. This entry is not a full army-legality certification.
