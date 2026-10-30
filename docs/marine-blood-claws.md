# Blood Claws local datasheet scope

## Source identity

Blood Claws is Space Wolves App datasheet `000000303` in the current Wahapedia 11th-edition rules. The current page was checked on 29 October 2026 against verified local Data Export snapshot `20261029T003124Z`, exported at `2026-10-28T23:48:19+03:00` using specification revision `20260817b`. The parent manifest SHA-256 is `457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d`; the scoped slice SHA-256 is `8C713E966DCB17BEEFD5B3556FBCF674A6EAA7080F628C2ED128D1DEC89B78A2`. The subject slice has zero validation errors and is structurally valid. The parent export has 68 unrelated validation errors, which are documented rather than treated as passed. Raw exports remain in ignored `.tools/`. Source hashes and reviewed facts are recorded in the [machine-readable audit](marine-blood-claws-audit.json).

Sources: [Wahapedia Blood Claws (11th edition)](https://www.wahapedia.ru/wh40k11ed/factions/space-marines/Blood-Claws) and [Wahapedia Data Export](https://wahapedia.ru/wh40k11ed/the-rules/data-export/).

## Integrated local scope

The consolidated catalog now offers the 10-model unit for 150 points and the 20-model unit for 290. The profile records M7, T5, Sv3+, W2, Ld6+, OC2 and the source keywords. Each model starts with a Bolt Pistol and Chainsword. Army Preparation offers the Pack Leader's Plasma Pistol and Power Weapon replacements independently; invalid choices are rejected and its equipment changes do not alter the other Blood Claws.

Berserk Charge keeps a Blood Claws unit eligible to declare a Charge after it Advances. The runtime uses the shared Charge-declaration eligibility path, and the ability does not grant shooting or action eligibility after an Advance.

The source lists six Leaders: Ragnar Blackmane, Njal Stormcaller, Ulrik the Slayer, Iron Priest, Wolf Guard Battle Leader and Wolf Priest. All six listed Leaders are integrated. Wolf Guard Headtakers is selectable as a Leader target for its admitted mixed 6/12-model configurations; its MFM-listed Headtakers-only rows remain blocked by Wahapedia's selected mixed minimum composition.

## Verification and limits

The focused offline regression passed all 7 processes: import, Python, `test_blood_claws`, `test_implemented_catalog`, `test_capabilities`, `test_combat_doctrines` and `test_execrator`. The report is `.tools/verification/20261029T015613920914Z/results.json` (SHA-256 `3F094EFE0B29A3B268AE34115D3B8A7889533960B1622E8D32A2A95B36C63288`; `network: false`; no cleanup diagnostics). It verifies both source-priced unit sizes in profile data, catalog admission, fixed characteristics and weapons, Pack Leader choices and their model boundary, Berserk Charge through the actual Charge declaration, and the normal restriction on other units.

This closes the local scope for the Blood Claws datasheet. Network validation, source-listed Leader attachment endpoints, human playtesting, full faction/army legality and complete-match certification remain open.
