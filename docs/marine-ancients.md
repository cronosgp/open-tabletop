# Ancient and Bladeguard Ancient — current e11 implementation

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
