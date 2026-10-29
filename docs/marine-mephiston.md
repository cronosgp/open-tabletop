# Chief Librarian Mephiston — 11th-edition local sheet audit

## Source identity

The runtime profile is matched to Chief Librarian Mephiston (`000000155`) in the Blood Angels App book (`000000021`) from the verified local Wahapedia 11th-edition Data Export snapshot `20261021T130623Z`. The export was retrieved on 21 October 2026, uses specification revision `20260817b`, and records manifest SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf` and Blood Angels slice SHA-256 `74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5`. The current datasheet page was checked on 28 October 2026: [Chief Librarian Mephiston — Wahapedia 11e](https://wahapedia.ru/wh40k11ed/factions/space-marines/Chief-Librarian-Mephiston).

## Integrated local scope

Mephiston is a one-model, 175-point Epic Hero on a 40 mm base, with M8, T6, Sv2+, W6, Ld6+, OC1, a 4+ invulnerable save and PSYKER Level 3. The profile registers all source keywords and weapon modes: both Fury of the Ancients profiles, standard and supercharged Plasma Pistol, and Vitarus. Current-catalog admission enforces the one-copy limit.

The local ability map includes Feel No Pain 5+, Fights First, Lone Operative, Combat Doctrines, Transhuman Strategist, Chief Librarian, Quickening and Transfixing Gaze. Quickening uses a one-die Psychic test in Mephiston's Command phase: a 1 Battle-shocks his unit; otherwise it adds Assault Doctrine until his next Command phase. Transfixing Gaze uses its one-die test at the start of the opponent's Movement phase; after a success, an enemy unit within 6 inches that is selected to Fall Back must pass a Leadership test or Remain Stationary. An eligible Leadership re-roll can be offered to that unit's controller.

## Local checks and limits

The focused offline suite covers source identity, profile and weapon values, ability registration, current-catalog admission and copy limit, Feel No Pain, Fights First and Lone Operative, both Quickening results and expiry, the inclusive Transfixing Gaze range, Leadership re-roll ownership, Fall Back continuation and the failed-test Remain Stationary result. The final focused offline run of `test_mephiston` and `test_capabilities` passed 4/4 processes at `.tools/verification/20261028T214559138364Z/results.json` (SHA-256 `70204ec555bce39d5a0fc0935288d503188cab032f02518e8c838d1756896078`; `network: false`, legacy starter staged, no headless cleanup diagnostics). The broader connected run also passed 7/7 processes, including current-catalog, Sanguinor and Castellan regressions, at `.tools/verification/20261028T214139903905Z/results.json`. This is source-bounded local coverage; network validation, complete Space Marine army legality and human playtesting remain open. See the [machine-readable Mephiston audit](marine-mephiston-audit.json).
