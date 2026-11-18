# Indomitor Kill Team saved equipment — 15 November 2026

The Army Workshop now saves Indomitor Kill Team replacement weapons by stable model and copy. This closes the equipment-choice migration for the profile; it does not certify every Deathwatch rule, all army legality, network play, or sculpt parity.

## Source boundary

- Edition/mode: Warhammer 40,000 11th edition, standard army datasheet.
- Datasheet: Deathwatch App book `000000035`, datasheet `000002781`.
- Authority: verified local Wahapedia Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, retrieved `2026-10-30T01:33:48.347556+00:00`, revision `2026-10-28T23:48:19+03:00`.
- Parent manifest SHA-256: `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`.
- Deathwatch verified-against slice manifest SHA-256: `ed356b7d4a9c34085a53daab7dc08325429f4d754d7441ac6f6728920affb109`.
- Runtime source digest: `2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68`.
- Relevant export files and SHA-256: `Datasheets_options.csv` `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853`; `Datasheets_unit_composition.csv` `f00a66fedc7b1df1a5a3907f763561db75789e3db82a0bd1f6a059fc2061e245`; `Datasheets_models_cost.csv` `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e`; `Datasheets_wargear.csv` `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d`.

The older 21 October extraction in the existing [Indomitor audit](../marine-indomitor-kill-team-audit.json) remains historical evidence. This migration's source-review row binds separately to the 30 October verified-against parent and Deathwatch slice; the two provenance pairs are not mixed. No network lookup was needed to resolve these options.

## Saved choices and validation

The fixed ten-model roster is three Aggressors, three Eradicators and four Heavy Intercessors. The saved schema provides exactly the role-appropriate choice:

- Each Aggressor may replace Flamestorm Gauntlets with Auto Boltstorm Gauntlets and a Fragstorm Grenade Launcher.
- One Eradicator per unit may replace a Melta Rifle with a Multi-melta.
- One Heavy Intercessor per five starting models may replace a Deathwatch Heavy Bolt Rifle with a Deathwatch Heavy Bolter, so the ten-model unit allows two.

These options add no points. The existing 280-point first/second-copy and 300-point third-plus prices are unchanged. Whole-copy validation rejects wrong-role fields, more than two Heavy Bolters, more than one Multi-melta, unknown keys, wrong types, short records and unsupported model counts. Materialization uses the existing local weapon factory and locks the saved weapons against duplicate Army Preparation changes.

The Workshop shows ten scrollable model cards labelled by their source roles. Each card exposes only its eligible replacement. Stable IDs keep equal unit copies independent; role-specific defaults ensure each model starts with the correct saved field shape.

## Verification

The offline command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_indomitor_saved_equipment --only test_indomitor_kill_team --only test_army_builder --only test_implemented_catalog --only test_model_equipment_visuals --timeout 360
```

It passed **7/7 verifier processes** at `.tools/verification/20261115T174004175092Z/results.json` (SHA-256 `c225cbd28d4ceec6dcdfdaaa2309beb7cde2a81acf9211d0210541323f0a05b6`; network disabled; legacy starter staged). The new regression covers all three option families and limits, three distinct copies and prices, atomic rejection, separate-process disk reopen, both-player materialization, setup-lock suppression/rejection and live Workshop selectors/signals. The existing Indomitor source suite, Army Builder suite, implemented-catalog suite and model-visual suite also passed. The Army Builder process exited with 15 dummy-texture, 4 shaped-text, 2 advanced-font and 5 CanvasItem RIDs plus 82 ObjectDB instances reported at shutdown. The implemented-catalog process exited with 12 dummy-texture, 2 advanced-font and 2 CanvasItem RIDs plus 58 ObjectDB instances. Both processes passed; the diagnostics are preserved in their logs.

## Actual Workshop captures

Godot 4.7.2 Compatibility captures use a staged local army at 1280×800. The “before” capture shows the generic model row before per-role controls. The updated captures show Aggressor Auto Boltstorm, Eradicator Multi-melta and Heavy Intercessor Heavy Bolter selectors. Each updated image was inspected. The capture process exits 0 but reports 19 GLES texture RIDs, 2 advanced-font RIDs, 2 CanvasItems and 47 ObjectDB instances at shutdown; captures demonstrate visible controls at this viewport, not smaller-window usability.

| Capture | SHA-256 |
|---|---|
| `.tools/indomitor-equipment-20261115/before/indomitor-before-1280x800.png` | `af76f44c1d1ef110e35d244e3c543a6a487afd6be04e1f390b6f47bdd626f19e` |
| `.tools/indomitor-equipment-20261115/after/indomitor-after-1280x800.png` — Aggressors | `6a32a4aeaf3cf01df800539fa5d51b78db90ce667a24bc48afb525b17e126851` |
| `.tools/indomitor-equipment-20261115/after/indomitor-after-middle-1280x800.png` — Eradicators | `df5292419b8c31e4b23cd17383da75930641d1b32efe6a8fdee9c5ed90d45248` |
| `.tools/indomitor-equipment-20261115/after/indomitor-after-lower-1280x800.png` — Heavy Intercessors | `b08fe227a0d82a9a8b4a3739d7993082485fd1b71cf5db2162eb3b17e850ce47` |

Full army legality, all Deathwatch rules, network behavior, sculpt parity and the wider Army Builder/ForceOrg acceptance gates remain open.
