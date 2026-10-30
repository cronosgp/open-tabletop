# Ravenwing Black Knights (Dark Angels App)

**Status:** source-bounded local scope passed on 28 October 2026. This closes one Chapter-book datasheet's declared local scope; Dark Angels roster legality, network behavior and complete Space Marines army legality remain open.

## Source identity

- Wahapedia 11th-edition Dark Angels App datasheet `000000241`, source book `000000023`.
- Verified local Data Export row stamped `2026-10-21 16:06:23 GMT+3`.
- Runtime profile and ability mapping: [current_reference_marine_profiles.gd](../scripts/edition_11/current_reference_marine_profiles.gd) and [unit_ability_catalog.gd](../scripts/edition_11/unit_ability_catalog.gd); construction gate and price tiers: [army_capabilities.gd](../scripts/edition_11/army_capabilities.gd).
- The profile supports the Huntmaster plus 2–5 Black Knights, for 3 or 6 models. First and second copies cost 85/170 points; third-plus copies cost 95/180 points. Each model has a Bolt Pistol, Plasma Talon and Corvus Hammers by default. One model per three may replace its Plasma Talon with a free Grenade Launcher.
- The 75 × 42 mm oval base is represented by a clearly labelled 37.5 mm bounding-circle proxy for local placement.

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

- Source identity, snapshot stamp, model characteristics, all source keywords, composition, copy-price tiers and the oval collision proxy.
- All fixed Bolt Pistol, Plasma Talon, Corvus Hammers and Grenade Launcher profile fields and traits, routed through Equipment and AttackPlan.
- Current catalog visibility, both model counts, third-copy pricing, the standard three-copy limit and materialization for both players.
- The reversible free Grenade Launcher option, one-per-three quota, wrong-owner rejection and unchanged points.
- Combat Doctrines and Knights of Caliban. A unit without a Charge move does not gain Anti traits; after a Charge move, its Corvus Hammers carry Anti-MONSTER 4+ and Anti-VEHICLE 4+ in the actual melee AttackPlan.
- Captain on Bike and Chaplain on Bike Leader links include Black Knights and preserve their existing Outrider Squad links.

The source also lists Sammael and Ravenwing Command Squad as Leaders for this unit. Their profiles remain outside the runtime catalog, so those two relations are intentionally not selectable yet. Full Dark Angels Chapter roster rules are also outside this sheet-level check.

## Verification

`python tools/verify.py --godot 'C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe' --profile focused --only test_ravenwing_black_knights --only test_captain_on_bike --only test_outrider_squad_current --timeout 300` passed **5/5 processes** at `.tools/verification/20261028T091330361383Z/results.json` (SHA-256 `8b74375d8f95fae875f78bda94b58bd0d6a92ff6da49e5cb3ed9ce5625d8f242`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). Alongside this sheet's complete local scope, the run confirms Captain on Bike and Outrider behavior still pass with the Chapter Leader links active. The detailed machine-readable record is [marine-ravenwing-black-knights-audit.json](marine-ravenwing-black-knights-audit.json).

Network validation is deferred to final integration. This result does not certify full Chapter roster legality or complete Space Marines army legality.
