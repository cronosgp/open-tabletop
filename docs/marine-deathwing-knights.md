# Deathwing Knights (Dark Angels App)

**Status:** source-bounded local scope passed on 28 October 2026. This closes the fixed datasheet, supported equipment options, listed Leader/Support relations and declared local ability scope. It does not certify complete Dark Angels or Space Marines army legality.

## Source identity

- [Wahapedia 11th-edition Deathwing Knights](https://wahapedia.ru/wh40k11ed/factions/space-marines/Deathwing-Knights), datasheet `000000231`, Dark Angels App book `000000023`.
- The live page was checked on 28 October 2026 against Dark Angels App revision 2.8.1 (October 2026). Fixed data comes from verified local Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, export specification revision `20260817b`; source row stamp `2026-10-21 16:06:23 GMT+3`.
- The machine-readable audit records the snapshot hashes and scoped slice identity. Raw export files remain outside Git. The slice has no validation errors; the parent export has 68 errors outside this sheet and is not treated as globally valid.

## Profile and equipment

- Five models: one Knight Master and four Deathwing Knights. Cost: 255 points for the first two units and 275 points for the third and later unit. Construction supports up to three copies.
- M5, T6, Sv2+, W4, Ld6+, OC1, 4+ invulnerable save; 40 mm bases.
- The Knight Master starts with the Great Weapon of the Unforgiven (A5, WS2+, S6, AP-2, D2, Devastating Wounds, Sustained Hits 1). Each other model starts with a Mace of Absolution (A4, WS2+, S6, AP-2, D2, Anti-MONSTER/VEHICLE 4+).
- The Knight Master may replace their Great Weapon with a Relic Weapon (A6, WS2+, S7, AP-2, D2, Lethal Hits). Each regular Knight may replace its Mace with a Power Weapon (A5, WS2+, S6, AP-2, D2). The selectable choices are role-specific and reversible during army preparation.
- The source keywords are represented, including TERMINATOR and DEATHWING.

## Rules and attachments in the checked scope

- Deep Strike and Combat Doctrines use the shared local paths.
- **Inner Circle:** incoming attack Damage is reduced by 1, to a minimum of 1; mortal wounds are not reduced. Deathwing Knights cannot be targeted by Tactical Dreadnought Fortitude.
- **Teleport Homer:** once per battle, the unit can set one token at the start of battle. Rapid Ingress then costs 1 fewer CP and places the unit within 3 inches of that token, more than 8 inches from enemies; the token is removed after use or when an enemy move ends within 1 inch. The declaration remains available when the unit starts in Reserves.
- **Watcher in the Dark:** an optional item selected during preparation. Once per battle, after a mortal wound is allocated to an Adeptus Astartes model in the unit, the owner may summon it for Feel No Pain 4+ against mortal wounds until phase end.
- The four Leader targets—Belial, Captain in Terminator Armour, Chaplain in Terminator Armour and Librarian in Terminator Armour—are represented. Ancient in Terminator Armour is represented as a Support attachment.

## Verification and limits

Focused offline verification passed 7/7 processes at `.tools/verification/20261028T113916146828Z/results.json`. The dedicated suite checks source identity, composition, points, characteristics, weapon profiles, role-specific loadout choices, optional Watcher behavior and mortal-wound prevention, Inner Circle attack Damage and the Fortitude restriction, Teleport Homer declaration and zero-CP Rapid Ingress, and Leader/Support links. The Belial, Deathwing Terminator Squad, common Leader/Support and shared Terminator regressions passed in the same run. Capability and Azrael regressions passed 4/4 targeted processes at `.tools/verification/20261028T113948965947Z/results.json`.

The checks are local and offline. They do not certify complete Dark Angels or Space Marines roster legality, network behavior, complete-match behavior or human playtesting. Forge World, Legends, Boarding Actions and other alternate modes are outside this scope.
