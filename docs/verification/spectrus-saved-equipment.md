# Spectrus Kill Team saved-equipment migration — 15 November 2026

## Scope

The Army Workshop now stores the four exported equipment-option rows per Spectrus Kill Team model and copy. Saved equipment validates on local catalog admission, materializes through the existing Spectrus factory before Deployment, and locks duplicate match-preparation changes. This is a persistence migration; it does not add unit abilities, change composition or points, or certify the entire datasheet or army.

## Source identity and provenance

The reviewed source is edition 11, Space Marines App book `000000035`, Spectrus Kill Team datasheet `000002779`. The saved-equipment review is `verified_against` the verified local snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, parent manifest SHA-256 `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`, final retrieval bracket `2026-10-30T01:33:48.347556+00:00`. The runtime profile keeps its original extraction snapshot `20261021T130623Z` and manifest; runtime digest continuity is `2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68`, and the verified-against local Spectrus slice manifest SHA-256 is `ed356b7d4a9c34085a53daab7dc08325429f4d754d7441ac6f6728920affb109`. The source review records exact saved fields and does not rewrite profile origin metadata. No online source was consulted for this migration.

Relevant raw file SHA-256 values in the verified parent export:

| File | SHA-256 |
|---|---|
| `Datasheets.csv` | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| `Datasheets_options.csv` | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| `Datasheets_unit_composition.csv` | `f00a66fedc7b1df1a5a3907f763561db75789e3db82a0bd1f6a059fc2061e245` |
| `Datasheets_models_cost.csv` | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| `Datasheets_wargear.csv` | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |

The source-option classification and provenance basis are recorded in the [Army Builder source-review ledger](../project/army-builder-source-review.tsv).

## Roles, options, and prices

The fixed ten-model order is two Sniper Infiltrators, two Occulus Infiltrators, two Special-issue Infiltrators and four Marksmen. The Workshop presents each model's own options:

| Eligible model | Saved choice | Source limit |
|---|---|---|
| Either Sniper Infiltrator | Bolt Sniper Rifle, Las Fusil, or Instigator Bolt Carbine | Each of the two may choose independently; no shared cap |
| Either Special-issue Infiltrator | Combat Knife, or the complete Deathwatch Bolt Carbine + Ceramite Fists package | Each eligible model may take the replacement |
| Any of four Marksmen | Deathwatch Marksman Bolt Carbine, or Helix Gauntlet | One Helix Gauntlet per unit |
| Occulus Infiltrators | Fixed Deathwatch Occulus Bolt Carbine / Paired Combat Blades loadout | No optional saved field |

The list source prices stay 185 points for the first and second copies and 195 from the third copy. Equipment adds no points. Match materialization calls the current `spectrus_kill_team_model_loadout` factory with the validated model-specific values, retaining all existing profiles, keywords and model roles.

## Source-specific attachment role

The Phobos Lieutenant is a Support character for its shared-book bodyguards but is a Leader for Spectrus Kill Team in the selected Chapter-book source map. Its Spectrus relation is now classified as Leader while its other Support relations remain. The local attachment regression reaches this role through the public preparation command. This correction changes only how the already-declared local link is classified; it adds no attachment endpoint.

## Saved fields and persistence

Stable model records use `spectrus_sniper_weapon`, `spectrus_knife_replaced`, and `spectrus_helix_gauntlet`. Model-role validation rejects sniper replacements on fixed Occulus models, Combat Knife swaps on non-Special-issue models, and Helix selections outside the Marksmen. Whole-copy validation permits at most one Helix Gauntlet. Separate-process reopen preserves independent choices across three copies, saved matches materialize the exact weapon package for both players, and direct match-time equipment edits are rejected without mutation.

## Verification

The final offline command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_spectrus_saved_equipment --only test_spectrus_kill_team --only test_apothecary --only test_army_builder --only test_implemented_catalog --only test_model_equipment_visuals --only test_saved_armies --only test_match_save --timeout 900
```

It passed **10/10 verifier processes** at `.tools/verification/20261115T195957153558Z/results.json` (SHA-256 `8eb0ccd2f6a71c6fa56b8ac74ebff4fc3b5c271683d6cd8a4bc3e7288089c539`; network disabled; legacy starter staged). The two source-specific Spectrus suites passed, as did Apothecary attachment, Army Builder, catalog, model visuals, saved-army reopen and match-save coverage. Army Builder, catalog, saved-army and match-save processes logged headless RID/ObjectDB cleanup diagnostics at shutdown and exited successfully; the other six reported none. `test_spectrus_kill_team` confirms the Phobos Lieutenant attaches to Spectrus as a Leader through the public preparation command.

The separate `test_space_marine_leader_links` batch passed the Spectrus role assertion after its test expectation was made target-specific, but failed five Necron Support-target cross-map assertions (Orikan, Plasmancer, Technomancer, Psychomancer and Chronomancer). That separate 3-process result is `.tools/verification/20261115T195846562216Z/results.json` (SHA-256 `abdc6fec673e93c90823994fb03848bc0826372c93b88605797bbac269260b6c`; network disabled; legacy starter not staged). The Spectrus source-role and direct Lieutenant attachment assertions pass in the profile-specific suite; no result is claimed for the Necron cross-map findings.

## Actual Workshop captures

These are actual Godot Compatibility captures at 1280×800, not mockups. They show the controls after selecting a role and scrolling its model card into view. Each capture process exited 0 and printed ten model cards, with the same shutdown diagnostics: 19 GLES texture RIDs, 2 advanced-font RIDs, 2 CanvasItem RIDs and 47 ObjectDB instances.

| Capture | SHA-256 | What it shows |
|---|---|---|
| `.tools/spectrus-equipment-20261115/after/spectrus-sniper-1280x800.png` | `58f325875cb89e113c2baffb2301017949c88b5fb8ef431f1c31490d5edb3476` | Sniper Infiltrator selector with Las Fusil selected |
| `.tools/spectrus-equipment-20261115/after/spectrus-special-1280x800.png` | `f5363fafd706c205d98dafde2de751732cab1c06c582524cd748effd79379167` | Complete Deathwatch Bolt Carbine + Ceramite Fists replacement |
| `.tools/spectrus-equipment-20261115/after/spectrus-marksman-1280x800.png` | `b89b15ada59b3e471dda80eb3dc5e683ea837c24a227f15fc274fd9499303ad5` | Single-per-unit Helix Gauntlet choice on a Marksman |

The captures do not establish small-window layout, keyboard/gamepad coverage, or human usability.

## Remaining plan work

Talonstrike Kill Team completed the last no-schema option migration; see its [saved-equipment evidence](talonstrike-saved-equipment.md). Fifty-nine other detected schemas still need source-option completeness review; twelve stale source reviews and nine unclassified profiles remain in the 213-profile ledger. The current 15 November export reports 117 detected schemas, 58 source-option completeness reviews, 75 fixed-equipment reviews and zero option migrations pending. Full rules coverage, complete army legality, network/separate-machine integration, broader recovery and human usability remain open; the saved-equipment migrations close none of those plan-wide gates.

