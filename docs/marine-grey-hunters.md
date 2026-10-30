# Grey Hunters local datasheet scope

## Source identity

Grey Hunters is Space Wolves App datasheet 000000305 in the current Wahapedia 11th-edition rules. The page was checked on 29 October 2026 against verified local Data Export snapshot 20261029T003124Z, exported at 2026-10-28T23:48:19+03:00 with specification revision 20260817b. The parent manifest SHA-256 is 457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d; the scoped slice manifest SHA-256 is B7E39365429434EE6416607CA5AFE7B4AC59D5D7738392BDFC526518F716568F. The subject slice is structurally valid with zero validation errors. The parent export has 68 unrelated errors; they remain documented and are not treated as passed. Raw export files remain in ignored .tools/. Exact source files and reviewed facts are in the [machine-readable audit](marine-grey-hunters-audit.json).

Sources: [Wahapedia Grey Hunters (11th edition)](https://www.wahapedia.ru/wh40k11ed/factions/space-marines/Grey-Hunters) and [Wahapedia Data Export](https://wahapedia.ru/wh40k11ed/the-rules/data-export/).

## Integrated local scope

The consolidated catalog offers the ten-model unit for 180 points. The profile records M7, T5, Sv3+, W2, Ld6+, OC3, its source keywords and 32 mm bases. All models start with a Bolt Carbine, Bolt Pistol and Chainsword. During Army Preparation, the Pack Leader can independently replace the pistol with a Plasma Pistol and the Chainsword with a Power Fist or Power Weapon; the catalog rejects choices outside those source-listed options.

Old Greymanes is available during Declare Battle Formations. The player explicitly selects five model identities for the second pack, and the remaining five form the first; confirming the division preserves the selected model equipment and the roster's total 180-point value. Canceling the setup draft leaves the roster unchanged.

Cunning Hunters improves melee Strength and AP by 1 for the Fight phase while any model in the unit is within objective range. The objective check follows the runtime's marker geometry and is phase-gated.

The source lists five Leaders: Ulrik the Slayer, Wolf Priest, Wolf Guard Battle Leader, Njal Stormcaller and Iron Priest. Ulrik, Njal, Iron Priest and Wolf Guard Battle Leader are integrated; Wolf Priest remains unavailable as a runtime profile.

## Verification and limits

The focused offline regression passed all eight processes: import, Python checks, test_grey_hunters, test_implemented_catalog, test_capabilities, test_blood_claws, test_combat_doctrines and test_roster_validation. The report is .tools/verification/20261029T021529028806Z/results.json (SHA-256 E53F5448997D72DBE37AC38D76B31678D9E53B5F69E8188E5C119DA97CD008C; network: false; legacy starter staged; no cleanup diagnostics). The suite covers source-bounded profile admission, Pack Leader options, exact 5+5 model membership and cost conservation, and the Cunning Hunters objective/phase/weapon modifiers.

This closes only the named Grey Hunters local datasheet scope. Two source-listed Leader endpoints, network validation, human playtesting, full faction/army legality and complete-match certification remain open.
