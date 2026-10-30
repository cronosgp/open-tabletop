# Techmarine datasheet audit

## Source and scope

This audit covers the 11th-edition shared Space Marines datasheet in source book `000000139`, datasheet `000000140`, using the pinned local Wahapedia Data Export snapshot `20261021T130623Z` (specification revision `20260817b`). The source page is [Techmarine](https://wahapedia.ru/wh40k11ed/factions/space-marines/Techmarine). The runtime profile retains its `2026-10-16T21:03:46+03:00` source-export stamp; this audit uses the separately identified export snapshot updated `2026-10-21 16:06:23 GMT+3` and does not rewrite that provenance. The local export lists no equipment-option rows for this datasheet.

The fixed profile is one model on a 40 mm base, with M6, T5, Sv2+, W4, Ld6+ and OC1, for 55 points. Its fixed weapons are Forge Bolter, Grav-pistol, and the combined Omnissian Power Axe/Servo-arm. The three weapon profiles and their attack-plan routes are checked against the source extract.

## Implemented scope checked

- **Profile and admission:** source identity, model count, base, characteristics, keywords, fixed cost and absence of equipment options; current consolidated local Marine catalog choices on both players.
- **Weapons:** all three fixed weapons through `Equipment` and `AttackPlan`, including the Grav-pistol's `Anti-Vehicle 2+` and `Close-quarters` handling.
- **Techmarine — Lone Operative:** checks the source condition using a living friendly Adeptus Astartes Vehicle. The 3-inch base-edge eligibility and 12-inch targeting boundary are tested at and just beyond the calibrated edges; invalid friendly/hostile or non-Astartes Vehicle cases remain excluded.
- **Blessings of the Omnissiah:** starts at the beginning or end of the Techmarine's own Movement-phase move, can defer from start to end, selects a friendly Adeptus Astartes Vehicle model within 3 inches, heals D3 wounds up to its maximum, and makes its attacks ignore Hit and Wound modifiers until the start of the owner's next Movement phase. The test covers movement continuation, save/restore, timing expiry and the friendly-vehicle distance boundary.
- **Leader/Support relationships:** the paired relation suite checks the shared source-derived 153-link map, including the Techmarine's Leader choices.

## Verification

The targeted offline verifier passed 5/5 processes: import, Python checks, `test_techmarine`, `test_techmarine_profile_parity` and `test_space_marine_leader_links`. It reported `network: false`, did not stage the legacy starter, and recorded no headless cleanup diagnostics.

- Command: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_techmarine --only test_techmarine_profile_parity --only test_space_marine_leader_links --timeout 300`
- Report: `.tools/verification/20261027T085333172418Z/results.json`
- Machine-readable source and scope record: [marine-techmarine-audit.json](marine-techmarine-audit.json)

This validates the declared local sheet scope. It does not certify complete army legality, Chapter-book variants, Forge World, Legends, Boarding Actions, network behavior, a complete match or human playtesting. Network validation remains deferred to final integration.
