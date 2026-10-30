# Asmodai (Dark Angels App)

**Status:** source-bounded local scope passed on 28 October 2026. This closes the declared local scope for this Chapter datasheet; Dark Angels roster legality, network behavior and complete Space Marines army legality remain open.

## Source identity

- Wahapedia 11th-edition Dark Angels App datasheet `000000225`, source book `000000023`.
- Verified local Data Export row stamped `2026-10-21 16:06:23 GMT+3`.
- Runtime profile and ability mapping: [current_reference_marine_profiles.gd](../scripts/edition_11/current_reference_marine_profiles.gd) and [unit_ability_catalog.gd](../scripts/edition_11/unit_ability_catalog.gd); construction gate and price: [army_capabilities.gd](../scripts/edition_11/army_capabilities.gd).
- One model, 80 points, maximum one copy. Asmodai has M6, T5, Sv3+, W4, Ld5+, OC1, a 4+ invulnerable save and a 50 mm round base.
- Fixed loadout: Heavy Bolt Pistol and Crozius Arcanum and Power Weapon. The pistol is 18", A1, BS2+, S5, AP-1, D1, Close-quarters. The melee weapon has Strike (A5, WS2+, S6, AP-2, D2, Precision) and Sweep (A8, WS2+, S5, AP-2, D1, Cleave 1).

## Pinned export provenance

Verified snapshot `20261021T130623Z`, retrieved 21 October 2026 at `2026-10-21T19:46:58Z`. Raw export files remain ignored under `.tools/wahapedia/11e/space-marines/20261021T130623Z`. SHA-256 values below match the snapshot manifest.

| File | SHA-256 |
|---|---|
| `Datasheets.csv` | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| `Datasheets_models.csv` | `9cb303097f003f2eaa3bfc7cba8d3d7579b0364a35a139bafa5c0705bbd68d03` |
| `Datasheets_unit_composition.csv` | `f00a66fedc7b1df1a5a3907f763561db75789e3db82a0bd1f6a059fc2061e245` |
| `Datasheets_models_cost.csv` | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| `Datasheets_options.csv` | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| `Datasheets_wargear.csv` | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |
| `Datasheets_abilities.csv` | `49b054afc2f9977b9c8168ee446b016bd097b047adbd7ec35d23df5f054d7fe6` |
| `Datasheets_keywords.csv` | `bdb2431dd3a24d34ec91e1aa1e7ddae9da3565faa18a56abcd8ead5247b4e341` |
| `Datasheets_leader.csv` | `af1d26d1d6188bb845777ad57aeb2a3c75e851c9a521b7c754b4607fa10abac4` |

## Checked local scope

- Exact source identity, export stamp, characteristics, invulnerable save, source keywords, loadout, fixed weapons, 80-point construction choice and one-copy EPIC HERO admission.
- Combat Doctrines and Transhuman Strategist registration; Asmodai can be selected as Warlord and grants its shared once-per-round CP effect.
- Exemplar of Hate re-rolls failed melee Hit rolls for the attached unit through AttackPlan; the test checks that it does not grant ranged Hit re-rolls.
- Feared Interrogator opens at Fight-phase start for each enemy CHARACTER unit within 6 inches, applies -1 to its Battle-shock roll, preserves an existing Battle-shock condition on a pass, and allows the tested unit's controller to use an eligible Tempered in Battle reroll. The serialized decision blocks phase close until it is resolved.
- Dark Angels Deathwing keyword context, public attachment to Inner Circle Companions, all seven source-listed Leader targets, and current Leader-catalog registration.

All seven Leader endpoints in this source row resolve to available current runtime profiles. The scope does not certify full Dark Angels roster legality, complete Space Marines army legality, network behavior or human playtesting.

## Verification

`python tools/verify.py --godot 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --profile focused --only test_asmodai --only test_attack_sequence --only test_inner_circle_companions --only test_ravenwing_black_knights --only test_reiver_squad --only test_captain_current --only test_ancients --only test_space_marine_leader_links --only test_leader_catalog --only test_captain_on_bike --only test_outrider_squad_current --timeout 300` passed **13/13 processes** at `.tools/verification/20261028T094914926379Z/results.json` (SHA-256 `32295d1ddc045f220cb1e0abf8dc13120c599f4fa55960ba92e2f9100e15ce9b`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). This includes the profile, Leader and support-link checks, Warlord CP, weapon plans, full melee Hit rerolls including successful rolls, preservation of existing Battle-shock after a passing reroll, and regressions for related Dark Angels and shared-book profiles.

The [machine-readable record](marine-asmodai-audit.json) preserves the source and verification metadata. Network validation is deferred to final integration.
