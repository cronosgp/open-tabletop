# Space Marines profile records

> Consolidated source and implementation notes for individual Space Marines profiles. These dated records explain bounded behavior and prior checks; current support and pending work are summarized in the [Space Marines catalog](space-marines-catalog.md), [support matrix](project/support-matrix.md), and [roadmap](project/roadmap.md). The capability registry and runtime remain authoritative for what is enabled.
<a id="marine-adrax-agatone"></a>
## Adrax Agatone

`marine-adrax-agatone.md`

Current Space Marines 11th-edition datasheet from the pinned local Wahapedia extraction. Source book `000000139`, datasheet `000002100`, export revision `2026-10-16T21:03:46+03:00`; [Wahapedia page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Adrax-Agatone).

## Profile

- One model, 90 points; M6, T5, Sv2+, 4++, W5, Ld6+, OC1; 40 mm base.
- Exported keywords include the Salamanders and Adeptus Astartes faction keywords, plus Captain, Character, Epic Hero, Explosives, Infantry, Imperium and Tacticus.
- Drakkis: 12", D6+3, Torrent, Close-quarters, S5, AP-1, D1.
- Malleus Noctum: 5A, WS2+, S10, AP-2, D3, Devastating Wounds.

## Rules implemented

- Leader attachment to the source-listed bodyguard identities admitted in the consolidated local catalog.
- Transhuman Strategist, using the existing Warlord CP effect.
- Lord of the Pyroclasts: enemy units engaged with Adrax's attached unit have -1 OC, minimum 0.
- Unto the Anvil: the attached unit's melee attacks re-roll wound rolls of 1; while Assault Doctrine is active for that unit, it re-rolls wound rolls instead.

The implementation is scoped to this local extraction and the listed bodyguard choices. It does not certify full Salamanders restrictions, faction legality or network integration.

Validation: `.tools/verification/20261019T114211481946Z/results.json` (10/10 local processes). Fixed-data comparison: `.tools/wahapedia-fixed-data-review-v87.json` (42/43 bounded profiles pass; the remaining keyword-context issue is Ancient in Terminator Armour). Network checks remain deferred.

---

<a id="marine-aethon-shaan"></a>
## Aethon Shaan — current e11 implementation

`marine-aethon-shaan.md`

This draft uses the pinned local Wahapedia 11e export only: shared Space Marines source `000000139`, datasheet `000004148`, updated `2026-10-16T21:03:46+03:00`. It records one 105-point model on a 50 mm base with M14, T5, Sv3+, W5, Ld6+, OC1 and a 4+ invulnerable save. The fixed loadout is Heavy Bolt Pistol and Claws of Severax. The pistol is 18", A1, BS2+, S5, AP-1, D1, Close-quarters. The claws are A7, WS2+, S5, AP-2, D2, Twin-linked, and have Sustained Hits 2 only against targets without MONSTER or VEHICLE.

The local export gives Shaan the character, Epic Hero, Infantry, Jump Pack, Fly, Tacticus, Smoke, Explosives, Imperium, Adeptus Astartes, Chapter Master and Raven Guard keywords. This datasheet has no Leader target list. His Character status makes him eligible to be selected as Warlord.

The local ability inventory also lists Deep Strike, Lone Operative, Stealth, Combat Doctrines and Transhuman Strategist. Deep Strike uses the existing reserve and ingress flow. Lone Operative protects Shaan while he is a standalone unit and turns off if he is in an Attached unit. Stealth grants the supported ranged benefit of cover. Combat Doctrines participates in the current Marine doctrine setup. If Shaan is the Warlord, Transhuman Strategist grants 1 CP at the start of the battle round, once per round.

Master of Shadows selects one friendly Adeptus Astartes Infantry unit in the Command phase and lets it re-roll Charge rolls until the start of the next Command phase. Both dice are replaced together, and the final result is mandatory. Blackwing Mantle is usable once per phase per army; it permits a Heroic Intervention targeting Shaan's unit regardless of other uses that phase, reduces that use by 1 CP (to a minimum of 0), and does not consume or block Heroic Intervention uses on other units. The Charge phase can continue to offer other eligible Heroic Interventions after the special use resolves.

Focused local validation covers the source profile and weapon traits, all seven listed abilities, Warlord selection and CP, Master of Shadows selection, the free charge re-roll and duration, plus Blackwing Mantle use before or after the ordinary Heroic Intervention. The profile is admitted through the consolidated local runtime catalog. The bounded source comparison has zero numeric or identity differences; Aethon passes its fixed-data checks.

Network checks remain deferred to final integration. This draft does not certify full faction or army legality.

---

<a id="marine-ancients"></a>
## Ancient and Bladeguard Ancient — current e11 implementation

`marine-ancients.md`

Reviewed 18 October 2026 against [Wahapedia Ancient](https://wahapedia.ru/wh40k11ed/factions/space-marines/Ancient) (`000002775`) and [Bladeguard Ancient](https://wahapedia.ru/wh40k11ed/factions/space-marines/Bladeguard-Ancient) (`000001165`), shared book `000000139`, App. Space Marines (11th edition). The local joined export revision is 16 October 2026, 21:03:46 GMT+3. Chapter, Legends and Boarding Actions adaptations remain excluded.

The Ancient is one 40-point model, 40mm base, M6/T5/Sv3/W4/Ld6/OC2, without an invulnerable save. Its Bolt Rifle has Focused Fire and Saturation profiles, alongside Bolt Pistol and Ceramite Fists. The rifle can be replaced with a Power Weapon; pistol and fists remain. Both melee weapons are ordinary weapons, so the existing selection rule still permits only one when fighting. The swap is reversible during preparation. Honour of the Company adds one OC to each model in its current unit, including itself. Battle-shock still removes usable OC; dead/off-board sources confer no bonus, and printed characteristics remain unmodified in the stored profile.

The Bladeguard Ancient is one 70-point model, 40mm base, M6/T5/Sv3/W4/Ld6/OC3, with general 4+ invulnerable protection. Its fixed equipment is Heavy Bolt Pistol and Relics of Battle, without replacements. Deeds of Legend grants +1 A to the current unit’s melee weapons while any living battlefield model in that unit is in objective range. Objective control is not required, and the effect does not modify ranged weapons. The shared profile retains the ANCIENT keyword and excludes the conditional Deathwing adaptation. The ordinary Ancient does not receive that keyword from its name.

Both models have Support and Raise the Banner. The latter automatically secures objectives controlled by the current unit at the end of its owner’s Movement phase. Control is resolved first, using effective OC and existing objective range/elevation geometry. A shocked unit cannot qualify through zero usable OC. The effect applies through bodyguard models in range; the source model need not itself be in range. Security persists after leaving, and normal enemy capture can remove it. No CP or extra player confirmation is added.

## Attachments and construction

The Ancient can accompany the admitted Intercessor, Assault Intercessor, Infernus, Hellblaster and Sternguard profiles. Bladeguard Ancient can accompany only Bladeguard Veterans. They use the Support slot, preserving the independent Leader slot, and must attach before checked preparations finish. They may be declared Warlord. Other source-linked profiles remain outside admission.

Support compatibility now has one shared definition used by preparation and checked construction. The roster validator performs bipartite matching between all selected Supports and distinct eligible bodyguard copies. This handles competition with Lieutenant, Judiciar and Biologis without relying on entry order or broad counts that could admit an impossible combination. Existing Gravis and Tacticus boundaries remain separate. Lists with enough nominal slots but no complete legal assignment are rejected; final in-game formation declarations are still required.

## Attack counts and validation

Deeds of Legend is included in the number of attacks the player must distribute. Default declarations and the planner use that modified count. Numeric melee rows do not add the same bonus again per target: a four-attack sword becomes five attacks total, including a split such as two plus three. The dedicated test checks a twenty-attack attached unit split across two enemy units, immutable source weapons, source death and changes in eligibility. Already prepared attack pools retain their declared characteristics during the existing attack resolution.

The suite also covers both profiles’ checked admission and prices, OC propagation and morale precedence, own/enemy phase boundaries, tied control, later enemy capture, both banner sources, public Support declarations with actor checks, reversible equipment and historical-implementation isolation. The [audit](marine-ancients-audit.json) records 64 numeric runtime-versus-export comparisons and the local regression reports.

## UI brief and actual captures

The player needs to understand what the equipment swap replaces and how many melee attacks to allocate. Existing layout, type, colors and controls are preserved. The preparation option is shortened to fit; visible help explains that only the Bolt Rifle is replaced and that the choice is reversible. Selector changes refresh the help while preserving the selected choice. With Deeds active, the planner exposes the modified maximum and explains that the additional attack is distributed once across targets.

Real Godot captures at 1600x1000 were inspected: `.tools/ancients-prep-before.png`, `.tools/ancients-prep-after.png` and `.tools/ancients-deeds-after.png`. These are staged admitted-profile fixtures, with a point objective carrying bounds for the existing board visualization. The Deeds capture shows five available attacks and an empty draft, with confirmation correctly unavailable until assignments are supplied. An initial capture missing visualization bounds was discarded and replaced. Captures establish the displayed local controls, not a completed match, all viewport sizes or imported-mesh accuracy.

Networking remains deferred to final integration by user instruction. Full army, faction and match certification remain incomplete.

---

<a id="marine-apothecary"></a>
## Apothecary — current e11 bounded implementation

`marine-apothecary.md`

Reviewed 18 October 2026 against [Wahapedia Apothecary](https://wahapedia.ru/wh40k11ed/factions/space-marines/Apothecary), datasheet `000002773`, shared App Space Marines book `000000139`, and [Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) 02.02.04, 01.02.03, 19.01.01. The local export revision is 16 October 2026, 21:03:46 GMT+3. Chapter, Legends and Boarding Actions variations remain excluded.

One model costs 45 points: M6/T5/Sv3/W4/Ld6/OC1 on a 40mm base, without an invulnerable save. Absolvor Bolt Pistol is ranged; Reductor Pistol is a melee Extra Attacks weapon and accompanies the ordinary Servo-armature in default melee declarations. Equipment is fixed. Neither EXPLOSIVES nor APOTHECARY is inferred from the model name; both are absent in this sheet's keyword rows. Pricing derives from the admitted profile through the shared catalog.

Narthecium heals the current unit D3+1 wounds during its owner's Command phase, without CP or a reroll option. Living wounded models take priority. When several are wounded, the controller chooses where to assign wounds. Only after every living model is at full wounds can a destroyed non-Character return with one wound; it is then healed before another return. Excess healing is discarded. Battle-shock does not prohibit this datasheet ability. Useful unresolved healing is offered before Command can finish, and each unit resolves it once in that turn.

Healing uses a shared preview transaction in `unit_healing.gd`. Neither wounds nor positions change in authoritative model data before confirmation. Reset preserves the rolled budget and spent ability. Actor, revision and available-action checks apply through the existing public command handler. Return endpoints share `return_placement.gd` with Necron Reanimation, retaining the existing ground-board scope: whole base on board, no overlap, phase-entry survivor anchors within two inches, unit coherency and no new engagement. Equipment remains on the original model record. If no return can be placed, the controller explicitly declares that and discards remaining healing; this is a recorded controller declaration, not an automated exhaustive proof that no geometric placement exists.

The Apothecary can accompany admitted Assault Intercessors, Bladeguard Veterans, Hellblasters, Infernus, Intercessors and Sternguard. The datasheet's explicit exception permits the Apothecary and Lieutenant to share one eligible bodyguard, in either declaration order. Construction matching accounts for that pair. One Leader plus one Support remains available; three attached Characters are outside this bounded implementation and rejected in preparation. Other source-linked bodies and Chapter Masters remain unadmitted. Core 19.01.01 keeps the current attached unit together after bodyguard casualties, superseding the sheet footer's older separation wording.

## Local verification and UI

The dedicated suite covers checked admission, price, wounded-model choices, survival-first healing, return priority, overlap rejection without mutation, same-roll reset, excess accounting, destroyed-Character exclusion, mandatory Command timing, Battle-shock, own-phase boundaries, once-per-turn refresh, invalid actor/revision rejection and ordinary plus Extra Attacks melee declarations. Regression includes Necron Reanimation and attached Reanimation, current abilities, Ancients, construction and preparation. The numeric/keyword audit compares 28 runtime fields with the pinned export. Passing tests do not certify every interaction or full army legality.

The UI preserves the existing ability selector, X/Z placement fields and right-click placement. Context help states the budget, remaining wounds, healing priority, preview status and same-roll reset. The inspected real 1600x1000 Godot capture `.tools/apothecary-healing-after.png` uses a staged admitted-profile fixture with a fixed healing budget and one returned-model preview. It verifies visible controls, not a completed match or every viewport. No pre-change capture was made for this increment.

The [audit](marine-apothecary-audit.json) records local evidence. Game/network validation remains deferred to final integration by user instruction.

---

<a id="marine-assault-intercessor-squad"></a>
## Assault Intercessor Squad — current local profile

`marine-assault-intercessor-squad.md`

This migration uses the pinned Wahapedia 11e Space Marines export: book `000000139`, datasheet `000001606`, export timestamp `2026-10-16T21:03:46+03:00`. The fixed profile is 5 or 10 models at 85 or 170 points, on 32 mm bases. Its characteristics are M6, T5, Sv3+, W2, Ld6+, OC2, with the shared `ADEPTUS ASTARTES`, `BATTLELINE`, `INFANTRY`, `TACTICUS`, `EXPLOSIVES` and `IMPERIUM` keywords.

The selectable fixed loadout is one Heavy Bolt Pistol and one Chainsword per model. The export's Sergeant replacements (Hand Flamer or Plasma Pistol; Power Fist, Power Weapon or Thunder Hammer) are retained as additional source profiles for audit, but cannot be selected in construction. `Targeted Intercession` is active: after the unit makes a charge move, its melee attacks gain +1 Strength and +1 AP for the turn. The effect is resolved through the attack profile and does not alter ranged attacks or the printed weapon data.

Local checks cover the source ID/revision, characteristics, faction keyword, 5/10 prices, default kit, optional source weapon profiles, construction-catalog publication, roster pricing, and charged/uncharged melee behavior. Focused offline validation passed 11/11 processes. The bounded comparison found no numeric or identity differences; the remaining `DEATHWING` keyword-context issue is on Ancient in Terminator Armour. The imported raw CSV snapshot still has structural warnings. Network validation is deferred, and full faction/army legality is not certified.

---

<a id="marine-ballistus-dreadnought"></a>
## Ballistus Dreadnought — 19 October 2026

`marine-ballistus-dreadnought.md`

Source: local Wahapedia 11th-edition export, Space Marines book `000000139`, datasheet `000000091`, exported `2026-10-16T21:03:46+03:00`. [Ballistus Dreadnought on Wahapedia](https://wahapedia.ru/wh40k11ed/factions/space-marines/Ballistus-Dreadnought).

## Implemented profile and abilities

One model for 150 points: M8, T10, Sv2+, W12, Ld6+, OC4 and a 90 mm base. Its default equipment is Ballistus Lascannon, one Ballistus Missile Launcher with Frag and Krak profiles, Storm Bolters and Armoured Feet. The extracted third-plus price is 170 points; local list admission charges 150 each for the first two copies and 170 for the third. The fixed-data comparison matches the local extraction.

- **Ballistus Strike:** ranged attacks targeting an enemy unit within 24 inches gain Sustained Hits 1.
- **Damaged 4:** while the model has 1–4 wounds remaining, its attacks have -1 to Hit. The modifier enters the actual attack plan for both shooting and melee.
- **Deadly Demise D3:** when destroyed, a D6 roll of 6 triggers an explosion. Every unit within 6 inches receives a separately rolled D3 mortal-wound packet. The affected unit's owner allocates those wounds through normal mortal-wound prevention. If a packet destroys another Ballistus, its explosion is queued and resolved in sequence before the suspended attack resumes.

The profile is selectable in the local construction catalog. Admission checks cover the one-model profile and the extracted one-, two- and third-copy prices; they do not certify full army legality.

## Local validation

Focused offline validation passed **11/11 processes** in `.tools/verification/20261019T050853510494Z/results.json`: import, Python checks, startup, `test_army_builder`, `test_attack_sequence`, `test_ballistus_dreadnought`, `test_combat_scenario`, `test_core_reactions`, `test_current_unit_abilities`, `test_implemented_catalog` and `test_roster_validation`. The Ballistus test exercises the 24-inch effect, the Damaged 4 threshold, the Deadly Demise roll, per-unit D3 packets, allocation, chain explosions, attack resumption and local admission including third-plus pricing.

The fixed-data comparator `.tools/wahapedia-fixed-data-review-v25.json` reports zero numeric or identity differences; this Ballistus profile is consistent. Across 21 profiles / 70 weapon profiles, 20 pass all bounded fixed-data checks; Ancient in Terminator Armour remains unresolved for the shared-versus-chapter `DEATHWING` context. Full local regression and final network validation remain pending. Full faction and army legality are not certified.

---

<a id="marine-bladeguard"></a>
## Bladeguard Veteran Squad — current e11 implementation

`marine-bladeguard.md`

Subsequent increment (18 October 2026): [Bladeguard Ancient](space-marines-profile-records.md#marine-ancients) is now an additional admitted Support for Bladeguard Veterans; the earlier linked-character boundary below is historical.



Reviewed 18 October 2026 against [Wahapedia Bladeguard Veteran Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Bladeguard-Veteran-Squad), datasheet `000000071`, shared book `000000139`, App. Space Marines (11th edition). The joined export revision is 16 October 2026, 21:03:46 GMT+3. Chapter, Legends and Boarding Actions variants remain excluded.

Admitted formations are three models at 90 points or six at 180, each with a 40mm base, M6/T5/Sv3/W3/Ld6/OC1 and a general 4+ invulnerable save. Each carries a Heavy Bolt Pistol and Master-crafted Power Sword. The Sergeant can replace the pistol with a Neo-volkite Pistol or Plasma Pistol, including both plasma profiles. The shared profile includes Explosives and Tacticus; the conditional Deathwing keyword remains outside this profile, as with Sternguard. Current Captain, Chaplain, Lieutenant and Judiciar links are admitted. Other linked characters remain outside scope.

Bladeguard offers a once-per-turn choice when selected to fight or targeted by an enemy during Fight: +1 to the unit’s melee hit rolls, or -1 to enemy hit rolls against the unit. Core [01.02.02 Persisting Rules Effects](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/#Persisting-Rules-Effects) gives the effect phase duration when no explicit duration is printed.

## Declaration and resolution

Attack legality is checked before offering a stance. The declaration stores independent copies of assignments and targets; no attack dice are rolled while choices remain. The selecting unit receives its selection trigger first, followed by each targeted Bladeguard unit once, in deterministic target order. Both stance options and an explicit decline are available at each trigger. Declining preserves the use for a later legal trigger in the same turn. Selecting either effect spends the one use for that current unit and turn; it cannot be changed at a later trigger. No CP is spent, and Battle-shock does not prevent this datasheet ability.

The final response resumes the same attack declaration and recalculates attack modifiers with the chosen effects. Bonuses and penalties combine before the final +1/-1 cap. The offensive effect applies only to melee; the defensive effect applies to attacks targeting that unit during Fight. Attached characters receive the unit effect. Core 19.04 also limits the effect to its living source: losing the last Bladeguard ends the benefit for surviving attached characters, after the attacking unit finishes all its attacks when that source was destroyed by an attack. A frozen allocation snapshot preserves it during that resolution, then later attacks cannot recover it from the spent record. A new player turn restores availability.

The window also precedes completion of an eligible unengaged fight. Manual allocation, Precision, attack/damage reroll windows and Hazardous resolution continue through their existing paths after the declaration response. Invalid actors, stale revisions, illegal declarations and invalid dice cannot commit a different choice or consume the final response. Already-resolved responses cannot replay the attack. Historical ability implementations do not activate this rule.

Only the first two copies are admitted, including in custom training: the export’s third-and-later prices (110/200) are retained as source evidence, and the generic admission layer explicitly rejects those copies rather than pricing them as the first two. This increment does not add additional game sizes or certify intermediate formations.

## UI brief and evidence

The player must identify which unit responds, choose an effect or decline, and understand that attacks are waiting. Existing selector, confirmation button, panel layout, type and semantic colors are preserved. The decision banner names Bladeguard; visible help states both effects, Fight-phase expiry, one use per turn, zero CP, and that declining preserves the use. Full option labels remain available through tooltips. No new placement controls or decorative assets are added.

Inspected real Godot captures at 1600x1000 use a staged Marine-versus-Marine training fixture: `.tools/bladeguard-before.png`, `.tools/bladeguard-after.png` and `.tools/bladeguard-defender.png`. The latter shows the defender’s response after the attacker chose its stance. The initial capture used a stale fixture priority annotation; the final fixture explicitly labels the remaining-fighters step. These captures verify the local controls and copy, not army legality, a completed match, network behavior or other viewport sizes. Checked admission is tested separately in the supported Marine-versus-Necron mission.

The [audit](marine-bladeguard-audit.json) records numeric comparison and local regression results. Full faction, army and match certification remain incomplete. Network validation remains deferred to final integration by user instruction.

---

<a id="marine-brutalis-dreadnought"></a>
## Brutalis Dreadnought — 19 October 2026

`marine-brutalis-dreadnought.md`

Source of truth: the local Wahapedia 11th-edition export, Space Marines book `000000139`, datasheet `000000136`, exported `2026-10-16T21:03:46+03:00`. [Brutalis Dreadnought source page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Brutalis-Dreadnought-UL).

## Implemented profile

One VEHICLE model: M10, T10, Sv2+, W12, Ld6+, OC4, 90 mm base. Construction charges 160 points for each of the first two copies and 180 for the third-plus copy; the supported copy limit is three.

The default weapons are Bolt Rifles (Twin-linked), Twin Heavy Bolter (Twin-linked, Sustained Hits 1, Rapid Fire 2), Twin Icarus Ironhail Heavy Stubber (Anti-Fly 3+, Rapid Fire 3, Twin-linked), and Brutalis Fists (Twin-linked). The local loadout choices implement the paired Bolt Rifles and Brutalis Fists replacement with Brutalis Talons (Sustained Hits 1 against targets without MONSTER or VEHICLE, Twin-linked, Cleave 2), and Twin Heavy Bolter replacement with Twin Multi-melta (Twin-linked, Melta 3).

- **Damaged 4:** while this model has 1–4 wounds remaining, subtract 1 from its Hit rolls.
- **Deadly Demise D3:** when destroyed, roll one D6; on a 6, each unit within 6 inches suffers a separately rolled D3 mortal-wound packet, allocated through the shared mortal-wound flow.
- **Brutalis Charge:** this unit can use Tank Shock even if another unit has already used it this phase; its use does not prevent other units using Tank Shock. Once per phase per Brutalis unit, Tank Shock costs 1 fewer CP.
- **Tank Shock (Crushing Impact):** immediately after a VEHICLE finishes a Charge move, choose an enemy unit engaged by a VEHICLE model in the charging unit. Roll a number of D6 equal to that model's Toughness; each 5+ inflicts 1 mortal wound, to a maximum of 6. The defending player allocates those mortal wounds through the ordinary allocation window.

The post-charge Tank Shock window opens only when the charging Vehicle is engaged with an eligible enemy and the stratagem can be used. Tank Shock uses record separately so the Brutalis exception preserves one ordinary use by another unit in the same phase.

## Local validation

The focused run passed **14/14 processes**, including `test_brutalis_dreadnought`, the capability registry, combat scenario, Tank Shock/core reactions, both existing Dreadnought regressions, the implemented catalog and roster checks. Results: `.tools/verification/20261019T053830682027Z/results.json`.

The bounded local comparison `.tools/wahapedia-fixed-data-review-v32.json` contains 23 runtime profiles and 85 weapon trait profiles; 22/23 pass all fixed-data checks with no numeric or identity differences. Ancient in Terminator Armour remains unresolved for the shared-versus-chapter `DEATHWING` keyword context. This comparison does not certify optional wargear legality, full faction coverage or full army legality. Network validation remains deferred to final integration.

---

<a id="marine-caanok-var"></a>
## Caanok Var

`marine-caanok-var.md`

Source: the local Wahapedia 11th-edition export snapshot, shared Space Marines book `000000139`, datasheet `000004166`, updated `2026-10-16T21:03:46+03:00`. Source page identity is recorded at `https://wahapedia.ru/wh40k11ed/factions/space-marines/Caanok-Var`.

Caanok is admitted as a one-model, 100-point Iron Hands Epic Hero with a 50 mm base, T6, 2+ save, 4+ invulnerable save and 6 wounds. The fixed loadout is a Storm Bolter and Axiom. His source-listed Leader targets are Terminator Squad and Terminator Assault Squad.

The local runtime implements Feel No Pain 5+, Deep Strike, Leader, Combat Doctrines, Transhuman Strategist, and both datasheet abilities:

- **Cold and Calculating:** when his unit is selected to attack in the Shooting or Fight phase, choose Lethal Hits against MONSTER/VEHICLE targets or Sustained Hits 1 against other targets. If Tactical Doctrine is active for the unit, both target-conditional effects apply.
- **Cerebrex Logic Engine:** during army preparation, optionally select one friendly Adeptus Astartes Infantry unit. The selected unit receives Scouts 6 for the pre-battle Scout workflow.

Focused checks cover the source profile and weapon traits, both Leader targets, personal Feel No Pain, the formation choice and Scout distance, both Cold and Calculating attack choices and target filters, Tactical Doctrine, and Warlord CP. This is local, targeted validation only. The fixed-data comparison remains deferred because the currently available comparison snapshot is structurally invalid. Network validation remains deferred to final integration; full faction and army legality are not certified.

---

<a id="marine-captain-on-bike"></a>
## Captain on Bike

`marine-captain-on-bike.md`

Current Space Marines 11th-edition profile from the pinned local Wahapedia extraction. Source book `000000139`, datasheet `000002702`, export revision `2026-10-16T21:03:46+03:00`; [Wahapedia page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Captain-On-Bike).

## Profile and equipment

- One model, 110 points; M12, T6, Sv3+, 4++, W6, Ld6+, OC2; 90 x 52 mm oval base.
- Exported keywords: ADEPTUS ASTARTES (faction), MOUNTED, CAPTAIN, CHARACTER, EXPLOSIVES, IMPERIUM and RAVENWING.
- Default weapons: Heavy Bolt Pistol; Twin Bolt Rifle (Twin-linked, Assault, Rapid Fire 2); Master-crafted Power Weapon.
- Free source replacements: Heavy Bolt Pistol to Plasma Pistol (standard/supercharge profiles), or Master-crafted Power Weapon to Thunder Hammer.

## Rules implemented

- Leader attachment to Outrider Squad in the consolidated local catalog. The source-listed Ravenwing Black Knights are chapter content outside that catalog.
- Strategic Acumen and Transhuman Strategist use the existing locally implemented Space Marines effects.
- Into the Fray: after this unit made a charge move this turn, its melee attacks gain Cleave 1.

The local fixed-data comparison confirms its profile, six weapon profiles/traits, default loadout and point cost. This is scoped local validation; network validation is deferred to final integration, and full faction/army legality remains uncertified.

Validation: `.tools/verification/20261019T112505737398Z/results.json`; fixed-data comparison: `.tools/wahapedia-fixed-data-review-v85.json`.

---

<a id="marine-captain-phobos"></a>
## Captain in Phobos Armour

`marine-captain-phobos.md`

The local Wahapedia 11e Space Marines export identifies shared-book datasheet `000002701` at 75 points for one 40 mm model. Its fixed profile is M8, T4, Sv3+, W5, Ld6+, OC1, 4+ invulnerable save, with Instigator Bolt Carbine, Bolt Pistol and Combat Knife. Weapon traits and the exact fixed loadout are materialized from [the current reference profiles](../scripts/edition_11/current_reference_marine_profiles.gd).

The admitted profile supplies Deep Strike, Infiltrators, Leader, Scouts 6, Stealth, Combat Doctrines, Transhuman Strategist, Strategic Acumen and Tactical Fluidity. Captain pairing choices follow the five Leader links in the local source export: Eliminators, Scouts, Infiltrators, Incursors and Reivers. Army setup permits this Character as Warlord. Its current Tactical Fluidity window offers a Normal Move up to D6 after the unit shoots while unengaged, or a Fall Back move up to 6 inches at the end of the opponent's Fight phase while engaged. It enforces a shared once-per-battle-round use, placement distance, terrain, base spacing, coherency and engagement endpoint.

Focused validation exercises source profile materialization, ability admission, Warlord and Leader choices, and each Tactical Fluidity branch. Network checks are deferred to the final integration stage. This single fixed profile is not full faction or army-legality certification.

---

<a id="marine-captain-titus"></a>
## Captain Titus — Space Marines e11 increment

`marine-captain-titus.md`

Source of truth: the local Wahapedia 11th-edition data export. Datasheet ID `000004187`, shared-book ID `000000139`, export timestamp `2026-10-16T21:03:46+03:00`; source page: https://wahapedia.ru/wh40k11ed/factions/space-marines/Captain-Titus. Network validation remains deferred to final integration.

## Admitted profile

Captain Titus is one Ultramarines Epic Hero model at 115 points on a 40mm base: M6, T5, Sv3+, invulnerable 4+, W6, Ld6+, OC1. His keywords include Infantry, Character, Epic Hero, Captain, Tacticus, Imperium, Explosives, Adeptus Astartes and Ultramarines.

- **Bolt Pistol:** 12”, A1, BS2+, S5, AP-1, D1; Close-Quarters.
- **Master-crafted Bolter:** 24”, A2, BS2+, S5, AP-1, D2; Assault, Rapid Fire 1, Heavy.
- **Master-crafted Chainsword:** melee A8, WS2+, S5, AP-1, D2; Anti-non-Monster/Vehicle 2+.

The local Leader target table contains no attachment targets for Titus; construction does not offer him as a Leader attachment.

## Implemented rules

- **Feel No Pain 5+, Leader, Combat Doctrines and Transhuman Strategist:** linked to the extracted core/faction records and existing shared implementations.
- **Press the Attack:** melee attacks gain Sustained Hits 1 against targets without Monster or Vehicle. If Assault Doctrine is active for his unit, they gain Sustained Hits 1 against any target.
- **Righteous Fury:** optional once per battle per army when Titus is selected to fight. It grants +1 Strength to melee attacks, then heals D3 after the unit fights, or 2D3 if Titus destroyed an enemy model this Fight phase. Healing is capped at his maximum Wounds.
- **Honour of Ultramar:** if Titus is destroyed in the Fight phase before his unit has been selected to fight, roll a D6; on 2+, he remains at 1 Wound until his unit fights or the Fight phase ends. Other units fighting do not prematurely remove him.
- **Anti-non-Monster/Vehicle 2+:** unmodified Wound rolls of 2+ are critical wounds only against targets with neither Monster nor Vehicle; excluded targets use the normal wound threshold.

## Local verification

Focused offline verification passed 15/15 processes, including profile, ability, Fight-phase effects, anti-keyword resolution, attack windows, catalog publication, roster and saved-army regressions. Results: `.tools/verification/20261019T181223215266Z/results.json`. The local runtime export is `.tools/marine-runtime-v107.json`. Network checks were not run, and this does not certify full faction or army legality.

---

<a id="marine-captain"></a>
## Captain — current e11 implementation

`marine-captain.md`

This increment uses the pinned local Wahapedia export only: shared Space Marines source `000000139`, datasheet `000000073`, export updated `2026-10-16T21:03:46+03:00`. The current Captain is one 90-point Tacticus model on a 40 mm base with M6, T5, Sv3+, W5, Ld6+, OC1 and a 4+ invulnerable save. His default weapons are a Master-crafted Bolter, Heavy Bolt Pistol and Master-crafted Power Weapon.

The source equipment choices are represented independently: the Bolter and Heavy Bolt Pistol can be replaced by a Neo-volkite Pistol or Plasma Pistol; the Bolter can instead be replaced by a Relic Shield, which adds 1 to the bearer’s W characteristic; and the Master-crafted Power Weapon can independently be replaced by a Power Fist. The Plasma Pistol has standard and supercharge profiles. These choices are reversible during deployment preparation.

The source lists Leader, Combat Doctrines, Transhuman Strategist, Strategic Acumen, Finest Hour and Relic Shield. The Captain can lead supported eligible units, can be selected as Warlord, and Strategic Acumen activates a locally available doctrine under the shared doctrine-selection limit. Transhuman Strategist grants its Warlord CP at the start of the battle round, once per round while the Warlord is alive. Finest Hour is once per battle and adds 3 attacks and Devastating Wounds to the Captain’s melee attacks for that Fight phase activation. Relic Shield is handled as a loadout and wound characteristic change.

Focused checks passed for the fixed source profile, weapon choices and traits, Relic Shield wound, supported Intercessor attachment, Warlord eligibility, Strategic Acumen, Transhuman Strategist and catalog admission. The bounded local fixed-data comparison has no numeric or identity differences; Captain's default and alternate weapon profiles pass their trait checks. Network validation remains deferred to final integration. Full faction and army legality are not certified.

---

<a id="marine-cato-sicarius"></a>
## Cato Sicarius

`marine-cato-sicarius.md`

This profile uses the local Wahapedia 11th-edition export as its rules source. Cato Sicarius is shared-book datasheet `000004184` (`000000139`), a single 40 mm model for 115 points with M6, T5, Sv2+, 4+ invulnerable, 5W, Ld6+ and OC1. The Artisan Plasma Pistol and all three Talassarian Tempest Blade profiles are transcribed into the runtime profile.

## Implemented scope

- **Leader:** the local export lists Victrix Honour Guard (`000004185`) as Cato's exact bodyguard target. The Victrix profile is now admitted, and Cato can attach to that exact target. Other bodyguards are rejected.
- **Captain of the Honour Guard:** the source changes Cato's Leader role to Support when Marneus Calgar is in the army. Marneus Calgar is now admitted. Local checks confirm that Cato changes to Support only while Calgar is in the army, retains Victrix Honour Guard as his exact target, and cannot be selected as Warlord in that army.
- **Knight Champion of Macragge:** once in the opponent's Movement phase per army, when an enemy unit ends a move within 8 inches and Cato's unit is unengaged, the controller may make a Normal Move up to 6 inches. The implementation validates movement distance, terrain, base spacing, coherency and an unengaged endpoint.
- **Honour or Death:** Heroic Intervention targeting Cato's unit costs 1 fewer CP, to a minimum of 0. The discount is limited to that stratagem and uses the shared reaction cost resolver.
- Combat Doctrines and Transhuman Strategist use the shared current runtime implementations.

## Local checks and boundaries

`tests/test_cato_sicarius.gd` checks the exported profile and weapon traits, ability registration, Warlord eligibility, the exact Leader boundary, Heroic Intervention discount scope, the opponent-movement trigger, optional movement and persisted use state. The local construction catalog admits Cato at 115 points.

The exact Victrix attachment target and Calgar-dependent Support replacement pass local checks. Network validation remains deferred to final integration; this increment does not certify full faction or army legality.

---

<a id="marine-chaplain-jump-pack"></a>
## Chaplain With Jump Pack

`marine-chaplain-jump-pack.md`

Implemented from the local Wahapedia 11th-edition extraction. Source book `000000139`, datasheet `000000112`, export revision `2026-10-16T21:03:46+03:00`. Wahapedia remains the sole rules authority under [project policy](rules-source-policy.md).

## Admitted scope

- One 75-point model: Move 12", Toughness 5, Save 3+, Wounds 4, Leadership 5+, Objective Control 1, 4+ invulnerable save; 40 mm base.
- Fixed source loadout: Absolvor Bolt Pistol and Crozius Arcanum. The pistol is close-quarters; the Crozius has Cleave 1.
- Deep Strike uses the shared reserves resolver. As a Leader, this Chaplain can attach to the locally admitted Assault Intercessors With Jump Packs or Vanguard Veteran Squad With Jump Packs. The extracted page also links Talonstrike Kill Team and Death Company Marines With Jump Packs, whose source books are not yet represented in the local catalog.
- Litany of Hate gives the attached unit's melee weapons Lance through the existing Chaplain rule implementation.
- Exhortation of Rage lets the attached unit re-roll its melee Wound rolls while it is at or below half-strength. The source does not limit this to failed rolls, so the player may choose any eligible Wound die, including a success. Eligibility is evaluated while preparing each melee attack, using the shared Morale half-strength calculation. Ranged attacks do not receive the re-roll.
- The profile is Character-eligible for Warlord selection.

## Validation

The source comparison covers its characteristics, fixed weapons/traits, shared keywords, composition and 75-point cost. The focused local test checks its actual local-catalog admission, allowed Leader links, Deep Strike across the assembled Jump Pack unit, Lance in a prepared Fight attack, and Exhortation before and at the attached unit's half-strength threshold.

The added profile advances the local implementation slice only. Full local regression, network integration and complete Space Marines faction/army legality remain pending.

---

<a id="marine-chaplain-on-bike"></a>
## Chaplain on Bike

`marine-chaplain-on-bike.md`

The Chaplain on Bike is admitted as a fixed-loadout Space Marines profile from the pinned local Wahapedia 11th-edition export. This increment adds its one-model, 75-point profile, Leader attachment to Outrider Squad, Litany of Hate and Catechism of Fire.

## Profile and loadout

The local row is M12, T6, Sv3+, 4+ invulnerable save, W5, Ld5+ and OC2. Its base is a 90 x 52 mm oval; the runtime represents it with the project’s documented 90 mm bounding-circle proxy. The fixed weapons are Absolvor Bolt Pistol, Twin Bolt Rifle and Crozius Arcanum. Weapon characteristics and traits match the pinned extraction.

## Implemented rules

- **Leader:** this admitted build allows attachment to Outrider Squad. The source export also links Ravenwing Black Knights, which is outside the consolidated shared-book construction choices.
- **Litany of Hate:** while the Chaplain source lives, attached unit melee attacks gain Lance.
- **Catechism of Fire:** when the unit is selected to shoot, the player may choose one visible enemy unit. The unit’s ranged attacks against that target gain Devastating Wounds for that Shooting phase. Other targets and melee attacks do not receive the effect.

## Validation boundary

The focused Godot run passed (7/7 selected processes) in [results.json](../.tools/verification/20261019T110640219017Z/results.json). The local fixed-data comparison [v80](../.tools/wahapedia-fixed-data-review-v80.json) covers 40 profiles and 179 weapon-trait profiles; 39/40 bounded checks pass with zero numeric or identity differences. The remaining bounded mismatch is Ancient in Terminator Armour’s `DEATHWING` chapter context. Network validation is deferred to final integration. This does not certify full faction support or full army legality.

---

<a id="marine-chaplain"></a>
## Chaplain — current e11 implementation

`marine-chaplain.md`

Subsequent increment (18 October 2026): [Bladeguard Veterans](space-marines-profile-records.md#marine-bladeguard) are now admitted as an additional Chaplain bodyguard; the historical increment below records the earlier boundary.



Reviewed 18 October 2026 against [Wahapedia Chaplain](https://wahapedia.ru/wh40k11ed/factions/space-marines/Chaplain), datasheet `000001174`, shared book `000000139`, App. Space Marines (11th edition), and the local export updated 16 October 2026, 21:03:46 GMT+3. Chapter and Boarding Actions adaptations are not enabled.

One model costs 60 points, with a 40mm base, M6/T5, four wounds, Leadership 5+, 3+ armour and a 4+ invulnerable save. The fixed equipment is an Absolvor Bolt Pistol and Crozius Arcanum; the sheet has no weapon replacements. The Crozius retains five attacks, WS2+, Strength 6, AP-1, Damage 2 and Cleave 1. Incursion allows two copies.

The Chaplain is selectable as Warlord and may remain standalone or lead the admitted Intercessor, Assault Intercessor, Infernus, Hellblaster and Sternguard profiles. It occupies the Leader slot, so another Leader cannot join the same bodyguard; the existing permitted Support slot is separate. Other linked bodyguards remain outside admission. The model retains its own defense and Leadership when attached.

Litany of Hate gives the current unit's melee weapons Lance while a living battlefield Chaplain source remains. This includes bodyguards and attached characters. The existing charge condition produces +1 to wound when that unit charged; the ability is not an unconditional wound bonus and does not affect ranged attacks or stack another copy of Lance. Source weapons remain immutable; source death removes the passive benefit.

Spiritual Leader is available at the start of Command, Movement, Shooting, Charge and Fight, during either player's turn. It removes Battle-shock from one friendly Astartes unit within 6 inches of the Chaplain model, with no line-of-sight or CP requirement. A shocked Chaplain can use it, including on its own unit. Dead and off-board sources cannot act. Usage is recorded once per battle round against the persistent Chaplain source model, so a second phase, the opponent's turn or attachment changes cannot refresh it. The next battle round restores availability.

The existing start-of-phase window offers the ability and an explicit decline. Other available start effects remain accessible in that window. Clearing a shocked SMOKE unit can restore its eligibility for Smokescreen before the window closes. This interaction is exercised through the public command path, including actor/revision checks and CP recording.

## Controls and validation

The existing ability selector identifies the Chaplain and target, with a full-label tooltip and contextual help explaining range, round limit and zero CP. The inspected real Godot capture `.tools/chaplain-spiritual-leader.png` uses admitted profiles in a staged start-of-Movement fixture at 1600x1000. It is not a completed match or proof of other viewport sizes. The earlier start-window controls remain documented in [the marksmen increment](space-marines-profile-records.md#marine-eliminators).

The [audit](marine-chaplain-audit.json) records the runtime-versus-export numeric comparison and the final local regression. Network validation remains deferred to final integration. Full army, faction, match and imported-mesh visibility certification remain false.

---

<a id="marine-chief-librarian-tigurius"></a>
## Chief Librarian Tigurius

`marine-chief-librarian-tigurius.md`

Wahapedia's local e11 export is the single rules source for this profile. Tigurius is shared-book datasheet `000001611` (`000000139`), one 40 mm model for 115 points, with M6, T5, Sv3+, 4+ invulnerable, 5W, Ld6+ and OC1. The fixed loadout is Bolt Pistol, Storm of the Emperor's Wrath and Rod of Tigurius. The weapon characteristics and traits are transcribed into [the runtime profile](../scripts/edition_11/current_reference_marine_profiles.gd).

## Implemented scope

- **Leader:** Sternguard Veteran Squad, Vanguard Veteran Squad, Infernus Squad, Assault Intercessor Squad, Bladeguard Veteran Squad, Intercessor Squad and Desolation Squad are listed by the source. Six exact identities are selectable and can be attached. The non-Jump-Pack Vanguard Veteran Squad identity is not admitted locally; it is not replaced with Vanguard Veteran Squad with Jump Packs.
- **Hood of Hellfire:** Tigurius and his attached unit receive Feel No Pain 4+ against Psychic attacks and mortal wounds, through the normal wound-prevention flow.
- **Prescience (level 2):** once in Tigurius's own Movement phase, make a psychic test. On a 1 his unit becomes Battle-shocked. His unit gains +1 to saving throws until the start of his next turn.
- **Telepathic Assault (level 1):** once in Tigurius's own Shooting phase, make a psychic test. On a 1 his unit becomes Battle-shocked. Select a visible enemy within 24 inches to suffer 2D3 mortal wounds, routed through ordinary defender allocation and applicable prevention.
- His separate level-2 and level-1 powers each have their own per-turn use, consistent with his source Psyker level 3.
- Combat Doctrines and Transhuman Strategist are inherited from the shared current runtime implementation.

## Local checks and boundaries

`tests/test_chief_librarian_tigurius.gd` checks the local profile values, weapon traits, listed Leader links available in the catalog, Warlord eligibility, Hood of Hellfire, both psychic powers, Prescience duration, Battle-shock on a psychic roll of 1, and Telepathic Assault mortal allocation. The consolidated construction catalog admits the 115-point profile.

The source lists Vanguard Veteran Squad as a Leader target, but that distinct non-Jump-Pack datasheet is not among the locally admitted profiles. The corresponding pairing is therefore unavailable. This increment does not certify full faction or army legality. The fixed-data comparison remains deferred while its available snapshot is structurally invalid; network validation remains deferred to the final integration stage.

---

<a id="marine-combi-lieutenant"></a>
## Lieutenant with Combi-weapon — local rules admitted

`marine-combi-lieutenant.md`

The fixed data baseline was transcribed on 19 October 2026 from the project's pinned Wahapedia 11th-edition extraction: Space Marines App book `000000139`, datasheet `000000076`, export revision `2026-10-16T21:03:46+03:00`. The local extracted tables are the authority for this work.

The admitted profile records one 85-point model on a 40 mm base: M8, T4, Sv3+, W4, Ld6+, OC1. Its fixed equipment is a Combi-weapon (Bolter or Flamer profile) and Paired Combat Blades. The extraction test checks profile characteristics and weapon values/traits against the local sheet.

The local runtime implements the datasheet's Feel No Pain 5+, Infiltrators, Lone Operative, Stealth, Priority Target Identified, and Evade and Survive. The test verifies FNP assignment through the prevention resolver, Lone Operative's 12-inch targeting boundary, standalone detection/cover abilities, visible terrain selection and its temporary detection bonus, and the full D3+3 reactive movement/placement flow. The grounded terrain model uses the existing cylindrical visibility and movement proxies. Focused validation passed 11/11 processes in `.tools/verification/20261019T065023692405Z/results.json`; the 25 Wahapedia import/comparator Python tests also passed. The profile is admitted to the consolidated local construction catalog. Network validation remains deferred to final integration.

Full faction and army legality remain uncertified. The next Space Marines increment should come from the remaining local extracted sheets and undergo the same profile, ability, combat and admission checks.

---

<a id="marine-company-heroes"></a>
## Company Heroes — current e11 implementation

`marine-company-heroes.md`

Implemented 19 October 2026 from the pinned local Wahapedia Space Marines App export (`000000139`), datasheet `000002772`, revision `2026-10-16T21:03:46+03:00`. The sheet uses a fixed four-model composition: Ancient, Company Champion, Company Veteran with Bolt Rifle, and Company Veteran with Heavy Bolter. Each has M6, T5, Sv3+, W4, Ld6+, OC2 and a 40 mm base. The first two units cost 125 points each; a third or later unit costs 145.

The unit materializer keeps the four roles in source order and assigns the source weapons to the appropriate models. The Ancient and Bolt Rifle Veteran carry a Master-crafted Bolt Rifle, Master-crafted Bolt Pistol and Combat Knife; the Champion has a Master-crafted Bolt Pistol and Master-crafted Power Weapon; the Heavy Bolter Veteran has a Master-crafted Bolt Pistol, Master-crafted Heavy Bolter and Combat Knife. Only the Ancient receives the Ancient keyword, and only the Champion receives Champion.

Both current datasheet abilities are enabled:

- **Raise the Banner:** at the end of the controlling player's Movement phase, secure an objective controlled by this unit.
- **Command Squad:** attacks against this unit subtract 1 from Wound rolls. There is no weapon-Strength eligibility condition in the source, and the shared roll-modifier cap still applies.

`tests/test_company_heroes_current.gd` checks the local profile and source identity, all four model roles and weapon assignments, model-scoped keywords, 4-model composition, 125/145 prices, checked-roster admission, both abilities and the Raise the Banner timing. `tests/test_attack_plan.gd` and `tests/test_capabilities.gd` cover adjacent modifier and registry behavior. The fixed-data comparison `.tools/wahapedia-fixed-data-review-v63.json` reports zero numeric/identity differences and all five unique weapon profile/trait checks, default loadout, composition, shared keywords and both source abilities consistent. Its bounded comparison does not itself certify role assignment; the local Company Heroes test covers that mapping.

This is a local source and combat increment, not full army-legality or complete faction certification. Network validation remains deferred to final integration.

---

<a id="marine-darnath-lysander"></a>
## Darnath Lysander

`marine-darnath-lysander.md`

Darnath Lysander is admitted from the local Wahapedia 11th-edition export for the shared Space Marines book: book `000000139`, datasheet `000002105`, export timestamp `2026-10-16T21:03:46+03:00`. The source profile is 160 points for one model, with a 50 mm base, the extracted characteristics and Fist of Dorn (5 attacks, WS 2+, Strength 10, AP -3, Damage 3, Devastating Wounds and Cleave 1). Imperial Fists and Adeptus Astartes are faction identity tags, not global chapter implementations.

The runtime implements the source-listed Deep Strike and Leader abilities; the two Leader targets are Terminator Squad and Terminator Assault Squad. Rampart can be activated once per battle per army in the start-of-phase decision window and gives Lysander a 2+ invulnerable save until that phase ends. Icon of Obstinacy subtracts 1 from hit rolls for attacks targeting his unit.

`tests/test_darnath_lysander.gd` checks the extracted profile, points, both Leader links, Warlord/Transhuman Strategist, phase-start timing and duration for Rampart, its once-per-battle limit, and Icon of Obstinacy for ranged and melee attacks. Network validation remains deferred to final integration. This entry is not a full army-legality certification.

---

<a id="marine-desolation-squad"></a>
## Desolation Squad

`marine-desolation-squad.md`

Current shared-book profile implemented 19 October 2026 from the local Wahapedia 11e extraction: datasheet `000002270`, Space Marines App book `000000139`, export revision `2026-10-16T21:03:46+03:00`. The [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Desolation-Squad) and extracted CSVs are the sole rules authority for this project.

The local catalog admits the fixed five-model unit at 140 points for the first two copies and 150 for the third. Each model has Bolt Pistol, Castellan Launcher, Ceramite Fists and a Superfrag Rocket Launcher by default. Preparation offers Superkrak Rocket Launchers to each model and Vengor Launcher to the Sergeant only; a Vengor adds five points. The profile records M6, T5, Sv3+, W2, Ld6, OC1 and 32mm bases.

Targeter Optics grants Ignores Cover to ranged attacks against visible targets. The Vengor's Indirect Fire profile uses the local Core Rules 10.07 implementation: the attack plan can select Indirect Shooting for an unengaged unit that did not Advance; hidden targets are selectable only for Indirect Fire weapons; those attacks grant cover, cannot re-roll hit rolls and fail on unmodified 1–5, or 1–3 when the firing unit remained stationary and a friendly model can see the target. After the unit shoots this way, it cannot start an action until the phase ends.

Focused local validation passed 14 processes, including the Desolation interaction suite, construction catalog, capability registry and combat regressions. The current local comparison covers 25 admitted profiles and 97 weapon trait profiles with zero numeric or identity differences; 24/25 profiles pass all bounded fixed-data checks. The pending Lieutenant with Combi-weapon data baseline is excluded. The unresolved Ancient in Terminator Armour chapter-keyword context remains outside this sheet. Network validation is deferred to final integration. This does not certify full Space Marine faction coverage or full army legality.

---

<a id="marine-eliminators"></a>
## Eliminator Squad — current e11 implementation

`marine-eliminators.md`

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

---

<a id="marine-eradicators"></a>
## Eradicator Squads — e11 implementation

`marine-eradicators.md`

Reviewed 18 October 2026 from the local Wahapedia export timestamped 16 October 2026, 21:03:46 GMT+3, shared book `000000139`. The joined catalog entries are datasheets `000004231` (Heavy Bolters) and `000004249` (Melta Rifles). Core Melta 24.25 and Hunter profiles 04.01.03 were read from the e11 rules pages because those weapon rules are not defined in the CSV tables. Chapter and Boarding Actions adaptations are not enabled.

| Unit | Admitted scope | Rule |
|---|---|---|
| Eradicator Squad with Heavy Bolters | 3/6 models, 100/215 points, 40mm bases; Bolt Pistol, Heavy Bolter and Ceramite Fists | Overlapping Destruction: during own Shooting, select one enemy; this unit's Heavy Bolters that target it have Blast 1 until the shot is committed |
| Eradicator Squad with Melta Rifles | 3/6 models, 100/200 points, 40mm bases; Bolt Pistol, Melta Rifle with Standard and Hunter profiles, Ceramite Fists; one Multi-melta per three Eradicator models | Total Obliteration: each ranged Damage roll may be re-rolled once. Melta 2/3 adds that value to Damage when the target was within half range at target selection |

The two sheets stay separate for repetition limits, prices and abilities. A Heavy Bolter unit does not gain damage re-rolls, and a Melta Rifle unit does not gain Blast selection. Incursion still admits at most two copies of each sheet, so the export's third-copy prices stay unused. Both are legal Apothecary Biologis bodyguards. Other Leader links on the export remain outside admission.

Melta uses the distance frozen when the target is selected. Hunter profiles can target only a unit that currently has Monster or Vehicle. The Multi-melta choice is available during army preparation, counts only Eradicator models, and can be reversed before preparations finish. Fixed pistol damage opens no re-roll. Keeping a roll spends no CP. A re-rolled Damage die cannot be re-rolled again by Command Re-roll.

Network validation remains deferred. Full army and faction certification remain false.

---

<a id="marine-fire-support"></a>
## Infernus and Hellblasters — current e11 implementation

`marine-fire-support.md`

Implemented 18 October 2026 from the shared App Space Marines e11 pages for [Infernus Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Infernus-Squad) (datasheet `000000126`) and [Hellblaster Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Hellblaster-Squad) (`000002098`). Both belong to source book `000000139` in the reviewed export updated `2026-10-16T21:03:46+03:00`; live pages were rechecked for this increment. Boarding Actions and chapter-specific adaptations are excluded. These records supersede their earlier definition-only status.

| Unit | Admitted configurations | Implemented rule |
|---|---|---|
| Infernus Squad | 5/10 models, 95/190 points; 32mm bases; Pyreblaster, Bolt Pistol and Ceramite Fists | Driven from Cover: after own Shooting, choose one hit enemy; friendly Astartes ranged attacks ignore that target's cover for this phase |
| Hellblaster Squad | 5/10 models, 115/230 points; 32mm bases; both Plasma Incinerator profiles, Bolt Pistol and Ceramite Fists; optional Sergeant Plasma Pistol with both profiles | Rites of Thermal Appeasement: +1 to the specified plasma weapons' Hazard rolls, preserved after Command Re-roll |

The constructor accepts both sizes of the same datasheet in one list. Repetition limits count all sizes together. Current Incursion admission allows at most two copies of each of these non-Battleline units, so third-copy price tiers are not enabled. The two new prices are checked against Wahapedia, not newly certified against GW's MFM. The other ten construction profiles retain their previous source boundaries. Captain Leader and Lieutenant Support pairings now include both units; other leaders remain outside the admitted roster.

New profiles resolve directly from project-owned current data and require current unit abilities enabled. They do not depend on a historical starter-pack record. The list builder maps the two confirmed OpenHammer discovery IDs to these canonical identities and exposes current 5/10 compositions and prices. This matters because the live discovery response still offers incorrect 1/6 compositions and historical prices. The raw discovery catalog is preserved; it is not rules authority. Explicit repricing retains the curated profiles' costs.

Driven from Cover requires an actual hit, not a wound or casualty. A mandatory owner choice separates split-fire targets; the mark does not affect enemies, melee, another target, later phases or later turns. A resolved mark lasts through its phase if the source is subsequently lost. Hazard modifiers are captured per weapon at declaration, rather than applied to the whole unit's hazards; unrelated weapons and Desperate Escape receive no bonus. Pyreblaster has no printed BS; the engine's unused numeric skill placeholder is bypassed by Torrent.

`tests/test_marine_fire_support.gd` covers actual shots, real terrain cover, split targets, effect expiry, source loss, serialization, plasma Hazard thresholds and rerolls, admission/prices/base sizes, mixed 5/10 configurations, combined repetition limits, permitted attachments, discovery overrides and Sergeant-only equipment. `tests/test_army_builder.gd` exercises the actual list controls and repricing. Validation evidence is in [the audit](marine-fire-support-audit.json). Network checks are deferred by user request; this increment does not certify remote play or complete faction/army legality.

Preparation UI brief: reuse the existing Play → Mission and unit choices selector. Only the Sergeant gets a free sidearm replacement before army preparations finish; the inverse choice restores the Bolt Pistol. Preserve existing layout, colors, keyboard controls and confirmation button. The label names the model and destination weapon. Actual staged Godot captures at 1600×1000 were inspected: `.tools/marine-support-setup-before.png` and `marine-support-setup-after.png`. The final label fits; these are fixture captures, not a completed mission or a small-window usability claim.

---

<a id="marine-firestrike-servo-turrets"></a>
## Firestrike Servo-turrets — 19 October 2026

`marine-firestrike-servo-turrets.md`

Source: local Wahapedia 11th-edition export, Space Marines book `000000139`, datasheet `000000086`, exported `2026-10-16T21:03:46+03:00`. The local Wahapedia extraction is the sole rules authority for this project. [Firestrike Servo-turrets on Wahapedia](https://wahapedia.ru/wh40k11ed/factions/space-marines/Firestrike-Servo-turrets).

## Admitted profile

- 1 turret for 80 points or 2 turrets for 160. Each has M5, T6, Sv2+, W6, Ld6+, OC2, and an 80 mm base.
- Default ranged weapon: Twin Firestrike Las-talon (36 inches, A2, BS2+, S10, AP-3, D3+3; Twin-linked).
- Each model may replace its Las-talon with a Twin Firestrike Autocannon (48 inches, A4, BS2+, S9, AP-1, D3; Twin-linked, Rapid Fire 2). The choice is individual to each turret.
- Hovering Bulk is the melee weapon (A3, WS3+, S5, AP0, D1).
- Sentinel Protocols lets this unit be targeted by Fire Overwatch regardless of other uses of that Stratagem in the phase. Once per phase per unit, the unit's snap shooting hits on unmodified 4+ until that Stratagem use is resolved. The usual CP cost and target eligibility remain. Snap shooting still cannot generate Critical Hits or use Hit re-rolls.

## Local validation

Focused offline validation passed **9/9 processes** in `.tools/verification/20261019T044616562986Z/results.json`: import, Python checks, startup, `test_combat_scenario`, `test_core_reactions`, `test_current_unit_abilities`, `test_firestrike_servo_turrets`, `test_implemented_catalog`, and `test_reiver_squad`.

The bounded fixed-data comparison `.tools/wahapedia-fixed-data-review-v20.json` covers **20 profiles / 65 weapon profiles**. Firestrike passes numeric characteristics, weapon traits, shared keywords, default loadout, composition and cost checks. Nineteen of twenty profiles are consistent; Ancient in Terminator Armour remains unresolved for shared-versus-chapter `DEATHWING` context. Network validation and full local regression remain pending. Full faction and army legality are not certified.

---

<a id="marine-gladiator-lancer"></a>
## Gladiator Lancer — current e11 implementation

`marine-gladiator-lancer.md`

Implemented 19 October 2026 from the pinned local Wahapedia Space Marines export, shared book `000000139`, datasheet `000002705`, revision `2026-10-16T21:03:46+03:00`. The fixed reference is one 100 mm base proxy with M10, T10, Sv3+, W12, Ld6+ and OC3. Costs are 160 points for each of the first two copies and 180 for the third-plus tier; local construction supports up to three copies.

The fixed loadout is one Defensive Array (24", A6, BS3+, S5, AP-1, D1, Rapid Fire 6), one Laser Destroyer (72", A2, BS3+, S14, AP-3, D6+3, Heavy) and Armoured Hull (A3, WS4+, S6, AP0, D1). Source keywords are VEHICLE, SMOKE, FRAME and IMPERIUM; ADEPTUS ASTARTES is retained as the runtime faction identity. Shared abilities are Damaged 4, Deadly Demise D3 and Combat Doctrines.

**Aquilon Optics:** the Lancer's ranged attacks targeting an enemy MONSTER or VEHICLE can re-roll one hit roll, one wound roll and one Damage roll. The runtime tracks each allowance once per qualifying target across the current declared attack plan, even when multiple weapons are assigned to that target. Each choice is optional and presented in its corresponding attack step. The Damage window lets the player keep or re-roll the current weapon Damage roll. The effect is excluded from melee attacks and attacks against other target keywords.

`tests/test_gladiator_lancer.gd` checks the pinned source identity, profile and weapons, local points tiers, roster materialization, all three Aquilon checkpoints, target restrictions and melee exclusion. Focused local verification passed 8/8 processes in `.tools/verification/20261019T102800580424Z/results.json`. The bounded local fixed-data comparison `.tools/wahapedia-fixed-data-review-v76.json` includes the Lancer's characteristics, all three weapon profiles, fixed loadout, one-model composition, source keywords and tiered points. Network validation remains deferred to final integration; this increment does not certify full faction or army legality.

---

<a id="marine-gladiator-reaper"></a>
## Gladiator Reaper — current e11 implementation

`marine-gladiator-reaper.md`

Implemented 19 October 2026 from the pinned local Wahapedia Space Marines App export (`000000139`), datasheet `000001667`, revision `2026-10-16T21:03:46+03:00`. The Gladiator Reaper is one 100 mm-base model with M10, T10, Sv3+, W12, Ld6+ and OC3. It costs 165 points for each of the first two copies and 185 for the third-plus price tier.

The model's fixed loadout is Armoured Hull, Defensive Array and Twin Heavy Onslaught Gatling Cannon. The weapon profiles preserve Rapid Fire 12 on the Defensive Array, and Twin-linked plus Sustained Hits 2 and Devastating Wounds against targets without MONSTER/VEHICLE on the cannon. The cannon loses those two conditional traits against a Monster or Vehicle; Twin-linked remains. No replacement options appear on this source sheet.

**Reaping Tally** improves the AP of the unit's ranged attacks by 1 when targeting a unit without the MONSTER or VEHICLE keyword. It does not modify melee attacks. The shared **Damaged 4** effect applies -1 to Hit while the model has 1–4 wounds remaining. **Deadly Demise D3** uses the shared destruction sequence: after destruction roll a D6; on 6, each unit within 6 inches suffers a separately rolled D3 mortal-wound packet.

The base is a 100 mm circle, represented by its 50 mm radius. `tests/test_gladiator_reaper_current.gd` checks the source identity, stats, weapons, prices, catalog publication, materialization, Reaping Tally versus ordinary/Monster/Vehicle targets, conditional cannon traits and the Damaged 4 threshold. The fixed-data audit also checks source loadout, composition, prices and all three weapon profiles/traits. This increment does not certify full faction or army legality; network checks remain deferred to final integration.

---

<a id="marine-gladiator-valiant"></a>
## Gladiator Valiant — current e11 implementation

`marine-gladiator-valiant.md`

Implemented 19 October 2026 from the pinned local Wahapedia Space Marines export, shared book `000000139`, datasheet `000001825`, revision `2026-10-16T21:03:46+03:00`. The fixed reference is one 100 mm base proxy with M10, T10, Sv3+, W12, Ld6+ and OC3. Costs are 165 points for each of the first two copies and 185 for the third-plus tier; the current construction scope supports up to three copies.

The model's loadout is one Defensive Array (24", A6, BS3+, S5, AP-1, D1, Rapid Fire 6), two separate Multi-meltas (18", A2, BS3+, S10, AP-3, D3+2, Melta 3 each), one Twin Las-talon (36", A2, BS3+, S10, AP-3, D3+3, Twin-linked) and Armoured Hull (A3, WS4+, S6, AP0, D1). Source keywords are VEHICLE, FRAME, IMPERIUM and SMOKE; ADEPTUS ASTARTES is retained as its faction identity.

**Priority Target Acquisition:** the Valiant's ranged attacks targeting an enemy unit within 12 inches gain +1 Strength. The check uses the nearest living model-base distance from the Valiant to the target unit, as the Valiant is a one-model unit. All ranged weapons receive the bonus; melee attacks do not. The shared core abilities are Damaged 4, Deadly Demise D3 and Combat Doctrines.

`tests/test_gladiator_valiant.gd` checks the source identity, characteristics, all weapon profiles and traits, both physical Multi-meltas, tiered prices, construction and materialization, Strength against targets within and beyond 12 inches, all ranged weapon instances, melee exclusion and attack-plan propagation. The focused local run passed 8/8 processes in `.tools/verification/20261019T101548046740Z/results.json`, including the exact 12-inch base-edge boundary and a target just outside it. The bounded fixed-data comparison checks the five physical weapon instances, four distinct profiles, uniform loadout, composition, source keywords and tiered costs. This remains bounded local rules support, not complete faction or army-legality certification; network validation is deferred to final integration.

---

<a id="marine-gravis-ancient-batch"></a>
## Gravis Captain and Terminator Ancient — targeted local validation passed

`marine-gravis-ancient-batch.md`

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

---

<a id="marine-gravis"></a>
## Aggressors and Apothecary Biologis — e11 implementation

`marine-gravis.md`

Reviewed 18 October 2026 from the shared App Space Marines e11 [Aggressor Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Aggressor-Squad) (`000002099`) and [Apothecary Biologis](https://wahapedia.ru/wh40k11ed/factions/space-marines/Apothecary-Biologis) (`000000060`) pages. Both have source book `000000139` in the reviewed export updated `2026-10-16T21:03:46+03:00`. Live pages were rechecked; chapter and Boarding Actions adaptations are not enabled by this increment.

| Unit | Admitted scope | Rule |
|---|---|---|
| Aggressor Squad | 3/6 models, 90/180 points, 40mm bases; Flamestorm Gauntlets with Close Quarters/Ranged modes and Twin Power Fists; optional whole-unit Auto Boltstorm Gauntlets + Fragstorm Grenade Launcher package | Close-quarters Firestorm: +1 Strength to unit attacks targeting a unit within 9 inches, including melee and attached Support attacks |
| Apothecary Biologis | One model, 60 points, 40mm base; Absolvor Bolt Pistol and Servo-armature; mandatory Support on admitted Aggressors or Heavy Intercessors | Vivispectral Analysis Targeting: unit attacks gain Lethal Hits against non-Vehicle targets; Monsters remain eligible |

Aggressor range is measured from the unit: one living nearby model suffices for another model's attack. It is not a bonus per source/model and does not stack. Destroyed models cannot establish the range. Flamestorm Ranged has Blast 2; its Close Quarters mode has no Blast. The alternate package replaces the whole unit's ranged inventory, and updates the squad's displayed primary weapon. No EXPLOSIVES keyword is invented from weapon names. Torrent weapons use the existing unused numeric skill placeholder for their printed dash.

Support preparation, formation sealing and Warlord selection now handle Biologis explicitly. Its legal bodyguards are tracked separately from Lieutenant bodyguards when admitting a roster. One Support slot per bodyguard remains enforced. The regular Captain and Lieutenant are not admitted onto Gravis bodyguards by this change. Both Eradicator variants are now admitted Gravis bodyguards. Indomitor Kill Team remains outside current roster admission. A living Biologis propagates the trait through its attached unit; its death removes the benefit from future declarations. Existing attack resolution freezes declared effects. The shared Lethal Hits resolver is reused; this increment does not add a per-critical-hit manual decline window.

Prices come from the selected Wahapedia snapshot. Construction metadata now records a `points_source` per entry and distinguishes these additions from the original MFM reference prices. The list builder uses current curated composition and cost through the confirmed discovery-ID aliases, preserving the raw discovery catalog.

Validation: `tests/test_aggressors.gd` and `tests/test_biologis.gd` cover admission, sizes, prices, base geometry, 9-inch boundaries, living range sources, both weapon packages, engagement restrictions, actual attack generation and wound rerolls, source-data immutability, Support attachment/sealing, invalid pairings, source loss, Monster/Vehicle distinctions, critical-hit automatic wounds and state serialization. [Audit evidence](marine-gravis-audit.json) records the passing local suites and source hashes. Network validation remains deferred by user request; full army and faction certification remain false.

UI brief: reuse Play → Mission and unit choices. Expose one whole-unit Aggressor equipment change during preparations, with an inverse choice to restore Flamestorm. Keep layout, colors and confirmation controls. The shortened label names the unit, the destination package and that it applies to all models. Real staged Godot captures at 1600×1000 were inspected: `.tools/gravis-setup-before.png` showed truncation; `.tools/gravis-setup-after.png` shows the complete shortened label. These capture a setup fixture, not a played mission or a small-window usability test.

---

<a id="marine-guilliman"></a>
## Roboute Guilliman — current Wahapedia 11e implementation

`marine-guilliman.md`

The local Wahapedia export identifies Roboute Guilliman as shared Space Marines datasheet `000000138` in book `000000139`, export revision `2026-10-16T21:03:46+03:00`. His one-model profile costs 415 points and uses a 60 mm base. The default profile, characteristics, invulnerable save, keywords, weapon values and traits, composition and cost pass the bounded local comparison against that export.

The consolidated local construction catalog now offers one copy of the 415-point fixed profile. `Supreme Commander` requires Guilliman to be selected as Warlord; the preparation choice only offers him while he is present. Existing execution covers his other current abilities: Codex Adept keeps all three Combat Doctrines active, Primarch of the XIII grants hit and wound re-rolls of 1 to nearby friendly Adeptus Astartes units, Author of the Codex offers an additional doctrine to a visible nearby unit during Movement, Feel No Pain 5+ applies to each wound, Leader of Astartes grants conditional Lone Operative near friendly Astartes Infantry, and Transhuman Strategist handles his Warlord CP effect.

The Hand of Dominion appears in both ranged and melee profiles but is one physical weapon; its shared `physical_weapon_id` lets the audit compare the source loadout correctly. His Emperor’s Sword keeps the extracted CLEAVE 2 and Devastating Wounds traits.

Focused local validation passed 10/10 processes, including the dedicated Guilliman checks, catalog admission, checked-roster cost/uniqueness, Warlord choice, combat doctrines, attack planning, wound prevention and capability metadata. No network validation was run. This admission does not certify every Gladius interaction, every army-construction restriction, other Chapter variants, or full faction/army legality.

---

<a id="marine-heavy-intercessor-squad"></a>
## Heavy Intercessor Squad — 19 October 2026

`marine-heavy-intercessor-squad.md`

The current 11th-edition profile uses the pinned local Wahapedia extraction as its sole rules source: Space Marines App (`000000139`), datasheet `000001177`, export revision `2026-10-16T21:03:46+03:00`. The sheet is admitted into the consolidated local construction catalog at 5 models / 115 points and 10 models / 230 points. The profile records the Sergeant and Heavy Intercessor characteristics, 40 mm bases, source keywords, Bolt Pistols, Heavy Bolt Rifles and Ceramite Fists.

During army preparation, one non-Sergeant model per five starting models can replace its Heavy Bolt Rifle with a Heavy Bolter. The chosen model receives the extracted 36-inch, A3, BS3, S5, AP-1, D2 profile with Heavy, Sustained Hits 1 and Rapid Fire 2. The choice does not change points. A 5-model unit permits one replacement; a 10-model unit permits two. The Sergeant is excluded.

Unyielding in the Face of the Foe grants +1 to saving throws while the unit controls an objective. The combat save modifier checks that the Heavy Intercessor squad is among the contributing squads on a friendly-controlled objective. Being near a friendly objective controlled by another squad is insufficient. The existing damage-resolution hook snapshots the modifier for the attack sequence.

Local validation: `tests/test_heavy_intercessor_current.gd` checks sourced characteristics, options, points, equipment limit, and objective-control behavior; `tests/test_implemented_catalog.gd` checks local publication. Fixed-data comparison `.tools/wahapedia-fixed-data-review-v57.json` reports all 4 Heavy Intercessor weapon profiles/traits consistent, with no numeric, identity, or keyword-scope differences. Snapshot structural validation passed. Network validation remains deferred; this increment does not certify full army legality or the complete Space Marines faction.

---

<a id="marine-inceptor-squad"></a>
## Inceptor Squad — current e11 local profile

`marine-inceptor-squad.md`

**Source of truth:** the pinned [Wahapedia 11th-edition Inceptor datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Inceptor-Squad) and its local export. Shared-book source `000000139`, datasheet `000000125`, export timestamp `2026-10-16T21:03:46+03:00`. This is not a network check.

## Admitted scope

- Unit composition: 1 Inceptor Sergeant and 2–5 Inceptors. The local construction catalog admits 3- or 6-model units. Points are 130/260 for the first two units and 150/280 for each later unit.
- Profile: Move 10", Toughness 6, Save 3+, 3 Wounds, Leadership 6+, Objective Control 1; 40 mm bases. Keywords: Infantry, Gravis, Jump Pack, Imperium, Fly, Adeptus Astartes.
- Default equipment: each model has Assault Bolters and Ceramite Fists. At army setup, each model may independently replace Assault Bolters with Plasma Exterminators. Standard and Supercharge profiles are available; Supercharge is Hazardous.
- Deep Strike uses the existing all-model ingress flow.
- Meteoric Descent adds +1 to Hit for ranged attacks after this unit made an Ingress move this turn. The shared hit modifier cap still applies; the effect also remains available to out-of-phase ranged attacks in that same turn.
- Parabolic Jetleap is offered at the end of the opponent's Fight phase when this unit is unengaged. Choosing it removes the whole unit into Strategic Reserves; it can return through the shared Deep Strike Ingress flow.

## Local checks

Focused validation is recorded in `.tools/verification/20261019T082438502854Z/results.json` (11/11 processes; 35 Python tests). `test_inceptor_squad` checks source identity, profile data, 3/6 sizes, first-two and third-plus prices, all weapon profiles/traits, per-model plasma replacement, Deep Strike, Meteoric Descent (including out-of-phase attacks), the unengaged end-of-Fight trigger, removal to reserves and the return choice. Adjacent checks cover roster validation, catalog publication, attack planning, doctrines, leaders and current abilities.

The bounded offline comparison `.tools/wahapedia-fixed-data-review-v53.json` includes this as profile 30. It found no numeric or identity differences; the Inceptor profile passes its bounded fixed-data checks, including all four weapon profiles and the Adeptus Astartes keyword context. The full comparison is 29/30 because Ancient in Terminator Armour retains unresolved chapter-specific `DEATHWING` context. The raw source snapshot has structural warnings.

Construction and combat coverage is local and partial. Final network validation remains deferred; this does not certify full Space Marines rules coverage, general reserve legality or full army legality.

---

<a id="marine-incursor-squad"></a>
## Incursor Squad — local Wahapedia implementation

`marine-incursor-squad.md`

Observed 19 October 2026 from the project's local 11th-edition Wahapedia export (book `000000139`, datasheet `000001159`, export timestamp `2026-10-16T21:03:46+03:00`). Wahapedia `/wh40k11ed/` is the sole rules authority for this implementation. The direct sheet is [Incursor Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Incursor-Squad).

## Runtime scope

- 5 models for 90 points or 10 models for 170 points for the first and second units; the third-plus reference is 100/180 points. The consolidated construction catalog admits at most two copies, so it never applies third-plus pricing to an admitted third unit.
- Characteristics: M8, T4, Sv3+, W2, Ld6+, OC1; 32 mm bases. Fixed equipment per model: Bolt Pistol, Occulus Bolt Carbine and Paired Combat Blades.
- The implemented default weapons are Bolt Pistol A1 BS3 S5 AP-1 D1 (Close Quarters); Occulus Bolt Carbine 24 inches A2 BS3 S5 AP-1 D1 (Assault, Ignores Cover); Paired Combat Blades A3 WS3 S5 AP-1 D1 (Sustained Hits 1).
- Scouts 6 is available only when all living models qualify; the shared pre-battle movement and reserve set-up constraints are reused.
- Divinator-class Auspexes can be offered once per phase per Incursor unit when a friendly ADEPTUS ASTARTES unit is selected to shoot. It scans one visible enemy unit within 18 inches; friendly ranged attacks against it re-roll Hit rolls of 1 until the end of the Shooting phase. The effect is integrated with hit-roll rerolls.
- Haywire Mine is optional once per battle in the Incursor unit's Shooting phase: choose a visible enemy within 6 inches, roll D6; on 2+ it suffers D3 mortal wounds, or 2D3 if it has VEHICLE. Wounds use the shared mortal-wound allocation/prevention flow.
- Phobos Librarian and Phobos Lieutenant are linked as Leaders. The external Phobos Captain identity remains inadmitted.

## Validation boundary

Focused offline verification passed 15/15 processes in `.tools/verification/20261019T042405255660Z/results.json`: import, Python checks, startup, and twelve relevant Godot suites covering combat, attack plans, roster/reserves, ability registry, current catalog, Scout and Incursor behavior, and the Phobos leaders. The direct Incursor suite passed with zero failures.

The bounded fixed-data comparison in `.tools/wahapedia-fixed-data-review-v17.json` covers 18 profiles and 59 weapon profiles. Incursor's numeric characteristics, weapon traits, default equipment, composition and price data match the local extraction. Seventeen profiles pass the full bounded comparison; Ancient in Terminator Armour remains unresolved for shared-versus-chapter `DEATHWING` context. Network validation and the full local regression remain pending. Full faction/army legality is not certified.

---

<a id="marine-intercessor-squad"></a>
## Intercessor Squad — local e11 profile

`marine-intercessor-squad.md`

The current Intercessor Squad profile is loaded from the project’s Wahapedia 11th-edition data export, book `000000139`, datasheet `000001157`, export revision `2026-10-16T21:03:46+03:00`. The local profile records M6, T5, Sv3+, W2, Ld6+, OC2, 32 mm bases, and the source keywords Infantry, Battleline, Explosives, Imperium, Tacticus and Adeptus Astartes.

Construction offers 5 models for 85 points or 10 for 170. A default model has a Bolt Pistol, Bolt Rifle and Knives and Fists. The Bolt Rifle exposes Focused Fire (24 inches, A1, BS3+, S6, AP-1, D2, Heavy, Rapid Fire 1) and Saturation (24 inches, A2, BS3+, S5, AP-1, D1, Assault, Rapid Fire 1).

During preparation, the Sergeant can separately replace Knives and Fists with a Chainsword, Power Fist, Power Weapon or Thunder Hammer, and replace the Bolt Rifle with a Chainsword, Hand Flamer, Plasma Pistol or Power Weapon. The Bolt Pistol remains equipped. Each five models permit one non-Sergeant Intercessor to add a Grenade Launcher; the launcher has Frag and Krak profiles. The exported optional weapon profiles are available to the combat resolver.

Bolter Discipline adds 1 to ranged Hit rolls in the unit’s own Shooting phase when the attacking unit or its selected target is in objective range. Tactical Mainstay allows the unit to start actions while Engaged or Battle-shocked and to shoot without that action itself making it ineligible; independent action requirements still apply.

`tests/test_intercessor_current.gd` covers the exported profile and points, construction admission, the Sergeant’s two independent weapon choices, the Grenade Launcher limit for five and ten models, and the ability assignments. The local CSV comparison is recorded in [the fixed-data report](wahapedia-fixed-data-review.md); it finds no numeric, keyword, composition, price or weapon-trait differences for this sheet. Local regression checks are recorded in [verification results](verification/verification-results.md). No network validation has been run. This admission does not certify all Leader links, full roster legality or the full faction.

---

<a id="marine-invader-atvs"></a>
## Invader ATVs — current e11 implementation

`marine-invader-atvs.md`

This increment uses the pinned local Wahapedia export only: shared Space Marines source `000000139`, datasheet `000004247`, export updated `2026-10-16T21:03:46+03:00`. The unit contains one or two Invader ATV models. Each model has M10, T6, Sv3+, W8, Ld6+, OC2 and no invulnerable save. Current unit costs are 65/130 points, with third-and-later copies at 75/140.

Every model defaults to Bolt Pistol, Onslaught Gatling Cannon, Twin Bolt Rifle and Armoured Impact. Each model can independently replace its Onslaught Gatling Cannon with a Multi-melta for 5 points. Twin Bolt Rifle keeps Twin-linked, Assault and Rapid Fire 2. The Onslaught Gatling Cannon has Devastating Wounds only against non-Monster/non-Vehicle targets; Multi-melta has Melta 3. The source says “Use model” for base size; the flat-board runtime uses an explicitly labelled 90 x 52 mm oval footprint proxy for these unbased vehicles.

Aggressive Reconnaissance gives the unit's ranged attacks +1 to wound in its own Shooting phase against an enemy unit that has no other enemy unit within 6 inches. The check measures edge-to-edge distance between the target and other living units belonging to the same opponent. The modifier is frozen into each prepared attack context, combines with the existing modifier cap, and does not apply in Overwatch.

Focused local checks passed for source characteristics, default and replacement weapon profiles, one/two-model construction, first/third-copy costs, per-model Multi-melta selection and cost, attack-phase timing, isolated-target bonus and removal of that bonus when another enemy unit is nearby. The fixed-data report checks this profile's data against the local extraction. Network validation remains deferred; this increment does not certify full faction or army legality.

---

<a id="marine-invictor-tactical-warsuit"></a>
## Invictor Tactical Warsuit — 19 October 2026

`marine-invictor-tactical-warsuit.md`

Source of truth: the local Wahapedia 11th-edition export, Space Marines book `000000139`, datasheet `000001156`, exported `2026-10-16T21:03:46+03:00`. [Invictor Tactical Warsuit source page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Invictor-Tactical-Warsuit).

## Implemented profile

One VEHICLE model: M10, T9, Sv3+, W12, Ld6+, OC4, 90 mm base. Construction charges 135 points for each of the first two copies and 150 for the third-plus copy; the supported copy limit is three.

The default weapons are Fragstorm Grenade Launcher (Blast 1), Heavy Bolter (Sustained Hits 1, Rapid Fire 2), Incendium Cannon (Torrent, Blast 2), Ironhail Heavy Stubbers (Rapid Fire 6), and Invictor Fist. The Incendium Cannon may be replaced by a Twin Ironhail Autocannon (Twin-linked).

- **Damaged 4:** while this model has 1–4 wounds remaining, subtract 1 from its Hit rolls.
- **Deadly Demise D3:** when destroyed, roll one D6; on a 6, each unit within 6 inches suffers a separately rolled D3 mortal-wound packet, allocated through the shared mortal-wound flow.
- **Scouts 8:** before the first turn, the unit may make a normal move up to 8 inches or be set up from Strategic Reserves wholly within its deployment zone; the shared Scout flow checks base placement, coherency and more than 8 inches from enemies.
- **Forward Assault Warsuit:** at the start of the first battle round, mark one enemy unit. The Invictor re-rolls Wound rolls of 1 against its mark. Each time the mark is destroyed, select a new living enemy mark. Replacement selection waits for attack and mortal-wound resolution to finish.

## Local validation

The focused run passed **6/6 processes**, including the Invictor mark lifecycle through a resolved attack, Strategic Reserves eligibility from Scouts 8, capability registry, implemented catalog and startup/import checks. Results: `.tools/verification/20261019T055549579499Z/results.json`.

The bounded local comparison `.tools/wahapedia-fixed-data-review-v35.json` covers 24 runtime profiles and 91 weapon trait profiles; 23/24 pass all fixed-data checks with zero numeric or identity differences. Ancient in Terminator Armour remains unresolved for the shared-versus-chapter `DEATHWING` keyword context. This comparison does not certify optional wargear legality, full faction coverage or full army legality. Network validation remains deferred to final integration.

---

<a id="marine-iron-father-feirros"></a>
## Iron Father Feirros

`marine-iron-father-feirros.md`

Iron Father Feirros is admitted from the local Wahapedia 11th-edition Space Marines export: shared book `000000139`, datasheet `000000127`, export timestamp `2026-10-16T21:03:46+03:00`. The one-model profile costs 85 points and uses the exported characteristics, 40 mm base, Bolt Pistol, Gorgon's Wrath, Harrowhand and Medusan Manipuli.

The runtime implements his four source-listed Leader links (Aggressor Squad, Heavy Intercessors and both Eradicator variants), Feel No Pain 5+, Combat Doctrines, Transhuman Strategist, Master of the Forge, Rites of Tempering and Iron Father. Master of the Forge can be used at the start or end of his unit's move to heal a nearby Adeptus Astartes Vehicle by 3 wounds and let its attacks ignore BS, Hit and Wound modifiers until the next Movement phase. Rites of Tempering gives his unit -1 to Wound when the attacking Strength exceeds that unit's Toughness. Iron Father grants Feirros Lone Operative near a friendly Astartes Vehicle; the core Attached-unit restriction still applies.

`tests/test_iron_father_feirros.gd` checks the source profile, all Leader links, personal Feel No Pain, Warlord eligibility and CP, both Strength conditions for Rites, conditional Lone Operative, deferred end-of-move repair timing, fixed 3-wound healing and modifier protection. The Techmarine regression checks the shared repair machinery. This profile is sourced from the pinned local extraction; network validation remains deferred to final integration. It does not certify full army legality.

---

<a id="marine-judiciar"></a>
## Judiciar — current e11 implementation

`marine-judiciar.md`

Subsequent increment (18 October 2026): [Bladeguard Veterans](space-marines-profile-records.md#marine-bladeguard) are now admitted as an additional Judiciar bodyguard; the historical increment below records the earlier boundary.



Reviewed 18 October 2026 against [Wahapedia Judiciar](https://wahapedia.ru/wh40k11ed/factions/space-marines/Judiciar), datasheet `000002707`, shared book `000000139`, App. Space Marines (11th edition). The local export revision is 16 October 2026, 21:03:46 GMT+3. Chapter, Legends and Boarding Actions variants are excluded.

The admitted fixed profile is one 50-point model on a 40mm base, M6/T5/Sv3/W4/Ld6/OC1. It carries an Absolvor Bolt Pistol and Executioner Relic Blade (five attacks, WS2+, S7, AP-2, D2, Precision and Devastating Wounds). Its 4+ invulnerable save applies only to melee attacks. It has no Explosives keyword or weapon replacements.

The Judiciar occupies the Support slot and must attach before checked preparations finish. Currently admitted bodyguards are Intercessors, Assault Intercessors, Infernus and Sternguard. Hellblasters are ineligible; Bladeguard awaits its own admission. It may be Warlord. Construction checks reserve enough eligible slots across Judiciar and Lieutenant selections, including their overlapping bodyguard choices.

Tempormortis gives its current unit Fights First. The fight queue recalculates this passive from the living battlefield source, preserving charge and Counteroffensive priority independently. Source death or removal stops the passive; a historical ability implementation cannot activate it. When both sides have eligible first-priority units, the existing alternating owner selection remains active.

## Integration and validation

Conditional invulnerable saves are explicit model-defense metadata. Both attachment paths retain the condition without granting it to bodyguards. Attack preparation, grouped defenses, automatic resolution and manual/Precision allocation receive the attack type. General saving throws remain independent, and a better universal invulnerable save takes precedence. Invalid conditional values fail validation even during ranged attacks.

The dedicated suite exercises current admission, prices and weapons, Support declarations, slot competition, save isolation, automatic damage, manual/Precision save evaluation, source removal, historical gating and opposing Fights First selection. Existing controls expose this passive-only unit without an added action window. The selected-model card and technical details explicitly label conditional protection as `InSv 4+ melee`.

The UI brief preserves the existing panel layout, typography, semantic colors and action hierarchy; only saving-throw copy changes. The player must distinguish conditional protection without hover or an extra click. Real Godot captures `.tools/judiciar-defense-before.png` and `.tools/judiciar-defense-after.png` were inspected at 1600x1000 with matching framing and a staged admitted-profile formation (Judiciar attached to Intercessors, model 300 selected). The new text fits the card. These captures do not prove deployment legality, a completed match or other viewport sizes. Historical import identity `8dcb-987c-1ab4-b976` is an alias only; all rules and points resolve from the current Wahapedia profile.

The [audit](marine-judiciar-audit.json) records the numeric comparison and final local regression. Network validation remains deferred to final integration. Full army, faction and match certification remain false.

---

<a id="marine-jump-pack-batch"></a>
## Assault Intercessors With Jump Packs — targeted local validation passed

`marine-jump-pack-batch.md`

18 October 2026. This batch admits Assault Intercessors With Jump Packs to the local runtime and construction catalog using the Wahapedia 11th-edition export as its rules authority. It does not certify the complete Space Marines faction or full army legality.

## Source and fixed profile

Reviewed against the local source record for [Assault Intercessors With Jump Packs](https://wahapedia.ru/wh40k11ed/factions/space-marines/Assault-Intercessors-With-Jump-Packs), datasheet `000002776`, shared Space Marines App book `000000139`, export revision `2026-10-16T21:03:46+03:00`. The source has five or ten models, with 95/190 points for the first two units and 105/200 for the third-plus tier. The current roster catalog cannot assign a cost according to copy index, so construction permits at most two copies. It does not silently price a third at the first/second tier.

The fixed profile matches the source characteristics, base size, composition, default Heavy Bolt Pistol and Chainsword, and two source weapon profiles in the local fixed-data comparison. Hammer of Wrath and Deep Strike are represented for this identity. Only the listed setup choices are exposed: Sergeant pistol and melee replacements, and up to one ordinary model's Plasma Pistol per five-model group. Optional choices are not separately priced because the source lists no additional cost for them.

## Implemented behavior

After this unit completes a charge, Hammer of Wrath offers eligible enemy units it is engaged with as targets, with a skip option. For each living model in the charging unit engaged with that target, the attacker rolls one D6; each 4+ causes one mortal wound. The defender must allocate each mortal wound, with the existing prevention and allocation flow. Charge failure or an invalid target/dice count does not trigger or partially apply the effect.

Deep Strike is recorded as an ability on the profile and continues to use the existing reserve mechanism. This batch adds no leader attachment or chapter-specific rules.

## Preparation UI

The Sergeant and ordinary-model equipment choices use the existing unit-action selector and help area; no panel or layout was changed. I could not make a new Godot capture in this environment because the runtime could not create its `user://` log/cache directory under the workspace sandbox. The suite verifies the generated options and replacement limits, but no new screenshot is claimed.

## Validation

The 16-process local run `.tools/verification/20261019T024716658895Z/results.json` passed, including `test_hammer_of_wrath`, `test_implemented_catalog`, `test_roster_validation`, `test_unit_reserves`, `test_capabilities`, `test_explosives`, and the recent Gravis, Ancient, Phobos and Infiltrator suites. Import, startup and all 30 Python checks also passed in that run. The full local regression remains pending. Network validation was deferred and not run. These checks do not establish full faction rules coverage or full army legality.

---

<a id="marine-jump-pack-captain"></a>
## Captain With Jump Pack — targeted local validation passed

`marine-jump-pack-captain.md`

19 October 2026. This increment admits Captain With Jump Pack from the local Wahapedia 11th-edition extraction as the sole rules authority for this project. It does not certify the full Space Marines faction or full army legality.

## Source and fixed profile

Reviewed against the local source record for [Captain With Jump Pack](https://wahapedia.ru/wh40k11ed/factions/space-marines/Captain-With-Jump-Pack), datasheet `000000083`, Space Marines App book `000000139`, export revision `2026-10-16T21:03:46+03:00`. The fixed 90-point, one-model profile uses the extracted characteristics and default Heavy Bolt Pistol and Chainsword. The local fixed-data comparison matched characteristics, default equipment, weapon traits, size and price.

The setup selector exposes seven supported source combinations: default pistol and Chainsword, Hand Flamer, Plasma Pistol, Power Fist, Relic Weapon, Thunder Hammer with Relic Shield, and Chainsword with Relic Shield. Replacements are represented as complete mutually exclusive sets. Relic Shield grants +1 Wound only to its bearer; changing back removes that wound and shield effect.

## Implemented rules

- **Leader:** may attach to the admitted Assault Intercessors With Jump Packs bodyguard. Other Jump Pack bodyguards remain unavailable until their own profiles and compatibility are reconciled.
- **Deep Strike:** uses the existing reserve implementation.
- **Strategic Acumen:** uses the existing Captain/doctrine use and limit mechanism.
- **Angel’s Wrath:** when its attached unit Advances, add 1 to the Advance result; when it Charges, add 1 to the Charge result. The Advance bonus is applied after any Command Re-roll resolves.
- **Relic Shield:** active only for a Captain equipped with that option, with bearer-only +1 Wound.

## Validation and limits

`tests/test_jump_pack_captain.gd` checks local profile admission, all seven equipment sets, the allowed attachment link, Leader behavior, Advance/Charge modifiers, re-roll ordering and Relic Shield source lifetime. The 13-process batch run `.tools/verification/20261019T025729062171Z/results.json` passed; after adding the explicit pre-attachment assertion, the five-process focused follow-up `.tools/verification/20261019T030130556533Z/results.json` also passed. The local source comparison is in `.tools/wahapedia-fixed-data-review-v7.json`: 11 of 12 exported profiles have consistent fixed-data scope; the remaining Ancient in Terminator Armour is still unresolved for `DEATHWING` chapter context. The Captain’s fixed profile is consistent.

The complete local regression remains pending. Network validation was deferred and not run. Optional enhancements, all possible leader bodyguards, general chapter interactions, and full faction/army legality are outside this increment.

---

<a id="marine-kaius-konorius"></a>
## Kaius Konorius

`marine-kaius-konorius.md`

Profile and rules transcribed from the pinned local Wahapedia 11th-edition export: source book `000000139`, datasheet `000004248`, export revision `2026-10-16T21:03:46+03:00`; [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Kaius-Konorius).

## Profile recorded

- One model, 100 points; M6, T5, Sv2+, 4++, W5, Ld6+, OC1; 40 mm base.
- Heavy Bolt Pistol: 18", A1, BS2+, S5, AP-1, D1, Close-quarters.
- Severance and Rebuke: Strike (5A, WS2+, S10, AP-3, D3, Precision) and Sweep (6A, WS2+, S6, AP-3, D2, Cleave 2).
- Exported Leader targets: Sternguard Veterans, Bladeguard Veterans, Assault Intercessors and Victrix Honour Guard. The currently admitted local choices are the first three; Victrix Honour Guard remains unimplemented.

## Rules recorded in code

- Veteran Bodyguard grants Feel No Pain 4+ against any wounds to other Character models in Kaius's attached unit.
- Calgar's Champion lets Kaius re-roll hit and wound rolls of 1 against an enemy Character unit.

Local profile, source-cost, Leader/Warlord, attached-Character prevention and target-specific attack reroll checks passed. The combined admission run `.tools/verification/20261019T115532567686Z/results.json` also confirms Kaius appears in the 58-choice consolidated catalog. The bounded source comparison includes Kaius and passes all of his fixed-data checks in `.tools/wahapedia-fixed-data-review-v89.json`; its one remaining overall failure is the existing Ancient in Terminator Armour `DEATHWING` keyword context. Network validation remains deferred to final integration, and this increment does not certify full faction or army legality.

---

<a id="marine-kayvaan-shrike"></a>
## Kayvaan Shrike

`marine-kayvaan-shrike.md`

Wahapedia's local e11 export is the rules authority for this profile. Kayvaan Shrike is shared-book datasheet `000002708` (`000000139`), a single 40 mm model for 95 points with M12, T4, Sv3+, 4+ invulnerable, 5W, Ld6+ and OC1. Blackout and Raven's Talons use the source-exported weapon profiles in [the runtime profile](../scripts/edition_11/current_reference_marine_profiles.gd).

## Implemented scope

- **Leader:** may lead Assault Intercessors With Jump Packs and Vanguard Veteran Squad With Jump Packs. Both exact source-listed identities are admitted; neither is substituted with a non-Jump Pack squad.
- **Deep Strike:** uses the existing reserve ingress rules.
- **Lone Operative:** active while Shrike is standalone and disabled while he is part of an attached unit.
- **Trifold Path of Shadow:** Shrike's unit has Stealth and applies a -3 inch detection-range modifier while he is alive on the battlefield. The benefit applies to the combined unit while he leads a bodyguard.
- **Echo of the Ravenspire:** at the end of the opponent's Fight phase, if his unit is unengaged, its controller can place the whole unit in Strategic Reserves. It uses the existing reserve ingress flow when it returns.
- Combat Doctrines and Transhuman Strategist use the shared current runtime implementations.

## Local checks and boundaries

`tests/test_kayvaan_shrike.gd` checks the source profile and weapon traits, both Leader links and an unsupported target, Deep Strike, standalone/attached Lone Operative behavior, Trifold Path's Stealth and detection modifier, Echo's phase/engagement gate and reserve transition, and Warlord/Transhuman Strategist behavior. The consolidated construction catalog admits Shrike at 95 points.

The check covers the current ground-level detection proxy and standard reserve ingress system. Network validation is deferred to final integration; this increment does not certify full faction or army legality.

---

<a id="marine-kor-sarro-khan"></a>
## Kor’sarro Khan — Space Marines e11 increment

`marine-kor-sarro-khan.md`

Source of truth: the local Wahapedia 11th-edition data export. Datasheet ID `000002709`, shared-book ID `000000139`, export timestamp `2026-10-16T21:03:46+03:00`; source page: https://wahapedia.ru/wh40k11ed/factions/space-marines/Kor-sarro-Khan. Network validation remains deferred to final integration.

## Admitted profile

Kor’sarro Khan is one Epic Hero model at 80 points on a 40mm base: M6, T5, Sv3+, invulnerable 4+, W5, Ld6+, OC1. His keywords include Infantry, Character, Epic Hero, Captain, Tacticus, Imperium, Explosives, Adeptus Astartes and White Scars.

- **Anzuq:** 18”, A2, BS3+, S4, AP-1, D2; Close-Quarters, Devastating Wounds, Anti-Infantry 4+.
- **Bolt Pistol:** 12”, A1, BS2+, S5, AP-1, D1; Close-Quarters.
- **Moonfang:** melee A6, WS2+, S6, AP-3, D2; Anti-Character 5+, Precision, Devastating Wounds.

## Implemented rules

- **Leader:** exact local source targets are Bladeguard Veteran Squad (`000000071`), Sternguard Veteran Squad (`000002255`), Intercessor Squad (`000001157`), Assault Intercessor Squad (`000001606`), Company Heroes (`000002772`) and Vanguard Veteran Squad (`000001154`). The jump-pack Vanguard Veterans are not a target. Target availability is bounded by admitted compatible profiles.
- **Combat Doctrines** and **Transhuman Strategist:** existing shared e11 implementations apply.
- **Trophy Taker:** while Kor’sarro is in the unit, attacks that target a CHARACTER unit re-roll Hit and Wound rolls of 1.
- **For the Khan!:** the unit’s ranged attacks have Assault and its melee attacks have Lance.
- **Weapon Anti traits:** Anti-Infantry 4+ and Anti-Character 5+ create critical wounds at the threshold; the critical-wound path correctly interacts with Devastating Wounds and interactive attack resolution.

## Local verification

Focused offline verification passed 15/15 processes, including profile, Leader, ability, catalog, attack sequence, interactive attack window, weapon selection, roster validation and saved-army regressions. Results: `.tools/verification/20261019T175834766365Z/results.json`. The local runtime export is `.tools/marine-runtime-v106.json`. Network checks were not run, and this does not certify full faction or army legality.

---

<a id="marine-land-speeder"></a>
## Land Speeder — current e11 implementation

`marine-land-speeder.md`

Implemented 19 October 2026 from the pinned local Wahapedia Space Marines export, shared book `000000139`, datasheet `000002711`, revision `2026-10-16T21:03:46+03:00`. The fixed reference is one model on a 105 × 70 mm oval, represented by the documented 52.5 mm bounding-circle proxy. It uses M14, T8, Sv3+, W9, Ld6+ and OC3. The first through third Land Speeder costs 105 points each.

The default ranged loadout is Multi-melta (18", A2, BS3+, S10, AP-3, D3+2, Melta 3), Onslaught Gatling Cannon (24", A8, BS3+, S5, AP-1, D1, Devastating Wounds except against MONSTER or VEHICLE) and Stormfury Missile Launcher (48", A1, BS3+, S10, AP-3, D3+3). During army preparation, the Onslaught Gatling Cannon can be replaced with a Pyrecannon (12", A4, Torrent, Blast 2). Armoured Impact is A3, WS4+, S6, AP0, D1. Source keywords are VEHICLE, FRAME, FLY, IMPERIUM, RAVENWING and SPEEDER; ADEPTUS ASTARTES is retained as the runtime faction identity. Deep Strike is available through the existing reserve flow.

**Purgation Run:** after the Land Speeder shoots during its own Shooting phase, its controller can decline or roll D6 and make a Normal Move up to that distance. The move uses the existing preview and confirm flow, stays within the battlefield and supported ground-level terrain/base checks, and must end unengaged. Choosing the ability blocks the unit from declaring a charge until the end of the turn.

`tests/test_land_speeder.gd` covers the pinned source identity, profile, costs, default weapons, Pyrecannon replacement, Deep Strike, restricted Devastating Wounds, post-shot offer, D6 movement, charge restriction and expiry. The broader local validation passed 9/9 processes in `.tools/verification/20261019T104954638154Z/results.json`. Network validation remains deferred to final integration; this increment does not certify full faction or army legality.

---

<a id="marine-librarian-phobos-armour"></a>
## Librarian in Phobos Armour — 19 October 2026

`marine-librarian-phobos-armour.md`

Profile source: [Wahapedia e11 datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Librarian-In-Phobos-Armour), local export `2026-10-16T21:03:46+03:00`, Space Marines App book `000000139`, datasheet `000000119`. The local extraction is the sole rule and profile authority for this increment.

The admitted fixed profile is 75 points for one model. Characteristics, keywords, Bolt Pistol, Force Weapon and the focused/Witchfire Smite profiles are represented from that sheet. The Librarian may Lead the admitted Infiltrator or Eliminator Squad. As with other admitted profiles, this does not establish full faction or army legality.

The runtime implements Leader, Deep Strike, Scouts 6, Infiltrators, Stealth, Psychic Hood and the level-1 Librarius powers. Psychic Hood grants the attached unit Feel No Pain 4+ against Psychic damage. Soul Sight is offered during its unit's Shooting phase against a visible enemy; a Psychic roll of 1 Battle-shocks the unit, otherwise that attached unit's ranged attacks ignore cover against the chosen enemy through the phase. Shrouding is offered when an enemy declares attacks against the unit and resolves before attack dice; a roll of 1 Battle-shocks it, otherwise attacks against it have -1 to hit through the phase. The unit can use only one level-1 Librarius power per battle round.

Scouts resolution is a pre-battle window after deployment and the first-turn roll-off. Eligible units alternate beginning with the first player. A unit already in Strategic Reserves can be set up wholly within its owner's deployment zone; an eligible on-board unit that began wholly in its deployment zone can make a normal move up to 6 inches. Model previews validate movement distance, movement path, coherency, base overlap, battlefield bounds and the requirement to finish more than 8 inches horizontally from every enemy unit. This admitted slice has no Scout-capable transport, so transport Scout movement is not offered.

Focused local validation `.tools/verification/20261019T040442936488Z/results.json` passed 9/9 processes, including the Phobos and Terminator Librarian checks, catalog, roster, capabilities and reserves. Local fixed-data comparison `.tools/wahapedia-fixed-data-review-v14.json` has 16 profiles, 47 weapon profiles and 15/16 fixed-data passes; the remaining Ancient in Terminator Armour keyword context is unresolved. Full local regression and final network validation were not run.

---

<a id="marine-librarian-terminator-armour"></a>
## Librarian in Terminator Armour — 19 October 2026

`marine-librarian-terminator-armour.md`

The current Librarian in Terminator Armour profile (Wahapedia sheet `000000079`, source book `000000139`) is admitted from the local 11th-edition extraction, revision `2026-10-16T21:03:46+03:00`. Its fixed profile costs 80 points and includes a 4+ invulnerable save, Storm Bolter, and Force Weapon (Psychic), with the extracted Smite focused and witchfire profiles. It can Lead the admitted Terminator Squad; the other source Leader links remain outside this admission.

The runtime implements Leader and Deep Strike, the Psychic Hood, and the Librarius ability's two selectable powers. Psychic Hood gives the attached unit Feel No Pain 4+ against damage inflicted by Psychic attacks, including mortal wounds caused by those attacks. Might of Heroes adds 2 Strength to the unit's melee weapons for the relevant Fight phase; a Psychic test result of 1 instead causes Battle-shock. Thunderous Force adds 6 inches to the unit's ranged weapon range for the relevant Shooting phase; a Psychic test result of 1 instead causes Battle-shock. The unit can use only one Librarius power per battle round, and the choices are made through the validated phase action flow.

The sheet's `DEATHWING` tag is conditional chapter context in the extraction, so it is excluded from the shared runtime keyword set. This is not a Dark Angels admission. Weapon fixed-data review covers all four extracted profiles and their Psychic/other traits.

Focused offline validation is recorded in [verification results](verification/verification-results.md): 12/12 processes passed, including the dedicated Librarian test, catalog admission, combat/prevention paths, roster validation, Terminator leaders and reserves. At that increment, the local comparator covered 15 fixed profiles and 43 weapon profiles; the current comparator covers 16 profiles and 47 weapon profiles, with Ancient in Terminator Armour still unresolved for conditional `DEATHWING` context. This validates only the recorded fixed-data and focused runtime scope. Network validation remains deferred to final integration; full faction and army legality are not certified.

---

<a id="marine-librarian"></a>
## Librarian (current Space Marines)

`marine-librarian.md`

The local Wahapedia 11th-edition export identifies this sheet as book `000000139`, datasheet `000002266`, updated with the pinned export at `2026-10-16T21:03:46+03:00`. Its fixed profile is 75 points for one model: M 6, T 5, Sv 3+, W 4, Ld 6+, OC 1, with Bolt Pistol, Smite (Focused Witchfire and Witchfire), and Force Weapon. The data comparison is in `.tools/wahapedia-fixed-data-review-v91.json`.

The local runtime implements the datasheet abilities in this scope: Leader, Librarius level-1 use, Psychic Hood's unit-wide Feel No Pain 4+ against Psychic damage, Veil of Time's Advance replacement and Force Dome's temporary 4+ invulnerable save. The Librarian is selectable from the consolidated local catalog. Local tests cover the attached unit, Warlord eligibility, Battle-shock on a psychic roll of 1, Force Dome expiry, the Advance reroll window and the level-1 use limit. This does not certify full faction or army legality.

Network validation remains deferred until final integration, as requested.

---

<a id="marine-lieutenant"></a>
## Lieutenant — Wahapedia e11 local profile

`marine-lieutenant.md`

Source: shared book `000000139`, datasheet `000001346`, from the local Wahapedia `/wh40k11ed/` export updated 16 October 2026.

The profile records the source identity, 50-point one-model cost, 40 mm base, M6, T5, Sv3+, W4, Ld6+, OC1, keywords, and the exported default Bolt Pistol, Master-crafted Bolter and Ceramite Fists. Its local runtime effects include Support, Combat Doctrines, Tactical Precision (Lethal Hits against targets without MONSTER or VEHICLE), and Demi-company Commander.

Army preparation exposes all source weapon replacements: both pistol choices, Master-crafted Bolter replacements, the combined Neo-volkite package, the independent Ceramite Fists replacements, and the optional Storm Shield. The shield is only available with the Neo-volkite package and grants a 4+ invulnerable save to the Lieutenant model. The shield costs no additional points in the local export. Focused local checks passed; the profile is selectable from the consolidated local catalog. Network validation remains deferred to final integration, and full army legality remains uncertified.

---

<a id="marine-marneus-calgar"></a>
## Marneus Calgar

`marine-marneus-calgar.md`

## Source and admitted profile

- **Rules authority:** Wahapedia 11th-edition local data export, Space Marines book 000000139, datasheet 000004246, export updated 2026-10-16T21:03:46+03:00. [Source page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Marneus-Calgar).
- **Runtime profile:** one Epic Hero model at 180 points, 50mm base; M6, T6, Sv2+, invulnerable save 4+, W6, Ld6+, OC1.
- **Weapons:** Gauntlets of Ultramar ranged profile (18 in, A4, BS2+, S5, AP-2, D2, Close-Quarters, Twin-linked); melee profile (A6, WS2+, S10, AP-3, D3, Twin-linked); Overhead Smash (A1, WS2+, S14, AP-3, D3+3, Extra Attacks, Twin-linked).
- **Keywords:** Infantry, Character, Epic Hero, Terminator, Imperium, Chapter Master, Adeptus Astartes and Ultramarines.

## Implemented rules

- **Codex Adept:** all three Combat Doctrines are active for Calgar’s unit.
- **Master Tactician:** during the owner’s Movement phase, select one visible friendly Adeptus Astartes unit within 9 inches; it gains one unused Combat Doctrine until the start of the owner’s next Command phase. Local checks cover visibility, range, doctrine availability, use limits and duration.
- **Thunderhawk Insertion:** during Declare Battle Formations, choose one friendly Gravis, Phobos or Tacticus unit; every model in that unit gains Deep Strike for the battle.
- **Leader:** the 14 target identities from the local Wahapedia export are recorded. Construction only offers currently admitted compatible targets.
- **Captain of the Honour Guard:** if Calgar is in the army, Cato Sicarius changes from Leader to Support, can attach only to Victrix Honour Guard and cannot be selected as Warlord. These checks pass locally with Calgar present and absent.

## Validation boundary

Focused local validation covers this source profile, composition limit, weapons, target allowlist, pre-battle selection, Deep Strike/reserves, Master Tactician and Cato’s conditional role. The latest artifact is recorded in [verification results](verification/verification-results.md). Network validation remains deferred to final integration. Full faction and army legality are not certified.

---

<a id="marine-outrider-squad"></a>
## Outrider Squad — current e11 implementation

`marine-outrider-squad.md`

Implemented 19 October 2026 from the pinned local Wahapedia Space Marines App export (`000000139`), datasheet `000002712`, revision `2026-10-16T21:03:46+03:00`. The selectable formations contain 3 or 6 models: one Outrider Sergeant and 2–5 Outriders. Costs are 80/160 points for the first two copies and 80/160 for each third-plus size. Each model has M12, T6, Sv3+, W4, Ld6+, OC2 and no invulnerable save.

The fixed loadout is one Heavy Bolt Pistol, Twin Bolt Rifle and Chainsword per model. The Sergeant may replace its Chainsword with a Power Weapon or Thunder Hammer. For every three models, one model may replace its Heavy Bolt Pistol with a Plasma Pistol; this is free and its standard and supercharge profiles retain their separate source traits. The setup choices allow one pistol at 3 models and two at 6 models.

**Full-throttle Assault** applies after the unit made a Charge move this turn. Thunder Hammer melee weapons gain +1 to hit and Sustained Hits 1. Other melee weapons gain +1 Damage and Sustained Hits 1. The ability is applied to weapon copies at attack time, leaving source profiles unchanged. The Thunder Hammer does not also receive the Damage bonus.

The source gives the models 90 × 52 mm oval bases. The prototype stores that source dimension and uses a 90 mm bounding-circle radius as a movement and range proxy; oval-base placement and full geometric legality are not certified. The local leader-attachment rows for Outriders are not enabled by this increment.

`tests/test_outrider_squad_current.gd` checks the local source identity, stats, copy prices, keywords, all seven weapon profiles/traits in the fixed-data comparison, construction and materialization, Sergeant-only melee choices, the Plasma Pistol cap and both charged weapon effects. The fixed-data report also checks the uniform default loadout, 3/6 composition and prices. This increment does not certify full faction or army legality. Network checks remain deferred to final integration.

---

<a id="marine-phobos-batch"></a>
## Phobos batch — targeted local validation passed

`marine-phobos-batch.md`

Targeted local validation ran on 18 October 2026. `test_infiltrator_squad.gd` and `test_phobos_lieutenant.gd` passed, alongside the local catalog, roster, reserve, capability, Infiltrators and Ancient regressions in verification run `.tools/verification/20261019T022024657123Z`. The runner passed 13 processes, including import, Python checks and startup. The full local suite and network validation remain pending; this batch does not establish full army legality.

## Sources and admitted scope

Reviewed 18 October 2026 against [Wahapedia Infiltrator Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Infiltrator-Squad), sheet `000000128`, and [Lieutenant In Phobos Armour](https://wahapedia.ru/wh40k11ed/factions/space-marines/Lieutenant-In-Phobos-Armour), sheet `000002530`, shared App Space Marines book `000000139`. Local export revision: 16 October 2026, 21:03:46 GMT+3. Core [01.02.02, 02.02.04, 24.31 and 24.33](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) govern duration, healing, Scouts and Stealth. Chapter, Boarding Actions and unadmitted bodyguard variants remain excluded.

Infiltrators support 5/10 models at 85/150 points, with M8/T4/Sv3/W2/Ld6/OC1 and 32mm bases. The carbine, pistol and fists use separate fixed weapon instances; the carbine keeps Precision and Rapid Fire. The squad's deployment ability uses the existing ground-board Infiltrators checks. Optional Helix equipment is selected on exactly one Infiltrator during preparation. Selecting another bearer transfers it, and removing it leaves the unit unequipped. It neither replaces weapons nor grants healing without a surviving equipped source.

Helix Gauntlet uses the shared D3 healing preview in the owner's Command phase. It can heal the attached Lieutenant and can return destroyed non-Characters under the existing survivor-first and placement rules. A dead equipped bearer supplies no action. Reset preserves the original budget. Mandatory useful Command healing includes both Helix and Narthecium choices; their labels and usage records remain separate. This batch retains the existing battlefield-source healing scope and does not certify new off-board healing interactions.

Omni-scramblers is a separate Shooting-phase action. Visibility and 18-inch unit range are checked before applying the mark; its detection benefit cannot bootstrap selection of an otherwise invisible target. A phase-stamped target mark adds three inches of detection, expires with the phase and does not stack with another identical mark. It can combine with the different Eliminator Optics bonus. It does not spend CP, consume shooting or require the unit to be unshocked. The once-per-phase source-unit limit is recorded independently of shooting.

The 40-point Phobos Lieutenant has M8/T4/Sv3/W4/Ld6/OC1 on 40mm. Pistol versus carbine is an exclusive reversible preparation swap; melee blades remain. Tactical Precision and Demi-company Commander reuse existing mechanisms. It is a Support and must join admitted Infiltrators or Eliminators before setup can finish. Other source-linked bodies remain outside admission; it does not use the Tacticus Lieutenant's attachment list or Apothecary pairing exception.

## Mixed-unit eligibility

Infiltrators deployment checks now recognize each reviewed provider individually. A Phobos Lieutenant attached to either admitted bodyguard preserves this ability. It does not supply Stealth, so attaching it to Eliminators prevents the whole unit from qualifying for all-model Stealth; their separate unit-level cloak rule is unchanged.

Scouts 6 inches is retained as source metadata on the Lieutenant and its all-model eligibility predicate is explicit. Both currently admitted mandatory bodyguards lack Scouts. Consequently, no legal completed formation introduced here qualifies for a Scout move; no general Scout movement controller is claimed implemented. Supporting future Scout-capable bodies requires implementing that controller before their admission. After combat casualties, an isolated Lieutenant cannot retroactively take a pre-battle Scout move.

Deep Strike is similarly model-specific and requires every model in a unit. The mixed Phobos formations do not qualify. Reserve selection now uses that whole-unit condition, and an unattached mandatory Support cannot enter reserves before formation declarations. Existing complete Terminator formations retain their eligibility. Regression of that shared change is pending the final run.

The profile digest now includes the alternate Terminator Captain, Gravis Captain and Phobos Lieutenant equipment helpers, avoiding silent compatibility changes from alternate loadout data.

## Written tests and UI evidence

`test_infiltrator_squad.gd` covers 5/10-model pricing, mixed-unit deployment eligibility, optional single Helix bearer transfer/removal, D3 healing previews, attached-character healing, revival, excess/usage/source boundaries, detection duration/combination, hidden/out-of-range selection and rejected actor/revision commands.

`test_phobos_lieutenant.gd` covers source stats, Support links, conditional Lethal Hits, mixed Deep Strike/Scouts/Stealth eligibility, exclusive gun swaps across attachment, reserve restrictions and doctrine response. `marine_phobos_fixture.gd` is shared data preparation. Both targeted suites passed. Earlier `test_infiltrators.gd` remains the existing core-deployment suite and was not overwritten.

The UI preserves existing layout, typography and controls. Context help identifies the single optional Helix bearer, transfer/removal, the exclusive Lieutenant swap and detection duration. Healing displays the actual source name. The inspected real Godot capture `.tools/phobos-batch-preparation.png` shows a staged 1600x1000 preparation fixture, the selected Helix option and readable help. No pre-implementation capture or full interaction validation is claimed. It is not a completed match or test-pass report.

Final-run queue: the complete Space Marine suite, including mixed-unit Stealth, detection/Optics, shared healing/Apothecary, Support matching, doctrines, preparation/UI startup and capability metadata. Game/network validation remains deferred to final integration. Runtime inventory is 27 shared-book Marines and four Necrons, with 58 shared-book Marine identities unimplemented. See the [audit](marine-phobos-batch-audit.json).

---

<a id="marine-redemptor-dreadnought"></a>
## Redemptor Dreadnought — 19 October 2026

`marine-redemptor-dreadnought.md`

Source: local Wahapedia 11th-edition extraction, Space Marines book `000000139`, datasheet `000002717`, exported `2026-10-16T21:03:46+03:00`. [Redemptor Dreadnought on Wahapedia](https://wahapedia.ru/wh40k11ed/factions/space-marines/Redemptor-Dreadnought).

## Implemented profile and rules

One model: M8, T10, Sv2+, W12, Ld6+, OC4 and a 90 mm base. The extracted cost is 170 points for each of the first two copies and 190 for the third-plus copy. Macro Plasma Incinerator costs an additional 10 points. The default ranged weapons are Fragstorm Grenade Launchers, Heavy Flamer and Heavy Onslaught Gatling Cannon; the default melee weapon is Redemptor Fist.

The local construction workflow supports the extracted options: Fragstorm Grenade Launchers to Storm Bolters; Heavy Flamer to Onslaught Gatling Cannon; Heavy Onslaught Gatling Cannon to Macro Plasma Incinerator; and add an Icarus Rocket Pod. The Macro Plasma Incinerator carries standard and supercharge profiles, with Hazardous on supercharge. The Icarus Rocket Pod has Anti-Fly 2+. Heavy Onslaught Gatling Cannon's Devastating Wounds and Sustained Hits 2 are restricted to targets without MONSTER or VEHICLE. Optional macro-plasma pricing updates the prepared roster and checks the points cap.

- **Damaged 4:** while the model has 1–4 wounds remaining, its attacks have -1 to Hit.
- **Deadly Demise D3:** on a 6 after destruction, each unit within 6 inches suffers a separately rolled D3 mortal-wound packet. Allocation and chained explosions use the shared local mortal-wound resolution queue.
- **Duty Eternal:** attacks targeting the Redemptor with Strength greater than its Toughness subtract 1 from the Wound roll.

The profile is selectable in the consolidated local construction catalog. This scope implements its fixed profile, listed weapon replacements, checked optional cost, abilities and targeted interactions. It does not certify every roster interaction, full army legality or a full match.

## Local validation

Focused offline validation passed **15/15 processes** in `.tools/verification/20261019T052426603673Z/results.json`. The selected checks include Redemptor, Ballistus, Attack Sequence, unit abilities, army builder, roster admission, combat scenario, Firestrike and Ancient regression coverage. The initial run found missing `damaged_threshold` metadata on the existing Ballistus profile; the metadata was corrected and the focused run passed. After marking Duty Eternal as locally validated in the capability registry, a follow-up run passed **7/7 processes** in `.tools/verification/20261019T052644446467Z/results.json`, including `test_capabilities`.

The bounded fixed-data comparison `.tools/wahapedia-fixed-data-review-v29.json` covers 22 profiles and 79 weapon trait profiles, with zero numeric or identity differences; 21/22 pass all fixed-data checks. Ancient in Terminator Armour remains unresolved for shared-versus-chapter `DEATHWING` context. Network validation is deferred to final integration. Full faction and army legality are not certified.

---

<a id="marine-reiver-squad"></a>
## Reiver Squad — local Wahapedia implementation

`marine-reiver-squad.md`

Observed 19 October 2026 from the project's local 11th-edition Wahapedia export (book `000000139`, datasheet `000002718`, export timestamp `2026-10-16T21:03:46+03:00`). Wahapedia `/wh40k11ed/` is the sole rules authority for this implementation. The source sheet is [Reiver Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Reiver-Squad).

## Runtime scope

- 5 models for 85 points or 10 for 165; one Reiver Sergeant plus four/nine Reivers. Stats: M8, T4, Sv3+, W2, Ld6+, OC1; 32 mm bases.
- Fixed equipment per model: Bolt Carbine (18 inches, A3, BS3+, S5, AP-1, D1; Assault, Precision), Special-issue Bolt Pistol (12 inches, A1, BS3+, S5, AP-2, D1; Close Quarters, Precision), and Monomolecular Combat Knife (A4, WS3+, S5, AP-1, D1; Precision).
- Scouts 6 uses the existing all-model pre-battle move or reserve set-up rules.
- Terror Troops reduces each enemy model's OC by 1 while it is within 3 inches of any living Reiver model. Battle-shock still sets OC to zero.
- Fearsome Assault resolves at the start of the Fight phase, before pile-in. Each unique enemy unit engaged with at least one Reiver unit takes a Battle-shock test with -1 to the roll. A passing test does not clear Battle-shock already in effect.
- Grav-chutes and Grapnel Launchers are optional unit-level equipment. Grav-chutes grant Deep Strike and reserve ingress eligibility while equipped. Grapnel Launchers permit movement paths through models and ignore vertical distance in supported flat-board geometry. Upper-floor movement remains unsupported by the board model.
- Phobos Librarian and Phobos Lieutenant Leader links are admitted; the external Phobos Captain remains excluded.

## Validation boundary

The local focused suite covers the source profile, both model counts and costs, default weapons/traits, Scouts, Leader links, gear-dependent Deep Strike, Grapnel pathing, model-level Terror Troops, Fight-phase Fearsome Assault, its -1 modifier and Battle-shock persistence. The fixed-data comparator is recorded in `.tools/wahapedia-fixed-data-review-v18.json`. Network validation and full local regression remain pending. Full faction/army legality is not certified.

---

<a id="marine-scout-squad"></a>
## Scout Squad — local Wahapedia implementation

`marine-scout-squad.md`

Observed 19 October 2026 from the project's local 11th-edition Wahapedia export (book `000000139`, datasheet `000001160`, export timestamp `2026-10-16T21:03:46+03:00`). Wahapedia `/wh40k11ed/` is the sole rules authority for this implementation. The direct sheet is [Scout Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Scout-Squad).

## Runtime scope

- 5 Scouts for 65 points or 10 for 120; one Scout Sergeant plus four/nine Scouts. Characteristics: M6, T4, Sv4+, W2, Ld6+, OC1.
- Fixed equipment: Bolt Pistol, Boltgun and Combat Knife per model.
- Sergeant may replace Boltgun with Shotgun and Combat Knife with Chainsword. Any Scout may replace Boltgun with Shotgun. Per five models, one Sniper Rifle and one additional special weapon; Heavy Bolter and Missile Launcher share the special-weapon slot. Missile Launcher has Frag and Krak profiles.
- Scouts 6 is available only when every living model qualifies. After deployment and first-turn determination, eligible units alternate; the squad may make a normal move up to 6 inches or set up from Strategic Reserves wholly within its owner's deployment zone. It must finish more than 8 inches horizontally from enemy models.
- Infiltrators applies the current deployment restriction. The linked Phobos Librarian Leader relationship is admitted and tested.
- Flexible Asset allows an otherwise eligible Action to start after the unit is selected to Advance or Fall Back; all other Action restrictions still apply.

## Validation boundary

Focused offline verification passed 13/13 processes in `.tools/verification/20261019T041415760366Z/results.json`: isolated import, Python checks, startup, ten related Godot suites (capabilities, current abilities, roster and reserves, Phobos leaders, Infiltrators, Eliminators, catalog and Scout Squad). The suite covers costs/admission, 5/10 composition, Scout movement, linked Librarian eligibility, action eligibility and wargear caps.

The bounded fixed-data comparator passed Scout Squad across all nine weapon profiles and its default equipment, composition and cost. The full comparison covers 17 profiles, 56 weapon profiles, with 16/17 complete data passes; Ancient in Terminator Armour has unresolved `DEATHWING` context. No network validation or complete local regression was run. Full faction/army legality is not certified.

---

<a id="marine-sternguard"></a>
## Sternguard Veterans — current e11 implementation

`marine-sternguard.md`

Reviewed 18 October 2026 against [Wahapedia Sternguard Veteran Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Sternguard-Veteran-Squad), datasheet `000002255` in shared book `000000139`, and the local export updated 16 October 2026, 21:03:46 GMT+3. The separate Black Templars `Sternguard-Veteran-Squad-1` page remains excluded. Deathwing is a conditional Dark Angels keyword and is not added to the shared runtime profile.

Five models cost 105 points and ten cost 210; Incursion admits at most two copies, so third-copy prices are not used. Models have 32mm bases, T5 and two wounds. The Sergeant starts with a Chainsword; ordinary Veterans start with Ceramite Fists. Everyone retains a Bolt Pistol and an Artificer Firearm with selectable Infernus, Purgatus and Damnatus profiles.

The Sergeant can replace the Chainsword with a Power Fist or Power Weapon. One ordinary Veteran per five Sternguard models may replace the Artificer Firearm with a Heavy Bolter or Pyrecannon. The Sergeant cannot use that option; attached models do not increase the allowance. Replacing a special weapon with another type remains possible at the cap, and restoring the firearm frees the slot. Every option is reversible before army preparation ends.

Veteran Marksmen combines ranged hit re-rolls of 1 with existing hit policies, preserving a stronger re-roll policy. It never permits re-rolling a replacement die, melee hits or snap-shooting hits. The existing resolver applies automatic re-rolls of failed natural 1s. The live unit source also applies to attached models and disappears when no living battlefield Sternguard source remains. Reviewed Captain and Lieutenant attachment links are admitted; other Leader links remain unimplemented.

Artificer profiles retain Assault, their individual Rapid Fire parameters and Damnatus Melta 2. The Pyrecannon uses Torrent and Blast 2. The Heavy Bolter is this sheet's Strength 5 weapon; it does not inherit Eradicator Strength or Overlapping Destruction. Default and optional weapons are covered by the profile digest and match identity.

The existing preparation selector exposes the new equipment choices. A real Godot capture of the admitted preparation fixture is `.tools/marksmen-sternguard.png`; this is staged controls evidence at 1600x1000, not a completed match or a rules certificate. Final local validation is recorded in [the shared audit](marine-marksmen-audit.json). Network validation is deferred; full faction, army and match certification remain false.

---

<a id="marine-storm-speeder-hailstrike"></a>
## Storm Speeder Hailstrike — current e11 implementation

`marine-storm-speeder-hailstrike.md`

Implemented 19 October 2026 from the pinned local Wahapedia Space Marines App export (`000000139`), datasheet `000000124`, revision `2026-10-16T21:03:46+03:00`. This is one 90 mm-base model with M14, T9, Sv3+, W11, Ld6+ and OC3. It costs 110 points for each of the first two copies and 120 for the third-plus tier. Its source keywords are RAVENWING, SPEEDER, IMPERIUM, FLY, VEHICLE and FRAME; ADEPTUS ASTARTES is also retained as its faction identity.

The fixed loadout is one Fragstorm Grenade Launcher (Blast 2, Ignores Cover), one Ironhail Heavy Stubber Array (Rapid Fire 6, Ignores Cover), one Onslaught Gatling Cannon (Devastating Wounds against targets without MONSTER or VEHICLE, Ignores Cover) and Armoured Impact.

**Hailstrike:** in its own Shooting phase, after it shoots, select one enemy unit hit by its attacks. Until the end of that phase, ranged attacks made by friendly ADEPTUS ASTARTES units against that target have Ignores Cover. The selection window only offers living enemy units hit by this Hailstrike's resolved attacks. The common cover-mark flow applies the effect to allied Astartes units, excludes the opposing side and melee attacks, and expires the mark at phase end. The datasheet also grants Deep Strike, Damaged 4 and Deadly Demise D3.

`tests/test_storm_speeder_hailstrike.gd` checks the local source IDs, characteristics, weapons and conditional cannon trait, tiered prices, construction admission, materialization, post-hit target selection, the Hailstrike prompt label, cover removal for later Marine shooting, exclusions and phase expiry. The fixed-data comparison checks all four weapon profiles/traits, source keywords, uniform loadout, composition and tiered costs. This is bounded local support, not a certification of complete faction rules or army legality. Network validation remains deferred to final integration.

---

<a id="marine-storm-speeder-hammerstrike"></a>
## Storm Speeder Hammerstrike — current e11 implementation

`marine-storm-speeder-hammerstrike.md`

Implemented 19 October 2026 from the pinned local Wahapedia Space Marines App export (`000000139`), datasheet `000000114`, revision `2026-10-16T21:03:46+03:00`. This is one 90 mm-base model with M14, T9, Sv3+, W11, Ld6+ and OC3. It costs 140 points for each of the first two copies and 150 for the third-plus price tier. Its source keywords are VEHICLE, FLY, FRAME, RAVENWING, IMPERIUM and SPEEDER; ADEPTUS ASTARTES is retained as the runtime faction identity tag.

The fixed loadout is one Hammerstrike Missile Launcher, one Krakstorm Grenade Launcher, one Melta Destroyer and Armoured Impact. The Melta Destroyer has Melta 3. The source also grants Deep Strike, Damaged 4, Deadly Demise D3 and Hammerstrike.

**Hammerstrike** gives each ranged attack made by this unit Sustained Hits 1 when its target enemy unit is within a terrain area. The runtime uses the existing terrain-area geometry: any living target model whose base overlaps an area qualifies, including when its centre is outside the area. Existing Sustained Hits values are not reduced. The rule does not affect melee attacks. The 11e terrain layout is represented at ground level; upper-floor terrain geometry is not part of this increment.

`tests/test_storm_speeder_hammerstrike.gd` checks source identity, characteristics, fixed weapons, copy-tier prices, local catalog publication, materialization, Deep Strike and the two shared vehicle abilities. Combat checks cover each ranged profile, a base overlapping the terrain boundary, targets outside terrain, no melee bonus, and the Damaged 4 threshold. The fixed-data comparison matches all four weapon profiles/traits, uniform loadout, composition, source keywords and costs. This is a bounded local implementation and does not certify full faction or army legality. Network validation remains deferred to final integration.

---

<a id="marine-storm-speeder-thunderstrike"></a>
## Storm Speeder Thunderstrike — current e11 implementation

`marine-storm-speeder-thunderstrike.md`

Implemented 19 October 2026 from the pinned local Wahapedia Space Marines export, shared book `000000139`, datasheet `000001610`, revision `2026-10-16T21:03:46+03:00`. The fixed reference is one 90 mm base proxy with M14, T9, Sv3+, W11, Ld6+ and OC3. Costs are 140 points for each of the first two copies and 150 for the third-plus tier, with a maximum of three copies represented by the current construction scope.

The fixed loadout is a Stormfury Missile Launcher (48", A2, BS3+, S10, AP-3, D3+3), Thunderstrike Icarus Rocket Pod (24", A6, BS3+, S6, AP-1, D2, Anti-Fly 2+), Thunderstrike Las-talon (36", A2, BS3+, S10, AP-3, D3+3) and Armoured Impact (A3, WS4+, S6, AP0, D1). Source keywords include VEHICLE, FLY, RAVENWING, SPEEDER, IMPERIUM and FRAME; ADEPTUS ASTARTES is retained as its faction identity.

**Thunderstrike:** ranged attacks made by this unit against a MONSTER or VEHICLE get +1 to the Wound roll. The modifier does not apply to melee attacks and is handled with the normal Wound modifier cap.

**Shattered Defences:** in your Shooting phase, after this unit shoots, select one enemy MONSTER or VEHICLE unit hit by its attacks. Until phase end, friendly ADEPTUS ASTARTES ranged attacks against that unit gain +1 AP. The action prompt only offers a qualifying living target that was hit. The mark is owned by the Thunderstrike’s side, applies to allied Astartes ranged attacks, excludes melee and enemy attacks, and expires at phase end. Deep Strike, Damaged 4 and Deadly Demise D3 use the existing current core-rule implementations.

`tests/test_storm_speeder_thunderstrike.gd` checks source identity and revision, fixed characteristics, all weapon profiles and Anti-Fly, construction and copy-tier totals, local materialization, ranged and melee Wound modifiers, hit-qualified MONSTER/VEHICLE selection, the Shattered Defences prompt, AP recipient and attack-type limits, and phase expiry. The focused local run passed 8/8 processes in `.tools/verification/20261019T100916115351Z/results.json`. The fixed-data comparison checks all four weapon profiles and traits, source keywords, uniform loadout, composition and tiered costs. This is bounded local support, not certification of complete faction rules or army legality; network validation remains deferred to final integration.

---

<a id="marine-suboden-khan"></a>
## Suboden Khan

`marine-suboden-khan.md`

Suboden Khan is admitted from the local Wahapedia 11th-edition Space Marines export: shared book `000000139`, datasheet `000004167`, export timestamp `2026-10-16T21:03:46+03:00`. The one-model profile costs 105 points and uses the extracted characteristics, 90 × 52 mm oval base proxy, Heavy Bolt Pistol, Onslaught Gatling Cannon, Stormtooth and Power Sword.

The runtime implements his source-listed Leader link to Outrider Squad, Combat Doctrines and Transhuman Strategist, plus Spear of Chogoris and Skilled Riders. Spear grants Assault to his ranged weapons, permits his unit to charge after Advancing, and gives +1 to its Advance and Charge rolls while Assault Doctrine is active. Skilled Riders grants Mobile to Suboden and the attached unit; Mobile units can move through dense terrain features above 2 inches in this ground-level terrain model.

`tests/test_suboden_khan.gd` checks source identity, points and characteristics, weapon traits, Leader eligibility, Assault on ranged weapons, Advance/charge conditions, Assault Doctrine modifiers and Mobile sharing after attachment. The catalog and capability admission regressions also pass. Fixed-data comparison remains deferred because the available local snapshot did not pass structural validation. Network validation remains deferred to final integration. This profile is not a full army-legality certification.

---

<a id="marine-techmarine"></a>
## Techmarine — local Wahapedia e11 implementation

`marine-techmarine.md`

Status (19 October 2026): admitted to the consolidated local Space Marines construction catalog after targeted local validation. The sole rules source is the pinned [Wahapedia Techmarine datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Techmarine) as captured in the local 11e export at revision `2026-10-16T21:03:46+03:00`, Space Marines book `000000139`, datasheet `000000140`.

The fixed profile is one Techmarine for 55 points, on a 40 mm base, with M6, T5, Sv2+, W4, Ld6+ and OC1. Its Forge Bolter, Grav-pistol and combined Omnissian Power Axe/Servo-arm use the extracted characteristics, ranges and weapon traits. The Grav-pistol's Anti-Vehicle 2+ is resolved as a Critical Wound against VEHICLE targets on an unmodified wound roll of 2 or more.

Implemented datasheet rules:

- **Techmarine:** gains Lone Operative while within 3 inches of a friendly Adeptus Astartes Vehicle unit. The check follows living battlefield models and uses edge-to-edge base distance. The faction identity comes from the local Space Marines definition ID or the explicit Adeptus Astartes keyword; enemy and non-Astartes Vehicles do not qualify.
- **Blessings of the Omnissiah:** at the start or end of this unit's own move in the Movement phase, select one friendly Adeptus Astartes Vehicle model within 3 inches. Roll D3 and restore up to that many wounds, capped at the model's maximum. Its attacks ignore hit and wound modifiers until the start of the Techmarine's next Movement phase. Start timing can be deferred to the end timing; resolve the choice before continuing the move. Reserve set-up is not treated as a move.

Targeted local validation passed in `.tools/verification/20261019T071657757403Z/results.json` (13/13 processes; 34 Python tests). `test_techmarine` covers extracted characteristics and weapons, Lone Operative's dynamic aura and 12-inch targeting boundary, start/end move integration, D3 healing and maximum-wound cap, pending-window restoration, next-Movement expiry, exclusion of reserve set-up, and hit/wound modifier handling in attack planning. `test_attack_sequence` verifies Anti-Vehicle 2+ against Vehicle and non-Vehicle targets. The combat fixture changes an admitted Captain model into a Techmarine to exercise its behavior; the catalog suite separately confirms the actual Techmarine profile is selectable.

The bounded local comparison `.tools/wahapedia-fixed-data-review-v42.json` covers 27 profiles and 103 weapon trait profiles. It reports zero numeric or identity differences and 26/27 fixed-data checks; Techmarine passes all of its bounded checks, while Ancient in Terminator Armour retains the documented chapter-keyword context issue. The extracted CSV snapshot still has structural warnings.

This is targeted local evidence, not full army or faction legality certification. Network validation remains deferred to final integration. The parent Wahapedia CSV snapshot retains its recorded structural warnings; this sheet-level work does not certify that snapshot as clean.

---

<a id="marine-terminator-assault-squad"></a>
## Terminator Assault Squad

`marine-terminator-assault-squad.md`

Current Space Marines 11th-edition profile from the project’s Wahapedia-only local extraction. Source book `000000139`, datasheet `000000118`, export revision `2026-10-16T21:03:46+03:00`; [Wahapedia page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Terminator-Assault-Squad).

## Admitted profile

- Five or ten Terminators; one Sergeant and four to nine Terminators.
- M5, T6, Sv2+, 4++, W3, Ld6+, OC1; 40 mm bases.
- Default weapon: Twin Lightning Claws (A6, WS3+, S5, AP-2, D1, Twin-linked).
- Five models cost 170 points and ten cost 340. Third and later units use 210/380; each Storm Shield adds 5 points.
- Each model may replace its Twin Lightning Claws with a Storm Shield and Thunder Hammer. The shield adds 1 Wound; the hammer is A3, WS3+, S8, AP-2, D3, Devastating Wounds.

## Implemented abilities

- Deep Strike and the existing Teleport Homer declaration/Rapid Ingress flow.
- Terminatus Assault: after a charge this turn, Lightning Claws gain Sustained Hits 1 against targets without MONSTER or VEHICLE; Thunder Hammers gain Sustained Hits 1 against targets with either keyword.
- Storm Shield equipment is selectable model by model during preparation, updates the model’s Wounds characteristic and adds the sourced equipment cost.

DEATHWING remains chapter-conditional and is not applied to this shared-book profile. No leader options are admitted for this squad in this increment. This is focused local profile and combat validation only; network validation is deferred to final integration, and full faction/army legality is not certified.

Validation: `.tools/verification/20261019T111723260184Z/results.json`; fixed-data comparison: `.tools/wahapedia-fixed-data-review-v83.json`.

---

<a id="marine-terminator-captain"></a>
## Captain in Terminator Armour — current e11 implementation

`marine-terminator-captain.md`

Reviewed 18 October 2026 against [Wahapedia Captain In Terminator Armour](https://wahapedia.ru/wh40k11ed/factions/space-marines/Captain-In-Terminator-Armour), datasheet `000000135`, shared App Space Marines book `000000139`. The pinned [export](https://wahapedia.ru/wh40k11ed/the-rules/data-export/) revision is 16 October 2026, 21:03:46 GMT+3. [Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) reroll, charge, weapon-selection and Torrent semantics apply. Chapter/Deathwing and Boarding Actions adaptations are outside this shared-book admission.

One model costs 90 points: M5/T6/Sv2/W6/Ld6/OC1, 4+ general invulnerable save and the source's 40mm base. This Captain is a separate identity and does not receive the ordinary Captain's Finest Hour. Its admitted bodyguard is Terminator Squad; other sheet links remain unadmitted. Existing mechanisms provide Deep Strike, Strategic Acumen and Transhuman Strategist. Current checked construction takes its price from the reviewed profile and accounts for its full 90 points when attached for reserves.

Two independent preparation swaps are reversible before setup finishes: Storm Bolter to Combi-weapon, and Relic Weapon to Relic Fist. The swaps preserve one another across attachment. The Combi-weapon is one weapon instance with three alternative profiles: Infernus, Purgatus and Damnatus. A declaration may use one of them, and cannot fire two profiles of that instance. Existing Torrent/Blast, Melta and random damage mechanisms resolve the relevant modes.

The Infernus row prints no BS. Runtime zero represents that absent stat only when Torrent provides automatic hits. Attack validation v5 accepts this narrow case while rejecting zero BS without Torrent; older Torrent weapons with a numeric stored BS retain their behavior. A dedicated check resolves automatic hits in cover without hit dice. The combat log does not display a worsened BS when no hit rolls were made.

## Unstoppable Valour and decision flow

The checked current-match reaction infrastructure now offers a free charge reroll when the living Captain is in the charging unit. It works at zero CP, with paid movement rerolls disabled, and while battle-shocked. The player can accept the original result or replace both D6. The replacement is mandatory even when worse. Either decision closes the window before target selection; another free or paid reroll of those dice is rejected. A failed charge still consumes that unit's charge declaration.

This datasheet choice is independent of Command Re-roll expenditure and usage. If the paid movement option is enabled and the unit is eligible, the player can instead use Command Re-roll normally. Enabling only attack rerolls does not enable the paid Advance/Charge option in a free ability window. No rerolling of only one charge die is exposed. Actor, squad, revision, phase and dice validity checks precede commitment. Free reroll scope is the current checked match with reaction infrastructure enabled; training combinations with core reaction infrastructure disabled are not newly supported.

## UI brief and validation

The player needs to distinguish accepting, paying for a reroll and using this free datasheet rule. Existing layout, typography and colors are preserved. The existing free-reroll button adapts its label and callback to the active ability, retaining Sudden Storm for Advance. Context help states zero CP, both D6, mandatory replacement and no second reroll. The top decision message names the available free ability. Equipment choices use the existing selector and explain independent replacements and alternative Combi profiles.

Real Godot before/after captures at 1600x1000 were inspected: `.tools/terminator-captain-before.png` and `.tools/terminator-captain-after.png`. Both use the same staged attached-unit Charge fixture, fixed [1,1] dice, zero CP, camera and framing. Before UI integration the free rule was absent from the controls and the message pointed to a disabled paid reroll. After integration the free action and its consequences are visible. These are staged decision captures, not completed-match or network evidence; equipment-selector help and all viewport sizes were not separately captured.

The dedicated suite covers admission, stats, base, distinct ability identity, attachment boundaries, independent and reversible equipment, all three Combi modes, rejection of multiple modes in one declaration, Strategic Acumen, free versus paid charge choices, mandatory lower results, dead source, Battle-shock and rejected actor/revision/dice commands without mutation. The [audit](marine-terminator-captain-audit.json) records 46 runtime-versus-export comparisons across default and alternate profiles, with explicit Deathwing exclusion and no-BS normalization. Regression covers the attack engine/checkpoints, equipment, movement decisions, core/detachment reactions and checked admission/preparation.

Network validation remains deferred to final integration by user instruction. Full faction, army and match certification remain incomplete.

---

<a id="marine-terminator-chaplain"></a>
## Chaplain in Terminator Armour — current e11 implementation

`marine-terminator-chaplain.md`

Reviewed 18 October 2026 against [Wahapedia Chaplain In Terminator Armour](https://wahapedia.ru/wh40k11ed/factions/space-marines/Chaplain-In-Terminator-Armour), datasheet `000000115`, shared App Space Marines book `000000139`, and [Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) 19.01, 19.04 and 24.12. The pinned export revision is 16 October 2026, 21:03:46 GMT+3. Chapter and Boarding Actions adaptations remain excluded. In particular, the consolidated DEATHWING keyword is not admitted into this shared-book profile.

One model costs 75 points: M5/T6/Sv2/W5/Ld5/OC1, general 4+ invulnerable protection and 50mm base. Fixed default equipment is Storm Bolter and Crozius Arcanum. The former retains Rapid Fire 2; the latter Cleave 1. During preparation the bearer may exchange its bolter for Relic Shield, increasing its maximum wounds to six. The crozius remains and the shield adds no shooting weapon. Swapping back restores the bolter and five wounds; both declarations remain available after attachment and before preparation finishes.

This is a separate Leader from the ordinary Chaplain. Its admitted bodyguard is Terminator Squad. Other sheet links are outside current admission. It has Deep Strike and can enter the existing checked reserve/ingress flow alone or with its eligible attached bodyguard. It grants the unit melee Lance through the existing Litany of Hate mechanism, and does not gain Spiritual Leader from the ordinary Chaplain.

Zealous Fortitude grants the whole current unit Feel No Pain 4+ against mortal wounds. A shared `unit_prevention.gd` derives unit grants from living battlefield sources and combines them with personal prevention rules. The existing wound-prevention engine selects the best applicable threshold and rolls once per prospective wound; a second rule does not create another prevention roll. Ordinary damage receives no benefit from this grant. Attack allocation snapshots retain the unit effect until that attacking unit finishes, as required when its source dies during the attack sequence. Outside that sequence, source death or removal stops the grant. Historical implementations do not acquire it, and malformed personal rules remain validation errors.

The same effective prevention rules feed automatic/manual attack allocation, Hazardous, escape mortal wounds and Explosives. Tests exercise actual automatic and manual devastating-damage allocation, direct escape allocation, mortal versus ordinary packets, overlapping prevention, source loss and historical isolation. Existing Hazardous and Explosives suites provide regression coverage; they do not prove every possible new mixed-unit interaction.

## Reserve cost correction

Attaching a Character now adds its construction cost to the body's stored unit cost. A Terminator unit with this Chaplain therefore costs 265 points for the existing half-points reserve limit. A staged 500-point limit rejects that assignment; a 1000-point limit accepts it and records 265. Attaching either side after it has been assigned to reserves is blocked, avoiding an orphan source reservation. Finish formation declarations before assigning reserves. Other reserve caps, missions and unadmitted transport interactions are not newly certified by this change.

## UI brief and evidence

The player needs to see exactly what the shield replaces and which model gains the wound. Existing viewport, layout, type, color and controls are preserved; only the option label and contextual help change. The label is shortened to fit. Help states the removed bolter, retained crozius, six-wound bearer and reversible preparation choice.

Real Godot before/after captures at 1600x1000 were inspected: `.tools/terminator-chaplain-before.png` and `.tools/terminator-chaplain-after.png`. Both use the same staged admitted-profile preparation fixture, framing and unshielded bearer. The initial label was clipped and generic help omitted the replacement; the revised label and contextual explanation fit. A third real capture, `.tools/terminator-chaplain-shield.png`, shows the successful swap, W6/6 and the option to restore the Storm Bolter. These staged captures do not establish a completed match or every viewport size.

The [audit](marine-terminator-chaplain-audit.json) records 22 comparisons of runtime characteristics, weapon numbers, cost, base and scoped keywords against the local export. Dedicated and regression suites cover admission, preservation of the ordinary Chaplain, protection, equipment, attachment and reserves. Network validation remains deferred to final integration by user instruction; full army and match certification remain incomplete.

---

<a id="marine-terminator-squad"></a>
## Terminator Squad — 19 October 2026

`marine-terminator-squad.md`

The current 11th-edition record is sourced from the pinned local Wahapedia extraction: Space Marines App (`000000139`), datasheet `000001183`, export revision `2026-10-16T21:03:46+03:00`. The admitted profile uses one Terminator Sergeant and four to nine Terminators, at 5/10 model sizes. The first two units cost 190/380 points; the third and later cost 230/420. Models use 40 mm bases.

Every model starts with a Storm Bolter and Power Fist. The Sergeant can replace its fist with a Chainfist or Power Weapon. Any number of regular Terminators may replace their Power Fists with Chainfists. For each five starting models, one regular Terminator may replace its Storm Bolter with an Assault Cannon or Heavy Flamer, or take a Cyclone Missile Launcher while keeping the Storm Bolter. A 10-model squad can assign two such weapons. Each Cyclone Missile Launcher adds 10 points.

The current profiles include the source Assault Cannon (Sustained Hits 1), Heavy Flamer (Torrent, Blast 2), Cyclone frag/krak profiles, both exported Chainfist profiles and Power Weapon. The Cyclone weapon action adjusts the admitted points total and the model's loadout; switching away from it removes its surcharge.

Deep Strike, Fury of the First and Teleport Homer already have runtime effect hooks. Fury of the First improves AP by 1 when the target is within 9 inches of the attacking Terminator unit. Teleport Homer is declared at the start of the battle; its Rapid Ingress use costs 1 fewer CP, must arrive within 3 inches of the token and more than 8 inches from enemies, and removes the token after use. The token is also removed when an enemy move ends within 1 inch.

Local validation: `tests/test_terminator_squad_current.gd`, `tests/test_implemented_catalog.gd`, and `tests/test_army_builder.gd` check source profiles, size/copy tiers, optional-equipment limits, Cyclone points and roster previews. Fixed-data comparison `.tools/wahapedia-fixed-data-review-v63.json` reports all 9 Terminator weapon profiles/traits consistent, source composition and default loadout consistent, and the shared-keyword context consistent. Snapshot structural validation passed. Network validation remains deferred; full army legality and complete Space Marines support are not certified.

---

<a id="marine-tor-garadon"></a>
## Tor Garadon

`marine-tor-garadon.md`

Tor Garadon is admitted from the local Wahapedia 11th-edition export: shared book `000000139`, datasheet `000002473`, export timestamp `2026-10-16T21:03:46+03:00`. The profile is 90 points for one model, with its extracted characteristics, 40 mm base, Artificer Grav-gun and Hand of Defiance. Faction keywords Adeptus Astartes and Imperial Fists remain identity tags; this does not implement an army-wide Imperial Fists rule.

The runtime implements Leader with the four linked datasheets in the local export: Aggressor Squad, Heavy Intercessor Squad, Eradicator Squad with Heavy Bolters and Eradicator Squad with Melta Rifles. Siege Captain adds 2 Strength, AP and Damage to Tor's attacks against Fortification, Monster or Vehicle targets. Signum Array is selectable once during the owner's Shooting phase against a visible enemy within 18 inches and removes that target's benefit of cover for the phase.

`tests/test_tor_garadon.gd` checks the source profile, catalog admission, a legal and an ineligible Leader pairing, Siege Captain against all three target keyword groups, Signum Array range/visibility/timing/use limit, and cover denial in an attack context. Network validation remains deferred to final integration. This entry is not a full army-legality certification.

---

<a id="marine-transports"></a>
## Space Marine transports — local implementation record

`marine-transports.md`

Status: internal rules work in progress, not admitted for army construction. Source: local Wahapedia 11th-edition export, book `000000139`, revision `2026-10-16T21:03:46+03:00`, plus the local 11e Core Rules capture. This record does not claim network validation or full legality.

## Implemented and locally checked

- A reproducible import creates eight source-linked profiles: Land Raider, Land Raider Crusader, Land Raider Redeemer, Drop Pod, Impulsor, Repulsor, Repulsor Executioner and Rhino.
- The rules engine reads the local profiles, checks friendly passengers, source-listed keyword inclusions/exclusions, full-unit capacity, Gravis/Terminator double-space costs, battlefield/range eligibility and the rule against embarking after being set up this turn.
- Army-preparation embark choices remove passenger models from the battlefield. Deployment omits embarked squads.
- Movement-phase embark choices require the passenger unit to have made a Normal, Advance or Fall Back move; every model must be within 3 inches and the transport must have room.
- Rapid/Tactical/Combat/Assault/Shock placement windows validate their source distances, board bounds, base overlap and unit coherency. Stationary transports require Tactical mode when a legal formation can be placed; otherwise Combat is mandatory. Combat uses 6 inches, allows engagement only with enemy units already engaged with the transport, and leaves the passengers Battle-shocked and unable to charge. Assault Ramp permits Assault Disembark after a Normal move; Impulsor Shock Disembark is available after Advance and blocks charging.
- Every regular Disembark mode now makes one Hazard roll per passenger model before placement. The passenger owner allocates failed-roll mortal wounds through the local prevention rules; the placement window opens after allocation finishes.
- When a destroyed transport has passengers, its emergency sequence now runs before Deadly Demise resolves: one Hazard D6 per passenger model, owner-allocated mortal wounds with applicable prevention, active-player placement within 6 inches in coherency and as close as possible. Models must be unengaged when possible; if no unengaged placement exists they may be set up engaged, and are destroyed only if no placement exists. Survivors become Battle-shocked and cannot charge this turn. The transport leaves the battlefield after all passenger units finish; the shared destruction queue then resumes.
- Rhino Veiling Smoke is wired into the local Smokescreen rule: the Rhino can use it once per phase for 0CP without blocking a separate unit's use, while the Rhino itself remains limited to one use that phase.
- Emergency placement uses the game's circular base proxies and samples legal positions in 0.1-inch radial steps / 5-degree angles to enforce “as close as possible”. This is the project's board-geometry approximation, not exact imported miniature geometry.
- Tactical availability samples 0.1-inch radial steps / 5-degree angles and searches coherent formations with a bounded budget; when that search is inconclusive it keeps Tactical mandatory. These checks use circular base proxies and are not exact imported miniature geometry.
- The shared 3-inch set-up distance, passenger eligibility, capacity, placement and Rapid/Tactical/Combat/Assault/Shock state transitions have targeted local Godot checks.
- An end-to-end local destruction test covers passenger Hazard, allocation, Emergency Disembark placement and resuming the destruction queue.
- A local Rhino test covers Veiling Smoke's free use, per-Rhino limit, separate unit use and overlapping Smokescreen sources.
- Drop Pod Assault automatically places each Drop Pod in Strategic Reserves during preparation, applies the half-army reserve cap, and offers its own ingress in the owner's first Movement phase. Arrival begins compulsory passenger disembarkation; each passenger must be set up more than 8 inches from every enemy. Passenger units resolve in sequence, including their Hazard rolls, and Deployment Complete blocks later embarkation. Targeted local Godot checks cover these steps.
- Repulsor Executioner's ranged attacks gain +1 to Hit against targets that are not below half-strength. The threshold follows the local Core Rules definition, so exactly half-strength still qualifies. The attack-plan check exercises both multi-model and single-model wound thresholds.
- Repulsor Combat Embarkation opens a defending-player reaction after the charging unit's targets are selected and before any model moves. The defender may embark one selected, unengaged friendly ADEPTUS ASTARTES unit eligible to embark and wholly within 3 inches; a unit set up this turn is excluded. The charge target list is updated, and the charger may revise targets before placement. Passing is optional, and the reaction does not repeat for that charge. Local checks cover eligibility, player ownership, pass/embark, removing the embarked target, retargeting and resuming placement.
- The Land Raider's Power of the Machine Spirit offers one optional Hit and one optional Wound re-roll across that unit's ranged attack activation; Hit re-rolls are unavailable for Snap Shooting and Indirect Fire. The Land Raider Crusader gains Lethal Hits against targets within 12 inches, and the Land Raider Redeemer gains Devastating Wounds against non-MONSTER, non-VEHICLE targets within 12 inches. These effects are resolved against each model's current transport profile and local attack checkpoints.
- Impulsor preparation now exposes its source-list wargear choices: optional Bellicatus Missile Array, Orbital Comms Array (+10 points), Ironhail Skytalon Array or Shield Dome; optional Storm Bolter replacement with Fragstorm Grenade Launchers; and optional Ironhail Heavy Stubber. Chosen arrays are added to the local weapon inventory, while Orbital Comms Array grants Scouts 6 and Shield Dome supplies a 5+ invulnerable save. Point cost changes are reflected in the match's local training-point total and rejected if they exceed its limit.
- Bellicatus Missile Array's Frag, Icarus and Krak profiles are exposed through the shared weapon selector and can be assigned to a legal ranged target. Local checks compare each selected attack plan's characteristics with the extracted Wahapedia profile.
- The shared One Shot profile ability is now enforced by the ranged attack sequence: use is recorded per model and weapon when its attack declaration enters resolution, and later declarations with that same weapon are rejected. The local Land Raider Hunter-killer Missile profile checks its use limit, while a second One Shot weapon on that model retains its separate use.
- **Firing Deck** is implemented from the local core ability row `000008334` and datasheet parameters: Impulsor Firing Deck 7 and Rhino Firing Deck 2. In the transport's Shooting-phase attack plan, the existing weapon selector exposes eligible weapons from embarked models, labels their passenger source and excludes One Shot profiles. The server enforces one ranged weapon profile per selected passenger model and the model limit. When the transport is selected to shoot, every unit embarked within it is blocked from shooting until the end of that turn, including when no passenger weapons are selected. The transport resolves selected weapons using its position, target range and attack activation; its own weapons remain selectable alongside them. The targeted local Godot check covers parameter loading, already-shot passenger exclusion, One Shot exclusion, per-model and Rhino model limits, attack resolution and passenger shooting locks.
- Land Raider, Land Raider Crusader and Land Raider Redeemer preparation exposes the source-listed Hunter-killer Missile, Multi-melta and Storm Bolter additions. Their local weapon profiles enter the live attack inventory, and no points surcharge is added because the source profiles list none for these options.
- Rhino preparation exposes its optional Hunter-killer Missile through the same transport-weapon flow; the local profile adds One Shot and the selected weapon can enter the attack sequence.
- Repulsor preparation independently replaces its Heavy Onslaught Gatling Cannon with a Las-talon and its Twin Heavy Bolter with a Twin Lascannon. Repulsor Executioner can replace its Heavy Laser Destroyer (+10 points) with a Macro Plasma Incinerator; both Standard and Supercharge profiles are selectable. Replacements are reversible before deployment and enforce the local army points limit.
- Local transport profile loading converts extracted AP strings to numeric values before building attack plans; the Repulsor Executioner attack test resolves against its source weapon profile.

## Local construction admission

- All eight source profiles are now selectable through the consolidated local e11 catalog. Rhino and the other seven transports pass focused checks for source prices, unit limits, roster admission, current-ability materialization and the shared transport runtime. Drop Pod materializes with empty ranged and melee inventories, as listed in its source profile.
- This admission covers bounded local rule support and does not certify complete faction composition or full army legality. Network validation remains deferred to final integration.

Wardens of Ultramar was added after the transport increment; see [its profile and local checks](space-marines-profile-records.md#marine-wardens-ultramar). All 85 shared-book Marine identities are now selectable.

---

<a id="marine-vanguard-veterans-jump-packs"></a>
## Vanguard Veteran Squad With Jump Packs

`marine-vanguard-veterans-jump-packs.md`

Implemented from the project's local Wahapedia 11th-edition extraction. Source book `000000139`, datasheet `000000147`, export revision `2026-10-16T21:03:46+03:00`. Wahapedia is the rules authority under [project policy](rules-source-policy.md); no other rules source was used to resolve this datasheet.

## Admitted scope

- One Sergeant and four to nine Vanguard Veterans; supported sizes are five or ten models. Characteristics: Move 12", Toughness 5, Save 3+, Wounds 2, Leadership 6+, Objective Control 1; 32 mm base.
- Points: 110/220 for five/ten models among the first two copies; 130/240 for the third-plus tier. Construction allows up to two copies because its local catalog has one unit price per identity and cannot correctly price a different third-plus tier per copy.
- Default equipment is role-specific: the Sergeant has a Heavy Bolt Pistol and Relic Blade; other models have a Heavy Bolt Pistol and Master-crafted Power Weapon.
- Models may replace their Heavy Bolt Pistol with a Plasma Pistol or Combat Shield. Ordinary Veterans can take at most two Plasma Pistols for every five models. The Sergeant has an independent pistol choice. A Combat Shield replaces the pistol and gives only its bearer a 5+ invulnerable save.
- The Sergeant may replace the Relic Blade with a Power Fist or Thunder Hammer. Alternate profiles preserve their extracted traits, including Hazardous on Plasma Pistol Supercharge and Devastating Wounds on the Thunder Hammer.
- Deep Strike uses the shared reserves implementation. Vanguard Assault adds one Attack to melee weapons while the unit has made a Charge move this turn. The Fight-phase attack planner is covered by the targeted test.
- Captain With Jump Pack is an allowed Leader from the extracted attachment link. Conditional `DEATHWING` is retained as chapter-context metadata and is not injected into the shared unit keyword set.

## Validation

The fixed-data comparison checks characteristics, default equipment by role, weapon profiles and traits, shared keyword scope, composition, and both points tiers. Targeted local tests check five/ten-model admission, the two-copy boundary, Leader attachment, Deep Strike, Vanguard Assault in a prepared attack plan, individual Combat Shields, Plasma Pistol limits and modes, Sergeant weapon choices, Thunder Hammer Devastating Wounds, and Relic Blade's conditional Lethal Hits.

These checks cover the admitted local slice. The full local regression and final network integration remain pending; this sheet does not certify complete Space Marine faction rules or full army legality.

---

<a id="marine-victrix-honour-guard"></a>
## Victrix Honour Guard

`marine-victrix-honour-guard.md`

This profile uses the local Wahapedia 11th-edition export as its rules source. Datasheet `000004185` in shared book `000000139` has 3/6-model configurations at 120/250 points, with a 15-point Banner of Macragge equipped by the Chapter Ancient. The runtime prices those fixed banner configurations at 135/265 points and the source-listed third-plus tiers at 165/295. This admitted slice uses the Ancient, Champion and Guard at three models, then the Ancient, Champion and four Guards at six models; other legal role combinations are not yet exposed as construction choices.

## Profile and rules

- M6, T5, Sv2+, W3, Ld6+, OC2 on 40 mm bases.
- A three-model configuration contains a Chapter Ancient, Chapter Champion and one Victrix Honour Guard. A six-model configuration contains the same Ancient and Champion with four Victrix Honour Guard.
- The Ancient has a Master-crafted Bolt Carbine and Master-crafted Power Weapon. The Champion has Blades of Honour (Twin-linked, Precision). Each ordinary Guard has a Master-crafted Bolt Carbine (Rapid Fire 1, Assault) and Master-crafted Power Weapon.
- **Glory of Ultramar:** after an enemy unit shoots in the opponent’s Shooting phase, a casualty caused by those attacks opens an optional D6-inch Surge move. Placement checks distance, terrain path, base overlap and coherency.
- **Honour Guard of Macragge:** attacks targeting the unit receive -1 to wound.
- **Banner of Macragge:** at end of the owner’s Movement phase, the Ancient secures an objective controlled by the unit. Once per battle per army, when selected to fight, the unit may add 1 Attack and 1 Strength to its melee attacks.
- **Leader:** Cato Sicarius can attach to this exact bodyguard unit. Other bodyguard targets remain rejected. Captain of the Honour Guard is implemented conditionally: when Marneus Calgar is in the army, Cato becomes Support while retaining Victrix as his exact target.
- **Combat Doctrines** use the shared current runtime implementation.

## Local checks and limits

`tests/test_victrix_honour_guard.gd` checks source identity and prices, both model counts, per-role loadouts and keywords, ability registration, wound modification, the exact Cato attachment, the Glory trigger and movement, Banner timing and once-per-army fight effect. The local catalog includes the profile. Network validation remains deferred to final integration, and this increment does not certify full faction or army legality.

---

<a id="marine-vulkan-hestan"></a>
## Vulkan He’stan

`marine-vulkan-hestan.md`

Implemented 19 October 2026 from the pinned local Wahapedia 11th-edition Space Marines export: shared book `000000139`, datasheet `000002726`, export revision `2026-10-16T21:03:46+03:00`. Vulkan costs 105 points for one 40 mm model. His profile, keywords, Bolt Pistol, Gauntlet of the Forge (including Torrent) and Spear of Vulkan (including Devastating Wounds) are copied from that local extraction.

The admitted rules are Leader, Combat Doctrines, Transhuman Strategist, Seeker of the Unfound and Forgefather. The first time Vulkan is set up on the battlefield, he chooses his objective; while he is within objective range, his OC is 10, his Leadership is 5+, and he has Feel No Pain 4+. Once in his Shooting phase, he marks one visible enemy unit within 24 inches. Until the phase ends, friendly Adeptus Astartes Melta and Torrent attacks against the marked unit gain +2 Strength. Supported bodyguard choices are limited to locally admitted source-listed targets: Infernus Squad, Bladeguard Veteran Squad, Eradicator Squad with Melta Rifles, Company Heroes and Assault Intercessor Squad.

Focused validation passed 4/4 processes (import, Python checks, startup and `test_vulkan_hestan`) in `.tools/verification/20261019T184929707752Z/results.json`. This is local validation only. Network checks remain deferred to final integration; full faction and army legality are not certified.

---

<a id="marine-wardens-ultramar"></a>
## Wardens of Ultramar

`marine-wardens-ultramar.md`

Implemented from the pinned local [Wahapedia e11 Space Marines export](https://wahapedia.ru/wh40k11ed/factions/space-marines/Wardens-of-Ultramar-1), shared book `000000139`, datasheet `000004188`, export timestamp `2026-10-16T21:03:46+03:00`. The six-model composition costs 115 points and uses 40 mm bases. Construction admits one copy, matching its EPIC HERO status and local admission scope.

The profile preserves each model's own Toughness, Save, Wounds, Objective Control and invulnerable save, as well as its fixed weapons. Ancient Gadriel carries both Bolt Rifle profiles; Gaius Silva alone has a 5+ invulnerable save. The local composition/equipment rows spell the Librarian's name **Dainal Kornelius**, while the model-characteristics table spells it **Dainal Komelius**; the implementation preserves the discrepancy in its source comment.

Implemented datasheet rules are **Combat Doctrines**, **Raise the Banner**, **Support**, and **Strategium Command**. The support targets are Intercessor Squad, Bladeguard Veteran Squad, Sternguard Veteran Squad, Assault Intercessor Squad and Vanguard Veteran Squad. Strategium Command resolves after both armies deploy and before Scouts; it can select up to three deployed friendly Adeptus Astartes units, repositioning them under normal set-up restrictions or placing them in Strategic Reserves without the normal points cap.

Focused offline validation passed in `.tools/verification/20261019T211419295401Z/results.json` (10/10 processes), `.tools/verification/20261019T212547325101Z/results.json` (8/8 processes) and `.tools/verification/20261019T212717951667Z/results.json` (7/7 processes). Checks cover source characteristics and weapon profiles, mixed-model defense/allocation, materialization, support eligibility, one-copy construction admission, the public Strategium action flow and reserve exception, pre-battle Scout sequencing, roster validation and adjacent leader/ability regressions.

Network validation is deferred to final integration, as requested. This profile's local checks do not certify complete Space Marine faction coverage or full army legality.
