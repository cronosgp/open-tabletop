# Necrons datasheet coverage

## Source of truth

Current Necrons datasheet facts for this project come from the local Wahapedia 11e Data Export. The export was retrieved at `2026-10-31T05:33:36Z`; its metadata says it was updated at `2026-10-30T22:19:16+03:00`. The selected source is the Necrons App, book ID `000000029`, version `1.2`. Wahapedia is used only to resolve ambiguities outside the local datasheet extraction. For the Necrodermis interaction, [Core Rules 05.03–05.04 and 24.10](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) were checked because the local datasheet export does not include the Core Rules sequence; this resolves whether the Damage reduction applies to allocated attacks or separate mortal wounds. For Transdimensional Displacement, Core Rules 09.06 and 21.03 were checked to resolve the normal Advance D6 and its interaction with the FLY Take to the Skies declaration. The C’tan datasheet facts below remain sourced from the local export.

Snapshot directory: `.tools/wahapedia/11e/necrons/20261031T053336Z`. Parent manifest SHA-256: `e292e43a4dc90ed529c60ac988d7f3351ae287a6bdfa8b85e9c818806b9020ef`. The focused Necrons slice has 51 datasheets and zero subject-scoped structural findings. Slice manifest SHA-256: `651601ce1262894f1fb5f20429daab8e88e0eab6fd8260b5b40041dc9dfbaae4`. Derived slice catalog SHA-256: `cee4e1ebfb73eda7c9596be33c4fed12fc421ed15f02932e11a948758078283f`. The parent export still reports 68 global findings; those are not findings in this Necrons slice.

The runtime record keeps these identifiers and hashes in [current_reference_necron_profiles.gd](../../scripts/edition_11/current_reference_necron_profiles.gd). The raw export and derived slice remain in the ignored `.tools/` tree and are not shipped with the game.

| Export file | SHA-256 |
|---|---|
| `Factions.csv` | `d5038518059e5deeafa8d74e814a51598929a45c2864d3056c92c8629e7d4608` |
| `Source.csv` | `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9` |
| `Datasheets.csv` | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| `Datasheets_abilities.csv` | `49b054afc2f9977b9c8168ee446b016bd097b047adbd7ec35d23df5f054d7fe6` |
| `Datasheets_keywords.csv` | `bdb2431dd3a24d34ec91e1aa1e7ddae9da3565faa18a56abcd8ead5247b4e341` |
| `Datasheets_models.csv` | `9cb303097f003f2eaa3bfc7cba8d3d7579b0364a35a139bafa5c0705bbd68d03` |
| `Datasheets_options.csv` | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| `Datasheets_wargear.csv` | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |
| `Datasheets_unit_composition.csv` | `c17b923ce78ac0f2a78d04efc06ad89c3394d854de9c4d00173e91fcef8d8e8f` |
| `Datasheets_models_cost.csv` | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| `Datasheets_leader.csv` | `ba3d15232183fa402d4fbd6feadd491f245236abccee52dbcaca9e216c04a9b6` |
| `Datasheets_stratagems.csv` | `cc9929a1a551dc1c608e84ea481285ece82296b9227815edb89404fcc2152cc7` |
| `Datasheets_enhancements.csv` | `97cd4bf6aac2064a7555dd04a067095e106ff263d57bf13b9d8e79fbe903158f` |
| `Datasheets_detachment_abilities.csv` | `c0011f8310f137969e0943059638587efb1b1821d78717340c831c05c80f87dc` |

## Current progress

| Scope | Status |
|---|---|
| Source identities | 51/51 matched by datasheet ID and name to the local slice; all have runtime admission metadata. |
| Current profile facts | 51/51 transcribed into runtime source profile records. The nineteen newly added records retain source model roles, costs, weapons and traits, loadouts, options, ability bindings, attachment links, rule links and snapshot hashes. |
| Focused local fact checks | The source-profile checks cover all 51 matched IDs and preserve pending gates except for the nine completed local scopes. Dedicated checks cover the Canoptek Reanimator, Royal Warden, Necron Warriors, Immortals, Deathmarks, Flayed Ones, Canoptek Scarab Swarms, Hexmark Destroyer and Canoptek Doomstalker rules, equipment, priced configurations and relevant shared regressions. |
| Current construction choices | 9/51 datasheets. Canoptek Reanimator (1 model/75 points), Royal Warden (1/50), Necron Warriors (10/85, 20/190), Immortals (5/65, 10/130), Deathmarks (5/60, 10/120; third-plus 5/70, 10/130), Flayed Ones (5/55, 10/100), Canoptek Scarab Swarms (3/40, 6/80), Hexmark Destroyer (1/75) and Canoptek Doomstalker (1/130) are admitted from the local profiles; the other 42 remain gated. |
| Complete datasheet scopes | 9/51. Canoptek Reanimator, Royal Warden, Necron Warriors, Immortals, Deathmarks, Flayed Ones, Canoptek Scarab Swarms, Hexmark Destroyer and Canoptek Doomstalker have source-bounded rules, equipment, configuration and focused local checks complete. Full roster legality remains a separate gate. |
| Full roster legality and certification | 0/51. These require separate gates and are not implied by the local fact checks. |

Thirty-two records had prior focused profile work:

**Shared C’tan rules increment:** Necrodermis now reduces the Damage characteristic of an allocated attack by 1, to a minimum of 1, for the Deceiver, Nightbringer, Void Dragon and Transcendent C’tan. Their source-listed **ENSLAVED STAR GOD** ability prevents Warlord selection through the choice and roster checks. The Transcendent C’tan’s local **C’TAN SHARD** text also forbids Enhancements, and forged assignments are rejected during mixed army admission. Its **Transdimensional Displacement** is selectable as an Advance, rolls the normal Advance D6, bypasses all model bases without a distance cap, and requires the C’tan to finish more than 8 inches horizontally from every enemy unit. Terrain path validation remains active unless the FLYING C’tan also declares Take to the Skies, which permits terrain transit without restoring a distance cap; board edges, final base spacing and coherency remain enforced. Focused movement tests passed. The Deceiver’s source-listed Stealth ability uses the existing shared rule. Separate mortal wounds remain unaffected because Devastating Wounds ends the attack sequence before an attack is allocated in the Inflict Damage step. Focused local checks passed; each C’tan still has its other datasheet blockers.

| Datasheet | Local facts recorded | Remaining implementation blockers |
|---|---|---|
| Necron Warriors (`000000534`) | 10/20 models, 85/190 points, characteristics, Gauss flayer/Reaper profiles and any-number per-model replacement, Reanimation Protocols, Their Number is Legion and source Leader/Support links | None for this datasheet's source rules, weapons or priced sizes; full faction roster legality remains separate |
| Immortals (`000000535`) | 5/10 models, 65/130 points, characteristics, Gauss blaster and Tesla carbine profiles, any-number per-model replacement, Reanimation Protocols and Implacable Eradication | None for this sheet’s local rules, equipment or priced sizes; full Necron roster legality remains separate |
| Overlord (`000000523`) | 90 points, characteristics, default weapons, alternate weapon profiles, listed abilities and source bodyguard links | Linked weapon replacement and conditional Resurrection Orb loadout; focused profile checks |
| Royal Warden (`000002350`) | 1 model/50 points, characteristics, fixed weapons, Leader targets, Adaptive Strategy, Engrammatic Logic and Reanimation Protocols | None for this datasheet's local rules, weapons or construction size; full Necron roster legality remains separate |
| Orikan the Diviner (`000000530`) | 90 points, characteristics, Staff of Tomorrow and Support targets; Support uses the existing attachment path | Reanimation Protocols, Master Chronomancer and The Stars Are Right |
| Trazyn the Infinite (`000000532`) | 60 points, characteristics, Empathic Obliterator and Leader targets; Leader pairings use the shared attachment catalog | Reanimation Protocols, Ancient Collector, Surrogate Hosts and the weapon's Sustained Hits D3 trait |
| Lychguard (`000000536`) | 5/10 models, 80/160 points, characteristics, sword and warscythe profiles, incoming Leader links | Reanimation Protocols, shielded loadout, Dispersion Shield and Guardian Protocols |
| Deathmarks (`000000537`) | 5/10 models, 60/120 points, 70/130 third-plus prices, characteristics, synaptic disintegrator and close combat weapon, Deep Strike, Reanimation Protocols and Hyperspace Hunters | None for this sheet’s local rules, equipment or priced sizes; full Necron roster legality remains separate |
| Flayed Ones (`000000538`) | 5/10 models, 55/100 points, 28.5 mm bases, flayer claws, Infiltrators, Stealth, Reanimation Protocols and Flesh Hunger | None for this sheet’s local rules, equipment or priced sizes; full Necron roster legality remains separate |
| Triarch Praetorians (`000000539`) | 5/10 models, 80/160 points, Rod of covenant, particle-caster/voidblade alternatives and shared Deep Strike path | Reanimation allocation limits; Relentless Combatants; linked all-model weapon replacement |
| Skorpekh Destroyers (`000002110`) | 3/6 models, 85/170 first-two prices, 95/180 third-plus prices, 3-wound characteristics, melee weapon and incoming Skorpekh Lord link | Reanimation allocation limits; Plasmacyte count/loadout; Whirling Onslaught |
| Canoptek Scarab Swarms (`000002114`) | 3/6 models, 40/80 points, 40 mm bases, 4-wound characteristics, OC 0, Feeder mandibles, Reanimation Protocols, Self-destruction and Chittering Swarm | None for this sheet’s local rules, equipment or priced sizes; full Necron roster legality remains separate |
| Canoptek Wraiths (`000000546`) | 3/6 models, first/second and third-plus prices, 4+ invulnerable save, all weapon profiles and Leader-free options | Reanimation allocation limits; Wraith Form; two equipment selections |
| Canoptek Reanimator (`000002112`) | 1 model, 75 points, 6-wound characteristics, two Atomiser beams, Reanimator's claws, locally bound Feel No Pain 4+, Reanimation Protocols and Nanoscarab Reanimation Beam; focused ability and aura checks passed | None for this sheet's rules or equipment; full Necron roster legality remains separate |
| Ghost Ark (`000000543`) | 1 model, 100 points, 14 wounds, two Gauss flayer arrays, Armoured bulk, Deadly Demise D3 and transport capacity text | Repair Barge; passenger transport rules; full vehicle and casualty checks |
| Canoptek Doomstalker (`000002115`) | 1 model, 130 points, 90 mm base, 12 wounds, 4+ invulnerable save, Doomsday blaster, Twin gauss flayer, Doomstalker limbs, Deadly Demise D3, Reanimation Protocols, Sentinel Construct and Damaged 4 | None for this sheet’s local rules, equipment or priced size; full Necron roster legality remains separate |
| Doomsday Ark (`000000554`) | 1 model, 200/230 first-two/third-plus costs, 14 wounds, fixed weapons, Deadly Demise D3, Damaged 5 | Overwhelming Obliteration; focused damaged-threshold and Deadly Demise event checks |
| Monolith (`000000552`) | 1 model, 420/440 first/second-plus copy costs, 22 wounds, fixed/alternate weapon profiles, Deep Strike, Deadly Demise D6 | Eternity Gate; 1–7 wound OC and Hit penalties; four Death Ray replacement; Death Ray Sustained Hits D3 |
| Catacomb Command Barge (`000000533`) | 1 model, 120 points, 9 wounds, gauss cannon/staff profiles, Deadly Demise 1 and Reanimation Protocols | Carrier Wave; Advanced Quantum Shielding; Resurrection Orb choice; alternate Tesla cannon and Overlord’s blade loadouts |
| Triarch Stalker (`000000540`) | 1 model, 110/120 first-two/third-plus costs, 12 wounds, heat ray modes, Stalker’s forelimbs, Scouts 8, Deadly Demise D3 | Targeting Relay; Particle shredder/Heavy gauss cannon array replacement; source footprint says “Use model” and runtime uses a labelled 120 mm proxy |
| Hexmark Destroyer (`000002355`) | 1 model, 75 points, 50 mm base, 5 wounds, Enmitic disintegrator pistols, Deep Strike, Lone Operative, Reanimation Protocols, Inescapable Death and Multi-threat Eliminator | None for this sheet’s local rules, equipment or priced size; full Necron roster legality remains separate |
| Ophydian Destroyers (`000002358`) | 3/6 models, 80/150 first-two and 90/160 third-plus prices, 3 wounds, hyperphase weapons, Deep Strike and Reanimation Protocols | Plasmacyte count/loadout; Tunnelling Horrors |
| Lokhust Destroyers (`000002359`) | 1/2/3/6 price rows, third-plus prices, 3-wound characteristics, Gauss cannon and Lokhust Lord link | Reanimation allocation limits; Hard-wired for Destruction; unpriced 4/5-model sizes and missing third-plus 6-model price |
| Lokhust Heavy Destroyers (`000002116`) | 1/2/3 prices, third-plus prices, 4-wound characteristics, Gauss destructor and Lokhust Lord link | Reanimation allocation limits; Optimised for Slaughter; Enmitic exterminator replacement |
| Imotekh the Stormlord (`000000522`) | 1 model, 100 points, Epic Hero copy limit, weapon profiles and source Leader targets | Reanimation Protocols, Grand Strategist and Lord of the Storm |
| Illuminor Szeras (`000002092`) | 1 model, 175 points, 9 wounds, 80 mm base and weapon profiles | Feel No Pain 4+, Reanimation Protocols, Illuminor, Mechanical Augmentation and Atomic Energy Manipulator |
| Plasmancer (`000002108`) | 1 model, 60 points, 4 wounds, weapons and local attachment targets | Support semantics, Reanimation Protocols, Harbinger of Destruction and Living Lightning |
| Skorpekh Lord (`000002109`) | 1 model, 95/105 first/third-plus prices, 7 wounds, weapons and Skorpekh Destroyer Leader link | Reanimation Protocols, United in Destruction and Crimson Harvest |
| Lokhust Lord (`000002351`) | 1 model, 80 points, 6 wounds, Staff of light/Lord’s blade and Lokhust Leader targets | Reanimation Protocols, Orb/amulet effects, Destroyer Cult and Driven by Hatred; linked weapon/wargear choices |
| Technomancer (`000002352`) | 1 model, 80/90 first/second-plus prices, 10-inch movement, Staff of light and three Support targets | Reanimation Protocols, Rites of Reanimation and model repair |
| Psychomancer (`000002353`) | 1 model, 65 points, 4 wounds, Abyssal lance and two Support targets | Reanimation Protocols, Nightmare Shroud and Harbinger of Despair |
| Chronomancer (`000002354`) | 1 model, 70/80 first/second-plus prices, 4+ invulnerable save, Aeonstave and two Support targets | Reanimation Protocols, Timesplinter Mantle and Chronometron |

The nineteen profiles below now also have hash-linked local source records. Their rules and loadout scopes are still blocked:

| Datasheet | Local facts recorded | Remaining implementation blockers |
|---|---|---|
| Annihilation Barge (`000000553`) | 1 model, 100 points, 9 wounds, source loadout, all three ranged profiles, melee profile, Deadly Demise 1, Reanimation Protocols and one cannon replacement | Tesla cannon selection; Malevolent Arcing; full profile and event checks |
| C’tan Shard of the Deceiver (`000000542`) | 1 model, 330 points, 16 wounds, source loadout and weapons, Stealth, Necrodermis, ENSLAVED STAR GOD, Deep Strike, Deadly Demise and Feel No Pain | Grand Illusion; remaining weapon, character and roster checks |
| C’tan Shard of the Nightbringer (`000000541`) | 1 model, 360 points, 16 wounds, strike/sweep weapon profiles, Necrodermis, ENSLAVED STAR GOD, Deep Strike, Deadly Demise and Feel No Pain | Drain Life; remaining weapon, character and roster checks |
| C’tan Shard of the Void Dragon (`000002357`) | 1 model, 345 points, ranged and strike/sweep melee profiles, Necrodermis, ENSLAVED STAR GOD, Deep Strike, Deadly Demise and Feel No Pain | Matter Absorption; remaining weapon, character and roster checks |
| Canoptek Macrocytes (`000004176`) | 5 models, 70 points, 1-wound profile, source default weapons, all weapon profiles, abilities and three option rows | Per-model Tesla choice and two distinct specialist loadouts; Harassment Swarm, Accelerator Mandible and Nanoscarab Projector |
| Canoptek Spyders (`000000551`) | 1/2 models, 65/110 points, 6 wounds, source weapons, abilities and three equipment groups | Particle beamer counts, Fabricator Claw Array, Gloom Prism and Canoptek Swarm |
| Canoptek Tomb Crawlers (`000004177`) | 2 models, 60 points, 3 wounds, all weapons, abilities and source isolator replacement | Weapon Sentinels, Canoptek Retinue and the per-model replacement |
| Doom Scythe (`000000545`) | 1 model, 200 points, 12 wounds, all weapons, Deadly Demise D3 and Reanimation Protocols | Atavistic Instigation, Aircraft reserve/flight behavior and event checks |
| Convergence of Dominion (`000002361`) | 1/2/3 Starsteles, 60/120/180 points, 7 wounds, Transdimensional Abductor and source abilities | Reanimation Nodes, Ancient Cover, Fortification and deployment interactions |
| Cryptothralls (`000002111`) | 2 models, 60 points, 3 wounds, all weapon profiles and source abilities | Bound Creation, Systematic Vigour, Cryptek Retinue and attached-unit composition |
| Geomancer (`000004178`) | 1 model, 75 points, 4 wounds, both Tremorglaive weapon types, source Support links and abilities | Tectonic Reverberations, Obelisk Node Control, Vanguard Protocols and Support admission |
| Nekrosor Ammentar (`000004186`) | 1 model, 195 points, 9 wounds, all weapon profiles, default Nullstone Field Generator and source abilities | Protective Disciples, Infectious Murder-madness, Prophet of Destruction and Nullstone Field Generator |
| Night Scythe (`000000544`) | 1 model, 125 points, 12 wounds, all weapons, Deadly Demise D3, Deep Strike, Hover and transport text | Invasion Beams, Quantum Invader, passenger transport and Aircraft behavior |
| Obelisk (`000000557`) | 1 model, 280/310 first/second-plus points, 24 wounds, all weapons and abilities | Gravitic Pulse and copy-price admission |
| Overlord with translocation shroud (`000003693`) | 1 model, 90 points, 6 wounds, blade and source Orb loadout, all Leader targets and abilities | Resurrection Orb, My Will Be Done, Translocation Shroud and Leader admission |
| Tesseract Vault (`000000556`) | 1 model, 465/505 first/second-plus points, 24 wounds, all weapon profiles and source abilities | Four C’tan Powers, D6+3 Deadly Demise, their weapon trait and copy-price admission |
| The Silent King (`000002360`) | 3-model unit with separate Szarekh/Menhir characteristics and loadouts, 420 points, all weapons and source abilities | Mixed-model wound/weapon runtime, Szarekh-only Deadly Demise, Menhir loss, Triarch abilities and auras |
| Tomb Blades (`000000548`) | 3/6 models, 70/140 first-second and 80/150 later-copy costs, 2 wounds, default weapons, all source weapon profiles and three option groups | Weapon replacement, Shieldvanes, Nebuloscope/Shadowloom, Evasion Engrams and per-model loadout resolution |
| Transcendent C’tan (`000000555`) | 1 model, 340/360 first/later-copy points, 16 wounds, all weapon profiles, Necrodermis, ENSLAVED STAR GOD, C’TAN SHARD Enhancement restriction, Transdimensional Displacement, Deep Strike, Deadly Demise and Feel No Pain | copy-price admission and remaining roster checks |

On 31 October 2026, the local Chronomancer composition text (“Chronomancer’s stave”) and weapon row (“Aeonstave”) were both present, so the current [Necrons App v1.2 page](https://wahapedia.ru/wh40k11ed/factions/necrons/Chronomancer) was checked for that ambiguity. The page retains both labels; the runtime uses the Aeonstave weapon row and stores the composition label separately. Other datasheet facts remain anchored to the local export.

On 31 October 2026, the local Immortals wording for Implacable Eradication was checked because its objective-range clause does not say “failed” before Wound rolls. The [current Immortals page](https://wahapedia.ru/wh40k11ed/factions/necrons/Immortals) repeats the local wording, so it does not resolve the ambiguity. The [Core Rules re-roll section](https://wahapedia.ru/wh40k11ed/the-rules/) allows a die to be re-rolled without requiring that it failed. The runtime therefore interprets the objective-range clause as an optional re-roll choice for any Wound die, successful or failed. This is an interpretation of the local wording with the general re-roll rule; datasheet facts remain sourced to the local App export.

On 31 October 2026, Canoptek Doomstalker (`000002115`) was taken from the local datasheet rows. The one-model 130-point cost, characteristics, fixed Doomsday blaster, Twin gauss flayer and Doomstalker limbs, Deadly Demise D3, Reanimation Protocols, Sentinel Construct and Damaged 4 sentences are unambiguous, so no extra online page was required. Sentinel Construct changes Fire Overwatch hits to unmodified 5+. It does not change the 1CP cost or the normal once-per-phase limit. Snap shooting ignores Hit modifiers, so the Damaged 1–4 wound penalty does not change that Overwatch threshold. A normal attack at 1–4 wounds still subtracts 1 from the Hit roll. Deadly Demise uses the shared resolver: a 6 triggers D3 mortal wounds against units within 6 inches, and a lower roll does not.

On 31 October 2026, Hexmark Destroyer (`000002355`) was taken from the local datasheet rows. The one-model 75-point cost, characteristics, Enmitic disintegrator pistols, Deep Strike, Lone Operative, Reanimation Protocols, Inescapable Death and Multi-threat Eliminator sentences are unambiguous, so no extra online page was required. The local weapon description says Pistol; the runtime uses the existing close-quarters shooting keyword for that Core rule, together with Ignores Cover. Inescapable Death lets one unit with the ability use Fire Overwatch for 0CP once per turn, including after another unit has used that Stratagem in the same phase. That use still counts as Fire Overwatch for units without their own extra-use permission. Every Hexmark Overwatch attack hits on an unmodified 2+, and those hits are not Critical Hits. Multi-threat Eliminator is optional after an enemy unit shoots a friendly Necrons unit within 3 inches, measured base edge to base edge. Declining does not spend the once-per-turn shot; completing it does, and the shot can target only that enemy unit. The Hexmark’s own unit qualifies as the friendly Necrons unit.

On 31 October 2026, Canoptek Scarab Swarms (`000002114`) were taken from the local datasheet rows. The composition, 3/40 and 6/80 prices, Feeder mandibles, Reanimation Protocols, Self-destruction and Chittering Swarm sentences are unambiguous, so no extra online page was required. Self-destruction is an optional Fight-phase start choice: one model that is itself in Engagement Range is destroyed, then one enemy unit in Engagement Range of that model takes D3 mortal wounds on a modified 2–5 or 3 mortal wounds on a 6+. A VEHICLE adds 1 to the D6; a modified 1 causes no mortal wounds. Engagement uses this project’s 2-inch base-edge check. Chittering Swarm subtracts 1 from the Objective Control of each model in an enemy unit that is in Engagement Range, once per engaged Scarab unit, to a minimum of 1, and does not raise a characteristic that is already below 1. While any living Scarab model is within 6 inches (base edge) of a friendly living on-battlefield CRYPTEK model, every model in that Scarab unit has Objective Control 1.

On 31 October 2026, the Flayed Ones local ability rows for `000000538` were re-read. They bind Infiltrators (`000008345`), Stealth (`000008337`), Reanimation Protocols (`000008369`) and the datasheet sentence for Flesh Hunger. An earlier transcription omitted Stealth; the runtime now includes it. Flesh Hunger turns each successful melee Hit into a Critical Hit when the target is Below Half-strength. The local sentence uses that Core Rules term and does not redefine it, so the runtime uses the existing strict comparison: fewer than half the starting models, with exactly half-strength left unchanged. No extra online page was required.

On 31 October 2026, Deathmarks Hyperspace Hunters was taken from the local datasheet ability row for `000000537`. The local sentence is unambiguous: the shot is offered only when the active player sets an enemy unit up from Reserves during that player’s own Movement-phase Reinforcements step, within 18 inches and visible to the Deathmarks, and only if that unit is an eligible ranged target. Declining the offer does not spend the once-per-turn shot; completing the shot does. A Drop Pod arrival that opens this choice delays passenger disembarkation until the choice ends. No extra online page was required.

All 51 current App identities have runtime source-fact records; the four starter-backed Necron training/reference flows remain on the explicitly historical path and do not count toward these records. Reanimation admits 27 single-profile unit identities using exact local model counts and heals eleven living single-model Character identities. Canoptek Reanimator has model-only Feel No Pain 4+ and Nanoscarab Reanimation Beam: one bonus D3 for a friendly unit within 3 inches each time it activates Reanimation, including its own unit while on the battlefield. Multiple sources of this same Aura still grant only one D3. Necron Warriors can re-roll their Reanimation dice each time their Reanimation Protocols activate. Immortals re-roll Wound rolls of 1 for each attack; against an objective-range target, they receive an optional re-roll choice for any Wound die. Royal Warden supplies Leader, Reanimation Protocols, Adaptive Strategy and once-per-battle Engrammatic Logic; its phase-start choice targets a friendly Battle-shocked Necrons unit within 12 inches, including during the opponent's phase. Ten profiles map Deadly Demise to the shared resolver; six profiles map Deep Strike, two map Scouts 8/9 inches, and four C’tan profiles use Feel No Pain 5+ and Necrodermis through shared rules; the Deceiver also has Stealth. The Silent King's mixed Szarekh/Menhir unit remains outside Reanimation; its model-role-specific Deadly Demise also remains blocked. Reanimation still blocks character revival, multiple wounded survivors, reserves, passengers and additional mixed compositions. Its end-of-Command selector queues only living units with a model on the battlefield and skips reserve or embarked units. Focused Necron destruction-event, Deep Strike deployment and Scout movement checks remain pending. Deathmarks use the shared Deep Strike path and can shoot once per turn at an enemy unit that arrives from Reserves within 18 inches and visible during that opponent’s Reinforcements step, targeting only that unit. Flayed Ones use Infiltrators and Stealth, and Flesh Hunger makes each successful melee Hit a Critical Hit against a target that is Below Half-strength. Canoptek Scarab Swarms can destroy one engaged model at the start of the Fight phase to inflict Self-destruction mortal wounds, and Chittering Swarm changes Objective Control for engaged enemies and for Scarabs near a friendly CRYPTEK. Hexmark Destroyer uses Deep Strike, the 12-inch Lone Operative range, a once-per-turn 0CP Fire Overwatch that hits on unmodified 2+, and Multi-threat Eliminator after an enemy shoots a friendly Necrons unit within 3 inches. Canoptek Doomstalker uses both fixed ranged weapons, Doomstalker limbs, the 4+ invulnerable save, Reanimation Protocols, Deadly Demise D3, a 1–4 wound Hit penalty, and Fire Overwatch hits on unmodified 5+. The other 42 Necron profiles remain excluded from construction until their local abilities, choices and focused checks close; these nine sheet admissions do not certify full faction roster legality.

## Verification boundary

The focused Godot command was:

```powershell
.tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/test_necron_warriors_current.gd
```

The integrated Royal Warden and Necron regression command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_royal_warden --only test_necron_warriors_current --only test_current_unit_abilities --only test_capabilities --only test_implemented_catalog --only test_reanimation_protocols
```

It passed **8/8 offline processes** at `.tools/verification/20261031T171745711032Z/results.json` (SHA-256 `168544b07e03ae40fe6e1864cd708c0c70cb1803cfcfe53ff481594e9ce990f9`; `network: false`, legacy starter staged by the verifier, no cleanup diagnostics). This checks the Warden's local facts and supported rules alongside the source profile records, current ability bindings, the selectable catalog and Reanimation regressions. It does not validate every Necron ability, weapon choice, attachment combination, network flow, event roster or full army legality. At that stage, the other 50 Necron profiles remained out of construction until their own blockers were closed.

The integrated Necron scope command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_warrior_gauss_reaper --only test_necron_warriors_current --only test_necron_royal_warden --only test_current_unit_abilities --only test_capabilities --only test_implemented_catalog --only test_reanimation_protocols
```

It passed **9/9 offline processes** at `.tools/verification/20261031T173143934713Z/results.json` (SHA-256 `0424deaa3e80943d507199e9145e1a0a60db0f53995587a517e475cf774aff65`; `network: false`, legacy starter staged, no cleanup diagnostics). It checks both Warriors sizes and prices, per-model Gauss Reaper replacement/restoration, Their Number is Legion's Reanimation reroll, the three admitted Necron datasheets, current abilities, construction catalog gates and shared Reanimation regressions. This remains local scope validation, not full roster legality, network validation or event certification.

The integrated Deathmarks scope command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_deathmarks --only test_necron_immortals --only test_necron_warriors_current --only test_current_unit_abilities --only test_capabilities --only test_implemented_catalog --only test_reanimation_protocols
```

It passed **9/9 offline processes** at `.tools/verification/20261031T193811705794Z/results.json` (SHA-256 `9b4f99a811f13131eb1710b18480965045adaccd23f39733e908d128f8bd2de0`; `network: false`, legacy starter staged, no cleanup diagnostics). It checks Deathmarks sizes and copy prices, Reanimation on both source sizes, Hyperspace Hunters offer, decline, eligible-target restriction, visibility and once-per-turn shot, plus the five admitted Necron datasheets, current abilities, construction catalog gates and shared Reanimation regressions. This remains local scope validation, not full roster legality, network validation or event certification. The other 46 datasheet scopes remain open.

The integrated Flayed Ones scope command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_flayed_ones --only test_necron_deathmarks --only test_necron_warriors_current --only test_current_unit_abilities --only test_capabilities --only test_implemented_catalog --only test_reanimation_protocols
```

It passed **9/9 offline processes** at `.tools/verification/20261031T195020897663Z/results.json` (SHA-256 `db4557baaa8bc30b422ef89118f13aaaeb4743e23ee79561bb26630d93e7e0cf`; `network: false`, legacy starter staged, no cleanup diagnostics). It checks Flayed Ones sizes and copy prices, Infiltrators deployment, Stealth cover, Reanimation on both source sizes, and Flesh Hunger at full strength, exactly half-strength and Below Half-strength, plus the six admitted Necron datasheets, current abilities, construction catalog gates and shared Reanimation regressions. This remains local scope validation, not full roster legality, network validation or event certification. At that stage, the other 45 datasheet scopes remained open.

The integrated Canoptek Scarab Swarms scope command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_scarab_swarms --only test_necron_flayed_ones --only test_necron_warriors_current --only test_current_unit_abilities --only test_capabilities --only test_implemented_catalog --only test_reanimation_protocols
```

It passed **9/9 offline processes** at `.tools/verification/20261031T200056963803Z/results.json` (SHA-256 `9ab16d121c3cbc9426c86d25d476ee8415e6c4d6a139c2cce6c7be104e0c14d4`; `network: false`, legacy starter staged, no cleanup diagnostics). It checks Scarab sizes and copy prices, melee-only Feeder mandibles, Reanimation on both source sizes, Self-destruction decline and mortal results, and Chittering Swarm Objective Control, plus the seven admitted Necron datasheets, current abilities, construction catalog gates and shared Reanimation regressions. This remains local scope validation, not full roster legality, network validation or event certification. At that stage, the other 44 datasheet scopes remained open.

The integrated Hexmark Destroyer scope command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_hexmark_destroyer --only test_necron_warriors_current --only test_current_unit_abilities --only test_capabilities --only test_implemented_catalog --only test_reanimation_protocols --only test_core_reactions
```

It passed **9/9 offline processes** at `.tools/verification/20261031T201625878945Z/results.json` (SHA-256 `af417d99df8ed2725ea52a3ef86b70a999677bdc39e204dd6f79ed1ffe0a433a`; `network: false`, legacy starter staged, no cleanup diagnostics). It checks the Hexmark price and copy cost, Lone Operative range, Multi-threat Eliminator offer, decline and restricted shot, and Inescapable Death’s 0CP Overwatch with unmodified 2+ hits, plus the eight admitted Necron datasheets, current abilities, construction catalog gates, shared Reanimation regressions and core Overwatch regressions. This remains local scope validation, not full roster legality, network validation or event certification. At that stage, the other 43 datasheet scopes remained open.

The integrated Canoptek Doomstalker scope command was:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --timeout 1200 --only test_necron_doomstalker --only test_necron_warriors_current --only test_current_unit_abilities --only test_capabilities --only test_implemented_catalog --only test_reanimation_protocols --only test_core_reactions
```

It passed **9/9 offline processes** at `.tools/verification/20261031T202516905119Z/results.json` (SHA-256 `a2c95f1a2fd9f2a3c3123dadbcd1084e729405245e9f81078177b14d38e76130`; `network: false`, legacy starter staged, no cleanup diagnostics). It checks the Doomstalker price and copy cost, both ranged weapons, the 4+ invulnerable save, Reanimation, the Damaged 1–4 Hit penalty, Sentinel Construct’s 1CP Overwatch on unmodified 5+, and Deadly Demise D3, plus the nine admitted Necron datasheets, current abilities, construction catalog gates, shared Reanimation regressions and core Overwatch regressions. This remains local scope validation, not full roster legality, network validation or event certification. The other 42 datasheet scopes remain open.
