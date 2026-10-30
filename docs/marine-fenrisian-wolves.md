# Fenrisian Wolves local datasheet scope

## Source identity

Fenrisian Wolves is Space Wolves App datasheet `000000323` in the current Wahapedia 11th-edition rules. The sheet was checked against verified local Data Export snapshot `20261029T003124Z`, exported at `2026-10-28T23:48:19+03:00` with specification revision `20260817b`. The parent manifest SHA-256 is `457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d`; the subject slice manifest SHA-256 is `DD01804235496759470C95A4B73CAFE3E04F924E10B5C62A68E2407B8E720EA1`. The slice is structurally valid with zero errors. The parent export has 68 unrelated validation errors; they remain documented and are not treated as passed. Raw exports remain under ignored `.tools/`. Exact source rows and hashes are in the [machine-readable audit](marine-fenrisian-wolves-audit.json).

Sources: [Wahapedia Fenrisian Wolves (11th edition)](https://www.wahapedia.ru/wh40k11ed/factions/space-marines/Fenrisian-Wolves) and [Wahapedia Data Export](https://wahapedia.ru/wh40k11ed/the-rules/data-export/).

## Integrated local scope

The consolidated catalog offers five models for 45 points or ten for 75; third and later copies cost 50/80 points. Each base is 40 mm. The profile records M10, T4, Sv6+, W1, Ld8+, OC0 and Teeth and Claws.

Predatory Instinct opens a reaction after an enemy move ends within 8 inches. If used, a D6 sets a Normal Move distance for the Fenrisian unit; the workflow checks placement, resumes the interrupted movement and limits the ability to once per battle round. Hunting Hounds adds 1 OC while within 6 inches of a friendly Space Wolves Character, except Wulfen Characters; Battle-shock suppresses the bonus.

## Verification and limits

The focused offline verification passed 7/7 processes: import, Python checks, `test_fenrisian_wolves`, `test_implemented_catalog`, `test_capabilities`, `test_cato_sicarius` and `test_roster_validation`. A connected Space Wolves regression later passed 12/12 processes, including Fenrisian Wolves, Wolf Guard Terminators, Blood Claws, Grey Hunters and the relevant catalog, rules and roster suites. Its report is `.tools/verification/20261029T024440783950Z/results.json` (SHA-256 `B302F9565738BA82CF5C926BB636A02C7E120E6FDD863FFE74AEDDF6DC0E3468`; `network: false`, legacy starter staged, no cleanup diagnostics). Both reports and hashes are in the [machine-readable audit](marine-fenrisian-wolves-audit.json). The local checks cover source prices, profile, abilities, reaction ownership and timing, movement limit, once-per-round use and Objective Control boundaries.

This closes only the named source-bounded local sheet scope. Network validation, human playtesting, full Chapter/army legality and complete-match certification remain open.
