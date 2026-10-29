# Apothecary datasheet audit

## Source and scope

This audit covers the 11th-edition shared Space Marines datasheet in source book `000000139`, datasheet `000002773`, from the [Wahapedia Apothecary page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Apothecary). The profile's runtime data stamp remains `2026-10-16T21:03:46+03:00`; this audit checks it against the separately identified local export snapshot `20261021T130623Z`, retrieved at `2026-10-21T19:46:58Z`, updated `2026-10-21 16:06:23 GMT+3`, specification revision `20260817b`. The 23-file manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`.

The local export has no equipment-option rows. Its fixed profile is one model, 45 points, 40 mm base, M6/T5/Sv3+/W4/Ld6+/OC1, with INFANTRY, CHARACTER, IMPERIUM, TACTICUS and ADEPTUS ASTARTES. Absolvor Bolt Pistol, Reductor Pistol and Servo-armature are the complete fixed loadout.

## Implemented scope checked

- **Profile and admission:** exact source identity, cost, composition, base, characteristics, keywords, fixed weapons and absent equipment options; both players use the consolidated current Space Marines catalog.
- **Weapons:** each weapon's profile is compared with the local export. Equipment selection checks all three; the default melee plan contains both the ordinary Servo-armature and the Reductor Pistol's Extra Attacks, while the Absolvor Bolt Pistol reaches AttackPlan with its source characteristics.
- **Narthecium:** the owner's Command phase opens one D3+1 unit-healing budget per turn. Core Rules §02.02.04 resolves living wounds first, then permits destroyed non-Character models to return with one wound per remaining wound; a returned model can receive further healing from the same budget. The suite checks player-directed allocation, preview-before-confirmation, same-roll reset, placement, overflow, Character exclusion, Battle-shock, timing, save/restore, phase-close suspension and public-command rejection.
- **Support:** all eight shared-book bodyguards are checked in this sheet's focused tests. The full 29 October cross-book export confirms fourteen standard targets overall, adding Inner Circle Companions, Deathwatch Veterans, Fortis Kill Team, Decimus Kill Team, Crusader Squad and Sword Brethren Squad. The dedicated relation suite exercises all fourteen current-catalog bodyguards, the Apothecary/Lieutenant shared-bodyguard exception and rejection of a third attached Character.
- **Shared healing regression:** the Infiltrator test now verifies the same Core healing rule for Helix Gauntlet, including a return after surviving wounds are healed and a return when no living model is wounded.

## Verification and limits

The targeted offline verifier passes the Apothecary scope, its profile parity check, the related Infiltrator healing regression and all 153 shared-book Leader/Support relations. The exact command passed **6/6 processes** (import, Python checks and the four selected suites), with `network: false`, `legacy_starter_staged: false` and no cleanup diagnostics, at `.tools/verification/20261027T092025938936Z/results.json`. The machine-readable audit is [marine-apothecary-audit.json](marine-apothecary-audit.json); the full command record is in [verification results](verification/verification-results.md).

The 29 October cross-book follow-up materializes and attaches all fourteen source-linked bodyguards from the current catalog. It passed as part of the **9/9-process** relation batch at `.tools/verification/20261029T102751146530Z/results.json`; the hash-verified relation audit is recorded in [verification results](verification/verification-results.md).

This validates the declared 11th-edition shared-book local scope. It does not certify complete army legality, Chapter-book variants, Forge World, Legends, Boarding Actions, network behavior, a complete match or human playtesting. Network validation remains deferred to final integration.
