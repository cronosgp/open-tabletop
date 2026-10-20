# Techmarine — local Wahapedia e11 implementation

Status (19 October 2026): admitted to the consolidated local Space Marines construction catalog after targeted local validation. The sole rules source is the pinned [Wahapedia Techmarine datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Techmarine) as captured in the local 11e export at revision `2026-10-16T21:03:46+03:00`, Space Marines book `000000139`, datasheet `000000140`.

The fixed profile is one Techmarine for 55 points, on a 40 mm base, with M6, T5, Sv2+, W4, Ld6+ and OC1. Its Forge Bolter, Grav-pistol and combined Omnissian Power Axe/Servo-arm use the extracted characteristics, ranges and weapon traits. The Grav-pistol's Anti-Vehicle 2+ is resolved as a Critical Wound against VEHICLE targets on an unmodified wound roll of 2 or more.

Implemented datasheet rules:

- **Techmarine:** gains Lone Operative while within 3 inches of a friendly Adeptus Astartes Vehicle unit. The check follows living battlefield models and uses edge-to-edge base distance. The faction identity comes from the local Space Marines definition ID or the explicit Adeptus Astartes keyword; enemy and non-Astartes Vehicles do not qualify.
- **Blessings of the Omnissiah:** at the start or end of this unit's own move in the Movement phase, select one friendly Adeptus Astartes Vehicle model within 3 inches. Roll D3 and restore up to that many wounds, capped at the model's maximum. Its attacks ignore hit and wound modifiers until the start of the Techmarine's next Movement phase. Start timing can be deferred to the end timing; resolve the choice before continuing the move. Reserve set-up is not treated as a move.

Targeted local validation passed in `.tools/verification/20261019T071657757403Z/results.json` (13/13 processes; 34 Python tests). `test_techmarine` covers extracted characteristics and weapons, Lone Operative's dynamic aura and 12-inch targeting boundary, start/end move integration, D3 healing and maximum-wound cap, pending-window restoration, next-Movement expiry, exclusion of reserve set-up, and hit/wound modifier handling in attack planning. `test_attack_sequence` verifies Anti-Vehicle 2+ against Vehicle and non-Vehicle targets. The combat fixture changes an admitted Captain model into a Techmarine to exercise its behavior; the catalog suite separately confirms the actual Techmarine profile is selectable.

The bounded local comparison `.tools/wahapedia-fixed-data-review-v42.json` covers 27 profiles and 103 weapon trait profiles. It reports zero numeric or identity differences and 26/27 fixed-data checks; Techmarine passes all of its bounded checks, while Ancient in Terminator Armour retains the documented chapter-keyword context issue. The extracted CSV snapshot still has structural warnings.

This is targeted local evidence, not full army or faction legality certification. Network validation remains deferred to final integration. The parent Wahapedia CSV snapshot retains its recorded structural warnings; this sheet-level work does not certify that snapshot as clean.
