# Chaplain on Bike — current e11 datasheet scope

Checked against the common Space Marines source book `000000139` for 11th edition, matched-play scope. The Wahapedia page was observed on 27 October 2026 (Space Marines App 2.8.1 / October 2026); the verified local Data Export snapshot is `20261021T130623Z`, revision `20260817b` (export update `2026-10-21 16:06:23 GMT+3`). The runtime source stamp remains `2026-10-16T21:03:46+03:00`; the newer snapshot is recorded separately. See the [source page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Chaplain-On-Bike) and [audit](marine-chaplain-on-bike-audit.json).

## Source profile and admitted scope

- One model, 75 points; M12, T6, Sv3+, 4+ invulnerable save, W5, Ld5+, OC2.
- Fixed weapons: Absolvor Bolt Pistol (18", A1, BS3+, S5, AP-2, D2, Close-quarters); Twin Bolt Rifle (24", A2, BS3+, S5, AP-1, D1, Twin-linked, Rapid Fire 2); Crozius Arcanum (A5, WS2+, S6, AP-1, D2, Cleave 1).
- Leader attachment is admitted for Outrider Squad. The source-listed Ravenwing Black Knights target now resolves to its separate Dark Angels Chapter profile; this Chaplain sheet's suite remains scoped to its common-book rules. See the [Ravenwing Black Knights sheet audit](marine-ravenwing-black-knights.md).
- Litany of Hate gives the attached unit's melee weapons Lance; a unit that Charged receives Lance's +1 to Wound through the existing attack planner.
- Catechism of Fire lets the unit choose one visible enemy when selected to shoot. Its ranged attacks against that target gain Devastating Wounds for the phase. It does not affect other targets or melee attacks.
- The 90 x 52 mm oval base is represented by the documented 90 mm bounding-circle proxy. Exact oval collision geometry is not certified.

The focused suite checks current-catalog admission, fixed equipment and weapon planning, the Outrider Leader link, target-choice ownership, Catechism visibility and source/target lifetime, ranged-versus-melee boundaries, and both Chaplain melee abilities.

## Validation limits

Focused offline verification passed **5/5 processes** (import, Python checks, both Chaplain scopes and the 153-link Leader/Support relation suite) at `.tools/verification/20261027T103130253761Z/results.json`. This closes only the common-book local datasheet scope. Network validation, full army/faction legality, human playtesting and complete-match certification remain open.
