# Spectrus Kill Team

**Status:** source-bounded local datasheet scope passed; network validation, human playtesting and full army legality remain open.

## Source identity

- Edition/game mode: Warhammer 40,000 11th edition, standard army datasheet.
- Source: Deathwatch App (`000000035`), Spectrus Kill Team (`000002779`).
- Current rules page checked 28 October 2026: [Wahapedia Spectrus Kill Team](https://wahapedia.ru/wh40k11ed/factions/space-marines/Spectrus-Kill-Team).
- Local Data Export: snapshot `20261021T130623Z`, retrieved 21 October 2026 at `19:46:58Z`, export updated `2026-10-21T16:06:23+03:00`, specification revision `20260817b`.
- Snapshot manifest SHA-256: `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`.
- Source-bounded slice manifest SHA-256: `4290befd02adf74ce1500df2c2425f9cb81b87d4d4b62fc0f9a39b17e3f05ade`.
- The raw export remains under ignored `.tools/`; it is not included in Git.

## Implemented scope

The profile admits its fixed ten-model composition at 185 points for the first two copies and 195 points from the third. It preserves two sniper Infiltrators, two Occulus Infiltrators, two Special-issue Infiltrators and four Marksmen, their M8/T4/3+/W2/OC1 characteristics, 32 mm bases, and all source-listed unit keywords.

All eleven exported weapon profiles resolve through Equipment and AttackPlan for the matching model role. The preparation flow supports both sniper replacements, the Special-issue model's Deathwatch Bolt Carbine/Ceramite Fists package and at most one Helix Gauntlet; each choice restores its source default. Instigator Bolt Carbine Lethal Hits are retained only against non-MONSTER/non-VEHICLE targets.

The runtime maps Infiltrators, Scouts 6, Combat Doctrines, Spectrus Doctrines and Helix Gauntlet. Helix healing uses the shared Command-phase healing flow. At the end of the opponent's Fight phase, an eligible unengaged Spectrus unit can use the shared Strategic Reserves state. The Captain, Lieutenant and Librarian in Phobos Armour are the three source-listed Leaders. A Phobos Lieutenant is a Leader for this Spectrus target while retaining its existing Support role for the shared-book targets.

Unsupported or unverified systems remain outside this sheet result. This local profile does not certify complete Chapter roster restrictions, full army legality, network behavior, other datasheets, or alternate game modes.

## Verification

- Focused offline run: `test_spectrus_kill_team`, 3/3 processes passed, no network and no legacy starter staged. Result: `.tools/verification/20261029T002046652774Z/results.json`.
- Connected offline regression: `test_spectrus_kill_team`, `test_space_marine_leader_links`, `test_infiltrator_squad`, `test_fortis_kill_team`, `test_indomitor_kill_team`, `test_unit_reserves` and `test_capabilities`; 9/9 processes passed, no network. Result: `.tools/verification/20261029T001832311393Z/results.json`.
- Network validation, human playtesting and full army legality have not been run or established.

Machine-readable provenance and run hashes are in the [Spectrus source audit](marine-spectrus-kill-team-audit.json).
