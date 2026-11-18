# Saved-schema source-option review — final Marine profiles — 15 November 2026

## Scope and provenance

This review completes source-option mapping for the last three admitted schemas in the current 117-schema coverage ledger. The source data is Warhammer 40,000 11th edition from the verified local Wahapedia export.

- Snapshot: `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, export revision `2026-10-28T23:48:19+03:00`, retrieved `2026-10-30T01:33:48.347556+00:00`.
- Parent manifest SHA-256: `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`.
- Relevant raw-file hashes, verified against that manifest:
  - `Source.csv`: `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9`
  - `Datasheets.csv`: `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`
  - `Datasheets_options.csv`: `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853`

Each runtime profile's verified-against snapshot, manifest, source digest and slice-manifest binding match this review basis.

## Profile findings

### Intercessor Squad — `000001157` (Space Marines)

Three source option rows cover the Sergeant's melee replacement, the Sergeant's ranged replacement, and the per-five-model Grenade Launcher. Sergeant choices persist per unit copy in `intercessor_sergeant_loadouts` and materialize as the Sergeant's `intercessor_rifle_choice` and `intercessor_melee_choice`. Grenade Launcher choices persist per copy and model in `intercessor_grenade_launcher_loadouts` and materialize through the detected `intercessor_grenade_launcher` field. Canonical admission and the focused regression cover the source choices and Grenade Launcher cap.

### Scout Squad — `000001160` (Space Marines)

Five source option rows cover the Sergeant's Shotgun and Chainsword, Shotgun choices for any Scout, and the per-five-model Sniper Rifle or Heavy Bolter/Missile Launcher alternatives. The existing `scout_gun` and `scout_sergeant_blade` fields represent ranged and Sergeant melee choices; validation preserves the source role and count limits.

### Venerable Dreadnought — `000000120` (Space Marines, Warhammer Legends)

Two source option rows cover the linked Dreadnought Fist/Storm Bolter package and the Assault Cannon replacement. The existing `venerable_dreadnought_legends_package` and `venerable_dreadnought_legends_primary` fields cover both groups, including the conflicting replacement combinations rejected by the local validator.

## Conclusion

All ten source option rows map to existing saved configuration paths. The last three schemas therefore complete the 117/117 source-option review ledger; this is not full rules, event or army-legality certification. Focused offline regressions are recorded in the [verification results](verification-results.md#final-marine-saved-schema-source-option-review-15-november-2026).
