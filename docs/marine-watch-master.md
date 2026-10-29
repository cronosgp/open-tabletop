# Watch Master

**Status:** source-bounded local datasheet scope passed. Network validation, human playtesting and full army legality remain open.

## Source identity

- Edition and mode: Warhammer 40,000 11th edition, standard army datasheet; Boarding Actions and alternate modes are separate.
- Source book: Deathwatch App (`000000035`); Watch Master (`000003871`).
- Current rules page checked 29 October 2026: [Wahapedia Watch Master](https://wahapedia.ru/wh40k11ed/factions/space-marines/Watch-Master).
- Local Data Export snapshot: `20261029T003124Z`, retrieved 29 October 2026, export updated `2026-10-28T23:48:19+03:00`, specification revision `20260817b`.
- Parent manifest SHA-256: `457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d`.
- Watch Master slice manifest SHA-256: `680cff731d32f16de516ae815963dc18ecb5091e51b95843dacc595999aca4de`.
- The bounded slice contains only this datasheet plus Deathwatch Veterans, Fortis Kill Team and Decimus Kill Team as identity-only attachment dependencies. The parent export reports 68 validation errors; the scoped slice is structurally valid with zero errors. This result relies on the slice, not a claim that the parent export is globally error-free.
- Raw export and derived source files remain under ignored `.tools/` and are not included in Git. File hashes and source identities are recorded in the [machine-readable audit](marine-watch-master-audit.json).

## Integrated local scope

The current catalog contains the one-model, 105-point Watch Master profile: M6, T5, Sv 2+, invulnerable save 4+, W5, Ld 6+, OC1, and a 32 mm base. The Vigil Spear's ranged and melee profiles, Lance trait, source keywords, and all three available Leader targets are recorded. The targets are Deathwatch Veterans, Fortis Kill Team and Decimus Kill Team.

Strategic Knowledge gives the unit's ranged attacks Assault, allows the unit to shoot after Falling Back and allows it to declare a Charge after Advancing or Falling Back. Watch Master re-rolls Hit and Wound rolls of 1 against CHARACTER targets for the Watch Master model only. Purgatus Quarry offers an explicit initial quarry selection or pass at the start of the first battle round, re-rolls Wound rolls of 1 against the selected quarry, and offers an explicit replacement selection or pass each time that quarry is destroyed. The replacement uses the existing normalized marked-target continuation.

## Verification and limits

The focused offline run passed import, Python checks and `test_watch_master` (3/3 processes) at `.tools/verification/20261029T005637251297Z/results.json`, SHA-256 `7bc0f4e042816ba40993ccdac0340c972ae9d28c0bb2f22204668cc8fc274f0c`. It covers source/profile admission, Leader attachment, both quarry choice paths, Assault eligibility after Advance, model-only CHARACTER re-rolls, quarry-target Wound re-rolls, Fall Back and Advance permissions, and replacement after destruction.

The connected offline regression passed 9/9 processes at `.tools/verification/20261029T005519320110Z/results.json`, SHA-256 `822ed338b843e5294a900a5fd6d8e29b0ea26ae52b7a284de0f8507af60928f6` (`network: false`, legacy starter staged, no headless cleanup diagnostics). It includes the Watch Master and Deathwatch Veterans suites, Leader links, Combat Doctrines, capabilities, the implemented catalog and the Invictor shared marked-target path. The Invictor test now uses Strike Force's 2,000-point category for its three-copy assertion; Incursion correctly applies a two-copy limit to non-Battleline units.

The normalized choice path was verified headlessly; no live game screenshot or human playtest was captured. These local checks do not establish network validation, full roster legality, all Space Marine rules or platform coverage.
