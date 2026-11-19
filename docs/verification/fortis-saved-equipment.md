# Fortis Kill Team saved-equipment migration — 15 November 2026

## Scope

The Army Workshop now stores the five optional-equipment fields per model on a Fortis Kill Team copy. Saved equipment is checked on current local catalog admission, materialized through the existing Fortis weapon factory before Deployment, and locked against duplicate match-preparation edits. This is only the persistent-equipment migration. It does not add rules effects, change the unit composition, prices, or points, or certify complete Fortis rules or army legality.

## Source identity and provenance

The source review is for the Space Marines App book `000000035`, Fortis Kill Team datasheet `000002780`, edition 11. It is marked `verified_against` the project's verified local snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, parent manifest SHA-256 `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`. Its final retrieval bracket is `2026-10-30T01:33:48.347556+00:00`. The source review uses the existing runtime source/slice binding and digest continuity; it does not rewrite the Fortis profile's origin extraction snapshot (`20261021T130623Z`). No online source was consulted for this migration.

Relevant raw export files and SHA-256 hashes from the verified manifest:

| File | SHA-256 |
|---|---|
| `Datasheets.csv` | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| `Datasheets_options.csv` | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| `Datasheets_unit_composition.csv` | `f00a66fedc7b1df1a5a3907f763561db75789e3db82a0bd1f6a059fc2061e245` |
| `Datasheets_models_cost.csv` | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| `Datasheets_wargear.csv` | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |

The source-option registry record is in [the Army Builder source-review ledger](../project/army-builder-source-review.tsv). It names the five saved fields and marks this review as equipment-option completeness only.

## Roles, options, and unchanged prices

The fixed ten-model sequence is one Castellan Intercessor, one Sergeant, two Plasma Incinerator Intercessors, two Deathwatch Bolt Rifle Intercessors, two Heavy Bolt Pistol Intercessors, and two Pyreblaster Intercessors.

| Eligible bearer | Saved choice | Source limit / condition |
|---|---|---|
| Castellan | Superfrag Launcher, Superkrak Launcher, or Vengor Launcher | One unique Castellan |
| Sergeant | Chainsword, Power Fist, Power Weapon, or Thunder Hammer | Replaces the Sergeant's listed melee weapon |
| Sergeant | Deathwatch Bolt Rifle, Chainsword, Hand Flamer, Plasma Pistol, or Power Weapon | Replaces the Sergeant's listed ranged weapon; the Grenade Launcher option requires retaining the Deathwatch Bolt Rifle |
| Deathwatch Bolt Rifle Intercessor | Retain Deathwatch Bolt Rifle or take Astartes Grenade Launcher | At most one per five models; only this bearer role is eligible |
| Plasma Incinerator Intercessor | Retain Bolt Pistol or take Plasma Pistol | One per unit |

Grenade Launcher validation also applies to the Sergeant only while the Sergeant retains the Deathwatch Bolt Rifle. The local adapter creates the complete existing weapon package for each selected role rather than editing rendered text. Choices add no points. The catalog's existing first/second-copy 210-point cost and third-plus 225-point cost remain unchanged.

## Persistence and verification

Fields are `fortis_kill_team_rocket_launcher`, `fortis_kill_team_sergeant_melee`, `fortis_kill_team_sergeant_ranged`, `fortis_kill_team_grenade_launcher`, and `fortis_kill_team_plasma_pistol`. The adapter validates roles, legal enumerated choices, the unit-wide Plasma Pistol limit, the one-per-five Grenade Launcher limit and the Sergeant's retained-rifle condition. It retains stable model identity, applies the local profile factory during saved-match preparation for either player, and prevents repeating these Army Preparation choices in the locked match.

The final offline command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_fortis_saved_equipment --only test_fortis_kill_team --only test_apothecary --only test_army_builder --only test_implemented_catalog --only test_model_equipment_visuals --only test_saved_armies --only test_match_save --timeout 900
```

It passed **10/10 verifier processes** at `.tools/verification/20261115T192549640335Z/results.json` (SHA-256 `03605ca4a13a852dafbd30e7bbe95171f04057f866b86a7b1d9c77c19beb6140`; network disabled; legacy starter staged). The report includes the import and Python checks plus all eight selected suites. The saved-equipment test reported zero failures and covers source-field binding, roles/caps, factory output, independent copies/prices, saved persistence, both-player preparation, match locks and actual Workshop control signals. Existing Fortis rules, Apothecary attachment, Army Builder, catalog, model visuals, saved-army and match-save suites all passed. Army Builder, catalog, saved-army and match-save processes also emitted Godot headless RID/ObjectDB cleanup diagnostics at shutdown and exited successfully; the other six processes reported none.

## Actual Godot captures

The following are actual Godot Compatibility captures at 1280×800, not mockups. They show the role-specific selector states after the migration. The capture runs exited successfully; at shutdown each reported 19 GLES texture RIDs, 2 advanced-font RIDs, 2 CanvasItem RIDs and 47 ObjectDB instances. The captures do not establish small-window layout, keyboard/gamepad coverage, or human usability.

| Capture | SHA-256 | What it shows |
|---|---|---|
| `.tools/fortis-equipment-20261115/after/fortis-rocket-1280x800.png` | `f858b88f4eeeb62336be42d4a1d2a7a4652a834100e4b6dcdaf986057f4cc74e` | Castellan launcher selector |
| `.tools/fortis-equipment-20261115/after/fortis-sergeant-1280x800.png` | `c6717f3ab3bf4f4c6fcbb68d5a238857ba0723691822bf3e10bcb9e1ee7b16362` | Sergeant melee/ranged selectors and Grenade Launcher eligibility |
| `.tools/fortis-equipment-20261115/after/fortis-plasma-1280x800.png` | `6a50b11f1faa7b8b57cf3f2ee84d718df379b5e9aef560cb1983ec2f0f348799` | Plasma Incinerator model's Plasma Pistol selector |
| `.tools/fortis-equipment-20261115/after/fortis-grenade-1280x800.png` | `1d5ddee3560cc34a9c556f84e4ae092da37b2dc77f0df0a33a67e81fd2a1e11d` | Both eligible Deathwatch Bolt Rifle model cards |

The no-schema option migration queue is now empty; the final Talonstrike migration is recorded in the [Talonstrike evidence](talonstrike-saved-equipment.md). Fifty-nine other detected saved schemas still need source-option completeness review; stale and unclassified ledger records remain unresolved. Full rules coverage, official army legality, network/multi-machine integration, wider recovery, and representative human usability remain open. Passing this profile's tests does not close those gates.
