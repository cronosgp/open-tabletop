# Eliminator Squad — current e11 implementation

Reviewed 18 October 2026 against [Wahapedia Eliminator Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Eliminator-Squad) and the local export updated 16 October 2026, 21:03:46 GMT+3: datasheet `000001668`, shared book `000000139`, App. Space Marines (11th edition). Chapter and Boarding Actions variants remain outside this admission.

The builder admits three models for 85 points, with 40mm bases and the current M8/T4 profile. The default Bolt Sniper Rifles, Bolt Pistols and Ceramite Fists materialize on their owners. The Sergeant independently chooses a sniper rifle, Las Fusil or Instigator Bolt Carbine; both ordinary Eliminators can exchange their rifles for Las Fusils together. Preparation choices are reversible. Incursion permits two copies of this datasheet. Other Leader links are not automatically admitted.

The Instigator's Lethal Hits applies only against units without Monster or Vehicle, with target keywords evaluated before casualties. Its Rapid Fire 2 and Precision use the existing planner and allocation flow. The Las Fusil retains D3+3 Damage and Heavy. The sniper retains Strength 6, Damage 3, Heavy and Precision.

Chameleoline Cloaks gives the unit -3 inches detection while a living battlefield source survives, including attached models. Hidden normally gives 12 inches with Cloaks and 9 with Gone to Ground; source loss removes the unit effect. It never grants Hidden or bypasses solid terrain. Stealth grants ranged cover only when every surviving battlefield model has that ability; Ignores Cover bypasses it.

Infiltrators permits alternate deployment only when all models qualify. Bases remain wholly on the board and more than 8 inches from the enemy zone and deployed enemy models. Enemy previews and off-board/dead models do not block placement. Ordinary own-zone placement, terrain endpoints, overlap, coherency, alternating ownership and confirmation revalidation remain enforced.

Special-issue Optics and Ammunition is optional in own Shooting. Choosing it selects that unit to shoot: either its ranged attacks ignore cover, or one enemy within 24 inches gains +6 detection until the shooting finishes. The latter selection does not require line of sight. One selection is active at a time; the player may revise or cancel the preview before committing dice. Other units cannot shoot or start actions and the phase cannot end until the selection finishes or is cancelled. Resolution windows take priority over changing the preview. A miss still finishes shooting and removes the effect. Effects also check phase/turn identity and cannot accumulate across units or phases.

Smokescreen is now available at the start of opponent Shooting through the existing decision window. It costs 1 CP with normal discounts, Battle-shock and phase/use restrictions. It grants phase-long cover to the selected SMOKE unit and units not fully visible because of an intervening living model in that unit, measured separately for each attacker in the existing ground-level cylindrical proxy. Dead/off-board models do not shield others, and Ignores Cover defeats the benefit. This does not certify imported miniature mesh visibility or unsupported upper-floor geometry.

## Controls and evidence

The existing Unit abilities selector remains the primary control; no new screen or dependency is introduced. Labels identify the unit and effect; full choice labels are available as tooltips. Once Optics is selected, the decision banner and help text explain the required shooting or cancellation. Setup exposes Sergeant and whole-trooper options in the same selector. Existing colors, typography and layout stay in place at the checked 1600x1000 desktop viewport.

Real Godot review captures are ignored artifacts under `.tools/`: `eliminators-optics-before.png` is the earlier synthetic controls baseline; `marksmen-optics.png`, `marksmen-sternguard.png` and `marksmen-smoke.png` use admitted profiles in staged match states. The focused controls capture uses a different scroll position from the early baseline, so these are interaction evidence, not an identical-framing visual comparison. Other viewport sizes have not been visually checked in this increment.

See [the machine-readable audit](marine-marksmen-audit.json) for final validation evidence. Older visibility/deployment reports remain in their original `.tools/verification/` directories. Full army/faction and match certification remain false; network validation is deferred to final integration by user instruction.
