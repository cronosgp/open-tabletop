# Decimus Kill Team — source-bounded local scope

**Status (30 October 2026, current page rechecked):** the local profile is complete for the selectable 10-model configuration under the project’s chosen Wahapedia 11e source (210 points). The current official GW MFM v1.0 lists that size at 190 points, so the runtime’s roster cost is not certified for events using the MFM. Wahapedia’s 5-model/110-point row remains blocked because the required roles have a six-model minimum. Full army legality and human playability are not certified.

## Source identity

- Edition and mode: Warhammer 40,000 11th edition, standard army datasheet.
- Wahapedia page checked: [Decimus Kill Team](https://wahapedia.ru/wh40k11ed/factions/space-marines/Decimus-Kill-Team), 30 October 2026.
- Source book/datasheet IDs: Deathwatch App `000000035` / `000004175`.
- Local Data Export snapshot: `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, retrieved 29 October local time at `2026-10-30T01:33:48.347556Z`; export updated `2026-10-28T23:48:19+03:00`, specification revision `20260817b`.
- Parent manifest-file SHA-256: `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`. Decimus subject-slice manifest-file SHA-256: `b258edd148a8b4f1dcb1dd174721c132b8337e6533b8aea597871dd96cd1aa88`; subject catalog SHA-256: `b57f6491ead33f53178f92da0260744367eecf3ba2523b5348c246f8fe0e72fd`. The [machine-readable audit](marine-decimus-kill-team-audit.json) records the current 22 export filenames and hashes.
- Current source check: the live 11e page and refreshed export list `5 models / 110` and `10 models / 210`, while the six required role rows sum to at least six models. Current [official MFM v1.0](https://mfm.warhammer-community.com/en/deathwatch), on the download index updated 14 October 2026, lists `5 / 100` and `10 / 190`. The project retains Wahapedia costs by policy; event roster pricing against the MFM is not certified. The subject slice has zero validation findings; the parent export retains 68 unrelated structural findings.

## Implemented scope

The runtime retains both Wahapedia price rows for auditability, but exposes only the source-composition-compatible ten-model configuration for 210 points. Under the official MFM v1.0, that same size costs 190 points; use of the local roster total is therefore limited to the project’s selected Wahapedia points source. The runtime models the Xenophase Veteran, Sergeant, Marksman Veteran, Heavy Veteran, Stalker Veteran and Gravis Veteran, including the Gravis model's separate movement, Toughness, Wounds and 40 mm base. It includes the source-listed weapons and their profiles, Combat Doctrines, Death to the Alien re-rolls, and the source-listed Leader/Support links.

Preparation exposes the Gravis weapon replacement, the Heavy Veteran Storm Shield/Power Weapon package and the Stalker Plasma Incinerator replacement with per-five-model limits. The Storm Shield's 4+ invulnerable save applies only to its bearer.

**Composition boundary:** the ten-model roster is two of each variable specialist and matches the listed 1–2 quantity for all four roles. A five-model roster cannot satisfy the sheet: after the fixed Xenophase Veteran and Sergeant, three spaces cannot meet the minimum of one model for each of four specialist roles. No five-model composition is stored as a selectable runtime choice.

## Verification and limits

The focused regression covering the selectable 10-model profile, explicit rejection of five models, the consolidated catalog, copy caps and Apothecary attachment passed **6/6 processes** at `.tools/verification/20261029T130559976998Z/results.json` (SHA-256 `9E7233099702A49D6B01D5E020A0CDC796D32B802F8142F086E4DE9A57B98AD1`; network disabled; no cleanup diagnostics). Checked-roster and source-link regressions passed **4/4 processes** at `.tools/verification/20261029T130749133650Z/results.json` (SHA-256 `4F823B79517A9372B934A070CA5807A99CA631DFC58A9E15CAC8ED566DFB1C82`; network disabled). The five-model row remains blocked at construction and preparation: the runtime offers no Decimus equipment choices for that size and rejects forged loadout commands without state changes. Full army legality and human playtesting remain open.

Latest provenance-rechecked focused run: `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_decimus_kill_team --timeout 300` passed **3/3 processes** at `.tools/verification/20261029T220221019374Z/results.json` (SHA-256 `d975ec817706afccb3831fcf2c3f3c129bec76f3c79bc713cb63dc67368d7210`; `network: false`, legacy starter staged, no cleanup diagnostics). The focused current batch passed **11/11 processes** at `.tools/verification/20261030T070201355409Z/results.json` (SHA-256 `eb3e935cc2ba1cbd6494ce3f5342b0af3a9a9f9b260affec4435a68b26b09913`; `network: false`, legacy starter staged, no cleanup diagnostics). It covers the three sheets, their relevant rules and catalog/capability gates. This offline run verifies local behavior only. This confirms the admitted profile remains source-matched; it does not resolve the five-model source conflict.

An earlier three-sheet readiness batch passed **14/14 processes** at `.tools/verification/20261030T015331833516Z/results.json` (SHA-256 `5B927A356524B9E0613EED2B39E33F4C5D17B851B1305D376944689D4A2B1338`; `network: false`, no cleanup diagnostics). The refreshed UI shows the 10-model/210-point legal choice and explains why the 5-model/110-point row is blocked.

The live Wahapedia page was checked again on 30 October and still lists both price rows while requiring at least six models in the composition. The focused three-sheet run passed **5/5 processes** at `.tools/verification/20261030T030111786006Z/results.json` (SHA-256 `6bee64a7cbcc7387b986e4cb9504a2e7798e1b6275474caa63f3899deacccd2d`; `network: false`, legacy starter staged, no cleanup diagnostics). It includes Decimus admission, exact composition and rejection of the five-model configuration.

The five-model composition conflict remains blocked. The ten-model profile is locally complete under Wahapedia, but the 210-point runtime value differs from the official MFM’s 190 points. Human playtesting, broader cross-sheet roster legality and final network integration remain open.

Latest linked-sheet regression passed **15/15 processes** at `.tools/verification/20261030T102146906553Z/results.json` (SHA-256 `daa3134c46d55086618e0a01ec438cbd5e431470fef33759c66a01e2cbdd5cde`; `network: false`, legacy starter staged, no cleanup diagnostics). Decimus remains selectable only as the 10-model/210-point Wahapedia configuration; its five-model row is blocked and MFM v1.0 prices the ten-model configuration at 190 points.
