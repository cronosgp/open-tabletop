# Saved mixed Space Wolves equipment — 14 November 2026

Wolf Scouts and Wolf Guard Headtakers now persist source-listed equipment per stable model and copy. The Workshop distinguishes Pack Leaders, ordinary Scouts, Headtakers and Hunting Wolves. Canonical admission validates the complete unit record, materialization applies role-specific weapons and characteristics before Deployment, and readiness rejects repeated equipment setup. Appearance sharing includes the model role, including the existing Bladeguard Sergeant distinction.

## Source and bounded scope

Authority: `.tools/wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z/`, snapshot of the same name, revision `2026-10-28T23:48:19+03:00`, specification `20260817b`, final retrieval bracket `2026-10-30T01:33:48.347556+00:00`. All 22 CSV hashes were rechecked. Both profiles are Space Wolves App book `000000036`, common 40K context; alternate modes are not certified. No online lookup was needed.

| File | SHA-256 |
|---|---|
| manifest.json | `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e` |
| Datasheets.csv | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| Source.csv | `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9` |
| Datasheets_options.csv | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| Datasheets_models_cost.csv | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| Datasheets_wargear.csv | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |

The runtime Marine digest remains `2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68`; verified-against Space Wolves slice hash remains `427316a1e2d42a21e90b0937d1792d92dcd0f6d6a3a3eed8775c21f52af64327`. Extraction provenance is preserved separately.

- Wolf Guard Headtakers (`000004131`): existing six-model 3+3 and twelve-model 6+6 mixes only, with the runtime composition's exact role order. Each Headtaker may replace paired power weapons with one power weapon and Storm Shield; Heavy Bolt Pistol retained. Shield gives only its bearer 4+ invulnerable and does not add Wounds. Wolves retain Teeth and Claws. All equipment is free. Existing costs remain 115/230 for copies 1–2 and 125/240 afterward. This does not resolve or admit other source mixes or re-certify the earlier duplicate six-model price resolution. See [existing partial composition boundary](../marine-wolf-guard-headtakers.md).
- Wolf Scouts (`000004182`): six/twelve models, one Pack Leader, one/two Hunting Wolves and four/nine Scouts. Leader has fixed Plasma Pistol and Power Weapon; wolves have fixed Teeth and Claws. Ordinary Scouts default to Plasma Pistol and Combat Knife. At most one Scout collectively replaces both with Bolt Pistol, Runic Stave or Thunderclap. One Plasma Gun per unit and one Instigator Bolt Carbine per twelve models replace the pistol and retain the knife. One Haywire Mine may be carried only by a model retaining a Plasma Pistol, including the Pack Leader. Costs remain 95/190 for copies 1–2 and 105/200 afterward, with free equipment.

The existing source weapon factories are reused. Mine use, quarry declarations and Let Loose the Wolves remain match actions; their equipment-carrier configuration is saved. Selections without saved records retain the legacy preparation route. Old Headtaker records without an explicit composition remain part of the broader legacy compatibility review; the new integration fixture supplies the same explicit composition as the Workshop.

Two exact-field reviews bring the ledger to 92 detected schemas, 33 explicit source-option completeness reviews, 87 fixed profiles and 25 migrations pending. The other 59 schemas still require completeness review. These counts do not certify all rules or full army legality.

## Checks and findings

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_mixed_space_wolves_saved_loadouts --only test_wolf_scouts --only test_wolf_guard_headtakers --timeout 300
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_mixed_space_wolves_saved_loadouts --only test_wolf_scouts --only test_wolf_guard_headtakers --only test_squad_specialist_saved_loadouts --only test_model_equipment_visuals --only test_implemented_catalog --timeout 300
python -m unittest discover -s tests -p test_army_builder_coverage.py
```

The first report, `.tools/verification/20261114T152956766873Z/results.json`, failed 2/5 processes. Its SHA-256 is `9daf01d47133d29dcc983902982c192e23a6ef2c0927736fde7fe2049bf68788`. The new fixture omitted the Headtaker composition ID needed for stable canonical mapping. The old Wolf Scouts test assumed first-two prices for all three units; the verified source and existing canonical pricing require a third-copy premium. The fixture now supplies its explicit admitted composition; the old test checks each actual tier and a 390-point Scout subtotal. Runtime pricing was not changed.

The final report, `.tools/verification/20261114T153240545996Z/results.json`, passed 8/8 processes. SHA-256: `6bf1dbecc4a0e808eb38cfa603a8dffcc6d51c5101c6cef707f827138b6684f4`. Import, Python and all six selected Godot suites passed; the catalog reported renderer/ObjectDB cleanup diagnostics. Network checks were disabled and the historical starter was staged by the verifier. This is not a network/source-certification result.

The new matrix covers all 4,160 six/twelve-model Headtaker shield distributions, with 8/64 legal outcomes. Scout checks cover every individual role/package/mine combination at both sizes and duplicate special/plasma/carbine/mine caps. They are not an exhaustive twelve-model Scout distribution matrix. Integration saves a four-entry/six-unit army totaling 860 points, reopens it in another Godot process, maps stable model identities and materializes it for both players. Checks compare exact source inventories, shield saves and Wounds, assert canonical/materialized point parity, preserve the whole state on forced locked actions, exercise the live mine-bearer lookup and Headtaker split, and inspect native fixed-role selectors and actual appearance-similarity filtering. The equipment-ledger Python suite passed 6 tests.

## Actual Godot capture review

Player goal: assign reusable equipment to the correct model, retain source role limits and enter a match without repeating those assignments. Existing native selectors, gold/black theme, per-copy identity and save footer are retained. Fixed role selectors are disabled. Invalid edits are rejected without changing the draft. Appearance sharing keeps leaders, ordinary models and wolves separate; visuals do not change rules.

Captures were rendered by Godot 4.7.2 Compatibility at 1280×800 with isolated user-data paths and no model downloads. Before uses stage `20261114T150852426899Z`; after uses `20261114T152956766873Z` (same runtime UI as the corrected test stage). Both capture processes exited 0. Godot reported renderer/ObjectDB cleanup diagnostics; capture success is not a clean-shutdown claim. These are real Workshop captures, not mockups or exact sculpt evidence.

Ignored evidence folder: `.tools/mixed-space-wolves-equipment-20261114/`, including `capture_equipment.gd`, `run_capture.py`, process results, logs and observations. Before captures show the former unit controls without these per-model equipment rows. After captures show fixed wolf weapons, free Headtaker shield replacement, the Pack Leader's fixed weapons and equipped mine, and a Scout's Runic Stave. Top/bottom captures show different subsets of the scrolling six-model rows; twelve-model visual/input review remains open.

![Headtaker and wolf roles](../../.tools/mixed-space-wolves-equipment-20261114/after/wolf-guard-headtakers-after-top-1280x800.png)

![Scout leader, wolf and specialist](../../.tools/mixed-space-wolves-equipment-20261114/after/wolf-scouts-after-top-1280x800.png)

Original plan gates remain open: remaining equipment migrations and completeness reviews, broader legacy/recovery/gallery cases, human review, and unequal-cache separate-machine LAN. No network or platform coverage is inferred from these local checks.
