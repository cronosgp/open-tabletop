# Decimus Kill Team saved equipment — 15 November 2026

The Army Workshop now stores the source-listed Decimus equipment choices by stable model and unit copy. This completes saved equipment for the admitted ten-model configuration only; composition, points-source, full-rules and army-legality boundaries remain open.

## Local source boundary

- Edition/mode: Warhammer 40,000 11th edition, standard Deathwatch App datasheet; alternate modes are not included.
- Book/datasheet: `000000035` / `000004175`.
- Authority: verified local Wahapedia Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, retrieved `2026-10-30T01:33:48.347556+00:00`, revision `2026-10-28T23:48:19+03:00`.
- Parent manifest SHA-256: `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`.
- Decimus slice manifest SHA-256: `b258edd148a8b4f1dcb1dd174721c132b8337e6533b8aea597871dd96cd1aa88`.
- Decimus slice catalog SHA-256: `b57f6491ead33f53178f92da0260744367eecf3ba2523b5348c246f8fe0e72fd`.
- Runtime profile source digest: `2ccdd7fecb2d18b5e3be87712c0823ca301caf3afa970610cc9e185bb36a5d68`.
- Relevant raw export SHA-256: `Datasheets_options.csv` `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853`; `Datasheets_unit_composition.csv` `f00a66fedc7b1df1a5a3907f763561db75789e3db82a0bd1f6a059fc2061e245`; `Datasheets_models_cost.csv` `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e`; `Datasheets_wargear.csv` `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d`.

The ten-model roster has a Xenophase Veteran, Sergeant and two models from each of four specialist roles. The source lists three option groups, each one model per five: a Gravis Veteran can replace its Infernus Heavy Bolter with a Frag Cannon or Hellstorm Bolt Rifle plus Grenade Launcher; a Heavy Veteran can replace its Heavy Thunder Hammer with a Power Weapon and Storm Shield; a Stalker Veteran can replace its Stalker Bolt Rifle with a Plasma Incinerator. These choices add no points. The Storm Shield's 4+ invulnerable save is attached only to its bearer.

Only the source-compatible ten-model composition is selectable. The export also lists five models at 110 points, but its six required roles need at least six models; that construction/preparation blocker remains intact. Runtime keeps the selected Wahapedia 210-point ten-model price. The existing 30 October current-page/MFM cross-check records 190 points in MFM v1.0; this migration did not refresh that comparison or certify event costs.

No online source lookup was needed for this equipment transfer: the verified local export and profile factory contained the option rows, role composition and weapons. This audit does not certify Decimus abilities, all Leader interactions, Deathwatch rules, complete army legality or event eligibility.

## Saved schema and verification

Model-scoped records use `decimus_gravis_weapon`, `decimus_storm_shield` and `decimus_plasma_incinerator` only on their respective roles; the fixed Xenophase, Sergeant and Marksman records remain empty. Whole-unit validation enforces the three per-five caps and exact role order. The Army Workshop applies the existing Decimus local factory before Deployment, preserves stable copy/model IDs, applies the shield benefit only to its bearer and suppresses/rejects the duplicate Army Preparation changes. The five-model composition and points are not changed.

Final focused command:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_decimus_saved_equipment --only test_decimus_kill_team --only test_apothecary --only test_army_builder --only test_implemented_catalog --only test_model_equipment_visuals --timeout 900
```

It passed **8/8 verifier processes** at `.tools/verification/20261115T185617124231Z/results.json` (SHA-256 `56e8ddd0004575e9d3b2b65f93012dfa1169ed1e31287a68e6cfc7df0a2046aa`; network disabled; legacy starter staged). The new regression covers source roles/options, per-five caps, wrong-role/type rejection, unchanged points, three independent copies, whole-list validation, separate-process save/reopen, both-player materialization, bearer defense, match locks and real Workshop selectors. The existing Decimus rules suite, Apothecary attachment, Army Builder, implemented catalog and model-visual suites also passed. Army Builder and implemented catalog reported shutdown RID/ObjectDB cleanup diagnostics and exited successfully.

An earlier wider adjacent run, `.tools/verification/20261115T183553260342Z/results.json`, also passed the Decimus, attachment, Army Builder, catalog and model-visual suites but failed `test_marine_category_copy_limits` on missing Necron copy-limit profiles `necron-warriors`, `immortals`, `royal-warden` and `overlord`. The final bounded Decimus regression excludes that independent failure; it is not counted as passed or resolved by this change.

## Actual Workshop captures

Godot 4.7.2 Compatibility captures were reviewed at 1280×800. They show two model cards at a time inside the inspector scroll area. They establish visible role labels and controls at this viewport only; they do not establish smaller-window usability or gamepad interaction. Each capture process exited 0 and reported 19 GLES texture RIDs, two advanced-font RIDs, two CanvasItems and 47 ObjectDB instances at shutdown.

| Capture | SHA-256 |
|---|---|
| `.tools/decimus-equipment-20261115/after/decimus-heavy-1280x800.png` — both Heavy Veteran cards, including the bearer Storm Shield choice | `fa2064866b90cb3487bcdcf60c311c16178f76dc7d8bd41b52d0886b0d7dd6e2` |
| `.tools/decimus-equipment-20261115/after/decimus-stalker-1280x800.png` — Stalker Veteran Plasma Incinerator and default cards | `69d4bc4cf2377026d9f6498ef6d944198c229371361a32accca342e3b7ae4c77c` |
| `.tools/decimus-equipment-20261115/after/decimus-gravis-1280x800.png` — Frag Cannon and Hellstorm replacement cards | `b0d88a11abb7353ca1aa92fcd70bca8d4b8234f3a47481b7e4c8a7a0867c75bf` |

The refreshed 213-profile ledger now reports 114 saved equipment schemas, 55 explicit source-option reviews, 75 fixed-equipment reviews, three option migrations pending, 12 stale reviews, nine unclassified profiles and 59 schemas still needing completeness review. This is one profile migration, not completion of the Army Builder plan.
