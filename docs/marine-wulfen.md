# Wulfen sheet audit

## Source and scope

This audit covers the standard 11th-edition Space Wolves App datasheet `000000311`, using the verified Wahapedia Data Export snapshot `20261029T003124Z` (export updated `2026-10-28T23:48:19+03:00`, specification revision `20260817b`). The source book is Space Wolves (`000000036`). The snapshot manifest SHA-256 is `457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d`; the subject-scoped slice manifest SHA-256 is `f3dedbf36bf9fa30d6db0b22f1a6cc4f95f2dceef136def80846496eaf2fe9d3`. The slice has zero validation errors. The parent export has 68 validation findings; they remain open and are not counted as passed.

The page/export network comparison is deferred to final integration. Raw exports and the scoped slice remain under ignored `.tools/`; the maintained source/hash record is in the [machine-readable audit](marine-wulfen-audit.json).

## Integrated local scope

The unit has 5 Wulfen for 90 points or 10 for 180; the third and later copies cost 105/195 points. Each model has M9, T6, Sv4+, W2, Ld7+, OC0 and a 40 mm base. Keywords are Adeptus Astartes, Space Wolves, Imperium, Infantry and Wulfen. Each model starts with a Death Totem and Wulfen Weapons.

During Army Preparation, each model can independently replace its Death Totem with a Stormfrag Auto-launcher. Wulfen Weapons have 3 attacks at WS3+, Strength 6, AP-2, Damage 2 and Sustained Hits 1. The Stormfrag Auto-launcher profile is 12 inches, 2 attacks, BS4+, Strength 4, AP-1, Damage 1, Blast 1 and Assault.

Savage Frenzy requires eligible enemy units that Fall Back from engagement with Wulfen to take Desperate Escape tests; when the Wulfen unit is Battle-shocked, its Hazard rolls take a -1 modifier. Death Totem grants melee Hit rerolls of 1 while the corresponding wargear remains equipped. Curse of the Wulfen grants the unit +1 Objective Control while it is within 6 inches of an eligible friendly Space Wolves Character or 12 inches of a friendly Wolf Priest; Battle-shocked units still cannot control objectives. Bestial Forms makes each Wulfen model count as two models for transport capacity. Combat Doctrines is also registered. The source export lists no Leader or Support relations for this datasheet.

## Verification and limits

Focused offline verification passed 3/3 processes (import, Python checks and `test_wulfen`) at `.tools/verification/20261029T031423847780Z/results.json` (SHA-256 `bc5c6ea36466cf39bafccf4cd1df4f83f572b8c81ec716d5b875956f7a24a61`; `network: false`, legacy starter staged, no cleanup diagnostics). The connected offline regression passed 13/13 processes at `.tools/verification/20261029T031521462605Z/results.json` (SHA-256 `e686b080096aeeca55981dfd5b6ec2adb295a6104d59a8620275e35f87660bf93`; `network: false`, legacy starter staged, no cleanup diagnostics). The checks cover the fixed profile and cost tiers, reversible per-model equipment, melee rerolls, Fall Back and Hazard behavior, Objective Control range and Battle-shock boundaries, transport capacity, catalog admission and connected Space Wolves/Marine behavior.

This closes only the source-bounded local datasheet scope. Network validation, human playtesting, full Chapter/army legality and complete-match certification remain open.
