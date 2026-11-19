# Talonstrike Kill Team saved-equipment migration — 15 November 2026

## Scope

The Army Workshop now saves each Talonstrike Kill Team model's source-listed equipment choices per stable army copy and model ID. Local admission validates role restrictions and the per-five-model Plasma Pistol allowance; match preparation applies the saved selections through the existing Talonstrike factory and locks duplicate setup edits. The fixed ten-model composition, three-copy cap, 280/280/300-point prices, datasheet abilities and attachment rules are unchanged. This migration covers saved equipment only; it does not certify the full datasheet or army legality.

## Source identity and provenance

The reviewed source is Warhammer 40,000 11th edition, Space Marines App book `000000035`, Talonstrike Kill Team datasheet `000003874`. The review uses the verified local snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, retrieved in a timestamp bracket ending `2026-10-30T01:33:48.347556+00:00`; its parent manifest SHA-256 is `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`. The runtime profile retains its original extraction snapshot `20261029T072022Z` and manifest `772952e313b6772022c68226514eba7cdde00464468fd79c8291d20c24da4801`; runtime source digest continuity is `2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68`. The verified-against local Talonstrike slice manifest is `ed356b7d4a9c34085a53daab7dc08325429f4d754d7441ac6f6728920affb109`. The source-review registry binds this review to the runtime digest and exact saved fields without rewriting the original extraction metadata. No online source was consulted.

The following unmodified raw files in the verified parent export were checked by SHA-256:

| File | SHA-256 |
|---|---|
| `Datasheets.csv` | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| `Datasheets_options.csv` | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| `Datasheets_unit_composition.csv` | `f00a66fedc7b1df1a5a3907f763561db75789e3db82a0bd1f6a059fc2061e245` |
| `Datasheets_models_cost.csv` | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| `Datasheets_wargear.csv` | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |

The exact exported composition is one Sergeant, four Heavy Intercessors and five Intercessors. Its four option rows state:

1. The Sergeant may replace its Chainsword with a Power Fist or Power Weapon.
2. The Sergeant may replace its Heavy Bolt Pistol with a Hand Flamer or Plasma Pistol.
3. For every five models, one Intercessor may replace its Heavy Bolt Pistol with a Plasma Pistol. In this fixed ten-model unit, up to two eligible Intercessors may make that replacement.
4. Any number of Heavy Intercessors may each replace their Assault Bolters with Plasma Exterminators.

## Saved model records

The shared adapter records the exact existing fields `talonstrike_sergeant_melee`, `talonstrike_sergeant_ranged`, `talonstrike_intercessor_plasma_pistol` and `talonstrike_plasma_exterminator`. Role validation rejects those fields on ineligible models. Whole-unit validation allows at most two Intercessor Plasma Pistols per ten models and allows all four Heavy Intercessors to take Plasma Exterminators. Saved choices are materialized through `talonstrike_kill_team_model_loadout`; optional equipment adds no points.

The Army Workshop presents a separate card for each of the ten models. The Sergeant card shows its melee and ranged choices together; each Heavy Intercessor and Intercessor card shows only that role's own choice. Existing preparation commands remain available to older/in-flight unit records without the saved-equipment lock. A saved record suppresses those duplicate prompts and rejects a forced edit without mutating match state.

## Verification

The final offline command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_talonstrike_saved_equipment --only test_talonstrike_kill_team --timeout 900
```

It passed **4/4 verifier processes** at `.tools/verification/20261115T205105179047Z/results.json` (SHA-256 `26ed5a8ac4c81ae7c1a13154532c1a17224a1792759d6d2b6974b6ff07b80c36`; network disabled; legacy starter staged). The new suite checks exported option metadata, fixed role sequence, strict field/type validation, source caps, zero equipment surcharge, unchanged copy-tier totals, independent copy records, separate-process reopen, exact materialization for both players, duplicate-choice suppression, forced-edit rejection, live Workshop controls and isolation from later source-army edits. The existing Talonstrike rules regression also passed. The batch reported no headless RID/ObjectDB cleanup diagnostics.

## Actual Workshop captures

These are actual 1280×800 captures from the Godot 4.7.2 stable windowed app using the Compatibility renderer. Each shows the current Army Workshop and its Talonstrike model cards; they are not mockups.

| Capture | SHA-256 | Visible choice |
|---|---|---|
| `.tools/talonstrike-equipment-20261115/after/talonstrike-sergeant-1280x800.png` | `c4fd38523eec67e7b2b9833ff1f7efe42be5f62fbe3a47e87b5f9ff2a0b83f23` | Sergeant Power Fist and Hand Flamer selectors |
| `.tools/talonstrike-equipment-20261115/after/talonstrike-heavy-1280x800.png` | `8982b1831cf60d8e43e346e38548c1b73ab934ce97ad3f9ae41d58dbfa159f9a` | Heavy Intercessor Plasma Exterminators selector |
| `.tools/talonstrike-equipment-20261115/after/talonstrike-intercessor-1280x800.png` | `56839d732096fc79c83e9cd7b5c3f6a794d8513a833ee8a1970246a681b1bfec` | Intercessor Plasma Pistol selector and per-five-model label |

The captures confirm the selectors fit at this desktop viewport and the selected values are visible. They do not establish small-window layout, keyboard/gamepad coverage or human usability.

## Remaining plan work

Talonstrike clears the last catalog-derived option migration without a saved schema. The current 213-profile ledger now reports 117 detected schemas, 58 source-option completeness reviews, zero option migrations, 75 fixed-equipment reviews, 12 stale source reviews, 9 unclassified profiles and 59 other schemas still needing option-completeness review. Full plan completion still requires those remaining reviews and the broader visual, readiness, restart/recovery, separate-machine and human-usability gates. This migration does not close those claims.
