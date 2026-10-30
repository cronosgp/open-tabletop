# Lazarus (Dark Angels App)

**Status:** source-bounded local scope passed on 28 October 2026. This closes the declared local scope for this Chapter datasheet; Dark Angels roster legality, network behavior and complete Space Marines army legality remain open.

## Source identity

- Wahapedia 11th-edition Dark Angels App datasheet `000002296`, source book `000000023`.
- Verified local Data Export row stamped `2026-10-21 16:06:23 GMT+3`.
- Runtime profile and ability mapping: [current_reference_marine_profiles.gd](../scripts/edition_11/current_reference_marine_profiles.gd) and [unit_ability_catalog.gd](../scripts/edition_11/unit_ability_catalog.gd); construction gate and price: [army_capabilities.gd](../scripts/edition_11/army_capabilities.gd).
- One model, 80 points, maximum one copy. Lazarus has M6, T5, Sv3+, W5, Ld6+, OC1, a 4+ invulnerable save and a 40 mm round base.
- Fixed loadout: Bolt Pistol and Enmity's Edge. The pistol is 12", A1, BS2+, S5, AP-1, D1, Close-quarters. Enmity's Edge is A6, WS2+, S6, AP-3, D2, Anti-Psyker 2+.

## Pinned export provenance

Verified snapshot `20261021T130623Z`, retrieved 21 October 2026 at `2026-10-21T19:46:58Z`. Raw export files remain ignored under `.tools/wahapedia/11e/space-marines/20261021T130623Z`. The source audit hashes below match the snapshot manifest.

| File | SHA-256 |
|---|---|
| `Datasheets.csv` | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| `Datasheets_models.csv` | `9cb303097f003f2eaa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| `Datasheets_unit_composition.csv` | `f00a66fedc7b1df1a5a3907f763561db75789e3db82a0bd1f6a059fc2061e245` |
| `Datasheets_models_cost.csv` | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| `Datasheets_options.csv` | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| `Datasheets_wargear.csv` | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |
| `Datasheets_abilities.csv` | `49b054afc2f9977b9c8168ee446b016bd097b047adbd7ec35d23df5f054d7fe6` |
| `Datasheets_keywords.csv` | `bdb2431dd3a24d34ec91e1aa1e7ddae9da3565faa18a56abcd8ead5247b4e341` |
| `Datasheets_leader.csv` | `af1d26d1d6188bb845777ad57aeb2a3c75e851c9a521b7c754b4607fa10abac4` |

## Checked local scope

- Exact source identity, export stamp, characteristics, invulnerable save, keywords, loadout, fixed weapons, 80-point catalog choice and one-copy EPIC HERO admission.
- Anti-Psyker 2+ now resolves through the shared attack path only against a PSYKER target; non-PSYKER attacks do not inherit the critical-wound threshold.
- Combat Doctrines and Transhuman Strategist registration; Lazarus can be selected as Warlord and receives its shared once-per-round CP effect.
- The Spiritshield Helm grants Feel No Pain 3+ against psychic attacks and mortal wounds to Lazarus and attached bodyguards; ordinary wounds are excluded.
- Intractable Will rolls before the unit fights in the Fight phase, retains a model on 4+, rejects an unmodified 3, and removes a retained model when its unit fights or the phase ends.
- Dark Angels Deathwing context and all seven source-listed Leader targets. The public attachment path is checked with Inner Circle Companions.

This does not certify full Dark Angels roster legality, complete Space Marines army legality, network behavior or human playtesting. The six non-ICC Leader targets are represented and admitted in the attachment catalog, but their individual public attachment flows are not all exercised by this scope.

## Verification

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_lazarus --only test_attack_sequence --only test_captain_titus --only test_inner_circle_companions --only test_asmodai --only test_chief_librarian_tigurius --timeout 300` passed **8/8 processes** at `.tools/verification/20261028T100238026258Z/results.json` (SHA-256 `4246119a7dc0ad9c103c287e9b45d3df62612aec42c17af5156c7f3034de448a`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics).

`python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_weapon_selection --timeout 300` passed **3/3 processes** at `.tools/verification/20261028T100308716157Z/results.json` (SHA-256 `4ad6240b98299a0c853c210f30f7db5f44d1f6fa4a36456ea8c2924c44587213`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics). The latter stages the existing legacy fixture because that suite explicitly exercises its historical selection path; it is not a current catalog source.

The [machine-readable record](marine-lazarus-audit.json) preserves the source and verification metadata. Network validation is deferred to final integration.
