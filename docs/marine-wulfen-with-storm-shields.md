# Wulfen with Storm Shields sheet audit

## Source and scope

This audit covers the 11th-edition Space Wolves App datasheet `000004132`, using the verified Wahapedia Data Export snapshot `20261029T003124Z` (export updated `2026-10-28T23:48:19+03:00`, specification revision `20260817b`). The source book is Space Wolves (`000000036`). The parent manifest SHA-256 is `457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d`; the subject-scoped slice manifest SHA-256 is `6cc0d72accb62915e6233a42d92a1f8d0da90566a60818597e569b3c562d2ae5`. The slice is structurally valid with zero errors. The parent export retains 68 findings, which remain open.

Raw exports and the subject slice remain under ignored `.tools/`. The complete parent and slice filename/hash records are in the [machine-readable audit](marine-wulfen-with-storm-shields-audit.json). Network page comparison is deferred to final integration.

## Integrated local scope

The datasheet has 5 models for 125 points or 10 for 250; third and later copies cost 155/280. Each model has M9, T6, Sv4+, a 4+ invulnerable save, W2, Ld7+, OC0 and a 40 mm base. Every model starts with a Stormfrag Auto-launcher and a Thunder Hammer. Any number can replace its launcher with a Death Totem, with no points adjustment.

The Stormfrag Auto-launcher is 12 inches, 2 attacks, BS4+, S4, AP-1, D1, Assault and Blast 1. The Thunder Hammer has an exported standard profile (2 attacks, WS3+, S8, AP-2, D3, Devastating Wounds) and a separately exported “Hunter” profile (3 attacks, WS3+, S10, AP-3, D3, Devastating Wounds). The export supplies no Hunter activation condition; the implementation retains it as an alternate profile of the same physical weapon and adds no unlisted restriction.

Death Totem grants melee Hit re-rolls of 1 while equipped. Curse of the Wulfen grants +1 OC near the listed friendly Space Wolves Character or Wolf Priest, subject to the Battle-shock boundary; its linked Bestial Forms rule makes each Wulfen count as two models for transport capacity. Hammer Blow opens an after-fight choice only for a MONSTER/VEHICLE unit hit by the Wulfen melee attacks; selecting it applies -1 to the target’s Hit rolls through the opponent’s turn and expires at the start of the Wulfen player’s next turn. Passing resumes any suspended fight window. Combat Doctrines is registered. Savage Frenzy, Leader relations and Support relations are not listed on this sheet and are not added.

## Verification and limits

Focused offline verification passed 3/3 processes (`import`, `python` and `test_wulfen_storm_shields`) at `.tools/verification/20261029T033331055146Z/results.json` (SHA-256 `F203254F1C6E0BA62D7489C8DA9A61A3170FDE78A18115C78B953A211BD4E124`; `network: false`, no legacy starter staged and no cleanup diagnostics). The Space Wolves/current-catalog regression passed 11/11 processes at `.tools/verification/20261029T033559838252Z/results.json` (SHA-256 `63916B3D07296BFAE5D0A6E617B4465D8F9D8E1ABC0B2F30BD4BE3CB916C6565`; no legacy starter staged). A separate set of five historical-data-dependent checks passed 7/7 processes at `.tools/verification/20261029T033713524054Z/results.json` (SHA-256 `53C4B2A7F4425ED55EE18B3D17A6CB716165254DA8620753F382BADD85B378E8`; the verifier staged the legacy starter for those declared dependencies). The suites cover source facts, cost tiers, equipment choices, both Thunder Hammer profiles, Death Totem, Objective Control, transport capacity, Hammer Blow target eligibility and public choice flow, suppression duration, the AttackPlan Hit modifier and a nested fight-window continuation.

This closes the source-bounded local sheet scope only. Network page validation, human playtesting, full Chapter/army legality and complete-match certification remain open. The Hunter profile’s activation condition needs source-page reconciliation before making a stronger rules claim.
