# Chaplain With Jump Pack — current e11 datasheet scope

Checked against the common Space Marines source book `000000139` for 11th edition, matched-play scope. The Wahapedia page was observed on 27 October 2026 (Space Marines App 2.8.1 / October 2026); the verified local Data Export snapshot is `20261021T130623Z`, revision `20260817b` (export update `2026-10-21 16:06:23 GMT+3`). The runtime source stamp remains `2026-10-16T21:03:46+03:00`; the newer snapshot is recorded separately. See the [source page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Chaplain-With-Jump-Pack) and [audit](marine-chaplain-with-jump-pack-audit.json).

## Source profile and admitted scope

- One model, 75 points; M12, T5, Sv3+, 4+ invulnerable save, W4, Ld5+, OC1; 40 mm base.
- Fixed weapons: Absolvor Bolt Pistol (18", A1, BS3+, S5, AP-2, D2, Close-quarters) and Crozius Arcanum (A5, WS2+, S6, AP-1, D2, Cleave 1).
- Deep Strike is available to the model and works through the shared reserve flow.
- Leader attachment is admitted for Assault Intercessors With Jump Packs and Vanguard Veteran Squad With Jump Packs. The source also lists chapter-specific bodyguards outside the shared-book local catalog.
- Litany of Hate gives the attached unit's melee weapons Lance; a unit that Charged receives Lance's +1 to Wound through the existing attack planner.
- Exhortation of Rage allows optional re-rolls of melee Wound rolls while the attached unit is at or below half-strength. The check covers both successful and failed dice; ranged attacks are excluded.

The focused suite checks current-catalog admission, the fixed loadout and attack plans, both common-book Leader links, Deep Strike across the attached Jump Pack unit, the Crozius in a complete attack plan, and Exhortation above, at and below the half-strength threshold.

## Validation limits

Focused offline verification passed **5/5 processes** (import, Python checks, both Chaplain scopes and the 153-link Leader/Support relation suite) at `.tools/verification/20261027T103130253761Z/results.json`. This closes only the common-book local datasheet scope. Chapter-specific units, network validation, full army/faction legality, human playtesting and complete-match certification remain open.
