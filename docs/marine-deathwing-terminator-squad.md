# Deathwing Terminator Squad (Dark Angels App)

**Status:** source-bounded local scope passed on 28 October 2026. The checks cover both squad sizes, listed weapons and options, construction admission, the source Leader/Support links and the declared Deathwing and Watcher rules paths. They do not certify complete Dark Angels or Space Marines army legality.

## Source identity

- [Wahapedia 11th-edition Deathwing Terminator Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Deathwing-Terminator-Squad), datasheet `000000230`, Dark Angels App book `000000023`.
- The current page was checked on 28 October 2026 against Dark Angels App revision 2.8.1 (October 2026). Fixed facts come from verified local Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, export specification revision `20260817b`; source row stamp `2026-10-21 16:06:23 GMT+3`.
- The machine-readable audit records the snapshot file hashes and scoped slice identity. The subject slice has no structural validation errors; the parent export has 68 validation errors outside this slice and is not treated as globally valid. Raw export files remain outside Git.

## Profile and equipment

- The unit contains five or ten Deathwing Terminators. It costs 190/380 points for the first two units and 230/420 points for the third and later unit. The local construction catalog supports up to three copies.
- M5, T6, Sv2+, W3, Ld6+, OC1, 4+ invulnerable save; 40 mm bases. Every model starts with a Power Fist and Storm Bolter.
- The Sergeant may replace its Power Fist with a Chainfist or Power Weapon. Any number of regular models may replace their Power Fists with Chainfists.
- For every five models, one regular model may replace its Storm Bolter with an Assault Cannon, Heavy Flamer or Plasma Cannon. The Plasma Cannon has standard and supercharge profiles; the latter has Hazardous.
- For every five models, one regular model may instead add a Cyclone Missile Launcher and keep its Storm Bolter. Frag and Krak profiles are supported, and each launcher adds 10 points.
- The source keywords are represented, including TERMINATOR and DEATHWING.

## Rules and attachments in the checked scope

- Deep Strike and Combat Doctrines use the shared local paths.
- **Deathwing:** attacks made by the unit ignore modifiers to its BS/WS characteristics and Hit rolls. AttackPlan applies this to the squad's own attacks, including attacks from attached models. It preserves separate Wound modifiers, including Belial's +1 to Wound against enemy CHARACTER units.
- **Watcher in the Dark:** one optional item can be selected during army preparation. Once per battle, after a mortal wound is allocated to an ADEPTUS ASTARTES model in the unit, the player can summon the Watcher for Feel No Pain 4+ against mortal wounds until the phase ends. The local response is available at supported mortal-wound decision points.
- The four source-listed Leader targets—Belial, Captain in Terminator Armour, Chaplain in Terminator Armour and Librarian in Terminator Armour—are represented. Ancient in Terminator Armour is represented as a Support attachment.

## Verification and limits

Focused offline verification passed 7/7 processes at `.tools/verification/20261028T113916146828Z/results.json` without network access, legacy starter staging or cleanup diagnostics. It covers the Deathwing profile, shared Terminator loadout behavior, Deathwing Knights, Belial, and the shared Leader/Support relation map. The dedicated suite checks source identity, prices, both unit sizes in the current catalog, weapon profiles, special-weapon limits and the Cyclone surcharge; it also exercises Watcher selection and response, public Leader/Support attachment, ignored Hit/BS/WS modifiers, and Belial's separate Wound bonus. Capability and Azrael regressions passed 4/4 targeted processes at `.tools/verification/20261028T113948965947Z/results.json`. The exact commands and report hashes are recorded in the [machine-readable audit](marine-deathwing-terminator-squad-audit.json).

The checks are local and offline. They do not certify complete Dark Angels or Space Marines roster legality, network behavior, complete-match behavior or human playtesting. Forge World, Legends, Boarding Actions and other alternate modes are outside this scope.
