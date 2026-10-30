# Thunderwolf Cavalry sheet audit

## Source and scope

This audit covers the standard 11th-edition Space Wolves App datasheet `000000322`, using the verified Wahapedia Data Export snapshot `20261029T003124Z` (export updated `2026-10-28T23:48:19+03:00`, specification revision `20260817b`). The source book is Space Wolves (`000000036`). The snapshot manifest SHA-256 is `457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d`; the structurally valid, subject-scoped slice manifest SHA-256 is `238c7c2f9d776cab7fc5ebe7103157781cb2d72397fce3872a923c4f37f627ff`. The slice has zero validation errors. The parent export has 68 validation findings, which remain open and are not counted as passed.

The page/export network comparison is deferred to final integration. Raw exports and the scoped slice remain under ignored `.tools/`; the maintained source/hash record is in the [machine-readable audit](marine-thunderwolf-cavalry-audit.json).

## Integrated local scope

The profile offers 3 models for 115 points or 6 for 230; the third and later copies cost 145/260. Both the Pack Leader and Cavalry model use M12, T6, Sv3+, W4, Ld6+, OC2 and a 60 mm base. The keywords are Adeptus Astartes, Space Wolves, Mounted, Explosives and Imperium.

Every model starts with a Bolt Pistol, Teeth and Claws and a Wolf Guard Weapon. During Army Preparation, one model for every three in the unit can replace its Bolt Pistol with a Plasma Pistol. Any model can instead replace the Bolt Pistol with a Boltgun and Storm Shield for 5 points. Only the bearer gains a 4+ invulnerable save; the datasheet does not add a Wound. Weapon profiles include both standard and Hazardous supercharge profiles for the Plasma Pistol. Teeth and Claws retains Extra Attacks.

Thunderous Charge applies +1 Strength and +1 Damage to the unit's melee attacks after it makes a Charge move. The shared attack path applies the modifier to melee profiles while `charged` is active; ranged attacks are unchanged. The local export has no Leader or Support relations for this datasheet.

## Verification and limits

The focused offline verification passed 3/3 processes (import, Python checks and `test_thunderwolf_cavalry`) at `.tools/verification/20261029T030029700768Z/results.json` (SHA-256 `8df5a19890dbb23b79db0a3a7795859246b5ed7a14ecd695b84b4002ec8fa7ba`; `network: false`, legacy starter staged, no cleanup diagnostics). The connected regression passed 12/12 processes at `.tools/verification/20261029T030340279801Z/results.json` (SHA-256 `2c6e87c63eef596bb6c1c9e4992d5b4d099031ef57c08e02c0f6b554aad14d05`; `network: false`, legacy starter staged, no cleanup diagnostics), including construction, capabilities, roster validation, Leader links, Combat Doctrines and the existing Space Wolves profiles. Checks cover source provenance and fixed profile data, all weapon profiles, both formation sizes and copy-price tiers, public owner-gated preparation choices, the per-three Plasma Pistol cap, priced Storm Shields and bearer-only defense, reversible equipment changes and the post-Charge Strength/Damage effect.

This closes only the source-bounded local datasheet scope. Network validation, human playtesting, full Chapter/army legality and complete-match certification remain open.
