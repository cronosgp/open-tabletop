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
- Combat Doctrines and Transhuman Strategist, using the existing Warlord CP effect.
- Lord of the Pyroclasts: enemy units engaged with Adrax's attached unit have -1 OC, minimum 0.
- Unto the Anvil: the attached unit's melee attacks re-roll wound rolls of 1; while Assault Doctrine is active for that unit, it re-rolls wound rolls instead.

The implementation is scoped to this local extraction and the listed bodyguard choices. It does not certify full Salamanders restrictions, faction legality or network integration.

27 October current-catalog scope: the full profile, source identity, both weapon plans, Combat Doctrines, Warlord selection/CP timing, and both-player Marine roster materialization are checked in [the datasheet audit](marine-adrax-agatone.md), [machine audit](marine-adrax-agatone-audit.json) and `.tools/verification/20261027T121145243348Z/results.json`. The 19 October run and fixed-data comparison below are historical evidence; full Salamanders/army legality and network integration remain outside this scope.

---

<a id="marine-aethon-shaan"></a>
## Aethon Shaan — current e11 implementation

`marine-aethon-shaan.md`

This draft uses the pinned local Wahapedia 11e export only: shared Space Marines source `000000139`, datasheet `000004148`, updated `2026-10-16T21:03:46+03:00`. It records one 105-point model on a 50 mm base with M14, T5, Sv3+, W5, Ld6+, OC1 and a 4+ invulnerable save. The fixed loadout is Heavy Bolt Pistol and Claws of Severax. The pistol is 18", A1, BS2+, S5, AP-1, D1, Close-quarters. The claws are A7, WS2+, S5, AP-2, D2, Twin-linked, and have Sustained Hits 2 only against targets without MONSTER or VEHICLE.

The local export gives Shaan the character, Epic Hero, Infantry, Jump Pack, Fly, Tacticus, Smoke, Explosives, Imperium, Adeptus Astartes, Chapter Master and Raven Guard keywords. This datasheet has no Leader target list. His Character status makes him eligible to be selected as Warlord.

The local ability inventory also lists Deep Strike, Lone Operative, Stealth, Combat Doctrines and Transhuman Strategist. Deep Strike uses the existing reserve and ingress flow. Lone Operative protects Shaan while he is a standalone unit and turns off if he is in an Attached unit. Stealth grants the supported ranged benefit of cover. Combat Doctrines participates in the current Marine doctrine setup. If Shaan is the Warlord, Transhuman Strategist grants 1 CP at the start of the battle round, once per round.

Master of Shadows selects one friendly Adeptus Astartes Infantry unit in the Command phase and lets it re-roll Charge rolls until the start of the next Command phase. Both dice are replaced together, and the final result is mandatory. Blackwing Mantle is usable once per phase per army; it permits a Heroic Intervention targeting Shaan's unit regardless of other uses that phase, reduces that use by 1 CP (to a minimum of 0), and does not consume or block Heroic Intervention uses on other units. The Charge phase can continue to offer other eligible Heroic Interventions after the special use resolves.

The 27 October source-bounded scope passed **5/5 processes** at `.tools/verification/20261027T122224029113Z/results.json`. It checks the exact profile, both weapons through Equipment/AttackPlan, current Marine catalogs for both players, all seven listed abilities and both Blackwing/Master of Shadows command paths. See the [datasheet audit](marine-aethon-shaan.md) and [machine audit](marine-aethon-shaan-audit.json). The bounded source comparison has zero numeric or identity differences; Aethon passes its fixed-data checks.

This closes only Aethon's shared-book local datasheet scope. Raven Guard/Chapter rules, full army legality and network validation remain open; network checks are deferred to final integration.

---

<a id="marine-ancients"></a>
## Ancient and Bladeguard Ancient — current e11 implementation

`marine-ancients.md`

Reviewed 18 October 2026 against [Wahapedia Ancient](https://wahapedia.ru/wh40k11ed/factions/space-marines/Ancient) (`000002775`) and [Bladeguard Ancient](https://wahapedia.ru/wh40k11ed/factions/space-marines/Bladeguard-Ancient) (`000001165`), shared book `000000139`, App. Space Marines (11th edition). The local joined export revision is 16 October 2026, 21:03:46 GMT+3. Chapter, Legends and Boarding Actions adaptations remain excluded.

The current catalog's Ancient and Bladeguard Ancient profile records now carry those exact book/datasheet identities for source-restricted options. The shared base profile omits `DEATHWING`. During prepared-match setup, ChapterRules removes source-projected conditional tags from current-reference Marine instances, then grants `DEATHWING` to Bladeguard Ancient in Dark Angels context.

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

The 27 October current-catalog scope rerun passed `test_ancients` and the complete 153-link relation suite in **4/4 processes** at `.tools/verification/20261027T080140069584Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). It verifies both profiles and their seven weapon profiles through Equipment and AttackPlan against the 21 October snapshot; full army and network certification remain open.

---

<a id="marine-apothecary"></a>
## Apothecary — source-bounded local scope validated

`marine-apothecary.md`

Reviewed 27 October 2026 against [Wahapedia Apothecary](https://wahapedia.ru/wh40k11ed/factions/space-marines/Apothecary), datasheet `000002773`, shared App Space Marines book `000000139`, and [Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) 02.02.04, 01.02.03, 19.01.01. The verified local export snapshot is `20261021T130623Z` (retrieved 21 October; specification `20260817b`); the runtime profile retains its 16 October source-export stamp. Chapter, Legends and Boarding Actions variations remain excluded.

One model costs 45 points: M6/T5/Sv3/W4/Ld6/OC1 on a 40mm base, without an invulnerable save. Absolvor Bolt Pistol is ranged; Reductor Pistol is a melee Extra Attacks weapon and accompanies the ordinary Servo-armature in default melee declarations. Equipment is fixed. Neither EXPLOSIVES nor APOTHECARY is inferred from the model name; both are absent in this sheet's keyword rows. Pricing derives from the admitted profile through the shared catalog.

Narthecium heals the current unit D3+1 wounds during its owner's Command phase. Under Core Rules 02.02.04, living wounded models take priority; when several are wounded, the controller chooses where to assign wounds. Once every living model is at full wounds, each remaining wound can return one destroyed non-Character model with one wound. That returned model can then receive further healing from the same budget. Excess is discarded when there are no eligible models left. Battle-shock does not prohibit this datasheet ability. Useful unresolved healing is offered before Command can finish, and each unit resolves it once in that turn.

Healing uses a shared preview transaction in `unit_healing.gd`. Neither wounds nor positions change in authoritative model data before confirmation. Reset preserves the rolled budget and spent ability. Actor, revision and available-action checks apply through the existing public command handler. Return endpoints share `return_placement.gd` with Necron Reanimation, retaining the existing ground-board scope: whole base on board, no overlap, phase-entry survivor anchors within two inches, unit coherency and no new engagement. Equipment remains on the original model record. If no return can be placed, the controller explicitly declares that and discards remaining healing; this is a recorded controller declaration, not an automated exhaustive proof that no geometric placement exists.

The shared-book export links eight admitted bodyguards: Assault Intercessors, Bladeguard Veterans, Company Heroes, Desolation, Hellblasters, Infernus, Intercessors and Sternguard. The dedicated test materializes each from the current catalog and attaches the Apothecary. Six other rows in the complete export belong to Chapter/Deathwatch source books outside this scope. The datasheet's explicit exception permits the Apothecary and Lieutenant to share one eligible bodyguard, in either declaration order. Construction matching accounts for that pair. One Leader plus one Support remains available; three attached Characters are rejected in preparation. Core 19.01.01 keeps the current attached unit together after bodyguard casualties, superseding the sheet footer's older separation wording.

## Local verification and UI

The dedicated suite covers current-catalog admission for both players, profile/source parity, all three fixed weapons through Equipment or AttackPlan, all eight shared-book bodyguard links, Apothecary/Lieutenant pairing, wounded-model priority, return placement and confirmation, overlap rejection without mutation, same-roll reset, excess accounting, destroyed-Character exclusion, mandatory Command timing, Battle-shock, own-phase boundaries, once-per-turn refresh and invalid actor/revision rejection. The related Infiltrator regression confirms that Helix Gauntlet uses the same Core unit-healing sequence. Passing tests do not certify every interaction or full army legality.

The existing UI preserves the ability selector, X/Z placement fields and right-click placement. Earlier capture `.tools/apothecary-healing-after.png` uses a staged admitted-profile fixture with a fixed budget and one returned-model preview; it checks visible controls, not a completed match or every viewport.

The [audit](marine-apothecary-audit.json) records local evidence. Game/network validation remains deferred to final integration by user instruction.

---

<a id="marine-assault-intercessor-squad"></a>
## Assault Intercessor Squad — current local profile

`marine-assault-intercessor-squad.md`

The runtime profile is tied to Wahapedia 11e Space Marines book `000000139`, datasheet `000001606`, with its original `2026-10-16T21:03:46+03:00` export stamp. The complete source-bounded audit separately checks the verified `20261021T130623Z` local snapshot. The unit has 5 or 10 models at 85 or 170 points, 32 mm bases, M6, T5, Sv3+, W2, Ld6+, OC2 and the shared `ADEPTUS ASTARTES`, `BATTLELINE`, `INFANTRY`, `TACTICUS`, `EXPLOSIVES` and `IMPERIUM` keywords.

Every model starts with a Heavy Bolt Pistol and Chainsword. During setup, the Sergeant can replace the pistol with a Hand Flamer or Plasma Pistol, and can independently replace the Chainsword with a Power Fist, Power Weapon or Thunder Hammer. Choices use the public `SELECT_UNIT_CHOICE` path, retain the correct Sergeant-only boundary and can be restored. `Targeted Intercession` adds +1 Strength and +1 AP to the unit's melee attacks after it makes a charge move; it applies to replacement melee weapons without changing their printed profiles and does not modify ranged attacks.

The [source-bounded datasheet audit](marine-assault-intercessor-squad.md) covers both compositions and prices, every weapon profile through Equipment and AttackPlan, the replacement/restore choices, command ownership and stale-option rejection, the post-charge Hammer interaction, the selectable Captain link, and current-catalog admission. The dedicated scope and 153-link relationship check passed 4/4 local processes. Network validation remains deferred; full faction/army legality is not certified.

---

<a id="marine-ballistus-dreadnought"></a>
## Ballistus Dreadnought — 27 October 2026

[Full source-bounded local scope](marine-ballistus-dreadnought.md) · [machine-readable audit](marine-ballistus-dreadnought-audit.json)

Source: Wahapedia 11th-edition shared Space Marines book `000000139`, datasheet `000000091`; checked against the pinned local export snapshot `20261021T130623Z`, specification revision `20260817b`. [Ballistus Dreadnought on Wahapedia](https://wahapedia.ru/wh40k11ed/factions/space-marines/Ballistus-Dreadnought).

One model for 150 points with a third-plus cost of 170: M8, T10, Sv2+, W12, Ld6+, OC4 and a 90 mm base. The fixed loadout is Ballistus Lascannon, one Ballistus Missile Launcher with Frag and Krak profiles, Storm Bolters and Armoured Feet. The pinned export lists no equipment-option rows.

The current-catalog suite exercises both players; all five weapon modes through Equipment and AttackPlan; Ballistus Strike at the inclusive 24-inch base-edge boundary, beyond range and against melee; Damaged 4 at four/five wounds; Deadly Demise D3 packets, defender ownership, nested Ballistus destruction, save/restore and attack resumption; and admission of one, two or three copies while rejecting a fourth in the checked Incursion roster.

Focused verification passed **5/5 processes** at `.tools/verification/20261027T084333440820Z/results.json` (`network: false`, no legacy starter staging, no cleanup diagnostics). Earlier 19–23 October tests covered the profile parity and nested mortal-wound workflows; those older reports remain historical evidence. This closes only the Ballistus shared-book local scope. Full army legality and network validation remain open.
---

<a id="marine-bladeguard"></a>
## Bladeguard Veteran Squad — current e11 implementation

`marine-bladeguard.md`

Subsequent increment (18 October 2026): [Bladeguard Ancient](space-marines-profile-records.md#marine-ancients) is now an additional admitted Support for Bladeguard Veterans; the earlier linked-character boundary below is historical.



Reviewed 18 October 2026 against [Wahapedia Bladeguard Veteran Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Bladeguard-Veteran-Squad), datasheet `000000071`, shared book `000000139`, App. Space Marines (11th edition). The joined export revision is 16 October 2026, 21:03:46 GMT+3. Chapter, Legends and Boarding Actions variants remain excluded.

Admitted formations are three models at 90 points or six at 180, each with a 40 mm base, M6/T5/Sv3+/W3/Ld6+/OC1 and a 4+ invulnerable save. Each carries a Heavy Bolt Pistol and Master-crafted Power Sword. The Sergeant can replace the pistol with a Neo-volkite Pistol or Plasma Pistol, including both plasma profiles. The shared profile includes Explosives and Tacticus; the conditional Deathwing keyword remains outside this generic profile. The common-book relation suite verifies all eight source-linked Leaders and six Supports: Adrax Agatone, Captain, Captain Titus, Chaplain, Chief Librarian Tigurius, Kor'sarro Khan, Marneus Calgar and Vulkan He'stan; Apothecary, Bladeguard Ancient, Judiciar, Kaius Konorius, Lieutenant and Wardens of Ultramar. Chapter-App links remain outside this scope.

Bladeguard offers a once-per-turn choice when selected to fight or targeted by an enemy during Fight: +1 to the unit’s melee hit rolls, or -1 to enemy hit rolls against the unit. Core [01.02.02 Persisting Rules Effects](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/#Persisting-Rules-Effects) gives the effect phase duration when no explicit duration is printed.

## Declaration and resolution

Attack legality is checked before offering a stance. The declaration stores independent copies of assignments and targets; no attack dice are rolled while choices remain. The selecting unit receives its selection trigger first, followed by each targeted Bladeguard unit once, in deterministic target order. Both stance options and an explicit decline are available at each trigger. Declining preserves the use for a later legal trigger in the same turn. Selecting either effect spends the one use for that current unit and turn; it cannot be changed at a later trigger. No CP is spent, and Battle-shock does not prevent this datasheet ability.

The final response resumes the same attack declaration and recalculates attack modifiers with the chosen effects. Bonuses and penalties combine before the final +1/-1 cap. The offensive effect applies only to melee; the defensive effect applies to attacks targeting that unit during Fight. Attached characters receive the unit effect. Core 19.04 also limits the effect to its living source: losing the last Bladeguard ends the benefit for surviving attached characters, after the attacking unit finishes all its attacks when that source was destroyed by an attack. A frozen allocation snapshot preserves it during that resolution, then later attacks cannot recover it from the spent record. A new player turn restores availability.

The window also precedes completion of an eligible unengaged fight. Manual allocation, Precision, attack/damage reroll windows and Hazardous resolution continue through their existing paths after the declaration response. Invalid actors, stale revisions, illegal declarations and invalid dice cannot commit a different choice or consume the final response. Already-resolved responses cannot replay the attack. Historical ability implementations do not activate this rule.

The checked roster mode is 1000-point Incursion, whose Core Rules §25.03 limit is two units per non-BATTLELINE datasheet. Incursion therefore accepts two Bladeguard copies and rejects a third. The export’s third-plus prices (110/200) remain in the runtime profile and consolidated catalog. Strike Force's three-copy admission is not implemented because the runtime copy cap does not yet vary by battle size.

## UI brief and evidence

The player must identify which unit responds, choose an effect or decline, and understand that attacks are waiting. Existing selector, confirmation button, panel layout, type and semantic colors are preserved. The decision banner names Bladeguard; visible help states both effects, Fight-phase expiry, one use per turn, zero CP, and that declining preserves the use. Full option labels remain available through tooltips. No new placement controls or decorative assets are added.

Inspected real Godot captures at 1600x1000 use a staged Marine-versus-Marine training fixture: `.tools/bladeguard-before.png`, `.tools/bladeguard-after.png` and `.tools/bladeguard-defender.png`. The latter shows the defender’s response after the attacker chose its stance. The initial capture used a stale fixture priority annotation; the final fixture explicitly labels the remaining-fighters step. These captures verify the local controls and copy, not army legality, a completed match, network behavior or other viewport sizes. Checked admission is tested separately in the supported Marine-versus-Necron mission.

28 October 2026 source-bounded scope closure: the current-catalog suite checks the verified `20261021T130623Z` export, both formations and cost tiers, 40 mm geometry, all characteristics and shared keywords, every fixed/optional pistol profile and the sword through `Equipment` plus the shared `AttackPlan` helper, Sergeant-only public setup choices, wrong-owner/stale rejection, and current catalogs for both players. The 153-relation suite verifies the eight common-book Leaders and six Supports. The clean run passed **4/4 processes** with `network: false` and no legacy starter at `.tools/verification/20261028T020001295731Z/results.json`. The Bladeguard ability regression passed **3/3** at `.tools/verification/20261028T015803358451Z/results.json`; its optional historical Necron training fixture means `legacy_starter_staged: true`. See the [source-bounded datasheet audit](marine-bladeguard-veteran-squad.md), [machine audit](marine-bladeguard-veteran-squad-audit.json) and [earlier combat audit](marine-bladeguard-audit.json). This closes only the shared-book local sheet scope; Chapter-context behavior, Strike Force admission, full army legality and network validation remain open.

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
- **Tank Shock (Crushing Impact):** immediately after a MONSTER or VEHICLE unit finishes a Charge move, choose an enemy unit engaged by a model in the charging unit, then select one of your models engaged with that enemy. Roll a number of D6 equal to its Toughness. Each 1 inflicts 1 mortal wound on the charging unit; each 5+ inflicts 1 on the enemy unit, to a maximum of 6 against that enemy. The charging player's unit resolves its mortal wounds first, followed by the enemy unit's owner resolving theirs. Both packets use the shared allocation, prevention and Deadly Demise continuation paths.

The post-charge Tank Shock window opens only when the charging MONSTER or VEHICLE is engaged with an eligible enemy and the stratagem can be used. Tank Shock uses record separately so the Brutalis exception preserves one ordinary use by another unit in the same phase.

## Local validation

The historical focused run passed **14/14 processes**, including `test_brutalis_dreadnought`, the capability registry, combat scenario, Tank Shock/core reactions, both existing Dreadnought regressions, the implemented catalog and roster checks. Results: `.tools/verification/20261019T053830682027Z/results.json`. That run predates MONSTER eligibility and the charging-unit mortal-wound packet; checks for the expanded current rule and human playtesting remain pending.

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

The current [Wahapedia page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Caanok-Var) and verified export snapshot `20261021T130623Z` were checked on 27 October 2026; the 85-profile fixed-data comparison reports no Caanok differences. The dedicated suite `tests/test_caanok_var.gd` checks the exact profile/cost/copy cap and fixed weapons through Equipment/AttackPlan, current-catalog materialization for both players, Deep Strike/FNP and all named abilities, both source-listed Leader targets plus a rejected target, Cerebrex's owner-checked preparation choice and Scouts 6 boundary, Cold and Calculating against real Vehicle/Infantry targets with Tactical Doctrine, and Warlord CP once per round. It passed 3/3 processes at `.tools/verification/20261027T224248107984Z/results.json` with no network or legacy starter staging. See [the local scope audit](marine-caanok-var.md) and [machine audit](marine-caanok-var-audit.json). This closes only Caanok's shared-book local scope; Iron Hands Chapter rules, network validation and full army legality are not certified.

---

<a id="marine-captain-on-bike"></a>
## Captain on Bike

`marine-captain-on-bike.md`

Current Space Marines 11th-edition profile from the pinned local Wahapedia extraction. Source book `000000139`, datasheet `000002702`, export revision `2026-10-16T21:03:46+03:00`; current Space Marines App 2.8.1 page checked on 28 October 2026: [Wahapedia page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Captain-on-Bike).

## Profile and equipment

- One model, 110 points; M12, T6, Sv3+, 4++, W6, Ld6+, OC2; 90 x 52 mm oval base.
- Exported keywords: ADEPTUS ASTARTES (faction), MOUNTED, CAPTAIN, CHARACTER, EXPLOSIVES, IMPERIUM and RAVENWING.
- Default weapons: Heavy Bolt Pistol; Twin Bolt Rifle (Twin-linked, Assault, Rapid Fire 2); Master-crafted Power Weapon.
- Free source replacements: Heavy Bolt Pistol to Plasma Pistol (standard/supercharge profiles), or Master-crafted Power Weapon to Thunder Hammer.

## Rules implemented

- Leader attachment to Outrider Squad in the consolidated local catalog. The source-listed Ravenwing Black Knights are chapter content outside that catalog.
- Combat Doctrines is registered in the source ability map. Strategic Acumen and Transhuman Strategist use the existing locally implemented Space Marines effects.
- Into the Fray: after this unit made a charge move this turn, its melee attacks gain Cleave 1.

The focused scope passed 4/4 processes, covering all four weapon packages through Equipment/AttackPlan, both-player current-catalog materialization, the three-copy limit, Outrider attachment, Warlord CP, owner-checked Strategic Acumen and the charged/uncharged Into the Fray boundary. The current fixed-data comparison reports no profile differences. Runtime placement uses a 90 x 52 mm bounding-circle proxy for the source oval; exact oval geometry remains outside this scope.

Validation: `.tools/verification/20261028T010904565443Z/results.json`; [human scope audit](marine-captain-on-bike.md); [machine audit](marine-captain-on-bike-audit.json); fixed-data comparison: `.tools/marine-comparison-20261027-v12.json`.

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

The shared-book Leader table contains six targets: Bladeguard Veteran Squad, Hellblaster Squad, Intercessor Squad, Sternguard Veteran Squad, Assault Intercessor Squad and Infernus Squad. The page also lists Vanguard Veteran Squad from Warhammer Legends book `000000356`, which is excluded from common-book construction.

## Implemented rules

- **Feel No Pain 5+, Leader, Combat Doctrines and Transhuman Strategist:** linked to the extracted core/faction records and shared implementations. Titus's model receives the personal Feel No Pain 5+ prevention rule.
- **Press the Attack:** melee attacks gain Sustained Hits 1 against targets without Monster or Vehicle. If Assault Doctrine is active for his unit, they gain Sustained Hits 1 against any target.
- **Righteous Fury:** optional once per battle per army when Titus is selected to fight. It grants +1 Strength to melee attacks, then heals D3 after the unit fights, or 2D3 if Titus destroyed an enemy model this Fight phase. Healing is capped at his maximum Wounds.
- **Honour of Ultramar:** if Titus is destroyed in the Fight phase before his unit has been selected to fight, roll a D6; on 2+, he remains at 1 Wound until his unit fights or the Fight phase ends. Other units fighting do not prematurely remove him.
- **Anti-non-Monster/Vehicle 2+:** unmodified Wound rolls of 2+ are critical wounds only against targets with neither Monster nor Vehicle; excluded targets use the normal wound threshold.

## Local verification

The 27 October source-bounded scope passed **5/5 processes** at `.tools/verification/20261027T122555251642Z/results.json`. It verifies the exact source profile and every weapon plan, both-player current Marine catalogs, Titus's six common-book Leader links, Feel No Pain 5+, Warlord CP, Press the Attack's Monster/Vehicle boundaries, Righteous Fury, Honour of Ultramar and Chainsword Anti thresholds. See the [datasheet audit](marine-captain-titus.md) and [machine audit](marine-captain-titus-audit.json). The Legends Leader target remains excluded; Ultramarines/army legality and network validation remain open.

Focused offline verification passed 15/15 processes, including profile, ability, Fight-phase effects, anti-keyword resolution, attack windows, catalog publication, roster and saved-army regressions. Results: `.tools/verification/20261019T181223215266Z/results.json`. The local runtime export is `.tools/marine-runtime-v107.json`. Network checks were not run, and this does not certify full faction or army legality.

---

<a id="marine-captain"></a>
## Captain — current e11 implementation

`marine-captain.md`

This increment uses the pinned local Wahapedia export only: shared Space Marines source `000000139`, datasheet `000000073`, export updated `2026-10-16T21:03:46+03:00`. The current Captain is one 90-point Tacticus model on a 40 mm base with M6, T5, Sv3+, W5, Ld6+, OC1 and a 4+ invulnerable save. His default weapons are a Master-crafted Bolter, Heavy Bolt Pistol and Master-crafted Power Weapon.

The public preparation selector represents the source choices and restoration: the Bolter and Heavy Bolt Pistol can be replaced by a Neo-volkite Pistol or Plasma Pistol; the Bolter can instead be replaced by a Relic Shield, which adds 1 to the bearer’s W characteristic; and the Master-crafted Power Weapon can be replaced by a Power Fist only when the Relic Shield is not selected. The Shield option explicitly says the Master-crafted Power Weapon cannot be replaced. The Plasma Pistol has Standard and Supercharge profiles.

The source lists Leader, Combat Doctrines, Transhuman Strategist, Strategic Acumen, Finest Hour and Relic Shield. The Captain can lead supported eligible units, can be selected as Warlord, and Strategic Acumen activates a locally available doctrine under the shared doctrine-selection limit. Transhuman Strategist grants its Warlord CP at the start of the battle round, once per round while the Warlord is alive. Finest Hour is once per battle and adds 3 attacks and Devastating Wounds to the Captain’s melee attacks for that Fight phase activation. Relic Shield is handled as a loadout and wound characteristic change.

The source-bounded local scope passed on 28 October 2026. It checks all seven legal equipment packages through Equipment and AttackPlan, the Shield/Power Fist exclusion in both selection directions, Shield wound restoration, both-player current catalogs, all nine common-book Leader links, public Strategic Acumen timing, Finest Hour (+3 melee attacks and Devastating Wounds, once per battle), Transhuman Strategist CP and Warlord selection. The fixed-data comparison has no differences. See [the datasheet audit](marine-captain.md), [machine audit](marine-captain-audit.json) and `.tools/verification/20261028T005647625078Z/results.json`. This does not certify full faction or army legality; network validation remains deferred to final integration.

---

<a id="marine-cato-sicarius"></a>
## Cato Sicarius

[Cato Sicarius audit](marine-cato-sicarius.md) · [machine audit](marine-cato-sicarius-audit.json)

This profile uses the local Wahapedia 11th-edition export as its rules source. Cato Sicarius is shared-book datasheet `000004184` (`000000139`), a single 40 mm model for 115 points with M6, T5, Sv2+, 4+ invulnerable, 5W, Ld6+ and OC1. The Artisan Plasma Pistol and all three Talassarian Tempest Blade profiles are transcribed into the runtime profile.

## Implemented scope

- **Leader:** the local export lists Victrix Honour Guard (`000004185`) as Cato's exact bodyguard target. The Victrix profile is now admitted, and Cato can attach to that exact target. Other bodyguards are rejected.
- **Captain of the Honour Guard:** the source changes Cato's Leader role to Support when Marneus Calgar is in the army. Marneus Calgar is now admitted. Local checks confirm that Cato changes to Support only while Calgar is in the army, retains Victrix Honour Guard as his exact target, and cannot be selected as Warlord in that army.
- **Knight Champion of Macragge:** once in the opponent's Movement phase per army, when an enemy unit ends a move within 8 inches and Cato's unit is unengaged, the controller may make a Normal Move up to 6 inches. The implementation validates movement distance, terrain, base spacing, coherency and an unengaged endpoint.
- **Honour or Death:** Heroic Intervention targeting Cato's unit costs 1 fewer CP, to a minimum of 0. The discount is limited to that stratagem and uses the shared reaction cost resolver.
- Combat Doctrines and Transhuman Strategist use the shared current runtime implementations.

## Local checks and boundaries

`tests/test_cato_sicarius.gd` and the Cato profile-parity suite check the exact exported profile and weapons, ability registration, Warlord selection and once-per-round Transhuman Strategist CP, the exact Leader boundary and Calgar-dependent Support/Warlord rule, Heroic Intervention discount, opponent-Movement trigger, optional movement and saved use state. Cato is admitted at 115 points. The shared 7/7 report is `.tools/verification/20261027T184013951006Z/results.json`.

The linked Victrix attachment target and Calgar-dependent Support replacement pass local checks. Victrix role composition and optional Banner pricing now have a dedicated source-bounded audit. Network validation remains deferred to final integration; full faction and army legality are not certified.

---

<a id="marine-chaplain-jump-pack"></a>
## Chaplain With Jump Pack

`marine-chaplain-with-jump-pack.md`

Implemented from the local Wahapedia 11th-edition extraction. Source book `000000139`, datasheet `000000112`, export revision `2026-10-16T21:03:46+03:00`. Wahapedia remains the sole rules authority under [project policy](rules-source-policy.md).

## Admitted scope

- One 75-point model: Move 12", Toughness 5, Save 3+, Wounds 4, Leadership 5+, Objective Control 1, 4+ invulnerable save; 40 mm base.
- Fixed source loadout: Absolvor Bolt Pistol and Crozius Arcanum. The pistol is close-quarters; the Crozius has Cleave 1.
- Deep Strike uses the shared reserves resolver. As a Leader, this Chaplain can attach to the locally admitted Assault Intercessors With Jump Packs or Vanguard Veteran Squad With Jump Packs. The extracted page also links Talonstrike Kill Team and Death Company Marines With Jump Packs, whose source books are not yet represented in the local catalog.
- Litany of Hate gives the attached unit's melee weapons Lance through the existing Chaplain rule implementation.
- Exhortation of Rage lets the attached unit re-roll its melee Wound rolls while it is at or below half-strength. The source does not limit this to failed rolls, so the player may choose any eligible Wound die, including a success. Eligibility is evaluated while preparing each melee attack, using the shared Morale half-strength calculation. Ranged attacks do not receive the re-roll.
- The profile is Character-eligible for Warlord selection.

## Validation

The dedicated current-catalog suite checks its fixed profile, composition/cost, both common-book Leader links, attached-unit Deep Strike, complete Crozius attack planning and Exhortation above, at and below half-strength. Focused offline verification passed **5/5 processes** at `.tools/verification/20261027T103130253761Z/results.json`; see [the source-bounded scope record](marine-chaplain-with-jump-pack.md) and [audit](marine-chaplain-with-jump-pack-audit.json). Chapter-specific links, network validation and full faction/army legality remain outside this scope.

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

The focused current-catalog scope passed as part of the **5/5-process** offline run at `.tools/verification/20261027T103130253761Z/results.json`; see [the source-bounded scope record](marine-chaplain-on-bike.md) and [audit](marine-chaplain-on-bike-audit.json). The oval base remains a documented bounding-circle proxy. Network validation is deferred to final integration; full faction support and army legality are not certified.

---

<a id="marine-chaplain"></a>
## Chaplain — current e11 implementation

`marine-chaplain.md`

Subsequent increment (18 October 2026): [Bladeguard Veterans](space-marines-profile-records.md#marine-bladeguard) are now admitted as an additional Chaplain bodyguard; the historical increment below records the earlier boundary.



Rechecked 27 October 2026 against the current [Wahapedia Chaplain](https://wahapedia.ru/wh40k11ed/factions/space-marines/Chaplain) page, datasheet `000001174`, shared book `000000139`, App. Space Marines (11th edition), and the verified local Data Export snapshot updated 21 October 2026. The runtime profile retains its earlier 16 October source stamp. Chapter and Boarding Actions adaptations are not enabled.

One model costs 60 points, with a 40mm base, M6/T5, four wounds, Leadership 5+, 3+ armour and a 4+ invulnerable save. The fixed equipment is an Absolvor Bolt Pistol and Crozius Arcanum; the sheet has no weapon replacements. The Crozius retains five attacks, WS2+, Strength 6, AP-1, Damage 2 and Cleave 1. Incursion allows two copies.

The Chaplain is selectable as Warlord and may remain standalone or lead the six admitted common-book targets: Assault Intercessors, Bladeguard Veterans, Hellblasters, Infernus, Intercessors and Sternguard Veterans. It occupies the Leader slot, so another Leader cannot join the same bodyguard; the permitted Support slot is separate. Other Chapter-book, Deathwatch and Legends links remain outside common-book admission. The model retains its own defense and Leadership when attached.

Litany of Hate gives the current unit's melee weapons Lance while a living battlefield Chaplain source remains. This includes bodyguards and attached characters. The existing charge condition produces +1 to wound when that unit charged; the ability is not an unconditional wound bonus and does not affect ranged attacks or stack another copy of Lance. Source weapons remain immutable; source death removes the passive benefit.

Spiritual Leader is available at the start of Command, Movement, Shooting, Charge and Fight, during either player's turn. It removes Battle-shock from one friendly Astartes unit within 6 inches of the Chaplain model, with no line-of-sight or CP requirement. A shocked Chaplain can use it, including on its own unit. Dead and off-board sources cannot act. Usage is recorded once per battle round against the persistent Chaplain source model, so a second phase, the opponent's turn or attachment changes cannot refresh it. The next battle round restores availability.

The existing start-of-phase window offers the ability and an explicit decline. Other available start effects remain accessible in that window. Clearing a shocked SMOKE unit can restore its eligibility for Smokescreen before the window closes. This interaction is exercised through the public command path, including actor/revision checks and CP recording.

## Controls and validation

The existing ability selector identifies the Chaplain and target, with a full-label tooltip and contextual help explaining range, round limit and zero CP. The inspected real Godot capture `.tools/chaplain-spiritual-leader.png` uses admitted profiles in a staged start-of-Movement fixture at 1600x1000. It is not a completed match or proof of other viewport sizes. The earlier start-window controls remain documented in [the marksmen increment](space-marines-profile-records.md#marine-eliminators).

The [audit](marine-chaplain-audit.json) records the runtime-versus-export numeric comparison and the final local regression. Network validation remains deferred to final integration. Full army, faction, match and imported-mesh visibility certification remain false.

The 27 October current-catalog scope suite and the full 153-link relation suite passed 4/4 offline processes at `.tools/verification/20261027T100107251997Z/results.json`. The detailed audit now covers the fixed no-option profile, both weapon plans, all six common-book Leaders, Litany of Hate, Spiritual Leader timing/range/source limits and current-catalog admission. See [marine-chaplain.md](marine-chaplain.md). This is local sheet-scope evidence; whole-army legality and network validation remain open.

---

<a id="marine-chief-librarian-tigurius"></a>
## Chief Librarian Tigurius — source-bounded scope closed

[Datasheet audit](marine-chief-librarian-tigurius.md) · [machine audit](marine-chief-librarian-tigurius-audit.json)

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

The source lists Vanguard Veteran Squad as a Leader target, but that distinct non-Jump-Pack datasheet is not among the locally admitted profiles. The corresponding pairing is therefore unavailable. This increment does not certify full faction or army legality. The 85-profile fixed-data comparison reports no differences for Tigurius against the verified 21 October 2026 Marine slice. The 27 October focused local run passed 4/4 processes, including the dedicated suite and all common-book Leader/Support relations. The source-linked Legends Vanguard Veteran target remains unavailable; network validation is deferred to final integration.

---

<a id="marine-combi-lieutenant"></a>
## Lieutenant with Combi-weapon — source-bounded scope closed

[Lieutenant with Combi-weapon audit](marine-combi-lieutenant.md) · [machine audit](marine-combi-lieutenant-audit.json)

The pinned Wahapedia 11th-edition export snapshot `20261021T130623Z` records shared-book datasheet `000000076`: one 85-point model on a 40 mm base, M8, T4, Sv3+, W4, Ld6+, OC1. The fixed loadout is a Combi-weapon with Bolter and Flamer modes plus Paired Combat Blades. Core abilities are Feel No Pain 5+, Infiltrators, Lone Operative and Stealth; the Army Rule is Combat Doctrines. Its datasheet abilities are Priority Target Identified and Evade and Survive. It has no equipment-option rows or Leader targets.

The source-bounded suite checks all three weapon routes through Equipment and AttackPlan; profile, keywords and 85-point admission; current Marine catalogs on both sides; FNP through wound prevention; Infiltrators and Stealth effect predicates; Lone Operative's 12-inch targeting limit; Combat Doctrines registration; Priority Target's visible-terrain choice, +3 detection range and end-of-turn expiry; and Evade and Survive through its owner/phase/range gates, D3+3 movement preview, public pass/use command and save/restore continuation. Focused offline verification passed 3/3 at `.tools/verification/20261027T220101252638Z/results.json` (network disabled, no legacy starter staged, no cleanup diagnostics). The verifier now classifies this suite as a current-catalog match fixture. The current Wahapedia page was checked on 27 October 2026 and agrees with the pinned local export.

The existing grounded terrain and movement proxies remain the local boundaries. Full Chapter/army legality, network validation, complete matches and human playtesting remain open; network validation is deferred to final integration.

---

<a id="marine-company-heroes"></a>
## Brutalis Dreadnought — current e11 implementation

[Dedicated source-bounded scope audit](marine-brutalis-dreadnought.md)

Implemented from the pinned local Wahapedia Space Marines App export (`000000139`), datasheet `000000136`. One model costs 160 points for each of the first two copies and 180 for the third-plus tier; the source profile has M10, T10, Sv2+, W12, Ld6+, OC4, a 90 mm base and Damaged 4. Its default Bolt Rifles, Twin Heavy Bolter, Twin Icarus Ironhail Heavy Stubber and Brutalis Fists materialize from the source profile. Options replace Bolt Rifles and Brutalis Fists with Brutalis Talons, or Twin Heavy Bolter with Twin Multi-melta.

Brutalis Charge grants an additional free Tank Shock use after the Brutalis completes a Charge. The dedicated local suite verifies both directions relative to an ordinary Tank Shock use and the shared defender allocation path. That run also found and corrected case-sensitive `VEHICLE` eligibility in the shared Crushing Impact resolver. The focused offline scope passed 3/3 processes at `.tools/verification/20261027T061109103709Z/results.json`; network validation remains deferred and full faction/army legality is not certified.

---

<a id="marine-company-heroes"></a>
## Company Heroes — current e11 implementation

[Dedicated source-bounded scope audit](marine-company-heroes.md)

Implemented 19 October 2026 from the pinned local Wahapedia Space Marines App export (`000000139`), datasheet `000002772`, revision `2026-10-16T21:03:46+03:00`. The sheet uses a fixed four-model composition: Ancient, Company Champion, Company Veteran with Bolt Rifle, and Company Veteran with Heavy Bolter. Each has M6, T5, Sv3+, W4, Ld6+, OC2 and a 40 mm base. The first two units cost 125 points each; a third or later unit costs 145.

The unit materializer keeps the four roles in source order and assigns the source weapons to the appropriate models. The Ancient and Bolt Rifle Veteran carry a Master-crafted Bolt Rifle, Master-crafted Bolt Pistol and Combat Knife; the Champion has a Master-crafted Bolt Pistol and Master-crafted Power Weapon; the Heavy Bolter Veteran has a Master-crafted Bolt Pistol, Master-crafted Heavy Bolter and Combat Knife. Only the Ancient receives the Ancient and Character keywords, and only the Company Champion receives Champion.

Both current datasheet abilities are enabled:

- **Raise the Banner:** at the end of the controlling player's Movement phase, secure an objective controlled by this unit.
- **Command Squad:** attacks against this unit subtract 1 from Wound rolls. There is no weapon-Strength eligibility condition in the source, and the shared roll-modifier cap still applies.

The 27 October dedicated scope run passed **4/4 processes** at `.tools/verification/20261027T060134565606Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). It checks each role-specific loadout and source weapon through AttackPlan, the Character keyword on the Ancient, Command Squad in an actual incoming attack plan, Raise the Banner control/timing, the Captain attachment predicate and the shared source Leader-link suite. That suite exposed the missing per-model Ancient `CHARACTER` keyword, now corrected. See [marine-company-heroes.md](marine-company-heroes.md) for source hashes, exact scope and limits. The fixed-data comparison `.tools/wahapedia-fixed-data-review-v63.json` remains bounded source-data evidence; the local suite closes the listed behavior for this datasheet only. Full army legality is not certified. Network validation remains deferred to final integration.

---

<a id="marine-darnath-lysander"></a>
## Darnath Lysander

`marine-darnath-lysander.md`

Darnath Lysander is admitted from the local Wahapedia 11th-edition export for the shared Space Marines book: book `000000139`, datasheet `000002105`, export timestamp `2026-10-16T21:03:46+03:00`. The source profile is 160 points for one model, with a 50 mm base, the extracted characteristics and Fist of Dorn (5 attacks, WS 2+, Strength 10, AP -3, Damage 3, Devastating Wounds and Cleave 1). Imperial Fists and Adeptus Astartes are faction identity tags, not global chapter implementations.

The runtime implements the source-listed Deep Strike and Leader abilities; the two Leader targets are Terminator Squad and Terminator Assault Squad. Rampart can be activated once per battle per army in the start-of-phase decision window and gives Lysander a 2+ invulnerable save until that phase ends. Icon of Obstinacy subtracts 1 from hit rolls for attacks targeting his unit.

`tests/test_darnath_lysander.gd` checks the exact profile, keywords, one-copy cap, fixed Fist of Dorn through Equipment/AttackPlan, both current-catalog sides, the two legal Leader targets and an ineligible target, all source-listed abilities, Warlord/Transhuman Strategist, Rampart at a non-Shooting phase start and phase expiry, and Icon of Obstinacy in ranged and melee attack contexts. The 27 October current-source closure is recorded in [the datasheet audit](marine-darnath-lysander.md) and [machine audit](marine-darnath-lysander-audit.json), with a passing offline report at `.tools/verification/20261027T223627402745Z/results.json`. Network validation remains deferred to final integration; full Chapter and army legality remain uncertified.

---

<a id="marine-desolation-squad"></a>
## Desolation Squad

`marine-desolation-squad.md`

Current shared-book profile is tied to Wahapedia 11e book `000000139`, datasheet `000002270`, and export revision `2026-10-16T21:03:46+03:00`. The [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Desolation-Squad) and verified local Data Export snapshot `20261021T130623Z` are the rules authority; the snapshot identity and hashes are recorded in [the machine audit](marine-desolation-squad-audit.json).

The unit has one Sergeant and four Desolation Marines at 140 points for each of the first two copies; the source retains 150 points for each third-plus copy. Every model has Bolt Pistol, Castellan Launcher, Ceramite Fists and Superfrag Rocket Launcher by default. Every model can replace Superfrag with Superkrak, while only the Sergeant can replace either rocket with a Vengor Launcher for 5 points. The profile records M6, T5, Sv3+, W2, Ld6+, OC1 and 32 mm bases. Incursion admission is capped at two copies; Strike Force admission is not implemented.

Targeter Optics grants Ignores Cover to ranged attacks against visible targets. The Vengor's Indirect Fire path checks hidden-target selection, cover, hit re-roll restrictions and the hit-failure band, as well as the post-shot action restriction. The current suite uses the local Core Rules implementation and tests visible and hidden targets. All ranged and melee profiles are checked through Equipment and AttackPlan.

The 28 October focused offline scope passed 4/4 processes. It checks both player catalogs, model roles and bases, all source options and reversals, the two-copy Incursion cap, source weapon paths, Targeter Optics, Vengor Indirect Shooting and all 153 common-book Leader/Support relations. See [the sheet audit](marine-desolation-squad.md) and [the machine audit](marine-desolation-squad-audit.json). Network validation remains deferred to final integration; full faction/army legality, complete matches and human playtesting are not certified.

---

<a id="marine-eliminators"></a>
## Eliminator Squad — current e11 implementation

`marine-eliminator-squad.md`

Reviewed 28 October 2026 against [Wahapedia Eliminator Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Eliminator-Squad) and the verified local Data Export snapshot `20261021T130623Z`: datasheet `000001668`, shared book `000000139`, Space Marines App 2.8.1 / October 2026. The snapshot identity and SHA-256 records are in the [machine audit](marine-eliminator-squad-audit.json). Chapter and Boarding Actions variants remain outside this admission.

The builder admits one Sergeant and two ordinary Eliminators for 85 points, with 40 mm bases and M8/T4/Sv3+/W2/Ld6+/OC1. Each starts with a Bolt Sniper Rifle, Bolt Pistol and Ceramite Fists. The Sergeant independently chooses a Bolt Sniper Rifle, Las Fusil or Instigator Bolt Carbine; each ordinary model can independently exchange its rifle for a Las Fusil. Every choice can be reversed during preparation. Incursion permits two copies of this datasheet. The source-listed Leaders are Captain in Phobos Armour and Librarian in Phobos Armour; Lieutenant in Phobos Armour is the listed Support.

The Instigator's Lethal Hits applies only against units without Monster or Vehicle, with target keywords evaluated before casualties. Its Rapid Fire 2 and Precision use the existing planner and allocation flow. The Las Fusil retains D3+3 Damage and Heavy. The sniper retains Strength 6, Damage 3, Heavy and Precision.

Chameleoline Cloaks gives the unit -3 inches detection while a living battlefield source survives, including attached models. Hidden normally gives 12 inches with Cloaks and 9 with Gone to Ground; source loss removes the unit effect. It never grants Hidden or bypasses solid terrain. Stealth grants ranged cover only when every surviving battlefield model has that ability; Ignores Cover bypasses it.

Infiltrators permits alternate deployment only when all models qualify. Bases remain wholly on the board and more than 8 inches from the enemy zone and deployed enemy models. Enemy previews and off-board/dead models do not block placement. Ordinary own-zone placement, terrain endpoints, overlap, coherency, alternating ownership and confirmation revalidation remain enforced.

Special-issue Optics and Ammunition is optional in own Shooting. Choosing it selects that unit to shoot: either its ranged attacks ignore cover, or one enemy within 24 inches gains +6 detection until the shooting finishes. The latter selection does not require line of sight. One selection is active at a time; the player may revise or cancel the preview before committing dice. Other units cannot shoot or start actions and the phase cannot end until the selection finishes or is cancelled. Resolution windows take priority over changing the preview. A miss still finishes shooting and removes the effect. Effects also check phase/turn identity and cannot accumulate across units or phases.

Smokescreen is now available at the start of opponent Shooting through the existing decision window. It costs 1 CP with normal discounts, Battle-shock and phase/use restrictions. It grants phase-long cover to the selected SMOKE unit and units not fully visible because of an intervening living model in that unit, measured separately for each attacker in the existing ground-level cylindrical proxy. Dead/off-board models do not shield others, and Ignores Cover defeats the benefit. This does not certify imported miniature mesh visibility or unsupported upper-floor geometry.

The shared-book local scope is closed by `tests/test_eliminators.gd` and the 153-link relation suite. The focused clean run passed 4/4 offline processes with no legacy starter staged; see the [source-bounded sheet audit](marine-eliminator-squad.md), [machine audit](marine-eliminator-squad-audit.json) and report `.tools/verification/20261028T023439939543Z/results.json`.

## Controls and evidence

The existing Unit abilities selector remains the primary control; no new screen or dependency is introduced. Labels identify the unit and effect; full choice labels are available as tooltips. Once Optics is selected, the decision banner and help text explain the required shooting or cancellation. Setup exposes the Sergeant's options and each ordinary trooper's Las Fusil choice separately. Existing colors, typography and layout stay in place at the checked 1600x1000 desktop viewport.

Real Godot review captures are ignored artifacts under `.tools/`: `eliminators-optics-before.png` is the earlier synthetic controls baseline; `marksmen-optics.png`, `marksmen-sternguard.png` and `marksmen-smoke.png` use admitted profiles in staged match states; `eliminator-loadouts-after.png` shows the staged preparation list with the Sergeant and both trooper options at 1600x1000. The focused controls capture uses a different scroll position from the early baseline, so these are interaction evidence, not an identical-framing visual comparison. Other viewport sizes have not been visually checked in this increment.

See the [Eliminator machine audit](marine-eliminator-squad-audit.json) for the closed shared-book sheet scope and [the Marksmen audit](marine-marksmen-audit.json) for earlier shared controls/visibility evidence. Older visibility/deployment reports remain in their original `.tools/verification/` directories. Full army/faction and match certification remain false; network validation is deferred to final integration by user instruction.

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

The Melta Rifle sheet closed its source-bounded local scope on 28 October. Focused offline verification passed 6/6 processes at `.tools/verification/20261028T044209175152Z/results.json`, covering the exact source profile, all weapon profiles, half-range Melta, Hunter gates, the public Total Obliteration reroll, reversible preparation choices, copy limits and current catalogs. The actual 1600×1000 preparation capture is `.tools/eradicator-melta-rifles-after.png`. See the [datasheet audit](marine-eradicator-melta-rifles.md) and [machine audit](marine-eradicator-melta-rifles-audit.json). Network checks are deferred; whole-army legality remains uncertified.

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
- Firestrike's Sentinel Protocols wording lets this unit be targeted by Fire Overwatch regardless of other uses of that Stratagem in the phase, and its use does not prevent other units from using it. Once per phase per unit, the unit's snap shooting hits on unmodified 4+ until that Stratagem use is resolved. The usual CP cost and target eligibility remain. Snap shooting still cannot generate Critical Hits or use Hit re-rolls. Do not apply the extra-use exception to Tarantula Sentry Battery, whose datasheet only changes the snap-hit threshold.

## Local validation

Focused offline validation passed **9/9 processes** in `.tools/verification/20261019T044616562986Z/results.json`: import, Python checks, startup, `test_combat_scenario`, `test_core_reactions`, `test_current_unit_abilities`, `test_firestrike_servo_turrets`, `test_implemented_catalog`, and `test_reiver_squad`.

The earlier bounded fixed-data comparison `.tools/wahapedia-fixed-data-review-v20.json` covers **20 profiles / 65 weapon profiles** and remains historical source-data evidence. Its 19/20 consistency result still records the Ancient in Terminator Armour shared-versus-Chapter `DEATHWING` issue. Firestrike's dedicated source-bounded local sheet scope subsequently passed **4/4 processes** on 27 October at `.tools/verification/20261027T055306196988Z/results.json`, including its current-catalog suite and the shared Core reaction regression. That work corrected Sentinel Protocols so a Firestrike extra Overwatch neither requires the ordinary use to remain available nor consumes another unit's ordinary use. See [marine-firestrike-servo-turrets.md](marine-firestrike-servo-turrets.md) for the pinned export hashes and scope limits. Network validation remains deferred to final integration; full faction and army legality are not certified.

---

<a id="marine-gladiator-lancer"></a>
## Gladiator Lancer — current e11 implementation

[marine-gladiator-lancer.md](marine-gladiator-lancer.md)

Implemented from the verified local Wahapedia 11e snapshot `20261021T130623Z`, shared book `000000139`, datasheet `000002705`. The one-model profile uses a 100 mm circular base, M10, T10, Sv3+, W12, Ld6+ and OC3. Costs are 160 points for each of the first two copies and 180 for the third-plus tier; the current construction path admits up to three copies.

The fixed loadout is one Defensive Array, one Laser Destroyer and Armoured Hull. The dedicated local scope checks all three weapon profiles through Equipment and AttackPlan; Aquilon Optics against MONSTER and VEHICLE with its optional hit, wound and damage decisions; Damaged 4 at the four-wound boundary; and Deadly Demise D3 on the trigger and nearby target path. Both players materialize from the consolidated current Marine catalog. The checked verification passed 4/4 at `.tools/verification/20261027T082732292887Z/results.json`. Full army legality and network validation remain uncertified.

---

<a id="marine-gladiator-reaper"></a>
## Gladiator Reaper — current e11 implementation

[marine-gladiator-reaper.md](marine-gladiator-reaper.md)

Implemented 19 October 2026 from the pinned local Wahapedia Space Marines App export (`000000139`), datasheet `000001667`, revision `2026-10-16T21:03:46+03:00`. The Gladiator Reaper is one 100 mm-base model with M10, T10, Sv3+, W12, Ld6+ and OC3. It costs 165 points for each of the first two copies and 185 for the third-plus price tier.

The model's fixed loadout is Armoured Hull, Defensive Array and Twin Heavy Onslaught Gatling Cannon. The weapon profiles preserve Rapid Fire 12 on the Defensive Array, and Twin-linked plus Sustained Hits 2 and Devastating Wounds against targets without MONSTER/VEHICLE on the cannon. The cannon loses those two conditional traits against a Monster or Vehicle; Twin-linked remains. No replacement options appear on this source sheet.

**Reaping Tally** improves the AP of the unit's ranged attacks by 1 when targeting a unit without the MONSTER or VEHICLE keyword. It does not modify melee attacks. The shared **Damaged 4** effect applies -1 to Hit while the model has 1–4 wounds remaining. **Deadly Demise D3** uses the shared destruction sequence: after destruction roll a D6; on 6, each unit within 6 inches suffers a separately rolled D3 mortal-wound packet.

The 27 October source-bounded suite compares every weapon field through Equipment and AttackPlan, tests current-catalog construction on both players, copy pricing and the three-copy cap, Reaping Tally in an actual prepared attack and its MONSTER/VEHICLE/melee exclusions, conditional cannon traits and the Damaged 4 threshold. The shared focused run passed 7/7 processes at `.tools/verification/20261027T104505989012Z/results.json`; see [the Reaper scope audit](marine-gladiator-reaper.md). Full faction and army legality, network validation and complete-match certification remain open.

---

<a id="marine-gladiator-valiant"></a>
## Gladiator Valiant — current e11 implementation

[marine-gladiator-valiant.md](marine-gladiator-valiant.md)

Implemented from the verified local Wahapedia 11e snapshot 20261021T130623Z, shared book 000000139, datasheet 000001825. The one-model profile uses a 100 mm circular base, M10, T10, Sv3+, W12, Ld6+ and OC3. Costs are 165 points for each of the first two copies and 185 for the third-plus tier; current construction admits up to three copies.

The fixed loadout is a Defensive Array, two separate Multi-meltas, a Twin Las-talon and Armoured Hull. The dedicated scope checks all five weapon instances through Equipment and AttackPlan, Priority Target Acquisition on every ranged profile at the 12-inch base-edge boundary and immediately beyond, and its melee exclusion. Damaged 4 is checked at four and five wounds, and Deadly Demise D3 is checked on both trigger outcomes. Both players materialize from the consolidated current Marine catalog. Focused verification passed 4/4 at .tools/verification/20261027T083654769142Z/results.json. Full army legality and network validation remain uncertified.

---

<a id="marine-gravis-ancient-batch"></a>
## Gravis Captain and Terminator Ancient — 18 October baseline (Gravis scope superseded)

`marine-gravis-ancient-batch.md`

Targeted local validation ran on 18 October 2026. `test_gravis_captain.gd` and `test_terminator_ancient.gd` passed, alongside the local catalog, roster, reserve, capability, Infiltrators and Ancients regressions in verification run `.tools/verification/20261019T022024657123Z`. The runner passed 13 processes, including import, Python checks and startup. The complete local suite and network validation remain pending; this batch does not establish full army legality.

## Sources and boundaries

Reviewed 18 October 2026 against Wahapedia [Captain In Gravis Armour](https://wahapedia.ru/wh40k11ed/factions/space-marines/Captain-In-Gravis-Armour), sheet `000001172`, and [Ancient In Terminator Armour](https://wahapedia.ru/wh40k11ed/factions/space-marines/Ancient-In-Terminator-Armour), sheet `000002677`. Both belong to shared App Space Marines book `000000139`. Local export revision: 16 October 2026, 21:03:46 GMT+3. Source links and data were read; this is separate from executable validation. Chapter/Deathwing and Boarding Actions adaptations remain excluded.

The 90-point Gravis Captain uses a 40mm base, M5/T6/Sv3/W6/Ld6/OC1 and 4+ invulnerable protection. Refuse to Yield joins the existing allocated-attack damage modifier, reducing damage on this bearer by one, with minimum one for positive damage. It does not confer that reduction on bodyguards or unrelated mortal-wound sources. Strategic Acumen and Transhuman Strategist reuse existing mechanisms; no Finest Hour or Deep Strike is copied from other Captain identities.

Default equipment is the heavy bolt rifle and power weapon. Each alternative replaces both defaults with the Boltstorm Gauntlet (ranged and ordinary melee profiles) plus exactly one relic blade, chainsword or power fist. Each relic is Extra Attacks. Four complete loadouts use the existing preparation selector and preserve replacement semantics across attachment. Eligible admitted bodies are Aggressors, Heavy Intercessors and both Eradicator identities; chapter bodies are excluded.

The 75-point Terminator Ancient has a 40mm base, M5/T6/Sv2/W5/Ld6/OC2, 4+ invulnerable protection and fixed Storm Bolter/Master-crafted Power Weapon. It uses Support, Deep Strike and the existing Raise the Banner mechanism; its common-book Support targets are Terminator Assault Squad and Terminator Squad. Support construction matching includes these links while preserving a separate Leader slot. It does not receive the ordinary Ancient's OC bonus or Bladeguard Ancient's melee attack bonus.

Never Shall the Standard Fall contributes -1 to wound when final attacking Strength exceeds the defending unit's Toughness and any living model in the Ancient's unit is in objective range. Control is not required. The effective weapon Strength and bodyguard Toughness feed declaration context before existing wound-modifier limits. Prepared batches keep their context for that attacking unit's resolution; later declarations recompute source/position eligibility. The 27 October source-bounded suite also checks exact source identity, characteristics, unconditional keywords and current-catalog admission/materialization for both players. Conditional `DEATHWING` remains excluded from shared runtime. See [the current sheet audit](marine-ancient-in-terminator-armour.md), [machine audit](marine-ancient-in-terminator-armour-audit.json) and `.tools/verification/20261027T115826825089Z/results.json`.

## Written tests and final-run queue

`test_gravis_captain.gd` covers admission, source stats, bearer-only damage reduction, allocated damage integration, Gravis/Terminator boundaries, all four loadouts, ordinary plus Extra Attacks default declarations, reversibility after attachment and historical isolation.

`test_terminator_ancient.gd` covers current-catalog admission for both players, Support plus Leader separation, both common-book Support targets, Deep Strike, strict S>T, objective range without control, bearer versus unit range, dead source, off-objective behavior, prepared defensive context and Raise the Banner. The 18 October Gravis test used a legacy fixture and is superseded by the 28 October current-catalog scope in the Captain in Gravis Armour audit (marine-captain-gravis.md). The Terminator Ancient suite uses a current-catalog Marine fixture.

Run the complete local suite at final integration, including regressions for attack allocation, modifiers, equipment/Extra Attacks, existing Ancients, Gravis bodyguards, Support matching, reserves, capability metadata and checked construction. Then run network validation as requested. These targeted local passes do not replace that final run.

## UI intent

Existing Godot captures `.tools/gravis-ancient-batch-before.png` and `.tools/gravis-ancient-batch-preparation.png` show the staged preparation fixture at 1600x1000 before and after the help-text change. They do not execute the source-bounded suites or establish combat correctness; viewport variants and network behavior remain unverified.

The counts in this 18 October batch record are historical. Current shared-book coverage and the Gravis scope closure are tracked in the coverage matrix and Captain in Gravis Armour audit.

---

<a id="marine-gravis"></a>
## Aggressors and Apothecary Biologis — e11 implementation

`marine-gravis.md`

Reviewed 18 October 2026 from the shared App Space Marines e11 [Aggressor Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Aggressor-Squad) (`000002099`) and [Apothecary Biologis](https://wahapedia.ru/wh40k11ed/factions/space-marines/Apothecary-Biologis) (`000000060`) pages. Both have source book `000000139` in the reviewed export updated `2026-10-16T21:03:46+03:00`. Live pages were rechecked; chapter and Boarding Actions adaptations are not enabled by this increment.

| Unit | Admitted scope | Rule |
|---|---|---|
| Aggressor Squad | 3/6 models, 90/180 points, 40mm bases; Flamestorm Gauntlets with Close Quarters/Ranged modes and Twin Power Fists; optional whole-unit Auto Boltstorm Gauntlets + Fragstorm Grenade Launcher package | Close-quarters Firestorm: +1 Strength to unit attacks targeting a unit within 9 inches, including melee and attached Support attacks |
| Apothecary Biologis | One model, 60 points, 40mm base; Absolvor Bolt Pistol and Servo-armature; mandatory Support on admitted Aggressors, Heavy Intercessors, Eradicators with Heavy Bolters or Eradicators with Melta Rifles | Vivispectral Analysis Targeting: unit attacks gain Lethal Hits against non-Vehicle targets; Monsters remain eligible |

Aggressor range is measured from the unit: one living nearby model suffices for another model's attack. It is not a bonus per source/model and does not stack. Destroyed models cannot establish the range. Flamestorm Ranged has Blast 2; its Close Quarters mode has no Blast. The alternate package replaces the whole unit's ranged inventory, and updates the squad's displayed primary weapon. No EXPLOSIVES keyword is invented from weapon names. Torrent weapons use the existing unused numeric skill placeholder for their printed dash.

Support preparation, formation sealing and Warlord selection now handle Biologis explicitly. Its legal bodyguards are tracked separately from Lieutenant bodyguards when admitting a roster. One Support slot per bodyguard remains enforced. The regular Captain and Lieutenant are not admitted onto Gravis bodyguards by this change. Both Eradicator variants are now admitted Gravis bodyguards. Indomitor Kill Team remains outside current roster admission. A living Biologis propagates the trait through its attached unit; its death removes the benefit from future declarations. Existing attack resolution freezes declared effects. The shared Lethal Hits resolver is reused; this increment does not add a per-critical-hit manual decline window.

Prices come from the selected Wahapedia snapshot. Construction metadata now records a `points_source` per entry and distinguishes these additions from the original MFM reference prices. The list builder uses current curated composition and cost through the confirmed discovery-ID aliases, preserving the raw discovery catalog.

Validation: `tests/test_aggressors.gd` covers Aggressor admission, sizes, prices, base geometry, 9-inch boundaries, living range sources, both weapon packages, engagement restrictions, attack generation and wound rerolls. `tests/test_biologis.gd` checks current-catalog Biologis admission, fixed profile and weapons, all four shared-book Support links, Vivispectral target/source lifetime and AttackPlan integration; its 6/6-process report is `.tools/verification/20261027T093653231740Z/results.json`. The standalone Aggressor scope now checks every ranged and melee profile against AttackPlan; see the [Aggressor Squad sheet audit](marine-aggressor-squad.md) for the verified snapshot hashes and the dedicated 3/3 offline artifact. [Combined Gravis audit evidence](marine-gravis-audit.json) records the earlier shared suites and source hashes. Network validation remains deferred by user request; full army and faction certification remain false.

UI brief: reuse Play → Mission and unit choices. Expose one whole-unit Aggressor equipment change during preparations, with an inverse choice to restore Flamestorm. Keep layout, colors and confirmation controls. The shortened label names the unit, the destination package and that it applies to all models. Real staged Godot captures at 1600×1000 were inspected: `.tools/gravis-setup-before.png` showed truncation; `.tools/gravis-setup-after.png` shows the complete shortened label. These capture a setup fixture, not a played mission or a small-window usability test.

---

<a id="marine-guilliman"></a>
## Roboute Guilliman — current Wahapedia 11e scope

The current Wahapedia datasheet and verified local export identify Roboute Guilliman as shared Space Marines datasheet `000000138` in book `000000139`, export revision `2026-10-16T21:03:46+03:00`. His single 415-point model uses a 60 mm base and a fixed loadout. The dedicated audit covers his characteristics, keywords, all three weapon profiles, all eight source-listed ability records, catalog admission and tested local action paths.

A source/runtime mismatch was found and corrected during closure: the local rule had assigned Feel No Pain 6+, while the source lists 5+. The runtime and dedicated suite now use 5+.

The focused offline scope run passed 5/5 processes, including the Guilliman suite, checked-roster validation and all 153 common-book Leader/Support relations. It used `network: false`; the verifier recorded `legacy_starter_staged: true`. Full army legality, Ultramarines/Gladius roster restrictions, network behavior and complete-match certification remain outside this datasheet scope. See [the detailed datasheet audit](marine-guilliman.md) and [machine-readable evidence](marine-guilliman-audit.json).

---

## Heavy Intercessor Squad — 19 October 2026

`marine-heavy-intercessor-squad.md`

The current 11th-edition profile uses the pinned local Wahapedia extraction as its sole rules source: Space Marines App (`000000139`), datasheet `000001177`, export revision `2026-10-16T21:03:46+03:00`. The sheet is admitted into the consolidated local construction catalog at 5 models / 115 points and 10 models / 230 points. The profile records the Sergeant and Heavy Intercessor characteristics, 40 mm bases, source keywords, Bolt Pistols, Heavy Bolt Rifles and Ceramite Fists.

During army preparation, one non-Sergeant model per five starting models can replace its Heavy Bolt Rifle with a Heavy Bolter. The chosen model receives the extracted 36-inch, A3, BS3, S5, AP-1, D2 profile with Heavy, Sustained Hits 1 and Rapid Fire 2. The choice does not change points. A 5-model unit permits one replacement; a 10-model unit permits two. The Sergeant is excluded.

Unyielding in the Face of the Foe grants +1 to saving throws while the unit controls an objective. The combat save modifier checks that the Heavy Intercessor squad is among the contributing squads on a friendly-controlled objective. Being near a friendly objective controlled by another squad is insufficient. The existing damage-resolution hook snapshots the modifier for the attack sequence.

Local validation: `tests/test_heavy_intercessor_current.gd` checks the source characteristics and six keywords, current-catalog prices/composition, all four weapons through Equipment and AttackPlan, the public Heavy Bolter setup/restore flow and one-per-five cap, the five source Leader/Support links, and Unyielding through the damage save resolver. The paired `test_space_marine_leader_links` suite checks the 153-link map. Focused verification passed 4/4 processes at `.tools/verification/20261027T073729361442Z/results.json`; see [the source-bounded sheet audit](marine-heavy-intercessor-squad.md). The fixed-data comparison `.tools/marine-comparison-20261027-v12.json` remains separate evidence for the bounded 85-profile comparison. Network validation remains deferred; this does not certify full army legality or the complete Space Marines faction.

---

<a id="marine-inceptor-squad"></a>
## Inceptor Squad — current e11 local profile

`marine-inceptor-squad.md`

**Source of truth:** the pinned [Wahapedia 11th-edition Inceptor datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Inceptor-Squad) and its local export. Shared-book source `000000139`, datasheet `000000125`, export timestamp `2026-10-16T21:03:46+03:00`. This is not a network check.

## Admitted scope

- Unit composition: 1 Inceptor Sergeant and 2–5 Inceptors. The local construction catalog admits 3- or 6-model units. Points are 130/260 for the first two units and 150/280 for each later unit.
- Profile: Move 10", Toughness 6, Save 3+, 3 Wounds, Leadership 6+, Objective Control 1; 40 mm bases. Keywords: Infantry, Gravis, Jump Pack, Imperium, Fly, Adeptus Astartes.
- Default equipment: each model has Assault Bolters and Ceramite Fists. At army setup, each model may independently replace Assault Bolters with Plasma Exterminators. Standard and Supercharge profiles are available; Supercharge is Hazardous.
- Deep Strike is present on every model. The current scope suite verifies that the shared Ingress choice is exposed after reserve placement; it does not resolve this unit’s complete placement path.
- Meteoric Descent adds +1 to Hit for ranged attacks after this unit made an Ingress move this turn. The shared hit modifier cap still applies; the effect also remains available to out-of-phase ranged attacks in that same turn.
- Parabolic Jetleap is offered at the end of the opponent's Fight phase when this unit is unengaged. Choosing it removes the whole unit into Strategic Reserves; it can return through the shared Deep Strike Ingress flow.

## Local checks

The current source-bounded implementation is recorded in the [dedicated Inceptor scope audit](marine-inceptor-squad.md). Its offline run passed 3/3 processes at `.tools/verification/20261027T063205977865Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). It checks the current source snapshot, composition/cost tiers, individual Plasma choices, all weapon profiles through Equipment and AttackPlan, Meteoric Descent boundaries, Deep Strike ability/Ingress choice and Parabolic Jetleap reserve timing.

The bounded offline comparison `.tools/wahapedia-fixed-data-review-v53.json` includes this as profile 30. It found no numeric or identity differences; the Inceptor profile passes its bounded fixed-data checks, including all four weapon profiles and the Adeptus Astartes keyword context. The full comparison is 29/30 because Ancient in Terminator Armour retains unresolved chapter-specific `DEATHWING` context. The raw source snapshot has structural warnings.

The declared Inceptor source-bounded shared-book local scope is closed. Final network validation remains deferred; this does not certify full Space Marines rules coverage, general reserve legality or full army legality.

---

<a id="marine-incursor-squad"></a>
## Incursor Squad — local Wahapedia implementation

[Dedicated source-bounded scope audit](marine-incursor-squad.md)

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

The historical focused run passed 15/15 processes in `.tools/verification/20261019T042405255660Z/results.json`, including combat, attack plans, roster/reserves, ability registry, catalog, Scout and Incursor behavior, and Phobos Leaders. The 27 October dedicated source-bounded run now passes 3/3 processes at `.tools/verification/20261027T061905870311Z/results.json`, using current Marine catalogs on both sides. It checks all three weapons through AttackPlan, all three Leader targets and both datasheet abilities, including rerolls, range, once-per-phase/battle limits and defender allocation. See [marine-incursor-squad.md](marine-incursor-squad.md) for the pinned export hashes, complete local scope and limits. Network validation remains deferred to final integration; full faction and army legality are not certified.

The bounded fixed-data comparison in `.tools/wahapedia-fixed-data-review-v17.json` covers 18 profiles and 59 weapon profiles. Incursor's numeric characteristics, weapon traits, default equipment, composition and price data match the local extraction. Seventeen profiles pass the full bounded comparison; Ancient in Terminator Armour remains unresolved for shared-versus-chapter `DEATHWING` context. The dedicated 27 October local scope is now closed; see [marine-incursor-squad.md](marine-incursor-squad.md) for its current evidence. Network validation and full faction/army legality remain uncertified.

---

<a id="marine-intercessor-squad"></a>
## Intercessor Squad — 28 October 2026

Implemented scope covers both source compositions and prices, characteristics, keywords, base, defaults, every Sergeant replacement and Grenade Launcher cap, all weapon profiles through Equipment/AttackPlan, Bolter Discipline, Tactical Mainstay, all fourteen common-book Leader/Support links and both-player catalog admission. The local Incursion validator's four-copy Battleline gate is recorded as a project limit, not full army-legality evidence. Focused verification passed 4/4 processes at `.tools/verification/20261028T051426845028Z/results.json`. See the [source-bounded sheet audit](marine-intercessor-squad.md) and [machine-readable audit](marine-intercessor-squad-audit.json). Network validation and full faction/army legality remain open.

---

<a id="marine-invader-atvs"></a>
## Invader ATVs — current e11 implementation

See the source-bounded [Invader ATVs scope audit](marine-invader-atvs.md) and [machine-readable source/hash audit](marine-invader-atvs-audit.json). This closes local profile, loadout, ability and construction checks against shared Space Marines book `000000139`, datasheet `000004247`, using snapshot `20261021T130623Z`.

The source composition is one or two models at 65/130 points, with third-and-later copies at 75/140. Each ATV has M10, T6, Sv3+, W8, Ld6+, OC2 and no invulnerable save. It defaults to Bolt Pistol, Onslaught Gatling Cannon, Twin Bolt Rifle and Armoured Impact. Each model can replace its cannon with a 5-point Multi-melta. Aggressive Reconnaissance grants +1 to wound in the controlling player's Shooting phase against an isolated enemy target; the source 6-inch limit is checked edge to edge and excludes Overwatch. The exported RAVENWING keyword is applied only in Dark Angels context. Wahapedia says “Use model” for its base, so the 90 × 52 mm flat-board footprint is a documented runtime proxy, not a source base measurement.

The focused offline scope passed; network validation remains deferred. Full faction/army legality, network behavior, Chapter-book variants, complete-match certification and human playtesting remain outside the scope.
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

The source-bounded local scope now checks the current catalog entry and all six weapon profiles through `Equipment` and `AttackPlan`, including the public autocannon replacement and restoration. It also checks Damaged 4 at four remaining wounds, Deadly Demise D3's trigger and allocation decision, Scouts 8 reserve eligibility and movement boundary, and the Forward Assault mark/replacement continuation through save/restore. The paired relation test covers the full 153-link source map; this datasheet has no source Leader/Support links.

## Local validation

The earlier 19 October focused run passed **6/6 processes**; its report remains `.tools/verification/20261019T055549579499Z/results.json`. The 27 October source-bounded scope and full Leader/Support-map recheck passed **4/4 processes** at `.tools/verification/20261027T074848766922Z/results.json`; see [the dedicated audit](marine-invictor-tactical-warsuit.md). The run used no network, staged no legacy starter and reported no cleanup diagnostics.

The bounded local comparison `.tools/wahapedia-fixed-data-review-v35.json` covers 24 runtime profiles and 91 weapon trait profiles; 23/24 pass all fixed-data checks with zero numeric or identity differences. Ancient in Terminator Armour remains unresolved for the shared-versus-chapter `DEATHWING` keyword context. This comparison does not certify optional wargear legality, full faction coverage or full army legality. Network validation remains deferred to final integration.

---

<a id="marine-iron-father-feirros"></a>
## Iron Father Feirros — source-bounded scope closed

[Datasheet audit](marine-iron-father-feirros.md) · [machine audit](marine-iron-father-feirros-audit.json)

Iron Father Feirros is admitted from the local Wahapedia 11th-edition Space Marines export: shared book `000000139`, datasheet `000000127`, export timestamp `2026-10-16T21:03:46+03:00`. The one-model profile costs 85 points and uses the exported characteristics, 40 mm base, Bolt Pistol, Gorgon's Wrath, Harrowhand and Medusan Manipuli.

The runtime implements his four source-listed Leader links (Aggressor Squad, Heavy Intercessors and both Eradicator variants), Feel No Pain 5+, Combat Doctrines, Transhuman Strategist, Master of the Forge, Rites of Tempering and Iron Father. Master of the Forge can be used at the start or end of his unit's move to heal a nearby Adeptus Astartes Vehicle by 3 wounds and let its attacks ignore BS, Hit and Wound modifiers until the next Movement phase. Rites of Tempering gives his unit -1 to Wound when the attacking Strength exceeds that unit's Toughness. Iron Father grants Feirros Lone Operative near a friendly Astartes Vehicle; the core Attached-unit restriction still applies.

`tests/test_iron_father_feirros.gd` materializes Feirros and both rosters from the current Marine catalog. It checks the exact profile and no-option fixed loadout, all four weapon plans, all four Leader links, personal Feel No Pain, public Warlord selection/CP, both Strength conditions for Rites, conditional Lone Operative, and Master of the Forge defer/repair/expiry through the normalized command flow. Together with `test_space_marine_leader_links`, focused verification passed 4/4 processes at `.tools/verification/20261027T230433907954Z/results.json`; the current Wahapedia page and pinned export match, and the fixed-data comparator reports no profile differences. Iron Hands Chapter behavior, network validation and full army legality remain outside this sheet scope.

---

<a id="marine-judiciar"></a>
## Judiciar — source-bounded local scope closed

[Datasheet audit](marine-judiciar.md) · [machine audit](marine-judiciar-audit.json)

Reviewed on 27 October 2026 against the current [Wahapedia Judiciar page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Judiciar), datasheet `000002707` in shared Space Marines App book `000000139`. The verified local export snapshot is `20261021T130623Z`; its manifest and relevant file hashes are recorded in the machine audit. The source has no equipment-option rows.

The fixed profile is one 50-point model on a 40 mm base, M6/T5/Sv3/W4/Ld6/OC1, with a melee-only 4+ invulnerable save. Its fixed Absolvor Bolt Pistol and Executioner Relic Blade pass Equipment and AttackPlan checks. Tempormortis grants Fights First. The Support role may attach to Assault Intercessors, Bladeguard Veterans, Infernus, Intercessors or Sternguard from the common book. The other seven source links belong to Chapter books or Legends and remain outside this scope.

The dedicated current-catalog suite checks both-player Marine materialization, the Support attachment command and roster gate, separate Leader/Support slots, all five common-book targets through the shared 153-link relation suite, conditional defense in grouped/automatic/manual allocation and bodyguard boundaries, and Tempormortis lifetime and FightQueue priorities. The selected-model card continues to label the conditional save as `InSv 4+ melee`; previous Godot captures cover only the staged card state and the tested viewport.

Focused verification passed 5/5 processes at `.tools/verification/20261027T231150548787Z/results.json`, with no network, optional legacy starter or cleanup diagnostics. The fixed-data comparison reports no Judiciar differences. Network validation, Chapter rules, full army legality and full-match certification remain open.

---

<a id="marine-jump-pack-batch"></a>
## Assault Intercessors With Jump Packs — source-bounded local scope passed

[Dedicated sheet audit](marine-assault-intercessors-with-jump-packs.md) · [machine-readable source and validation audit](marine-assault-intercessors-with-jump-packs-audit.json)

Initial catalog admission was recorded on 18 October 2026. This sheet's declared shared-book local scope closed on 28 October against the current Wahapedia 11th-edition Space Marines App page, datasheet `000002776`, book `000000139`, App 2.8.1 / October 2026. Datasheet facts were compared with verified local snapshot `20261021T130623Z`; the runtime profile keeps its earlier `2026-10-16T21:03:46+03:00` source stamp.

The source profile has one Sergeant and four to nine ordinary models, 5/10-model costs of 95/190 for the first two units and 105/200 for third-plus units, 32 mm bases, M12/T5/3+/2/6+/OC1, all seven keywords, Deep Strike and Hammer of Wrath. The public preparation flow applies the Sergeant's pistol and melee choices plus one ordinary Plasma Pistol per five models. All weapon modes pass through Equipment and AttackPlan. Both current catalogs materialize 5- and 10-model units; the common-book Leader targets Captain With Jump Pack, Chaplain With Jump Pack and Kayvaan Shrike are checked for both players. The catalog keeps the source third-plus prices but caps admission at two copies until copy-index-aware pricing is supported.

Focused current-catalog verification passed 6/6 processes at `.tools/verification/20261028T014923681819Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). A broader copy-cost/Chaplain regression passed 8/8 processes at `.tools/verification/20261028T014453977946Z/results.json` and records `legacy_starter_staged: true`; Hammer of Wrath behavior separately passed 3/3 at `.tools/verification/20261028T014532504875Z/results.json` using its legacy training fixture. The test dependency and exact boundaries are listed in the sheet audit. Commander Dante is a Blood Angels App target outside the common 85. Full Chapter and army legality, network behavior, complete-match certification and human playtesting remain open.

---

<a id="marine-jump-pack-captain"></a>
## Captain With Jump Pack — source-bounded local scope passed

`marine-captain-with-jump-pack.md`

Scope closed 28 October 2026. The sole rules authority is the Wahapedia 11th-edition Space Marines App, datasheet `000000083`, book `000000139`, export revision `2026-10-16T21:03:46+03:00`. The exact snapshot, source fields, filenames and SHA-256 hashes are recorded in [the machine audit](marine-captain-with-jump-pack-audit.json).

The one-model, 90-point profile uses a 40 mm base and matches the extracted characteristics and keywords. Its three option rows produce seven legal equipment sets. All eight weapon profiles/modes are checked against source fields and through Equipment and AttackPlan. The test covers both-player current-catalog construction, the three-copy cap, both common-book Jump Pack Leader targets, the assembled unit’s Deep Strike reserve choice, actual Angel’s Wrath Advance and Charge results, Strategic Acumen ownership/timing, Transhuman Strategist Warlord CP and the bearer-only Relic Shield wound/restore path. Sanguinary Guard and Talonstrike Kill Team remain excluded as Blood Angels and Deathwatch App targets.

Focused verification passed 5/5 processes at `.tools/verification/20261028T011901622074Z/results.json` (SHA-256 `eaad69347d993b453fe65ae4582ead8bc413d144bf8941c37a0b4d06168a47db`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The run included the Captain suite, the paired Vanguard Veteran suite and the 153-link Leader/Support regression. This closes only the Captain’s shared-book local scope; full faction/army legality, network behavior, complete-match certification and human playtesting remain open.

---

<a id="marine-kaius-konorius"></a>
## Kaius Konorius

`marine-kaius-konorius.md`

Profile and rules transcribed from the pinned local Wahapedia 11th-edition export: source book `000000139`, datasheet `000004248`, export revision `2026-10-16T21:03:46+03:00`; [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Kaius-Konorius).

## Profile recorded

- One model, 100 points; M6, T5, Sv2+, 4++, W5, Ld6+, OC1; 40 mm base.
- Heavy Bolt Pistol: 18", A1, BS2+, S5, AP-1, D1, Close-quarters.
- Severance and Rebuke: Strike (5A, WS2+, S10, AP-3, D3, Precision) and Sweep (6A, WS2+, S6, AP-3, D2, Cleave 2).
- Exported Support targets: Sternguard Veterans, Bladeguard Veterans, Assault Intercessors and Victrix Honour Guard. All four are admitted in the local catalog.

## Rules recorded in code

- **Support and Combat Doctrines:** Kaius is classified as a Support unit, with the exact four source-listed targets. His attached unit receives the active Combat Doctrine.
- **Veteran Bodyguard** grants Feel No Pain 4+ against any wounds to other Character models in Kaius's attached unit.
- Calgar's Champion lets Kaius re-roll hit and wound rolls of 1 against an enemy Character unit.

The source-bounded local scope now passes in `tests/test_kaius_konorius.gd` and `.tools/verification/20261027T225347438197Z/results.json`. It checks Kaius's actual Support role and preparation choice, all four Support targets, both-player current catalogs, Combat Doctrines, all fixed weapons through Equipment/AttackPlan, the Captain Leader + Kaius Support attachment, Veteran Bodyguard's other-Character boundary and Calgar's Champion target filter. The 85-profile fixed-data comparison reports no Kaius differences in `.tools/marine-comparison-20261027-v12.json`. See [the local datasheet audit](marine-kaius-konorius.md) and [machine audit](marine-kaius-konorius-audit.json). This closes only the shared-book local scope; Ultramarines Chapter rules, network validation and full army legality remain outside this result.

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

- **Leader:** the export links five common-book targets: Sternguard Veteran Squad, Assault Intercessor Squad, Company Heroes, Intercessor Squad and Bladeguard Veteran Squad. The separately listed Vanguard Veteran Squad target is from Warhammer Legends book `000000356` and is excluded from shared-book construction.
- **Combat Doctrines** and **Transhuman Strategist:** existing shared e11 implementations apply.
- **Trophy Taker:** while Kor’sarro is in the unit, attacks that target a CHARACTER unit re-roll Hit and Wound rolls of 1.
- **For the Khan!:** the unit’s ranged attacks have Assault and its melee attacks have Lance.
- **Weapon Anti traits:** Anti-Infantry 4+ and Anti-Character 5+ create critical wounds at the threshold; the critical-wound path correctly interacts with Devastating Wounds and interactive attack resolution.

## Local verification

Historical offline verification passed 15/15 processes on 19 October. The 27 October current-catalog audit additionally checks exact profile and all weapon routes, Character-gated rerolls, attached-unit Assault/Lance, Anti thresholds through direct and interactive attacks, and current Marine rosters for both players; see [the datasheet audit](marine-kor-sarro-khan.md), [machine audit](marine-kor-sarro-khan-audit.json) and `.tools/verification/20261027T121145243348Z/results.json`. The Vanguard Veteran Squad target is from Warhammer Legends and remains outside the shared 85-sheet scope. Full White Scars/army legality and network validation remain open.

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

The 27 October source-bounded follow-up now checks all four fixed weapon profiles through Equipment and AttackPlan, exact exported profile data, current-catalog admission and materialization for both players, the source-listed Combat Doctrines metadata, attached Psychic Hood prevention, Soul Sight, Shrouding and both Scouts 6 paths. The paired Leader-link suite checks all five common-book targets. Focused offline verification passed 4/4 processes at `.tools/verification/20261027T113634638636Z/results.json`; network validation remains deferred. See [the Librarian in Phobos Armour audit](marine-librarian-phobos.md) for its declared limits and local export provenance.

---

<a id="marine-librarian-terminator-armour"></a>
## Librarian in Terminator Armour — 19 October 2026

`marine-librarian-terminator-armour.md`

The current Librarian in Terminator Armour profile (Wahapedia sheet `000000079`, source book `000000139`) is admitted from the local 11th-edition extraction, revision `2026-10-16T21:03:46+03:00`. Its fixed profile costs 80 points and includes a 4+ invulnerable save, Storm Bolter, and Force Weapon (Psychic), with the extracted Smite focused and witchfire profiles. It can Lead both common-book targets, Terminator Assault Squad and Terminator Squad; Chapter-book bodyguards remain outside the shared 85-sheet scope.

The runtime implements Leader and Deep Strike, the Psychic Hood, and the Librarius ability's two selectable powers. Psychic Hood gives the attached unit Feel No Pain 4+ against damage inflicted by Psychic attacks, including mortal wounds caused by those attacks. Might of Heroes adds 2 Strength to the unit's melee weapons for the relevant Fight phase; a Psychic test result of 1 instead causes Battle-shock. Thunderous Force adds 6 inches to the unit's ranged weapon range for the relevant Shooting phase; a Psychic test result of 1 instead causes Battle-shock. The unit can use only one Librarius power per battle round, and the choices are made through the validated phase action flow.

The sheet's `DEATHWING` tag is conditional chapter context in the extraction, so it is excluded from the shared runtime keyword set. This is not a Dark Angels admission. Weapon fixed-data review covers all four extracted profiles and their Psychic/other traits.

Focused offline validation was initially recorded as 12/12 processes; that was an earlier increment. The current source-bounded scope closure and its exact verification evidence are recorded below. At the earlier increment, the local comparator covered 15 fixed profiles and 43 weapon profiles; the current comparator covers 16 profiles and 47 weapon profiles, with Ancient in Terminator Armour still unresolved for conditional `DEATHWING` context. Network validation remains deferred to final integration; full faction and army legality are not certified.

**27 October 2026 source-bounded scope closure:** the dedicated current-catalog suite now checks the exact one-model/40 mm/80-point profile and unconditional keywords, all four fixed weapon profiles through Equipment and AttackPlan, current-catalog resolution and admission for both players, Deep Strike, Combat Doctrines, Psychic Hood and the two Librarius powers including the level-1 round limit. The paired relation suite covers the common-book Leader links. Focused offline verification passed 4/4 processes at `.tools/verification/20261027T114625824325Z/results.json`; see [the current datasheet audit](marine-librarian-terminator-armour.md). The shared profile keeps `DEATHWING` conditional and excluded. Only the declared common-book local scope is closed; network validation and full army legality remain open.

---

<a id="marine-librarian"></a>
## Librarian (current Space Marines)

See the [source-bounded datasheet audit](marine-librarian.md) and [machine-readable audit](marine-librarian-audit.json).

The shared-book Wahapedia 11th-edition source is book `000000139`, datasheet `000002266`, checked on 27 October 2026 against verified local export snapshot `20261021T130623Z`. It defines one 75-point, 40 mm model with Bolt Pistol, both Smite profiles and Force Weapon, and no equipment-option rows. The fixed-data comparison reports no differences.

The closed local scope covers Combat Doctrines, six common-book Leader targets, Librarius level-1 use, Psychic Hood, Force Dome and Veil of Time. The focused Librarian and shared relation suites passed 4/4 processes; they cover the source-listed weapon plans, both-player catalog materialization, power timing and ownership, save and Battle-shock outcomes, and all 153 common-book Leader/Support links. This closes only the shared-book local scope, not Chapter interactions, complete army legality, network behavior or complete-match certification.

Network validation remains deferred to final integration.

---

<a id="marine-lieutenant"></a>
## Lieutenant — Wahapedia e11 local profile

See the [dedicated Lieutenant scope and source audit](marine-lieutenant.md).

Source: shared book `000000139`, datasheet `000001346`, from the local Wahapedia `/wh40k11ed/` export updated 16 October 2026.

The profile records the source identity, 50-point one-model cost, 40 mm base, M6, T5, Sv3+, W4, Ld6+, OC1, keywords, and the exported default Bolt Pistol, Master-crafted Bolter and Ceramite Fists. Its local runtime effects include Support, Combat Doctrines, Tactical Precision (Lethal Hits against targets without MONSTER or VEHICLE), and Demi-company Commander.

Army preparation exposes every source weapon replacement, including the combined Neo-volkite package and its optional Storm Shield. The dedicated suite covers all legal loadout combinations, profile routing through AttackPlan, the model-only 4+ invulnerable save, Tactical Precision target exclusions and Demi-company Commander timing. The profile remains selectable from the consolidated local catalog. These results close only the source-defined local Lieutenant scope; network validation remains deferred to final integration, and full army legality remains uncertified.

---

<a id="marine-marneus-calgar"></a>
## Marneus Calgar

[Marneus Calgar audit](marine-marneus-calgar.md) · [machine audit](marine-marneus-calgar-audit.json)

## Source and admitted profile

- **Rules authority:** Wahapedia 11th-edition local data export, Space Marines book 000000139, datasheet 000004246, export updated 2026-10-16T21:03:46+03:00. [Source page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Marneus-Calgar).
- **Runtime profile:** one Epic Hero model at 180 points, 50mm base; M6, T6, Sv2+, invulnerable save 4+, W6, Ld6+, OC1.
- **Weapons:** Gauntlets of Ultramar ranged profile (18 in, A4, BS2+, S5, AP-2, D2, Close-Quarters, Twin-linked); melee profile (A6, WS2+, S10, AP-3, D3, Twin-linked); Overhead Smash (A1, WS2+, S14, AP-3, D3+3, Extra Attacks, Twin-linked).
- **Keywords:** Infantry, Character, Epic Hero, Terminator, Imperium, Chapter Master, Adeptus Astartes and Ultramarines.

## Implemented rules

- **Codex Adept:** all three Combat Doctrines are active for Calgar’s unit.
- **Transhuman Strategist:** Calgar is checked as a Warlord choice and for the once-per-round CP grant.
- **Master Tactician:** during the owner’s Movement phase, select one visible friendly Adeptus Astartes unit within 9 inches; it gains one unused Combat Doctrine until the start of the owner’s next Command phase. Local checks cover visibility, range, doctrine availability, use limits and duration.
- **Thunderhawk Insertion:** during Declare Battle Formations, choose one friendly Gravis, Phobos or Tacticus unit; every model in that unit gains Deep Strike for the battle.
- **Leader:** the export lists 13 shared-book targets and one Warhammer Legends Vanguard Veteran Squad target (`000001154`); only the 13 current common-book links are in the local catalog scope.
- **Captain of the Honour Guard:** if Calgar is in the army, Cato Sicarius changes from Leader to Support, can attach only to Victrix Honour Guard and cannot be selected as Warlord. These checks pass locally with Calgar present and absent.

## Validation boundary

Focused local validation covers this source profile, composition limit, all three weapon profiles through Equipment and AttackPlan (including Extra Attacks), the 13 common-book Leader links, pre-battle selection and Deep Strike/reserves, Master Tactician, Codex Adept, once-per-round Transhuman Strategist/Warlord CP, and Cato’s conditional Support role. The 7/7 artifact is recorded in [verification results](verification/verification-results.md). Network validation remains deferred to final integration. Full faction and army legality are not certified.

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

<a id="marine-lieutenant-in-phobos-armour"></a>
## Lieutenant in Phobos Armour — source-bounded local scope, 28 October 2026

Reviewed against [Wahapedia Lieutenant in Phobos Armour](https://wahapedia.ru/wh40k11ed/factions/space-marines/Lieutenant-In-Phobos-Armour), sheet `000002530`, shared Space Marines App book `000000139`. The live page was checked on 28 October 2026; the source is App 2.8.1 / October 2026. Datasheet facts use verified local snapshot `20261021T130623Z`, specification revision `20260817b`; the machine audit records provenance and relevant source hashes.

The dedicated scope checks the one-model 40-point/40 mm profile, full keywords, one pistol-to-carbine replacement, both ranged choices and retained blades through Equipment and AttackPlan, both-player current-catalog materialization and the three-copy cap. The four common-book Support links match the source and pass the paired 153-link regression. The suite also covers Deep Strike, Scouts and Infiltrators model-level eligibility, the mixed-unit Stealth boundary, reserve setup, Tactical Precision's target exclusion, reversible equipment while attached, and the public-command Demi-company Commander response to Strategic Acumen. Spectrus Kill Team and Wolf Scouts are source-listed but belong to Deathwatch and Space Wolves Apps, so remain outside the shared-book catalog.

Focused offline verification passed 5/5 processes at `.tools/verification/20261028T013420957771Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). This closes only the shared-book local sheet scope; full Chapter/army legality, complete-match behavior, human playtesting and network validation remain outside the result. See the [dedicated audit](marine-lieutenant-phobos-armour.md).

---

<a id="marine-phobos-batch"></a>
## Phobos batch — historical targeted validation (18 October 2026)

`marine-phobos-batch.md`

Targeted local validation ran on 18 October 2026. `test_infiltrator_squad.gd` and `test_phobos_lieutenant.gd` passed, alongside the local catalog, roster, reserve, capability, Infiltrators and Ancient regressions in verification run `.tools/verification/20261019T022024657123Z`. The runner passed 13 processes, including import, Python checks and startup. The full local suite and network validation remain pending; this batch does not establish full army legality.

The 18 October batch is historical evidence. The current Infiltrator Squad sheet scope is recorded in the [dedicated audit](marine-infiltrator-squad.md); its source-checked offline run passed 3/3 processes on 27 October 2026 at `.tools/verification/20261027T065849306066Z/results.json`, using current Space Marines catalogs for both players. That scope closes composition/costs, weapons, the individual Helix option and healing path including destroyed non-Character return, Infiltrators placement, Omni-Scramblers and all three Leader links. It remains local scope evidence only; network validation and full army legality are still deferred.

## Sources and admitted scope

Reviewed 18 October 2026 against [Wahapedia Infiltrator Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Infiltrator-Squad), sheet `000000128`, and [Lieutenant In Phobos Armour](https://wahapedia.ru/wh40k11ed/factions/space-marines/Lieutenant-In-Phobos-Armour), sheet `000002530`, shared App Space Marines book `000000139`. Local export revision: 16 October 2026, 21:03:46 GMT+3. Core [01.02.02, 02.02.04, 24.31 and 24.33](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) govern duration, healing, Scouts and Stealth. Chapter, Boarding Actions and unadmitted bodyguard variants remain excluded.

Infiltrators support 5/10 models at 85/150 points, with M8/T4/Sv3/W2/Ld6/OC1 and 32mm bases. The carbine, pistol and fists use separate fixed weapon instances; the carbine keeps Precision and Rapid Fire. The squad's deployment ability uses the existing ground-board Infiltrators checks. Optional Helix equipment is selected on exactly one Infiltrator during preparation. Selecting another bearer transfers it, and removing it leaves the unit unequipped. It neither replaces weapons nor grants healing without a surviving equipped source.

Helix Gauntlet uses the shared D3 healing preview in the owner's Command phase. It can heal the attached Lieutenant and can return destroyed non-Characters under the existing survivor-first and placement rules. A dead equipped bearer supplies no action. Reset preserves the original budget. Mandatory useful Command healing includes both Helix and Narthecium choices; their labels and usage records remain separate. This batch retains the existing battlefield-source healing scope and does not certify new off-board healing interactions.

Omni-scramblers is a separate Shooting-phase action. Visibility and 18-inch unit range are checked before applying the mark; its detection benefit cannot bootstrap selection of an otherwise invisible target. A phase-stamped target mark adds three inches of detection, expires with the phase and does not stack with another identical mark. It can combine with the different Eliminator Optics bonus. It does not spend CP, consume shooting or require the unit to be unshocked. The once-per-phase source-unit limit is recorded independently of shooting.

The earlier Phobos implementation admitted the Lieutenant only with Infiltrators or Eliminators. The current 28 October source-bounded scope verifies all four shared-book targets and the complete local profile; Spectrus Kill Team and Wolf Scouts remain outside this catalog. The Tacticus Lieutenant keeps a separate attachment list and Apothecary pairing exception.

## Mixed-unit eligibility

Infiltrators deployment checks now recognize each reviewed provider individually. A Phobos Lieutenant attached to either admitted bodyguard preserves this ability. It does not supply Stealth, so attaching it to Eliminators prevents the whole unit from qualifying for all-model Stealth; their separate unit-level cloak rule is unchanged.

Scouts 6 inches is retained as source metadata on the Lieutenant and its all-model eligibility predicate is explicit. Both currently admitted mandatory bodyguards lack Scouts. Consequently, no legal completed formation introduced here qualifies for a Scout move; no general Scout movement controller is claimed implemented. Supporting future Scout-capable bodies requires implementing that controller before their admission. After combat casualties, an isolated Lieutenant cannot retroactively take a pre-battle Scout move.

Deep Strike is similarly model-specific and requires every model in a unit. The mixed Phobos formations do not qualify. Reserve selection now uses that whole-unit condition, and an unattached mandatory Support cannot enter reserves before formation declarations. Existing complete Terminator formations retain their eligibility. Regression of that shared change is pending the final run.

The profile digest now includes the alternate Terminator Captain, Gravis Captain and Phobos Lieutenant equipment helpers, avoiding silent compatibility changes from alternate loadout data.

## Written tests and UI evidence

`test_infiltrator_squad.gd` covers 5/10-model pricing, mixed-unit deployment eligibility, optional single Helix bearer transfer/removal, D3 healing previews, attached-character healing, revival, excess/usage/source boundaries, detection duration/combination, hidden/out-of-range selection and rejected actor/revision commands.

The current `test_phobos_lieutenant.gd` uses current Marine catalogs on both sides. Its 28 October run passed alongside the Infiltrator regression and all 153 common-book Leader/Support links; it covers exact profile/weapon data, Equipment and AttackPlan, construction, abilities, mixed-unit eligibility, the reversible gun swap and doctrine response. Earlier `test_infiltrators.gd` remains the separate core-deployment suite and was not overwritten.

The UI preserves existing layout, typography and controls. Context help identifies the single optional Helix bearer, transfer/removal, the exclusive Lieutenant swap and detection duration. Healing displays the actual source name. The inspected real Godot capture `.tools/phobos-batch-preparation.png` shows a staged 1600x1000 preparation fixture, the selected Helix option and readable help. No pre-implementation capture or full interaction validation is claimed. It is not a completed match or test-pass report.

Final-run queue: the complete Space Marine suite, including mixed-unit Stealth, detection/Optics, shared healing/Apothecary, Support matching, doctrines, preparation/UI startup and capability metadata. Game/network validation remains deferred to final integration. Runtime inventory is 27 shared-book Marines and four Necrons, with 58 shared-book Marine identities unimplemented. See the [audit](marine-phobos-batch-audit.json).

---

<a id="marine-redemptor-dreadnought"></a>
## Redemptor Dreadnought — source-bounded local scope, 27 October 2026

The Redemptor's one-model profile, copy costs and limit, all four source equipment rows, sixteen loadout packages, 64 ranged AttackPlan routes, melee Fist, weapon traits and target conditions, Damaged 4, Duty Eternal, Combat Doctrines, Deadly Demise and conditional Dark Angels `DEATHWING` context have a dedicated source-bounded suite. The detailed source snapshot, relevant file hashes, exact tested scope and limits are recorded in the [Redemptor datasheet audit](marine-redemptor-dreadnought.md).

The focused offline run passed **3/3 processes** at `.tools/verification/20261027T051901469684Z/results.json` (`network: false`, `legacy_starter_staged: false`). This closes the Redemptor's local scope within the shared-book 85 only; it does not establish general roster legality or match/network certification.

---

<a id="marine-reiver-squad"></a>
## Reiver Squad — local Wahapedia implementation

`marine-reiver-squad.md`

The initial implementation was recorded on 19 October 2026 using the profile's `2026-10-16T21:03:46+03:00` source stamp. Its current source-bounded scope is recorded in the [dedicated Reiver audit](marine-reiver-squad.md), verified 27 October against the 21 October local export snapshot. Wahapedia `/wh40k11ed/` is the sole rules authority. The source sheet is [Reiver Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Reiver-Squad).

## Runtime scope

- 5 models for 85 points or 10 for 165; one Reiver Sergeant plus four/nine Reivers. Stats: M8, T4, Sv3+, W2, Ld6+, OC1; 32 mm bases.
- Fixed equipment per model: Bolt Carbine (18 inches, A3, BS3+, S5, AP-1, D1; Assault, Precision), Special-issue Bolt Pistol (12 inches, A1, BS3+, S5, AP-2, D1; Close Quarters, Precision), and Monomolecular Combat Knife (A4, WS3+, S5, AP-1, D1; Precision).
- Scouts 6 uses the existing all-model pre-battle move or reserve set-up rules.
- Terror Troops reduces each enemy model's OC by 1 while it is within 3 inches of any living Reiver model. Battle-shock still sets OC to zero.
- Fearsome Assault resolves at the start of the Fight phase, before pile-in. Each unique enemy unit engaged with at least one Reiver unit takes a Battle-shock test with -1 to the roll. A passing test does not clear Battle-shock already in effect.
- Grav-chutes and Grapnel Launchers are independent optional unit-level equipment choices. Grav-chutes grant Deep Strike while equipped. Grapnel Launchers permit movement paths through models and ignore vertical distance; the current focused check covers the supported central first floor and confirms that normal ruin-wall access still applies.
- The verified local export lists Leader links for Librarian in Phobos Armour, Captain in Phobos Armour and Lieutenant in Phobos Armour. The current suite admits all three and rejects a generic Captain.

## Validation boundary

The current local focused suite covers both priced compositions, all weapon statistics through Equipment and AttackPlan, both independent equipment choices and their removal, all three source Leader links, all-model Scouts 6, model-level Terror Troops, Fight-phase Fearsome Assault and its persisted defender reroll, gear-dependent Deep Strike and Grapnel movement through models and the supported first-floor wall-access boundary. See the [dedicated audit](marine-reiver-squad.md) for snapshot hashes and the passing run. Network validation, full faction/army legality and human playtesting remain outside this scope.

---

<a id="marine-scout-squad"></a>
## Scout Squad — local Wahapedia implementation

`marine-scout-squad.md`

Reviewed 27 October 2026 against the project's verified 11th-edition Wahapedia export (book `000000139`, datasheet `000001160`, export timestamp `2026-10-16T21:03:46+03:00`). Wahapedia `/wh40k11ed/` is the sole rules authority for this implementation. The direct sheet is [Scout Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Scout-Squad).

## Runtime scope

- 5 Scouts for 65 points or 10 for 120; one Scout Sergeant plus four/nine Scouts. Characteristics: M6, T4, Sv4+, W2, Ld6+, OC1.
- Fixed equipment: Bolt Pistol, Boltgun and Combat Knife per model.
- Sergeant may replace Boltgun with Shotgun and Combat Knife with Chainsword. Any Scout may replace Boltgun with Shotgun. Per five models, one Sniper Rifle and one additional special weapon; Heavy Bolter and Missile Launcher share the special-weapon slot. Missile Launcher has Frag and Krak profiles.
- Scouts 6 is available only when every living model qualifies. After deployment and first-turn determination, eligible units alternate; the squad may make a normal move up to 6 inches or set up from Strategic Reserves wholly within its owner's deployment zone. It must finish more than 8 inches horizontally from enemy models.
- Infiltrators applies the current deployment restriction. Both source-linked Leaders, Captain in Phobos Armour and Librarian in Phobos Armour, are admitted and tested.
- Flexible Asset allows an otherwise eligible Action to start after the unit is selected to Advance or Fall Back; all other Action restrictions still apply.

## Validation boundary

The original focused offline verification passed 13/13 processes in `.tools/verification/20261019T041415760366Z/results.json`. The expanded Scout suite now checks both model counts and prices, every equipment replacement and cap, each ranged profile and the Sergeant's Chainsword through AttackPlan, Infiltrators deployment, Scouts 6 movement and Strategic Reserves set-up for Scout Squad, Flexible Asset after Advance/Fall Back with Battle-shock still enforced, and both source-linked Leaders. It passed with import and Python checks in `.tools/verification/20261027T044508003953Z/results.json`.

The reproducible fixed-data comparison passed Scout Squad across all nine weapon profiles and its default equipment, composition and cost. Together with the expanded rule tests, this is the first shared-book datasheet whose source-defined local scope is implemented and locally tested. It does not certify full faction/army legality, every detachment interaction or network behavior. Chapter-book, Forge World and Legends variants remain excluded.

---

<a id="marine-sternguard"></a>
## Sternguard Veteran Squad — current e11 implementation

Reviewed 28 October 2026 against [Wahapedia Sternguard Veteran Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Sternguard-Veteran-Squad), datasheet `000002255` in shared book `000000139`, and the verified local export snapshot `20261021T130623Z`. The distinct Black Templars Sternguard page remains excluded. Deathwing is a conditional Dark Angels keyword and is not added to the shared runtime profile.

Five models cost 105 points and ten cost 210 for the first two copies; the source third-plus costs are 120/225. The local Incursion gate admits at most two non-BATTLELINE copies. Models have 32 mm bases, M6, T5, Sv3+, W2, Ld6+ and OC1. The Sergeant starts with a Chainsword; ordinary Veterans start with Ceramite Fists. Everyone retains a Bolt Pistol and an Artificer Firearm with Infernus, Purgatus and Damnatus profiles.

The Sergeant can replace the Chainsword with a Power Fist or Power Weapon. One ordinary Veteran per five models may replace the Artificer Firearm with a Heavy Bolter or Pyrecannon. The dedicated suite checks the Sergeant/player boundary, five- and ten-model limits, public choice validation, changing a special weapon at capacity, restoration and reuse. The attached Captain case preserves the five-model allowance.

Veteran Marksmen re-rolls ranged Hit rolls of 1, including attached Leader ranged attacks. The suite checks actual Hit resolution, prevents rerolling a replacement 1, and confirms no melee reroll or Snap Shooting exception. It also checks that the benefit ends when no living Sternguard source remains.

The shared relation map retains eight common-book Leader and six `Supported by` identities. The paired relation suite checks all 153 common-book links. Each default and replacement weapon passes the shared Equipment/AttackPlan path; the focused suite also checks Rapid Fire, the inclusive Damnatus Melta boundary, Advance with Assault and Pyrecannon Blast 2/Torrent.

Focused offline validation passed 4/4 processes at `.tools/verification/20261028T052655350303Z/results.json`; see the [source-bounded local scope report](marine-sternguard-veteran-squad.md) and [machine audit](marine-sternguard-veteran-squad-audit.json). Network validation is deferred to final integration. Full faction/army legality, Chapter adaptations, Strike Force admission and full-match certification remain outside this scope.

---

<a id="marine-storm-speeder-hailstrike"></a>
## Storm Speeder Hailstrike — current e11 implementation

[marine-storm-speeder-hailstrike.md](marine-storm-speeder-hailstrike.md)

Implemented 19 October 2026 from the pinned local Wahapedia Space Marines App export (`000000139`), datasheet `000000124`, revision `2026-10-16T21:03:46+03:00`. This is one 90 mm-base model with M14, T9, Sv3+, W11, Ld6+ and OC3. It costs 110 points for each of the first two copies and 120 for the third-plus tier. Its source keywords are RAVENWING, SPEEDER, IMPERIUM, FLY, VEHICLE and FRAME; ADEPTUS ASTARTES is also retained as its faction identity.

The fixed loadout is one Fragstorm Grenade Launcher (Blast 2, Ignores Cover), one Ironhail Heavy Stubber Array (Rapid Fire 6, Ignores Cover), one Onslaught Gatling Cannon (Devastating Wounds against targets without MONSTER or VEHICLE, Ignores Cover) and Armoured Impact.

**Hailstrike:** in its own Shooting phase, after it shoots, select one enemy unit hit by its attacks. Until the end of that phase, ranged attacks made by friendly ADEPTUS ASTARTES units against that target have Ignores Cover. The selection window only offers living enemy units hit by this Hailstrike's resolved attacks. The common cover-mark flow applies the effect to allied Astartes units, excludes the opposing side and melee attacks, and expires the mark at phase end. The datasheet also grants Deep Strike, Damaged 4 and Deadly Demise D3.

`tests/test_storm_speeder_hailstrike.gd` checks every weapon field through Equipment and AttackPlan, current-catalog construction for both players, the tiered prices and three-copy cap, the conditional cannon trait and the public hit-target mark with allied ranged Ignores Cover, ownership/target/attack-type exclusions and phase expiry. It passed as part of the 7/7-process run `.tools/verification/20261027T104505989012Z/results.json`; see [the Hailstrike scope audit](marine-storm-speeder-hailstrike.md). This does not certify complete faction rules or army legality. Network validation remains deferred to final integration.

---

<a id="marine-storm-speeder-hammerstrike"></a>
## Storm Speeder Hammerstrike — current e11 implementation

[marine-storm-speeder-hammerstrike.md](marine-storm-speeder-hammerstrike.md)

Implemented 19 October 2026 from the pinned local Wahapedia Space Marines App export (`000000139`), datasheet `000000114`, revision `2026-10-16T21:03:46+03:00`. This is one 90 mm-base model with M14, T9, Sv3+, W11, Ld6+ and OC3. It costs 140 points for each of the first two copies and 150 for the third-plus price tier. Its source keywords are VEHICLE, FLY, FRAME, RAVENWING, IMPERIUM and SPEEDER; ADEPTUS ASTARTES is retained as the runtime faction identity tag.

The fixed loadout is one Hammerstrike Missile Launcher, one Krakstorm Grenade Launcher, one Melta Destroyer and Armoured Impact. The Melta Destroyer has Melta 3. The source also grants Deep Strike, Damaged 4, Deadly Demise D3 and Hammerstrike.

**Hammerstrike** gives each ranged attack made by this unit Sustained Hits 1 when its target enemy unit is within a terrain area. The runtime uses the existing terrain-area geometry: any living target model whose base overlaps an area qualifies, including when its centre is outside the area. Existing Sustained Hits values are not reduced. The rule does not affect melee attacks. The 11e terrain layout is represented at ground level; upper-floor terrain geometry is not part of this increment.

`tests/test_storm_speeder_hammerstrike.gd` checks every weapon field through Equipment and AttackPlan, current-catalog construction for both players, source price tiers and the three-copy cap, terrain-overlap Sustained Hits 1 in a prepared ranged attack, outside-terrain and melee exclusions, and the Damaged 4 threshold. It passed as part of the 7/7-process run `.tools/verification/20261027T104505989012Z/results.json`; see [the Hammerstrike scope audit](marine-storm-speeder-hammerstrike.md). Full faction/army legality and network validation remain open.

---

<a id="marine-storm-speeder-thunderstrike"></a>
## Storm Speeder Thunderstrike — current e11 implementation

[marine-storm-speeder-thunderstrike.md](marine-storm-speeder-thunderstrike.md)

Implemented 19 October 2026 from the pinned local Wahapedia Space Marines export, shared book `000000139`, datasheet `000001610`, revision `2026-10-16T21:03:46+03:00`. The fixed reference is one 90 mm base proxy with M14, T9, Sv3+, W11, Ld6+ and OC3. Costs are 140 points for each of the first two copies and 150 for the third-plus tier, with a maximum of three copies represented by the current construction scope.

The fixed loadout is a Stormfury Missile Launcher (48", A2, BS3+, S10, AP-3, D3+3), Thunderstrike Icarus Rocket Pod (24", A6, BS3+, S6, AP-1, D2, Anti-Fly 2+), Thunderstrike Las-talon (36", A2, BS3+, S10, AP-3, D3+3) and Armoured Impact (A3, WS4+, S6, AP0, D1). Source keywords include VEHICLE, FLY, RAVENWING, SPEEDER, IMPERIUM and FRAME; ADEPTUS ASTARTES is retained as its faction identity.

**Thunderstrike:** ranged attacks made by this unit against a MONSTER or VEHICLE get +1 to the Wound roll. The modifier does not apply to melee attacks and is handled with the normal Wound modifier cap.

**Shattered Defences:** in your Shooting phase, after this unit shoots, select one enemy MONSTER or VEHICLE unit hit by its attacks. Until phase end, friendly ADEPTUS ASTARTES ranged attacks against that unit gain +1 AP. The action prompt only offers a qualifying living target that was hit. The mark is owned by the Thunderstrike’s side, applies to allied Astartes ranged attacks, excludes melee and enemy attacks, and expires at phase end. Deep Strike, Damaged 4 and Deadly Demise D3 use the existing current core-rule implementations.

`tests/test_storm_speeder_thunderstrike.gd` checks every weapon field through Equipment and AttackPlan, current-catalog construction for both players, source price tiers and the three-copy cap, Anti-Fly 2+, the +1 Wound modifier against a real current-catalog Vehicle and its ordinary/melee boundaries, and Shattered Defences through the public hit-target choice, AP recipient and phase limits. It passed as part of the 7/7-process run `.tools/verification/20261027T104505989012Z/results.json`; see [the Thunderstrike scope audit](marine-storm-speeder-thunderstrike.md). Full faction/army legality and network validation remain open.

---

<a id="marine-suboden-khan"></a>
## Suboden Khan

[Dedicated scope audit](marine-suboden-khan-audit.json)

Suboden Khan is admitted from the verified local Wahapedia 11th-edition Space Marines export: shared book 000000139, datasheet 000004167. Snapshot 20261021T130623Z was retrieved on 21 October 2026; the live 11e page was checked on 27 October. The fixed-data comparator reports no Suboden differences. The source lists one 105-point model on a 90 × 52 mm oval base, four fixed weapons and no equipment-option rows.

The dedicated scope covers the four weapons through Equipment and AttackPlan, current Marine catalogs for both players, unique-copy admission, the sole Outrider Squad Leader link, Combat Doctrines and Transhuman Strategist, Spear of Chogoris, Skilled Riders, the Power Sword target-gated Sustained Hits 1, and Stormtooth Anti-MONSTER/VEHICLE 4+ and Lance effects. Focused verification passed 7/7 processes. The run records network=false and legacy_starter_staged=true; this is bounded local evidence, not clean-checkout demo evidence, network validation or full army-legality certification.

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

**27 October 2026 scope closure:** the current source-bounded suite now covers all three weapons through Equipment and AttackPlan, both ability effects at their calibrated base-edge and phase boundaries, deferred movement timing, D3 healing, modifier expiry, saved movement continuation and current-catalog admission for both players. Focused offline verification passed 5/5 processes at `.tools/verification/20261027T085333172418Z/results.json`; see the [current Techmarine audit](marine-techmarine.md). This closes the shared-book local sheet scope only.

---

<a id="marine-terminator-assault-squad"></a>
## Terminator Assault Squad

[Current source-bounded sheet audit](marine-terminator-assault-squad.md) · [Machine audit](marine-terminator-assault-squad-audit.json)

The shared Space Marines 11th-edition profile comes from Wahapedia book 000000139, datasheet 000000118, local export timestamp 2026-10-16T21:03:46+03:00. One Terminator Sergeant and four to nine Terminators form five- or ten-model units. They cost 170/340 points for the first two copies and 210/380 for third-plus. Each 40 mm model has M5/T6/Sv2+/W3/Ld6+/OC1 and a 4+ invulnerable save. Each starts with Twin Lightning Claws; any model may replace them with a Storm Shield and Thunder Hammer. The shield adds one Wound and costs 5 points per model.

The runtime checks Deep Strike, Teleport Homer and Terminatus Assault. The Homer can be placed at the start of battle; its once-per-battle Rapid Ingress use is free, places the unit within 3 inches of the marker and more than 8 inches from enemies, and consumes the marker. An enemy ending a move within 1 inch removes it. Deep Strike placement observes the current Core Rules exception to Strategic Reserves edge/deployment-zone limits while keeping enemy clearance, terrain, bases and coherency valid. Terminatus Assault grants Sustained Hits 1 to Lightning Claws after a charge against non-MONSTER/VEHICLE targets and to Thunder Hammers against MONSTER/VEHICLE targets. The common-book links are six Leaders and the Ancient in Terminator Armour as its one Support target; Chapter-book links remain out of scope.

`tests/test_terminator_assault_squad.gd` covers both unit sizes and cost tiers, exact model profiles and weapon traits, reversible shield choices and costs, weapon plans, ability target/timing boundaries, both-player catalog materialization, the local two-copy Incursion limit, and common-book links. Focused offline verification passed 11/11 processes at `.tools/verification/20261028T054135729338Z/results.json`; see the sheet audit. This closes only its shared-book local scope. Chapter-conditional DEATHWING, Chapter-book variants, full faction/army legality and network validation remain outside this result; network validation is deferred to final integration.
---

<a id="marine-terminator-captain"></a>
## Captain in Terminator Armour — current e11 implementation

`marine-terminator-captain.md`

Reviewed 18 October 2026 against [Wahapedia Captain In Terminator Armour](https://wahapedia.ru/wh40k11ed/factions/space-marines/Captain-In-Terminator-Armour), datasheet `000000135`, shared App Space Marines book `000000139`. The pinned [export](https://wahapedia.ru/wh40k11ed/the-rules/data-export/) revision is 16 October 2026, 21:03:46 GMT+3. [Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) reroll, charge, weapon-selection and Torrent semantics apply. Chapter/Deathwing and Boarding Actions adaptations are outside this shared-book admission.

One model costs 90 points: M5/T6/Sv2/W6/Ld6/OC1, 4+ general invulnerable save and the source's 40mm base. This Captain is a separate identity and does not receive the ordinary Captain's Finest Hour. Its common-book Leader targets are Terminator Assault Squad and Terminator Squad; Chapter-book links remain outside this shared scope. Existing mechanisms provide Deep Strike, Strategic Acumen and Transhuman Strategist. Current checked construction takes its price from the reviewed profile and accounts for its full 90 points when attached for reserves.

Two independent preparation swaps are reversible before setup finishes: Storm Bolter to Combi-weapon, and Relic Weapon to Relic Fist. The swaps preserve one another across attachment. The Combi-weapon is one weapon instance with three alternative profiles: Infernus, Purgatus and Damnatus. A declaration may use one of them, and cannot fire two profiles of that instance. Existing Torrent/Blast, Melta and random damage mechanisms resolve the relevant modes.

The Infernus row prints no BS. Runtime zero represents that absent stat only when Torrent provides automatic hits. Attack validation v5 accepts this narrow case while rejecting zero BS without Torrent; older Torrent weapons with a numeric stored BS retain their behavior. A dedicated check resolves automatic hits in cover without hit dice. The combat log does not display a worsened BS when no hit rolls were made.

## Unstoppable Valour and decision flow

The checked current-match reaction infrastructure now offers a free charge reroll when the living Captain is in the charging unit. It works at zero CP, with paid movement rerolls disabled, and while battle-shocked. The player can accept the original result or replace both D6. The replacement is mandatory even when worse. Either decision closes the window before target selection; another free or paid reroll of those dice is rejected. A failed charge still consumes that unit's charge declaration.

This datasheet choice is independent of Command Re-roll expenditure and usage. If the paid movement option is enabled and the unit is eligible, the player can instead use Command Re-roll normally. Enabling only attack rerolls does not enable the paid Advance/Charge option in a free ability window. No rerolling of only one charge die is exposed. Actor, squad, revision, phase and dice validity checks precede commitment. Free reroll scope is the current checked match with reaction infrastructure enabled; training combinations with core reaction infrastructure disabled are not newly supported.

## UI brief and validation

The player needs to distinguish accepting, paying for a reroll and using this free datasheet rule. Existing layout, typography and colors are preserved. The existing free-reroll button adapts its label and callback to the active ability, retaining Sudden Storm for Advance. Context help states zero CP, both D6, mandatory replacement and no second reroll. The top decision message names the available free ability. Equipment choices use the existing selector and explain independent replacements and alternative Combi profiles.

Real Godot before/after captures at 1600x1000 were inspected: `.tools/terminator-captain-before.png` and `.tools/terminator-captain-after.png`. Both use the same staged attached-unit Charge fixture, fixed [1,1] dice, zero CP, camera and framing. Before UI integration the free rule was absent from the controls and the message pointed to a disabled paid reroll. After integration the free action and its consequences are visible. These are staged decision captures, not completed-match or network evidence; equipment-selector help and all viewport sizes were not separately captured.

The 27 October current-catalog suite covers both-player admission/materialization, exact profile and source identity, default and alternate weapon routes through Equipment/AttackPlan, all three Combi modes, both independent replacements, Strategic Acumen, Unstoppable Valour and Transhuman Strategist timing/limits. The shared relation suite verifies both common-book Leader links. See the [current sheet audit](marine-terminator-captain.md), [machine audit](marine-terminator-captain-audit.json) and `.tools/verification/20261027T115826825089Z/results.json`. Historical charge-decision, actor/revision and regression evidence remains in the machine audit and earlier verification records.

Network validation remains deferred to final integration by user instruction. Full faction, army and match certification remain incomplete.

---

<a id="marine-terminator-chaplain"></a>
## Chaplain in Terminator Armour — current e11 implementation

`marine-terminator-chaplain.md`

Reviewed 18 October 2026 against [Wahapedia Chaplain In Terminator Armour](https://wahapedia.ru/wh40k11ed/factions/space-marines/Chaplain-In-Terminator-Armour), datasheet `000000115`, shared App Space Marines book `000000139`, and [Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) 19.01, 19.04 and 24.12. The pinned export revision is 16 October 2026, 21:03:46 GMT+3. Chapter and Boarding Actions adaptations remain excluded. In particular, the consolidated DEATHWING keyword is not admitted into this shared-book profile.

One model costs 75 points: M5/T6/Sv2/W5/Ld5/OC1, general 4+ invulnerable protection and 50mm base. Fixed default equipment is Storm Bolter and Crozius Arcanum. The former retains Rapid Fire 2; the latter Cleave 1. During preparation the bearer may exchange its bolter for Relic Shield, increasing its maximum wounds to six. The crozius remains and the shield adds no shooting weapon. Swapping back restores the bolter and five wounds; both declarations remain available after attachment and before preparation finishes.

This is a separate Leader from the ordinary Chaplain. Its common-book Leader targets are Terminator Assault Squad and Terminator Squad; Chapter-book links are outside this shared scope. It has Deep Strike and can enter the existing checked reserve/ingress flow alone or with its eligible attached bodyguard. It grants the unit melee Lance through the existing Litany of Hate mechanism, and does not gain Spiritual Leader from the ordinary Chaplain.

Zealous Fortitude grants the whole current unit Feel No Pain 4+ against mortal wounds. A shared `unit_prevention.gd` derives unit grants from living battlefield sources and combines them with personal prevention rules. The existing wound-prevention engine selects the best applicable threshold and rolls once per prospective wound; a second rule does not create another prevention roll. Ordinary damage receives no benefit from this grant. Attack allocation snapshots retain the unit effect until that attacking unit finishes, as required when its source dies during the attack sequence. Outside that sequence, source death or removal stops the grant. Historical implementations do not acquire it, and malformed personal rules remain validation errors.

The same effective prevention rules feed automatic/manual attack allocation, Hazardous, escape mortal wounds and Explosives. Tests exercise actual automatic and manual devastating-damage allocation, direct escape allocation, mortal versus ordinary packets, overlapping prevention, source loss and historical isolation. Existing Hazardous and Explosives suites provide regression coverage; they do not prove every possible new mixed-unit interaction.

## Reserve cost correction

Attaching a Character now adds its construction cost to the body's stored unit cost. A Terminator unit with this Chaplain therefore costs 265 points for the existing half-points reserve limit. A staged 500-point limit rejects that assignment; a 1000-point limit accepts it and records 265. Attaching either side after it has been assigned to reserves is blocked, avoiding an orphan source reservation. Finish formation declarations before assigning reserves. Other reserve caps, missions and unadmitted transport interactions are not newly certified by this change.

## UI brief and evidence

The player needs to see exactly what the shield replaces and which model gains the wound. Existing viewport, layout, type, color and controls are preserved; only the option label and contextual help change. The label is shortened to fit. Help states the removed bolter, retained crozius, six-wound bearer and reversible preparation choice.

Real Godot before/after captures at 1600x1000 were inspected: `.tools/terminator-chaplain-before.png` and `.tools/terminator-chaplain-after.png`. Both use the same staged admitted-profile preparation fixture, framing and unshielded bearer. The initial label was clipped and generic help omitted the replacement; the revised label and contextual explanation fit. A third real capture, `.tools/terminator-chaplain-shield.png`, shows the successful swap, W6/6 and the option to restore the Storm Bolter. These staged captures do not establish a completed match or every viewport size.

The 27 October current-catalog suite covers both-player admission/materialization, the exact source profile, fixed weapons through Equipment/AttackPlan, Storm Bolter-to-Relic Shield replacement and Wound change, Leader/Deep Strike/Combat Doctrines metadata, Litany of Hate, Zealous Fortitude and reserve placement. The shared relation suite verifies both common-book Leader links. See the [current sheet audit](marine-terminator-chaplain.md), [machine audit](marine-terminator-chaplain-audit.json) and `.tools/verification/20261027T115826825089Z/results.json`. The machine audit preserves 22 earlier comparisons of runtime characteristics, weapon numbers, cost, base and scoped keywords. Network validation remains deferred to final integration; full army and match certification remain incomplete.

---

<a id="marine-terminator-squad"></a>
## Terminator Squad — 28 October 2026

[Terminator Squad source-bounded audit](marine-terminator-squad.md) · [machine audit](marine-terminator-squad-audit.json)

The current 11th-edition record is sourced from the verified local Wahapedia export snapshot `20261021T130623Z`, revision `20260817b`, with the live shared Space Marines page checked on 28 October: Space Marines App (`000000139`), datasheet `000001183`, runtime export stamp `2026-10-16T21:03:46+03:00`. The unit has one Terminator Sergeant and four to nine Terminators, in five- or ten-model sizes. The first two units cost 190/380 points; later copies cost 230/420. Models use 40 mm bases and M5/T6/Sv2+/W3/Ld6+/OC1 with a 4+ invulnerable save. Deathwing remains Chapter-contextual and is not applied as a shared-book keyword.

Every model starts with a Storm Bolter and Power Fist. The Sergeant can replace its fist with a Chainfist or Power Weapon. Any number of regular Terminators may replace their Power Fists with Chainfists. For each five starting models, one regular Terminator may replace its Storm Bolter with an Assault Cannon or Heavy Flamer, or take a Cyclone Missile Launcher while keeping the Storm Bolter. A 10-model squad can assign two such weapons. Each Cyclone Missile Launcher adds 10 points. All source-listed profiles, including both Chainfist modes and both Cyclone modes, resolve through Equipment and AttackPlan.

Deep Strike and Teleport Homer are available. The Homer is once per battle per unit; Rapid Ingress through its token costs 0 CP, sets the unit up within 3 inches and more than 8 inches from enemies, and removes the token. An enemy move ending within 1 inch also removes it. Fury of the First improves ranged and melee AP by 1 when the target is within 9 inches of the attacking unit, including attacks made by an attached Leader. A focused match suite checks both unit sizes for both players, all current weapon/options and their caps, AP range boundaries, reserve arrival and the local Incursion cap. It also checks the six common-book Leaders and Ancient in Terminator Armour Support target; the paired relation regression covers all 153 common-book links.

Focused offline verification passed **7/7 processes** at `.tools/verification/20261028T055847733207Z/results.json` (SHA-256 `2d63936c3e478b86194ef0782f4417b31ae27660429d6bb2822d4be4f1fce829`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics). This is the 75th of 85 shared-book local scope closures; ten option-bearing scopes remain. The checks also caught and fixed an initializer that erased the default Power Fist when current abilities were enabled. Network validation remains deferred; full army legality and complete Space Marines support are not certified.
---

<a id="marine-tor-garadon"></a>
## Tor Garadon

[Tor Garadon source-bounded audit](marine-tor-garadon.md) · `marine-tor-garadon-audit.json`

Tor Garadon is admitted from the local Wahapedia 11th-edition export: shared book `000000139`, datasheet `000002473`, export timestamp `2026-10-16T21:03:46+03:00`. The profile is 90 points for one model, with its extracted characteristics, 40 mm base, Artificer Grav-gun and Hand of Defiance. Faction keywords Adeptus Astartes and Imperial Fists remain identity tags; this does not implement an army-wide Imperial Fists rule.

The runtime implements Leader with the four linked datasheets in the local export: Aggressor Squad, Heavy Intercessor Squad, Eradicator Squad with Heavy Bolters and Eradicator Squad with Melta Rifles. Siege Captain adds 2 Strength, AP and Damage to Tor's attacks against Fortification, Monster or Vehicle targets. Signum Array is selectable once during the owner's Shooting phase against a visible enemy within 18 inches and removes that target's benefit of cover for the phase.

The source-bounded local scope passed on 27 October 2026. The focused run checks both fixed weapons through Equipment and AttackPlan; current Space Marines catalogs on both sides; one-copy admission; Warlord/CP timing; Siege Captain's Vehicle, Monster, Fortification and ordinary-target conditions in ranged/melee plans; Signum Array ownership, selected-target cover denial, use limit and phase expiry; and all 153 source Leader/Support relations. See the [Tor Garadon audit](marine-tor-garadon.md) and `.tools/verification/20261027T235102047086Z/results.json`. Network validation and full army legality remain outside this scope.

---

<a id="marine-transports"></a>
## Space Marine transports — local implementation record

`marine-transports.md`

Status: the eight shared-book transport profiles are admitted through the consolidated local catalog; transport rules and full-list legality remain bounded by their individual evidence. Source: local Wahapedia 11th-edition export, snapshot `20261021T130623Z` (retrieved 2026-10-21 19:46:58 UTC; export updated `2026-10-21 16:06:23 GMT+3`), plus the local 11e Core Rules capture. This record does not claim network validation or full legality.

## Implemented and locally checked

- A reproducible import creates eight source-linked profiles: Land Raider, Land Raider Crusader, Land Raider Redeemer, Drop Pod, Impulsor, Repulsor, Repulsor Executioner and Rhino.
- The rules engine reads the local profiles, checks friendly passengers, source-listed keyword inclusions/exclusions, full-unit capacity, Gravis/Terminator double-space costs, battlefield/range eligibility and the rule against embarking after being set up this turn.
- Army-preparation embark choices remove passenger models from the battlefield. Deployment omits embarked squads.
- Movement-phase embark choices require the passenger unit to have made a Normal, Advance or Fall Back move; every model must be within 3 inches and the transport must have room.
- Rapid/Tactical/Combat/Assault/Shock placement windows validate their source distances, board bounds, base overlap and unit coherency. Stationary transports require Tactical mode when a legal formation can be placed; otherwise Combat is mandatory. Combat uses 6 inches, allows engagement only with enemy units already engaged with the transport, and leaves the passengers Battle-shocked and unable to charge. Assault Ramp permits Assault Disembark after a Normal move; Impulsor Shock Disembark is available after Advance and blocks charging.
- Combat Disembark and Emergency Disembark make Hazard rolls before placement. The passenger owner allocates failed-roll mortal wounds through the local prevention rules; the placement window opens after allocation finishes. Rapid, Tactical, Assault and Shock Disembark do not make these Hazard rolls.
- When a destroyed transport has passengers, its emergency sequence now runs before Deadly Demise resolves: one Hazard D6 per passenger model, owner-allocated mortal wounds with applicable prevention, active-player placement within 6 inches in coherency and as close as possible. Models must be unengaged when possible; if no unengaged placement exists they may be set up engaged, and are destroyed only if no placement exists. Survivors become Battle-shocked and cannot charge this turn. The transport leaves the battlefield after all passenger units finish; the shared destruction queue then resumes.
- Rhino Veiling Smoke is wired into the local Smokescreen rule: the Rhino can use it once per phase for 0CP without blocking a separate unit's use, while the Rhino itself remains limited to one use that phase.
- Emergency placement uses the game's circular base proxies and samples legal positions in 0.1-inch radial steps / 5-degree angles to enforce “as close as possible”. This is the project's board-geometry approximation, not exact imported miniature geometry.
- Tactical availability samples 0.1-inch radial steps / 5-degree angles and searches coherent formations with a bounded budget; when that search is inconclusive it keeps Tactical mandatory. These checks use circular base proxies and are not exact imported miniature geometry.
- The shared 3-inch set-up distance, passenger eligibility, capacity, placement and Rapid/Tactical/Combat/Assault/Shock state transitions have targeted local Godot checks.
- An end-to-end local destruction test covers passenger Hazard, allocation, Emergency Disembark placement and resuming the destruction queue.
- A local Rhino test covers Veiling Smoke's free use, per-Rhino limit, separate unit use and overlapping Smokescreen sources.
- Drop Pod Assault automatically places each Drop Pod in Strategic Reserves during preparation, applies the half-army reserve cap, and offers its own ingress in the owner's first Movement phase. Arrival begins compulsory passenger Rapid Disembark; each passenger must be set up more than 8 inches from every enemy. This Rapid Disembark does not make Hazard rolls. Passenger units resolve in sequence, and Deployment Complete blocks later embarkation. The focused Drop Pod suite covers current-catalog admission for both players, the source profile and point tiers, reserve placement, ingress, passenger sequencing, saved continuation and phase-close identity. The optional Gauntlet Task Force Aggressive Disembarkation interaction is present in the choice path but still needs focused checks for CP, pass, multi-passenger continuation and save/restore. See [the Drop Pod audit](marine-drop-pod.md).
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

Wardens of Ultramar was added after the transport increment; see [its profile and local checks](space-marines-profile-records.md#marine-wardens-ultramar). All 85 shared-book Marine identities are selectable. Fifteen Dark Angels App profiles have separate source-linked runtime records and passed their declared source-bounded local scopes. The records include Ravenwing Darkshroud with its explicit Large Flying Base geometry limitation, followed by Azrael, Belial, Deathwing Knights, Deathwing Terminator Squad, Ezekiel, Sammael, Ravenwing Command Squad, Nephilim Jetfighter and Ravenwing Dark Talon.

---

<a id="marine-vanguard-veterans-jump-packs"></a>
## Vanguard Veteran Squad With Jump Packs

The source-bounded local scope is closed against verified snapshot `20261021T130623Z`. It supports five- and ten-model configurations, correct first-two and third-plus prices, all four source option rows, Plasma Pistol limits and modes, bearer-specific Combat Shields, all six ranged/melee profile routes, Vanguard Assault, Deep Strike reserve assignment, its Jump Pack Captain Leader link and conditional Dark Angels `DEATHWING` context. The profile now uses the existing catalog's third-plus copy-cost tier and supports up to three copies.

See the [Vanguard Veteran Squad With Jump Packs scope audit](marine-vanguard-veterans-jump-packs.md) for the verified export identity, hashes, complete test scope, exact command, artifact and limitations. Its dedicated offline run passed 3/3 processes with no network access or legacy starter data staged. This result does not certify full faction/army legality, every reserve ingress path, network behavior or full-match rules.

---

<a id="marine-victrix-honour-guard"></a>
## Victrix Honour Guard

`marine-victrix-honour-guard.md`

This profile uses the local Wahapedia 11th-edition export as its rules source. Datasheet 000004185 in shared book 000000139 has 3/6-model configurations at 120/250 points, with a 15-point Banner of Macragge equipped by the Chapter Ancient. Runtime construction exposes every legal combination of 0–1 Ancient, 0–1 Champion and 1–6 Guards at those sizes; it adds 15 points only when the Ancient is included. Third-plus costs are 150/280 without the Ancient and 165/295 with it. The current [sheet audit](marine-victrix-honour-guard.md) records the focused scope and evidence.

## Profile and rules

- M6, T5, Sv2+, W3, Ld6+, OC2 on 40 mm bases.
- Each 3/6-model configuration follows the source limits: 0–1 Ancient, 0–1 Champion, and at least one Guard. All eight resulting role combinations are available in the Army Workshop.
- The Ancient has a Master-crafted Bolt Carbine and Master-crafted Power Weapon. The Champion has Blades of Honour (Twin-linked, Precision). Each ordinary Guard has a Master-crafted Bolt Carbine (Rapid Fire 1, Assault) and Master-crafted Power Weapon.
- **Glory of Ultramar:** after an enemy unit shoots in the opponent’s Shooting phase, a casualty caused by those attacks opens an optional D6-inch Surge move. Placement checks distance, terrain path, base overlap and coherency.
- **Honour Guard of Macragge:** attacks targeting the unit receive -1 to wound.
- **Banner of Macragge:** at end of the owner’s Movement phase, the Ancient secures an objective controlled by the unit. Once per battle per army, when selected to fight, the unit may add 1 Attack and 1 Strength to its melee attacks.
- **Leader:** Cato Sicarius can attach to this exact bodyguard unit. Other bodyguard targets remain rejected. Captain of the Honour Guard is implemented conditionally: when Marneus Calgar is in the army, Cato becomes Support while retaining Victrix as his exact target.
- **Combat Doctrines** use the shared current runtime implementation.

## Local checks and limits

`tests/test_victrix_honour_guard.gd` checks all eight role compositions, model-specific loadouts and keywords, 3/6 and third-plus prices, optional Banner cost, current-catalog admission/materialization, ability registration, the exact Cato attachment, Glory of Ultramar continuation and movement, Banner timing and its once-per-army fight effect. The Army Workshop suite also checks the Bannerless role selection. See the [source-bounded sheet audit](marine-victrix-honour-guard.md). Network validation remains deferred to final integration; full faction and army legality are not certified.

---

<a id="marine-vulkan-hestan"></a>
## Vulkan He’stan

[Source-bounded audit](marine-vulkan-hestan.md) · [machine-readable provenance](marine-vulkan-hestan-audit.json)

Vulkan is a 105-point, one-model, 40 mm shared-book datasheet with no equipment-option rows. The three fixed weapons match the pinned export and pass through Equipment/AttackPlan. His source Feel No Pain 6+ is always active; Seeker of the Unfound changes it to 4+ while Vulkan is within range of his selected objective, alongside OC 10 and Leadership 5+. Forgefather selects one visible enemy within 24 inches once in the Shooting phase; friendly Adeptus Astartes Melta and Torrent attacks against it gain +2 Strength until that phase ends. Five common-book Leader targets are covered through the 153-link relation regression; the Legends Vanguard Veteran target is outside this scope.

The 27 October local run passed all five processes, including current-catalog materialization on both sides, weapon plans, deployment-choice ownership/save-restore, FNP resolution, target visibility/range and the Forgefather effect. The fixed-data comparator reports no per-profile differences but is not globally certified. See the [verification record](verification/verification-results.md). Full Salamanders/army legality and network validation remain open.
---

<a id="marine-wardens-ultramar"></a>
## Wardens of Ultramar

`marine-wardens-ultramar.md`

Implemented from the pinned local [Wahapedia e11 Space Marines export](https://wahapedia.ru/wh40k11ed/factions/space-marines/Wardens-of-Ultramar-1), shared book `000000139`, datasheet `000004188`, export timestamp `2026-10-16T21:03:46+03:00`. The six-model composition costs 115 points and uses individual bases: four 28.5 mm and two 40 mm. Construction admits one copy.

The profile preserves every model's characteristics, keywords, base size and fixed weapons. Dainal alone has PSYKER; Gaius Silva has a 5+ invulnerable save; Veteran Sergeant Metaurus has a 4+ invulnerable save. The source spells Dainal's surname **Kornelius** in composition/loadout and **Komelius** in the characteristics table; the implementation preserves this discrepancy.

Implemented rules are **Support**, **Combat Doctrines**, **Raise the Banner** and **Strategium Command**. The four common-book Support targets are Assault Intercessor Squad, Bladeguard Veteran Squad, Intercessor Squad and Sternguard Veteran Squad. The separate Vanguard Veteran Squad target on Wahapedia is Legends and is excluded from the shared-book 85. Strategium Command resolves after both armies deploy and before Scouts; it selects up to three deployed friendly Adeptus Astartes units for normal redeployment or Strategic Reserves without the usual points cap.

The focused offline scope passed 3/3 processes at `.tools/verification/20261028T003202038856Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). The dedicated audit checks the fixed profile and every weapon plan, both-player current catalogs, four Support links, Raise the Banner timing, and Strategium ownership, placement, reserve exception and three-unit limit. See [the detailed scope report](marine-wardens-ultramar.md) and [source/evidence audit](marine-wardens-ultramar-audit.json).

Network validation is deferred to final integration. This closure does not certify complete Space Marine faction coverage, full army legality, complete-match behavior or human playtesting.


---

<a id="marine-land-speeder-vengeance"></a>
## Land Speeder Vengeance (Dark Angels App)

Implemented from the verified local Wahapedia 11e Data Export, snapshot `20261021T130623Z` (retrieved 21 October 2026, export revision `20260817b`; source update `2026-10-21T16:06:23+03:00`). The source is the Dark Angels App datasheet `000000242`, book `000000023`, and is separate from the 85 shared-book Space Marine identities. The [source ledger](space-marines-rules-ledger.json) records the filenames and SHA-256 hashes used.

## Profile and loadout

- One model, up to three copies; 150 points for the first and second copy, 160 points for the third. M14, T9, Sv3+, 5+ invulnerable save, W11, Ld6+, OC3; 60 mm flying base.
- Fixed equipment: Armoured Hull, Heavy Bolter and Plasma Storm Battery. Before deployment, the Heavy Bolter can be replaced with an Assault Cannon. The Plasma Storm Battery exposes Standard and Supercharge profiles, with Hazardous on Supercharge.
- The profile carries ADEPTUS ASTARTES and DARK ANGELS faction keywords, plus SPEEDER, FRAME, FLY and RAVENWING keywords. Deep Strike, Deadly Demise D3 and Combat Doctrines use their shared runtime paths.

## Storm of Vengeance

Once per turn per unit in the opponent's Shooting phase, after an enemy shooting activation destroys a friendly Dark Angels unit within 6 inches of this model, the Vengeance may shoot normally but can target only the enemy unit that made that activation. Eligible Vengeance units are offered one at a time. Its reactive attack and saved Shooting-reaction frame stay bound to the triggering enemy unit.

The fixed profile, loadout choice, Storm of Vengeance reaction and Nightforged Battery choices for random weapon Attack and Hazard rolls are implemented. Its source-bounded local scope passed on 28 October 2026 and it is admitted to the current catalog; human playtesting, network validation and full Dark Angels army legality remain open.

---

<a id="marine-ravenwing-darkshroud"></a>
## Ravenwing Darkshroud (Dark Angels App)

Implemented from the verified local Wahapedia 11e Data Export, snapshot `20261021T130623Z` (retrieved 21 October 2026, export revision `20260817b`; source update `2026-10-21T16:06:23+03:00`). The Dark Angels App sheet is `000000238` in book `000000023`, separate from the 85 shared-book identities. The current Space Marines page lists App revision 2.8.1 (October 2026). See the [source-bounded local scope](marine-ravenwing-darkshroud.md) and [machine-readable audit](marine-ravenwing-darkshroud-audit.json).

The one-model, 80-point profile records M14, T8, Sv3+, 5+ invulnerable, W10, Ld6+ and OC3, with all source keywords. It carries a Heavy Bolter and Armoured Hull; before deployment, the Heavy Bolter may be replaced by an Assault Cannon. The export identifies a Large Flying Base but does not give dimensions, so the local 60 mm circular geometry remains explicitly provisional.

The local profile registers Deep Strike, Deadly Demise D3 and Combat Doctrines on their shared rule paths, adds the source 15-inch Lone Operative target boundary, and resolves Icon of Old Caliban as a 6-inch Stealth aura for friendly Dark Angels units. The public loadout choice is reversible and owner-checked, and both ranged weapon profiles select legal targets through AttackPlan. Its focused offline check passed 3/3 processes at `.tools/verification/20261028T102401179066Z/results.json`; the sheet-specific suite does not exercise Deep Strike ingress, the Deadly Demise trigger or Combat Doctrine effects. Chapter detachment interactions, full army legality, network validation and human playtesting remain outside this datasheet scope.

---

<a id="marine-azrael"></a>
## Azrael (Dark Angels App)

Implemented from the verified local Wahapedia 11e Data Export, snapshot `20261021T130623Z` (retrieved 21 October 2026, export revision `20260817b`; source update `2026-10-21T16:06:23+03:00`). The Dark Angels App datasheet is `000000218` in book `000000023`, separate from the 85 shared-book identities. The current page was checked against App revision 2.8.1 (October 2026). See the [source-bounded local scope](marine-azrael.md) and [machine-readable audit](marine-azrael-audit.json).

The one-model, 150-point profile records M6, T5, Sv2+, 4+ invulnerable, W6, Ld6+, OC1 and a 50 mm base. Lion’s Wrath and the Sword of Secrets use the source profiles, including their weapon traits. The Deathwing keyword is preserved in Dark Angels Chapter context. Azrael can lead all eight source-listed units: Assault Intercessors, Bladeguard Veterans, Company Heroes, Hellblasters, Infernus Marines, Intercessors, Sternguard Veterans and Inner Circle Companions.

Masterful Tactician lets the player choose a visible friendly Adeptus Astartes unit within 9 inches during the Movement phase and give it one Combat Doctrine until the start of the player’s next Command phase. Supreme Grand Master grants Sustained Hits 1 to Azrael’s attached unit. Watcher in the Dark is an optional once-per-battle defense: when the unit suffers mortal wounds, its models gain Feel No Pain 4+ against those mortal wounds. Focused offline verification passed 3/3 processes; capability and shared Leader-link checks passed 4/4 at `.tools/verification/20261028T103807866500Z/results.json`. Network validation, human playtesting and full Dark Angels/army legality remain outside this scope.

---

<a id="marine-belial"></a>
## Belial (Dark Angels App)

Implemented from the verified local Wahapedia 11th-edition Data Export, snapshot `20261021T130623Z` (retrieved 21 October 2026, export revision `20260817b`; source update `2026-10-21T16:06:23+03:00`). Belial is datasheet `000000219` in the Dark Angels App book `000000023`. The current page was checked against Dark Angels App revision 2.8.1 (October 2026). See the [source-bounded local scope](marine-belial.md) and [machine-readable audit](marine-belial-audit.json).

The one-model, 100-point profile records M5, T6, Sv2+, 4+ invulnerable, W6, Ld6+, OC1 and a 50 mm base. Fixed equipment is Master-crafted Storm Bolter (24", A2, BS2+, S5, AP-1, D2, Precision) and The Sword of Silence (A6, WS2+, S6, AP-3, D2). The source keywords, including TERMINATOR and DEATHWING, are preserved in Dark Angels context.

Belial can lead Terminator Assault Squad, Terminator Squad, Deathwing Knights or Deathwing Terminator Squad; all four profiles are now selectable. Grand Master of the Deathwing grants the attached unit +1 to Wound against enemy CHARACTER units, including bodyguard attacks. Strikes of Retribution rolls a D6 when Belial is destroyed in the Fight phase before his unit has fought; on 2+, he remains until his unit fights or the phase ends. Leader, Deep Strike, Combat Doctrines and Transhuman Strategist use the existing shared paths.

The combined focused check passed 7/7 processes at `.tools/verification/20261028T113916146828Z/results.json`, including Belial's attachment targets, Deathwing Terminator Squad and the merged Leader/Support links. Capability and Azrael regressions passed 4/4 processes at `.tools/verification/20261028T113948965947Z/results.json`. Full Dark Angels/army legality, remaining unavailable Chapter Leader endpoints, network validation and human playtesting remain outside this scope.

---

<a id="marine-deathwing-knights"></a>
## Deathwing Knights (Dark Angels App)

Implemented from the verified local Wahapedia 11th-edition Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, specification revision `20260817b`; source row timestamp `2026-10-21 16:06:23 GMT+3`. Deathwing Knights is datasheet `000000231` in Dark Angels App book `000000023`. The current page was checked on 28 October 2026 against App revision 2.8.1 (October 2026). See the [sheet audit](marine-deathwing-knights.md) and [machine audit](marine-deathwing-knights-audit.json).

The fixed five-model profile costs 255 points for the first two units and 275 for the third-plus tier. It records M5, T6, Sv2+, 4+ invulnerable, W4, Ld6+, OC1 and 40 mm bases. The Knight Master starts with the Great Weapon of the Unforgiven; the four other models start with Maces of Absolution. The Knight Master may select a Relic Weapon, and each other Knight may select a Power Weapon.

Deep Strike and Combat Doctrines use the shared paths. Inner Circle reduces attack Damage by 1 to a minimum of 1 and blocks Tactical Dreadnought Fortitude; the modifier does not reduce mortal wounds. Teleport Homer uses the shared start-of-battle token and zero-CP Rapid Ingress flow, including when the unit begins in Reserves. Watcher in the Dark is optional and provides once-per-battle Feel No Pain 4+ against mortal wounds after the response is selected. The four source Leader links and the Ancient in Terminator Armour Support link are represented.

Focused offline verification passed 7/7 processes at `.tools/verification/20261028T113916146828Z/results.json`; it includes the Belial, Deathwing Terminator Squad, common Leader/Support and shared Terminator regressions. Capability and Azrael regressions passed 4/4 processes at `.tools/verification/20261028T113948965947Z/results.json`. Full Dark Angels/Space Marines army legality, network validation and human playtesting remain outside this scope.

---

<a id="marine-deathwing-terminator-squad"></a>
## Deathwing Terminator Squad (Dark Angels App)

Implemented from the verified local Wahapedia 11e Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, specification revision `20260817b`; source row timestamp `2026-10-21 16:06:23 GMT+3`. Deathwing Terminator Squad is datasheet `000000230` in Dark Angels App book `000000023`. The current page was checked on 28 October 2026 against App revision 2.8.1 (October 2026). See the [source-bounded local scope](marine-deathwing-terminator-squad.md) and [machine-readable audit](marine-deathwing-terminator-squad-audit.json).

The five- or ten-model profile costs 190/380 points for the first two units and 230/420 for the third and later unit. Every model has M5, T6, Sv2+, W3, Ld6+, OC1, 4+ invulnerable and a 40 mm base, with a Power Fist and Storm Bolter by default. The Sergeant can replace its Power Fist with a Chainfist or Power Weapon; any regular model can take a Chainfist. One regular model per five can replace its Storm Bolter with an Assault Cannon, Heavy Flamer or Plasma Cannon, including Hazardous supercharge. A Cyclone Missile Launcher keeps the Storm Bolter and adds 10 points.

Deep Strike and Combat Doctrines use the shared paths. Deathwing ignores modifiers to BS/WS and Hit rolls in AttackPlan, including attacks by attached models; it leaves separate Wound modifiers such as Belial's CHARACTER bonus intact. The optional Watcher in the Dark can be selected during preparation and used once per battle after a mortal wound is allocated to a unit model for Feel No Pain 4+ against mortal wounds until phase end. Belial, Captain/Chaplain/Librarian in Terminator Armour, and Ancient in Terminator Armour are represented as its four Leader and one Support attachment links.

Focused local checks cover both formations, costs, all listed weapon profiles and options, Deathwing and Watcher behavior, and public Leader/Support attachment. Full Dark Angels/Space Marines army legality and network validation remain open. The parent export's 68 errors outside the structurally valid sheet slice are not claimed as passed.

## Marine transport Deadly Demise — 26 October 2026

The shared destruction queue now resolves the source-linked Deadly Demise value for the eight locally admitted transport profiles: Land Raider, Land Raider Crusader and Land Raider Redeemer use D6; Drop Pod uses 1; Impulsor and Rhino use D3; Repulsor and Repulsor Executioner use D6. Passenger Emergency Disembark must finish before the transport's trigger roll. On a 6, every unit within 6 inches receives a separately rolled X mortal-wound packet when X is random; packets use the normal owner allocation and prevention flow, and chain destructions stay queued. Medusa's Wrath Vengeful Animus can force the trigger roll for eligible Astartes Vehicles.

The resolved `Datasheets.csv` identities are Land Raider `000000065`, Land Raider Crusader `000000066`, Land Raider Redeemer `000002173`, Drop Pod `000000087`, Impulsor `000002568`, Rhino `000002723`, Repulsor `000002721`, and Repulsor Executioner `000002722`. Their relations point to the shared `Deadly Demise` ability `000008339` in `Abilities.csv` through `Datasheets_abilities.csv`.

Source facts come from the verified Wahapedia 11e Space Marines Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`: `Datasheets.csv` SHA-256 `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`, `Abilities.csv` SHA-256 `4922f4c86c5b3ad31d5651feb4b395255a14912ec361e2296f80364a9a731410`, and `Datasheets_abilities.csv` SHA-256 `49b054afc2f9977b9c8168ee446b016bd097b047adbd7ec35d23df5f054d7fe6`. Core Rules §24.08 was checked against Wahapedia's June 2026 Core Rules page on 26 October 2026. This profile addition has not had focused local checks or playtesting; it does not certify all transport rules or full army legality.

---

<a id="marine-ezekiel"></a>
## Ezekiel (Dark Angels App)

Implemented from the verified local Wahapedia 11e Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, specification revision `20260817b`; source row timestamp `2026-10-21 16:06:23 GMT+3`. Ezekiel is datasheet `000000226` in Dark Angels App book `000000023`. The current page was checked on 28 October 2026 against App revision 2.8.1 (October 2026). See the [sheet audit](marine-ezekiel.md) and [machine audit](marine-ezekiel-audit.json).

The fixed one-model profile costs 110 points and has a 25 mm base, M6, T5, Sv2+, W5, Ld6+, OC1, 4+ invulnerable save and PSYKER Level 3. Mind Wipe has Focused Witchfire and Witchfire profiles; he also carries The Deliverer and Traitor’s Bane. Book of Salvation adds one melee Attack to the unit. Psychic Hood provides Feel No Pain 4+ against Psychic attacks and mortal wounds. Engulfing Fear can force an enemy within 12 inches of Ezekiel to take a Battle-shock roll at -1 in the owner’s Shooting phase; on a Psychic roll of 1, his unit also becomes Battle-shocked. Whispers of the Shadow Forest reacts when an enemy targets his unit, with a -1 Hit effect through the phase after a successful Psychic roll and Battle-shock on a roll of 1. Core Rules §22.03.01 prevents using the same Psychic ability more than once per phase.

Ezekiel’s seven Leader links—Assault Intercessors, Bladeguard Veterans, Hellblasters, Infernus Marines, Intercessors, Sternguard Veterans and Inner Circle Companions—are represented. The focused current-catalog regression passed 4/4 processes at `.tools/verification/20261028T120027007826Z/results.json`; related Phobos Librarian, capability and Leader-link regressions passed 6/6 at `.tools/verification/20261028T120048353698Z/results.json`. This closes the Inner Circle Companions Leader endpoint. Full Dark Angels/Space Marines army legality, network validation and human playtesting remain outside this scope.

<a id="marine-sammael-ravenwing-command-squad"></a>
## Sammael and Ravenwing Command Squad (Dark Angels App)

Implemented from the verified local Wahapedia 11e Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, specification revision `20260817b`; source row timestamp `2026-10-21 16:06:23 GMT+3`. Sammael (`000002291`) and Ravenwing Command Squad (`000002748`) are in Dark Angels App book `000000023`. The current pages were checked on 28 October 2026 against App revision 2.8.1 (October 2026). See the [Sammael audit](marine-sammael.md), [Sammael machine audit](marine-sammael-audit.json), [Ravenwing Command Squad audit](marine-ravenwing-command-squad.md) and [Ravenwing Command Squad machine audit](marine-ravenwing-command-squad-audit.json).

Sammael is a one-model, 120-point Epic Hero with a 60 mm flying base, M12, T6, Sv3+, W7, Ld6+, OC2 and 4+ invulnerable save. His three ranged profiles and The Raven Sword are source-linked. He can lead Outriders or Ravenwing Black Knights. The bounded rules scope includes Transhuman Strategist/Warlord CP, Cut Off Their Escape's forced Desperate Escape and Battle-shock hazard modifier, and Grand Master of the Ravenwing's selected Combat Doctrine through the start of his next Command phase.

Ravenwing Command Squad is three role-specific models at 115 points for the first/second copy and 135 points from the third copy; the 75 × 42 mm oval is a labelled 37.5 mm bounding-circle collision proxy. The Ancient, Apothecary and Champion use their source weapons and role-gated abilities. The optional Grenade Launcher replaces one Plasma Talon per three models. The squad can join Outriders or Ravenwing Black Knights as Support. Attachment now transfers all three models, retains role and defense state, and preserves each component's original starting strength for per-three-model equipment caps. The Ancient's banner adds OC while alive; the Champion adds 1 to Advance and Charge and discounts Heroic Intervention; the Apothecary's Narthecium heals D3+1 through the shared healing flow.

Focused offline verification passed 9/9 processes at `.tools/verification/20261028T123024695254Z/results.json` (SHA-256 `4F9C777FDCA0F947637893E529B1331A6605B0C4660871200B2CAE6745ACBD0A`; `network: false`, no legacy starter staged, no cleanup diagnostics). It includes both dedicated datasheet tests, Ravenwing Black Knights' Grenade Launcher cap, six-model Wardens Support transfer, shared Leader/Support links, Ancient and Apothecary regressions, import and Python checks. These local scopes do not establish full Dark Angels/Space Marines army legality, network behavior, complete-match behavior or human playtesting. Forge World, Legends, Boarding Actions and other alternate modes remain outside scope.

---

<a id="marine-nephilim-jetfighter-ravenwing-dark-talon"></a>
## Nephilim Jetfighter and Ravenwing Dark Talon (Dark Angels App)

Implemented from the verified local Wahapedia 11e Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, export revision `20260817b`; source row timestamp `2026-10-21 16:06:23 GMT+3`. Nephilim Jetfighter (`000000239`) and Ravenwing Dark Talon (`000000240`) are Dark Angels App datasheets in book `000000023`. The current pages were checked on 28 October 2026 against App revision 2.8.1. See the [Nephilim sheet audit](marine-nephilim-jetfighter.md), [Nephilim machine audit](marine-nephilim-jetfighter-audit.json), [Dark Talon sheet audit](marine-ravenwing-dark-talon.md) and [Dark Talon machine audit](marine-ravenwing-dark-talon-audit.json).

Both are one-model Aircraft with T8, Sv3+, 5+ invulnerable save, W11, Ld6+, OC0 and 120 × 92 mm source ovals represented by labelled 60 mm bounding-circle proxies. The Nephilim costs 200 points and can exchange its Twin Heavy Bolter for Nephilim Lascannons; the Dark Talon costs 190 points and keeps separately addressable Hurricane Bolters. Their fixed weapon profiles, keywords, Damaged 3 and Deadly Demise D3 parameter are source-linked. The Nephilim's Lightning-fast Manoeuvres subtracts 1 from ranged Wound rolls regardless of Strength and does not affect melee.

The shared Aircraft path handles mandatory Strategic Reserves placement, the Aircraft's own Movement-phase ingress and end-of-opponent-turn return, the first-ingress reserve cutoff, Rapid Ingress exclusion, passage through Aircraft bases, the Aircraft Charge/melee restrictions and the engagement-only movement exception. The focused pair also checks non-FLY contact/Surge target filtering. The Dark Talon's Stasis Bomb offers its end-of-opponent-Fight target choice, filters AIRCRAFT and Lone Operative, resolves both roll branches and expiry, and on the tested low branch suspends mortal-wound allocation before resuming the selected Normal Move.

Focused offline verification passed 4/4 processes at `.tools/verification/20261028T130615559370Z/results.json` (SHA-256 `08537FEBF4151D7AB8F7E91638DEEB1DB8E7E05928375BB5F6819A2E761771B2`; `network: false`, no legacy starter staged, no cleanup diagnostics). Aircraft-specific Deadly Demise triggering, doctrine effects, Plunging Fire targeting, exact oval-base geometry, network validation, full army legality and human playtesting remain outside this increment.

---

<a id="marine-lion-eljonson"></a>
## Lion El’jonson (Dark Angels App)

Lion is the 415-point, one-copy Dark Angels Epic Hero from datasheet `000002682` in App book `000000023`. Its 13 source ability records, fixed profile, weapons, Warlord restriction and bounded local effects are source-audited in [the sheet audit](marine-lion-eljonson.md) and [machine-readable record](marine-lion-eljonson-audit.json). Focused offline verification passed 3/3 processes, including the reserve-cap check for Mist-wreathed Shadow Realms. This completed all 16 Dark Angels datasheet scopes locally; it does not certify full army legality or network behavior.

<a id="marine-emperors-champion"></a>
## Emperor’s Champion (Black Templars App)

Emperor’s Champion is the 100-point, one-copy Black Templars Epic Hero from datasheet `000002795` in App book `000000162`. Its fixed profile, weapons, six ability records, source Leader targets, local admission and bounded rules checks are documented in [the sheet audit](marine-emperors-champion.md) and [machine-readable record](marine-emperors-champion-audit.json). Focused offline verification passed 5/5 processes. Sword Brethren is now a source-listed, admitted Leader target at the export-priced 4/5/9/10-model sizes; the source-unpriced 6–8 sizes remain blocked. Crusader Squad remains partial.
