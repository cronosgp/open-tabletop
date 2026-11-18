# Crusader Squad saved equipment — 15 November 2026

The Army Workshop now saves Crusader Squad weapon choices for each stable model and unit copy. This completes the saved-equipment choice path for this profile; Crusader rules and army legality remain partial.

## Source boundary

- Edition/mode: Warhammer 40,000 11th edition, standard Black Templars App datasheet.
- Source book/datasheet: `000000162` / `000002799`.
- Authority: verified local Wahapedia Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, retrieved `2026-10-30T01:33:48.347556+00:00`, revision `2026-10-28T23:48:19+03:00`.
- Parent manifest SHA-256: `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`.
- Crusader subject-slice manifest SHA-256: `c826abb55add7cc48814b3df865546da059e17f311a62fc581092c2d43aa1bc8`.
- Crusader slice catalog SHA-256: `eb00c58cec9995d72716d20ac606067cb82d7762693fccdd79cd7357e84e58ef`.
- Runtime source digest: `2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68`.
- Relevant raw export file hashes: `Datasheets_options.csv` `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853`; `Datasheets_unit_composition.csv` `f00a66fedc7b1df1a5a3907f763561db75789e3db82a0bd1f6a059fc2061e245`; `Datasheets_models_cost.csv` `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e`; `Datasheets_wargear.csv` `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d`.

The local source lists four equipment-option rows and a fixed role sequence at both supported sizes. No network lookup was needed. The existing [Crusader datasheet audit](../marine-crusader-squad.md) records the separate official MFM comparison: the runtime keeps Wahapedia's 160/305-point values, while MFM v1.0 lists 150/290. The runtime totals are not certified for events using those MFM prices.

## Saved choices and validation

The 10-model unit contains one Sword Brother, four Neophytes and five Initiates. The 20-model unit contains one Sword Brother, eight Neophytes and eleven Initiates. Each model card is named by its source role.

- The Sword Brother may replace the Heavy Bolt Pistol with a Hand Flamer.
- Any Neophyte may replace the Bolt Pistol and Neophyte Chainsword with a Shotgun and Combat Knife.
- Any Initiate may replace the Bolt Rifle with a Heavy Bolt Pistol and Initiate Chainsword.
- For every ten models, up to two Initiates may instead take a Heavy Bolt Pistol and Power Fist or a Pyreblaster. The shared cap is two for ten models and four for twenty.

These choices add no points. The saved field reuses the existing local Crusader weapon factory. Whole-unit validation rejects wrong-role options, mixed-cap overflow, unknown IDs, wrong value types, short records and unsupported sizes. Stable model and copy IDs keep selections independent. Prepared matches install the saved weapons and suppress/reject the older duplicate Army Preparation choices.

## Verification

The offline command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_crusader_saved_equipment --only test_crusader_squad --only test_fist_god_emperor --only test_army_builder --only test_implemented_catalog --only test_model_equipment_visuals --timeout 900
```

It passed **8/8 verifier processes** at `.tools/verification/20261115T175549767382Z/results.json` (SHA-256 `582693809ea0c36345c022ba570c9eec603e78f5bc1ea246bcab10e7a947fe2d`; network disabled; legacy starter staged). It covered 10/20-model role defaults, all choices and caps, unchanged source costs, three independent copies, atomic rejection, separate-process save/reopen, both-player materialization, duplicate-action suppression/rejection and live Workshop selectors. The existing Crusader, Fist of the God-Emperor, Army Builder, implemented-catalog and model-visual suites also passed. Army Builder and implemented catalog exited successfully with shutdown RID/ObjectDB cleanup diagnostics; their logs are in the report directory.

## Actual Workshop captures

Godot 4.7.2 Compatibility captures show the scrollable 20-model Workshop at 1280×800. Each capture process exited 0 and reported 19 GLES texture RIDs, 2 advanced-font RIDs, 2 CanvasItems and 47 ObjectDB instances at shutdown. The captures show visible controls at this viewport; they do not establish smaller-window usability.

| Capture | SHA-256 |
|---|---|
| `.tools/crusader-equipment-20261115/after/crusader-top-1280x800.png` — Sword Brother Hand Flamer and first Neophyte | `0ffa3d88270f0838226ce3ac3b46e50cf0104063a9365c07f2e296d02fb39503` |
| `.tools/crusader-equipment-20261115/after/crusader-middle-1280x800.png` — Initiate Power Fist and Pyreblaster | `c5c05056ef3bf49b27f0d68190c6cb89d64eac8cb1258df55873c4fbf3e0a486` |
| `.tools/crusader-equipment-20261115/after/crusader-lower-1280x800.png` — later Initiate cards | `168cea5331900ea4616746ab3f338d7805d6bcecdfbbb06feac5814ecc420c57` |

Crusader Squad remains partial because its Righteous Zeal/Purge and Sanctify movement route candidates and whole-formation placement proofs are bounded. Current event-cost reconciliation, full Black Templars army legality, network behavior, human playtesting and wider Army Builder acceptance gates remain open.
