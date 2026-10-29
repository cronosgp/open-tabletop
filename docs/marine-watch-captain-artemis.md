# Watch Captain Artemis

**Status:** source-bounded local datasheet scope passed. Network validation, human playtesting and full army legality remain open.

## Source identity

- Edition and mode: Warhammer 40,000 11th edition, standard army datasheet; Boarding Actions and alternate modes are separate.
- Source book: Deathwatch App (`000000035`); Watch Captain Artemis (`000003872`).
- Current rules page checked 29 October 2026: [Wahapedia Watch Captain Artemis](https://wahapedia.ru/wh40k11ed/factions/space-marines/Watch-Captain-Artemis).
- Local Data Export snapshot: `20261029T003124Z`, retrieved 29 October 2026, export updated `2026-10-28T23:48:19+03:00`, specification revision `20260817b`.
- Parent manifest SHA-256: `457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d`.
- Artemis slice manifest SHA-256: `eb17311be3c05709b6f91c747dee5e7e8ec91b9a90c2555c3232ba9dfbdfbfca`.
- The bounded slice contains Artemis and Deathwatch Veterans, Fortis Kill Team and Decimus Kill Team as identity-only Leader endpoints. The parent export reports 68 validation errors; the scoped slice is structurally valid with zero errors. This result uses the slice and does not treat the parent export as globally error-free.
- Raw source files remain under ignored `.tools/`; parent and slice file hashes are recorded in the [machine-readable audit](marine-watch-captain-artemis-audit.json).

## Integrated local scope

The current catalog contains the one-model, 75-point Epic Hero profile: M6, T5, Sv 3+, invulnerable save 4+, W4, Ld 6+, OC1, and a 32 mm base. Hellfire Extremis and Master-crafted Power Weapon use the source weapon profiles. Artemis can lead Deathwatch Veterans, Fortis Kill Team and Decimus Kill Team.

Feel No Pain 6+ applies to Artemis herself. Tactical Instinct grants Sustained Hits 1 to every attack made by her attached unit. Unstoppable Champion is once per battle per army: at the end of the phase in which she was destroyed, roll one D6; on 2+, return her with 3 wounds at the closest legal point outside Engagement Range.

## Verification and limits

The focused offline command `python tools/verify.py --profile focused --only test_watch_captain_artemis --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe` passed import, Python checks and `test_watch_captain_artemis` (3/3 processes) at `.tools/verification/20261029T011058690940Z/results.json`, SHA-256 `a155e992d4ae7e8723742c47dad793e2c039fe30640c1246b826e66c5c6895fe` (`network: false`, no legacy starter staged, no headless cleanup diagnostics).

The connected offline regression `python tools/verify.py --profile targeted --only test_watch_captain_artemis --only test_deathwatch_veterans --only test_fortis_kill_team --only test_decimus_kill_team --only test_space_marine_leader_links --only test_combat_doctrines --only test_capabilities --only test_implemented_catalog --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --timeout 300` passed 10/10 processes at `.tools/verification/20261029T011706897051Z/results.json`, SHA-256 `de3809fe4cbf7d6e3019042e0ecd87556912cd0d431c3e9540476455a0d3c6ac` (`network: false`, legacy starter staged, no headless cleanup diagnostics). It checks the Deathwatch Leader targets, shared doctrine flow, capability metadata and current construction catalog.

The focused suite checks source profile facts, Epic Hero copy limit, all three Leader endpoints, Artemis-only Feel No Pain, unit-wide Sustained Hits 1, owner/phase-qualified destruction, both D6 outcomes, nearest legal placement and once-per-army use. Unstoppable Champion currently records only on-battlefield destruction paths and validates placement on the modeled battlefield; off-board or transport destruction and other unsupported match pathways are not certified.
