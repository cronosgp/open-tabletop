# Wolf Guard Terminators local datasheet scope

## Source identity

Wolf Guard Terminators is Space Wolves App datasheet `000000318` in the current Wahapedia 11th-edition rules. The current faction page was checked on 29 October 2026 against verified local Data Export snapshot `20261029T003124Z`, exported at `2026-10-28T23:48:19+03:00` with specification revision `20260817b`. The parent manifest SHA-256 is `457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d`; the subject slice manifest SHA-256 is `BBF8E8372AA7A599BEEB7EC92CE309D2C8073C3A638F8A0CA4A52FB4AC78FB1E`. The slice contains the subject sheet and six identity-only Leader/Support endpoints; it is structurally valid with zero slice errors. The parent export has 68 unrelated validation errors; they remain documented and are not treated as passed. Raw exports remain under ignored `.tools/`. Exact source rows, hashes and reviewed facts are in the [machine-readable audit](marine-wolf-guard-terminators-audit.json).

Sources: [Wahapedia Wolf Guard Terminators (11th edition)](https://www.wahapedia.ru/wh40k11ed/factions/space-marines/Wolf-Guard-Terminators) and [Wahapedia Data Export](https://wahapedia.ru/wh40k11ed/the-rules/data-export/).

## Integrated local scope

The consolidated construction catalog offers 5 models for 180 points or 10 for 365; third and later copies cost 220/405 points. Each base is 40 mm. The profile records M6, T6, Sv2+, W3, Ld6+, OC1 and the datasheet's baseline 4+ invulnerable save.

All models start with a Storm Bolter and Master-crafted Power Weapon. During Army Preparation, a Pack Leader can replace both with a Relic Greataxe or Twin Lightning Claws. Any model can replace its Storm Bolter with a Storm Shield for 5 points and +1 Wound; the existing 4+ invulnerable save does not change. One regular Terminator per five models can instead replace both default weapons with an Assault Cannon and Power Fist. The limit and role restrictions are checked when choices are shown and submitted.

Deep Strike and Combat Doctrines use the shared rule paths. Rugged Resilience applies -1 to wound against attacks whose Strength is greater than the unit's Toughness, for ranged and melee attacks. The source-listed Leader relations include Captain, Chaplain and Librarian in Terminator Armour, Arjac Rockfist and Logan Grimnar. The first three profiles are available; Arjac and Logan remain dependency blockers until their sheets enter the local catalog. Ancient in Terminator Armour is a source-listed Support and is admitted.

## Verification and limits

The focused offline suite passed 3/3 processes: import, Python checks and `test_wolf_guard_terminators`. A connected regression passed 12/12 processes, including the Wolf Guard and Fenrisian suites, Blood Claws, Grey Hunters, catalog and capability metadata, Leader links, Deathwatch Terminators, roster validation and Combat Doctrines. Its report is `.tools/verification/20261029T024440783950Z/results.json` (SHA-256 `B302F9565738BA82CF5C926BB636A02C7E120E6FDD863FFE74AEDDF6DC0E3468`; `network: false`, legacy starter staged, no cleanup diagnostics). The checks cover source identity and profile values, default and alternate weapon profiles, both formation sizes/prices, owner-gated public preparation commands, the one-per-five special-weapon cap, Storm Shield pricing and bearer wounds, restoration, ability registration, Leader/Support endpoints and the Rugged Resilience strength boundary. The focused report is also recorded in the [machine-readable audit](marine-wolf-guard-terminators-audit.json).

This closes only the named source-bounded local sheet scope. Arjac and Logan, network validation, human playtesting, full Chapter/army legality and complete-match certification remain open.
