# Vanguard Veteran saved equipment — 15 November 2026

## Source boundary

Both profiles were checked against the local, verified Wahapedia 11th-edition Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, on the selected Space Marines App data. The slice review records retrieval at `2026-10-30T01:33:48.347556Z`, export revision `2026-10-28T23:48:19+03:00`, manifest SHA-256 `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`, and runtime Space Marines source digest `2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68`.

| Profile | App book | Datasheet | Source options covered |
|---|---:|---:|---|
| Vanguard Veteran Squad (Warhammer Legends) | `000000356` | `000001154` | Any model can replace its Bolt Pistol with a Storm Shield or one listed pistol: Grav-pistol, Hand Flamer, Inferno Pistol or Plasma Pistol. |
| Vanguard Veteran Squad With Jump Packs | `000000139` | `000000147` | Sergeant Heavy Bolt Pistol to Plasma Pistol; Sergeant Relic Blade to Power Fist or Thunder Hammer; any model may replace its Heavy Bolt Pistol with a Combat Shield; up to two ordinary models per five may replace Heavy Bolt Pistols with Plasma Pistols. |

The local files used for this equipment audit have these SHA-256 hashes:

- `Datasheets_options.csv`: `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853`
- `Datasheets_models_cost.csv`: `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e`
- `Datasheets_wargear.csv`: `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d`

Both datasheets retain their source base costs without an equipment surcharge. The Legends squad costs 120/240 points at five/ten models. Jump Pack squads cost 110/220 for the first two copies and 130/240 for the third and later copies at five/ten models, respectively. The existing Army Builder copy-tier prices are preserved.

## Saved behavior

The Workshop stores each choice against the stable model ID. Validation checks complete 5/10-model records, the Sergeant's distinct Jump Pack options, fixed ordinary melee and the whole-unit ordinary Plasma limit (two per five). Equipment resolves only through the corresponding local Marine profile factory. Saved options are applied when building a match, before Deployment, and their equipment actions are hidden or rejected without mutating the match. A Legends Storm Shield gives only its bearer the local 4+ invulnerable save; a Jump Pack Combat Shield gives only its bearer the local 5+ invulnerable save. Existing in-match Plasma and combat decisions remain separate from the saved starting equipment.

The focused fixture checks source factories and caps, individual choices across multiple copies, first-two/third-plus totals (1,040 points for the fixture army), separate-process disk reopen, current-catalog admission, prepared weapons and saves for every materialized model, setup locks, and Army Builder control signals. The Jump Pack Workshop uses scrollable cards with each model name above its pistol/shield and melee selectors; ordinary models show the fixed Master-crafted Power Weapon disabled. The Legends selector stays in a single readable row per model.

## Verification

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_vanguard_saved_equipment --only test_vanguard_veterans --only test_vanguard_veteran_squad_legends --only test_deathwatch_saved_loadouts --only test_deathwatch_terminator_squad --only test_deathwatch_veterans --only test_terminator_saved_loadouts --only test_deathwing_saved_loadouts --only test_specialist_squad_saved_loadouts --only test_model_equipment_visuals --only test_army_builder --only test_implemented_catalog --timeout 300
& .tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tools/export_army_builder_coverage.gd -- --output .tools/army-builder-coverage.json
python tools/render_army_builder_coverage.py --input .tools/army-builder-coverage.json --output docs/project
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

The verifier passed **14/14 processes** at `.tools/verification/20261115T062111845814Z/results.json`, SHA-256 `9f2416bb7390f1c4260e18aaeebab5317a17710373f04c9e0e8a00d3b3c9ad33`. It ran with `network: false` and staged the historical starter; network validation was not attempted. The six Python ledger tests passed. Army Builder and implemented-catalog processes exited successfully but retain cleanup diagnostics: Army Builder reported 15 dummy Texture RIDs, 4 ShapedTextAdvanced RIDs, 2 FontAdvanced RIDs, 5 CanvasItem RIDs and 82 ObjectDB instances; the catalog reported 12 dummy Texture RIDs, 2 FontAdvanced RIDs, 2 CanvasItem RIDs and 58 ObjectDB instances.

Two actual Godot Compatibility runtime captures at 1280×800 were inspected from the staged project: `.tools/vanguard-equipment-20261115/after/vanguard-veteran-squad-saved-1280x800.png` and `.tools/vanguard-equipment-20261115/after/vanguard-veteran-squad-with-jump-packs-saved-1280x800.png`. The capture harness exited 0 and records the selected model choices in `observations.json`; its shutdown log also reports Texture RID and 55 ObjectDB cleanup diagnostics. These are scripted staged captures, not a human usability review or small-window evidence. Captures remain in the gitignored `.tools` directory.

The refreshed coverage ledger contains 213 admitted profiles, 107 detected schemas (48 with explicit source-option completeness reviews), 75 current fixed-equipment reviews, 10 option-bearing profiles awaiting migration, 12 stale source reviews, 9 unclassified profiles and 59 schemas still needing option-completeness review. All 12 stale and 9 unclassified rows remain open; this migration does not certify complete rules, full army legality, every sculpt, network play or the remaining plan gates.
