# Land Speeder Vengeance (Dark Angels App)

**Status:** source-bounded local scope passed on 28 October 2026. This is one Chapter-book profile and does not establish full Dark Angels or Space Marines army legality.

## Source identity

- Wahapedia 11th-edition Dark Angels App datasheet `000000242`, source book `000000023`.
- Local verified Data Export row stamped `2026-10-21T16:06:23+03:00`.
- Runtime profile: [current_reference_marine_profiles.gd](../scripts/edition_11/current_reference_marine_profiles.gd); construction gate and copy limit: [army_capabilities.gd](../scripts/edition_11/army_capabilities.gd).
- The local source facts include the one-model profile, 150-point first/second-copy price, 160-point third-plus price, and the exported weapon configuration.

## Pinned export provenance

Verified local snapshot `20261021T130623Z`, retrieved 21 October 2026 at `2026-10-21T19:46:58Z`. The raw files remain ignored under `.tools/wahapedia/11e/space-marines/20261021T130623Z`; the listed SHA-256 values are recorded in that snapshot's manifest.

| File | SHA-256 |
|---|---|
| `Datasheets.csv` | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| `Datasheets_models.csv` | `9cb303097f003f2eaa3bfc7cba8d3d7579b0364a35a139bafa5c0705bbd68d03` |
| `Datasheets_options.csv` | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| `Datasheets_wargear.csv` | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |
| `Datasheets_models_cost.csv` | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| `Datasheets_abilities.csv` | `49b054afc2f9977b9c8168ee446b016bd097b047adbd7ec35d23df5f054d7fe6` |
| `Datasheets_keywords.csv` | `bdb2431dd3a24d34ec91e1aa1e7ddae9da3565faa18a56abcd8ead5247b4e341` |

## Checked local scope

- Source identity, export stamp, profile facts, weapon profiles and Assault Cannon option.
- Local catalog visibility, copy-price tiers, repetition ceiling and source-restricted Nightforged Battery eligibility under Darkflight Pursuit.
- Deep Strike and Combat Doctrines mapping, including current reserve eligibility. Storm of Vengeance triggers after an enemy Shooting activation destroys a friendly Dark Angels unit within 6 inches; the destroyed unit retains its source keywords for the trigger check.
- Correct defending player, binding the response to the attacking enemy, rejecting other targets without state mutation, sequential reactions by two eligible Vengeance units, and declining the second response.
- Deadly Demise D3 does not trigger on a 5, triggers on a 6, and creates one mortal-wound packet for a unit within 6 inches; the outside unit is excluded. Nightforged Battery's random Attack-characteristic reroll and one-time Hazard reroll preserve attack continuation.

## Verification

`python tools/verify.py --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_land_speeder_vengeance --timeout 300` passed **3/3 processes** at `.tools/verification/20261028T085143396826Z/results.json` (SHA-256 `cafc7aec5a07dd9bc4f02143ffd31e58b71dea6fa91b8861a9cb4ac65d2abe2d`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics).

The focused checks exposed and fixed two runtime issues: Dark Angels keywords were unavailable after the last model in a unit was destroyed, and the Nightforged Attack reroll did not enter the serialized attack-allocation path. Network validation, full Chapter roster restrictions and broader army legality remain open.
