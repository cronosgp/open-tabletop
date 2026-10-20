# Gravis Captain and Terminator Ancient — targeted local validation passed

Targeted local validation ran on 18 October 2026. `test_gravis_captain.gd` and `test_terminator_ancient.gd` passed, alongside the local catalog, roster, reserve, capability, Infiltrators and Ancients regressions in verification run `.tools/verification/20261019T022024657123Z`. The runner passed 13 processes, including import, Python checks and startup. The complete local suite and network validation remain pending; this batch does not establish full army legality.

## Sources and boundaries

Reviewed 18 October 2026 against Wahapedia [Captain In Gravis Armour](https://wahapedia.ru/wh40k11ed/factions/space-marines/Captain-In-Gravis-Armour), sheet `000001172`, and [Ancient In Terminator Armour](https://wahapedia.ru/wh40k11ed/factions/space-marines/Ancient-In-Terminator-Armour), sheet `000002677`. Both belong to shared App Space Marines book `000000139`. Local export revision: 16 October 2026, 21:03:46 GMT+3. Source links and data were read; this is separate from executable validation. Chapter/Deathwing and Boarding Actions adaptations remain excluded.

The 90-point Gravis Captain uses a 40mm base, M5/T6/Sv3/W6/Ld6/OC1 and 4+ invulnerable protection. Refuse to Yield joins the existing allocated-attack damage modifier, reducing damage on this bearer by one, with minimum one for positive damage. It does not confer that reduction on bodyguards or unrelated mortal-wound sources. Strategic Acumen and Transhuman Strategist reuse existing mechanisms; no Finest Hour or Deep Strike is copied from other Captain identities.

Default equipment is the heavy bolt rifle and power weapon. Each alternative replaces both defaults with the Boltstorm Gauntlet (ranged and ordinary melee profiles) plus exactly one relic blade, chainsword or power fist. Each relic is Extra Attacks. Four complete loadouts use the existing preparation selector and preserve replacement semantics across attachment. Eligible admitted bodies are Aggressors, Heavy Intercessors and both Eradicator identities; chapter bodies are excluded.

The 75-point Terminator Ancient has a 40mm base, M5/T6/Sv2/W5/Ld6/OC2, 4+ invulnerable protection and fixed Storm Bolter/power weapon. It uses Support, Deep Strike and the existing Raise the Banner mechanism, with Terminator Squad as its admitted bodyguard. Support construction matching includes this link while preserving a separate Leader slot. It does not receive the ordinary Ancient's OC bonus or Bladeguard Ancient's melee attack bonus.

Never Shall the Standard Fall contributes -1 to wound when final attacking Strength exceeds the defending unit's Toughness and any living model in the Ancient's unit is in objective range. Control is not required. The effective weapon Strength and bodyguard Toughness feed declaration context before existing wound-modifier limits. Prepared batches keep their context for that attacking unit's resolution; later declarations recompute source/position eligibility. The targeted tests exercised these interactions.

## Written tests and final-run queue

`test_gravis_captain.gd` covers admission, source stats, bearer-only damage reduction, allocated damage integration, Gravis/Terminator boundaries, all four loadouts, ordinary plus Extra Attacks default declarations, reversibility after attachment and historical isolation.

`test_terminator_ancient.gd` covers admission, Leader plus Support, combined reserve cost, Deep Strike, strict S>T, objective range without control, bearer versus unit range, dead source, off-objective behavior, prepared defensive context, Raise the Banner, construction matching and historical isolation. Both suites share `marine_gravis_ancient_fixture.gd`.

Run the complete local suite at final integration, including regressions for attack allocation, modifiers, equipment/Extra Attacks, existing Ancients, Gravis bodyguards, Support matching, reserves, capability metadata and checked construction. Then run network validation as requested. These targeted local passes do not replace that final run.

## UI intent

Existing layout, colors and controls remain. Loadout names identify the gauntlet/relic combination; default restoration names the rifle and power weapon. Replacement logic prevents retaining incompatible gear. No new panel or automatic rules-certification feedback was added. Contextual help explains that both default weapons are replaced together and that the relic grants Extra Attacks. Actual Godot captures `.tools/gravis-ancient-batch-before.png` and `.tools/gravis-ancient-batch-preparation.png` show the same staged preparation fixture at 1600x1000, before and after the help-text change. The selected option and explanation fit. These captures do not execute the written suites, exercise every loadout or establish combat correctness. Interaction and full runtime validation remain pending.

Current implementation inventory: 27 shared-book Marine identities, four Necrons and 58 unimplemented shared-book Marine identities. This batch's two targeted local suites passed; the complete current build still needs its final regression run. See the [batch audit](marine-gravis-ancient-batch-audit.json).
