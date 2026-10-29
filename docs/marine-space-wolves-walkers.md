# Space Wolves Dreadnoughts

## Source and profile scope

This local increment integrates four Space Wolves App datasheets from the Wahapedia 11th-edition Data Export: Bjorn the Fell-handed (`000000302`), Murderfang (`000000314`), Venerable Dreadnought (`000002801`) and Wulfen Dreadnought (`000004133`). Their exact source IDs, characteristics, costs, equipment choices, abilities, export identity and SHA-256 evidence are recorded in the [machine-readable audit](marine-space-wolves-walkers-audit.json).

The verified source export was updated `2026-10-28T23:48:19+03:00`. The scoped Space Wolves slice is structurally valid with zero findings; its parent export has 68 unrelated validation findings and is not described as globally clean. A fresh, timestamp-bracketed capture on 29 October retained the same source data. Raw exports stay under ignored `.tools/`.

The current 11e [Bjorn](https://wahapedia.ru/wh40k11ed/factions/space-marines/Bjorn-The-Fell-handed), [Murderfang](https://wahapedia.ru/wh40k11ed/factions/space-marines/Murderfang), [Venerable Dreadnought](https://wahapedia.ru/wh40k11ed/factions/space-marines/Venerable-Dreadnought-1) and [Wulfen Dreadnought](https://wahapedia.ru/wh40k11ed/factions/space-marines/Wulfen-Dreadnought-1) pages were compared with the local slice on 29 October. The compared profiles, costs, listed loadouts and abilities agree.

## Runtime support

- **Bjorn:** 160 points, one copy, 60 mm base. The three source-listed ranged weapon choices and Trueclaw are available. Legendary Tenacity modifies wound rolls only when Strength exceeds Toughness. Ancient Tactician reduces the CP cost of a stratagem targeting Bjorn's unit once per turn per army. Feel No Pain 5+ and Deadly Demise 1 use the shared prevention/allocation flow.
- **Murderfang:** 150 points, one copy, 60 mm base. The fixed Heavy Flamer, Storm Bolter and Murderclaws package is admitted. Murder-maker, Bestial Fury and the Warlord exclusion are implemented; Feel No Pain 6+, Curse of the Wulfen and Deadly Demise 1 are registered.
- **Venerable Dreadnought:** 130 points for the first two copies and 140 for the third-plus tier, 60 mm base. The Assault Cannon, Helfrost Cannon or Multi-melta, secondary Storm Bolter/Heavy Flamer and legal Great Axe plus Blizzard Shield package are selectable. Fervour of the Ancients, Blizzard Shield, Combat Doctrines and Deadly Demise 1 are implemented.
- **Wulfen Dreadnought:** 140 points for the first two copies and 150 for the third-plus tier, 60 mm base. Storm Bolter/Heavy Flamer and the Fenrisian Great Axe/Blizzard Shield choices are selectable. Violent Fury, Bestial Rage, Blizzard Shield, Feel No Pain 6+, Curse of the Wulfen, Combat Doctrines and Deadly Demise 1 are implemented.

The targeted local suite checks source identities and fixed values, equipment legality through the public construction boundary, copy-price tiers, ability registration and capabilities, Warlord rejection, attack/save effects, CP discount timing, reroll windows, casualty retention and the supported Surge movement path. This closes only these four local datasheet scopes; full Space Wolves legality and army-wide validation remain open.

## Verification

The connected targeted run passed **13/13 processes**: import, Python checks and 11 selected suites, including `test_space_wolves_walkers`, Wulfen regressions, capabilities, roster validation, consolidated catalog, Ballistus, Baal Predator, movement rerolls and Jump Pack Captain.

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_space_wolves_walkers --only test_wulfen --only test_wulfen_storm_shields --only test_core_reactions --only test_capabilities --only test_roster_validation --only test_implemented_catalog --only test_ballistus_dreadnought --only test_baal_predator --only test_movement_rerolls --only test_jump_pack_captain --timeout 300
```

Report: `.tools/verification/20261029T064721289232Z/results.json`, SHA-256 `A46BDC2EC53361FA110F7CCF1BBFD0CDF1FE29426842F14C82E837DECB56A251`. The verifier had `network: false`; supplemental legacy fixtures were staged for its selected suites, and no headless cleanup diagnostics were reported. Live Wahapedia page comparison was carried out separately. It does not certify every Marine page or full army legality.
