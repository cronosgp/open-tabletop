# Bladeguard Veteran Squad

**Status:** complete source-bounded local scope for shared Space Marines datasheet `000000071` in book `000000139`. This does not certify full Chapter or army legality, Strike Force roster admission, network behavior or a complete match.

## Source and implemented profile

The authority is the [current Wahapedia 11th-edition datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Bladeguard-Veteran-Squad), checked against verified local Data Export snapshot `20261021T130623Z` (retrieved 21 October 2026; export update 21 October 2026, 16:06:23 GMT+3; Space Marines App 2.8.1 / October 2026; stable `Last_update` 19 October 2026, 03:47:32). The full snapshot manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the source-slice manifest SHA-256 is `f11ff7ddce6e12b33abf62426a245711611667a98e13969efa8679bef88c7989`. The [machine audit](marine-bladeguard-veteran-squad-audit.json) records relevant CSV hashes and report checksums.

The shared runtime profile matches the source's 3-model and 6-model formations, first/second-copy prices of 90/180 points and third-plus prices of 110/200. Each model uses a 40 mm circular movement proxy and M6, T5, Sv3+, W3, Ld6+, OC1, with a 4+ invulnerable save. Every model starts with a Heavy Bolt Pistol and Master-crafted Power Sword. The Sergeant alone can restore the Heavy Bolt Pistol or replace it with a Neo-volkite Pistol or Plasma Pistol. All five weapon profiles, including Plasma Pistol Standard and Supercharge, pass source-stat checks through `Equipment`; the shared Extra Attacks-aware helper checks the live loadouts through `AttackPlan`.

Setup exposes exactly those Sergeant pistol states. Public choice submission rejects wrong-owner and stale options unchanged, and ordinary Veterans cannot receive the replacement. Current Space Marines catalogs materialize both formations for both players. The consolidated catalog publishes both cost tiers. The checked roster mode is 1000-point Incursion: Core Rules §25.03 limit that mode to two units with the same datasheet, so admission accepts two copies and rejects a third. The source's third-plus prices remain recorded; Strike Force's three-copy admission is not implemented in the current checked roster mode.

The common-book relation map includes all eight source-linked Leaders and six Supports for this sheet and is covered by the 153-relation regression. Chapter-App links are outside this shared-book scope. The generic shared profile omits the conditional Deathwing keyword; Chapter-context behavior is not closed here.

## Bladeguard ability

The existing [combat audit](marine-bladeguard-audit.json) and `tests/test_bladeguard.gd` cover the once-per-turn choice when the unit is selected to fight or targeted in the Fight phase. The player can give the unit +1 to melee Hit rolls, give attacks targeting it -1 to Hit, or decline the trigger. The regression covers ordering, expiry, saved pending choices, split-target attacks, manual allocation, attached units, source destruction and continuation into Judiciar Precision. Core Rules §01.02.02 provides the phase duration when the datasheet does not state one.

## Local evidence and limits

The clean current-catalog scope run passed **4/4 processes** (`network: false`, `legacy_starter_staged: false`) at `.tools/verification/20261028T020001295731Z/results.json`. It ran `test_bladeguard_veteran_squad` and `test_space_marine_leader_links`, with import and Python checks.

The dedicated ability regression passed **3/3 processes** at `.tools/verification/20261028T015803358451Z/results.json` (`network: false`, `legacy_starter_staged: true`). Its checked-match opponent uses the optional historical Necron training fixture; this is separate from the clean current-catalog profile and relation evidence above. The test explicitly selects an 11th-edition Event Companion terrain layout.

The scope covers only the shared-book datasheet and its local Incursion admission. It does not certify conditional Chapter keywords or rules, external Leader/Support profiles, Strike Force admission, every faction/army restriction, network behavior, complete matches or human playtesting. Network validation remains deferred to final integration.
