# Decimus Kill Team — source-bounded local scope

**Status (29 October 2026):** the 10-model/210-point configuration has a source-bounded local implementation. The 5-model/110-point row is blocked from construction because the current source composition requires at least six models. This does not certify full army legality or human playability.

## Source identity

- Edition and mode: Warhammer 40,000 11th edition, standard army datasheet.
- Wahapedia page checked: [Decimus Kill Team](https://wahapedia.ru/wh40k11ed/factions/space-marines/Decimus-Kill-Team), 29 October 2026.
- Source book/datasheet IDs: Deathwatch App `000000035` / `000004175`.
- Local Data Export snapshot: `20261029T072022Z-final-integration`; the relevant source files were retrieved from 2026-10-29T07:20:48Z through 07:21:20Z, export updated 2026-10-28T23:48:19+03:00, revision `20260817b (URL query parameter)`.
- Parent manifest SHA-256: `772952e313b6772022c68226514eba7cdde00464468fd79c8291d20c24da4801`. Decimus scoped-slice manifest SHA-256: `4fd505e6f0b8eea123fc253a4e2017cfe3d3fd1b838abf2081697b455cef825f`. The [machine-readable audit](marine-decimus-kill-team-audit.json) records the current source filenames and file hashes.
- Final source check: the 29 October page and refreshed export still list `5 models / 110` and `10 models / 210`, while the six required role rows sum to at least six models. The subject slice has zero validation findings; the parent export retains 68 unrelated structural findings.

## Implemented scope

The runtime retains both source price rows, but the construction catalog exposes only ten models for 210 points until the five-model contradiction is corrected. The runtime models the Xenophase Veteran, Sergeant, Marksman Veteran, Heavy Veteran, Stalker Veteran and Gravis Veteran, including the Gravis model's separate movement, Toughness, Wounds and 40 mm base. It includes the source-listed weapons and their profiles, Combat Doctrines, Death to the Alien re-rolls, and the source-listed Leader/Support links.

Preparation exposes the Gravis weapon replacement, the Heavy Veteran Storm Shield/Power Weapon package and the Stalker Plasma Incinerator replacement with per-five-model limits. The Storm Shield's 4+ invulnerable save applies only to its bearer.

**Composition boundary:** the ten-model roster is two of each variable specialist and matches the listed 1–2 quantity for all four roles. The local profile preserves 16 possible five-model role distributions for comparison, but none is offered for construction: keeping one Xenophase Veteran and one Sergeant leaves three models to fill four roles that each have a source minimum of one. A five-model distribution therefore cannot be selected without a source correction or erratum.

## Verification and limits

The focused regression covering the selectable 10-model profile, explicit rejection of five models, the consolidated catalog, copy caps and Apothecary attachment passed **6/6 processes** at `.tools/verification/20261029T130559976998Z/results.json` (SHA-256 `9E7233099702A49D6B01D5E020A0CDC796D32B802F8142F086E4DE9A57B98AD1`; network disabled; no cleanup diagnostics). Checked-roster and source-link regressions passed **4/4 processes** at `.tools/verification/20261029T130749133650Z/results.json` (SHA-256 `4F823B79517A9372B934A070CA5807A99CA631DFC58A9E15CAC8ED566DFB1C82`; network disabled). The five-model row remains blocked at construction and preparation: the runtime offers no Decimus equipment choices for that size and rejects forged loadout commands without state changes. Full army legality and human playtesting remain open.

Latest provenance-rechecked focused run: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_decimus_kill_team --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T220221019374Z/results.json` (SHA-256 `d975ec817706afccb3831fcf2c3f3c129bec76f3c79bc713cb63dc67368d7210`; `network: false`, legacy starter staged, no cleanup diagnostics). This confirms the local profile remains tied to the refreshed 29 October export; it does not resolve the five-model source conflict.

Network validation, human playtesting, broader cross-sheet roster legality and the composition wording review remain open.
