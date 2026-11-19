# Army Workshop

## Workspace

Open **Armies** from the title-screen bottom bar. The library keeps New,
Edit selected, Duplicate and confirmed Delete together with saved roster inspection.
The editor shows a unit catalog, current roster and selected-unit inspector. Search
and select a catalog unit to inspect its available compositions before adding it.
The Add action stays beside the catalog; roster model-size and unit-copy controls
appear at the top of the **Unit** inspector. Apply unit size commits those edits.

The header keeps points, unit/model counts and remaining budget visible. Save list,
Save a copy and New match stay in the footer. **Appearance** retains paint choices,
per-model overrides and palette preparation; **Army** retains category, faction,
notes and advanced construction controls. The miniature's rotate, zoom and Fit
controls change the preview only. At narrow logical widths, choose a workspace
region from the selector instead of using compressed columns.

Below 1560 logical pixels, the Workshop uses its compact region selector before
the three workspace columns can push the inspector off-screen. Opening a
selected entry's Appearance view switches to the inspector. That view keeps the
live miniature preview beside the appearance gallery, with the selectable local
looks before optional preparation and palette controls. The observed 1280×800
layout is recorded in [verification results](../verification/verification-results.md#responsive-appearance-workspace--13-november-2026).

**Miniatures & import** separates miniature browsing from Advanced source, files
and fit. Local cache preview does not download or link a model. Explicit download
and Link to unit type retain their previous scope. New match opens both saved-army
side selectors; advanced download settings and LAN options remain on that screen.

Closing the editor retains the session draft; use **Resume unsaved draft** in the
library to continue it. Editing the same saved army also resumes its dirty revision.
Before New, Edit another army or Duplicate replaces unsaved work, choose **Save
draft**, **Keep editing** or explicit **Discard changes**. A failed save preserves
the draft. Save explicitly to persist the army across application restarts.

Appearance cards show the selected sculpt's local readiness and any equipment or
role mapping rationale recorded in the local catalog. For supported model roles,
changing saved equipment refreshes that comparison; a conflicting manual sculpt
stays selected and is flagged for review. When catalog metadata cannot confirm a
match, the gallery labels it unverified instead of inferring compatibility.

Large local previews and the first large Appearance search show loading feedback
while their files and variants are prepared in the background. Selection changes
ignore older completions. Explicit source scans, large-catalog match/appearance preparation, heavy cached
imports and GLB preparation also run in the background. **Cancel preparation**
stops a batch from installing later results; existing saved links are preserved. Changing
the source path or a conversion target/fit prevents the obsolete result from
replacing the current catalog/mapping. Preparation can still take several seconds;
whole-library transfer speed and wider device behavior remain unverified. See the [redesign implementation and
verification record](../project/ui-redesign.md) for observed coverage and limits.

## Catalog and admission

The workshop offers only profiles in the consolidated local runtime catalog. Wahapedia 11e is the selected source for rules and datasheet facts; see the [source policy](../data/source-assessment.md) and [construction catalog policy](../construction-catalog-policy.md). The catalog currently contains 85 shared Space Marine profiles. A selectable profile does not imply complete rules support, full army legality or network certification.

Use the workshop to choose a profile, an available composition, unit counts and supported roster options. Save a list or a copy, then select it for a local match. Match admission revalidates each identity and composition against the enabled rules. Unsupported or unreconciled entries remain blocked or labelled as legacy drafts; they are not silently rewritten.

For the supported one-model Predator Destructor Legends profile, the Workshop saves the paired Lascannon/Heavy Bolter sponson selection plus its optional Storm Bolter and Hunter-killer Missile per vehicle copy. Saved-list matches install that package before Deployment and skip the duplicate preparation choices. Competitive event use still requires organiser permission; see the [Predator Destructor sheet scope](../marine-predator-destructor.md).

For Predator Annihilator Legends, the Workshop also stores the paired sponson replacement, Storm Bolter and Hunter-killer Missile per stable vehicle copy. Saved-list matches apply and lock that package before Deployment. Equipment edits remain draft changes until the list is saved. See the [profile scope](../marine-predator-annihilator.md).

## Character and artillery equipment

The Unit inspector saves the Execrator's pistol and conditional extra Power Weapon, the Phobos Lieutenant's pistol/carbine replacement, the Terminator Chaplain's Storm Bolter/Relic Shield replacement, and the Rapier Carrier's four main-weapon choices. Select the unit copy, choose its equipment and **Save list**. Invalid combinations preserve the draft and return the selector to its current value. The Execrator's extra Power Weapon requires the Absolvor Bolt Pistol; remove that extra weapon before selecting a Hand Flamer. The Chaplain's shield adds one Wound in the prepared match. Rapier remains a Warhammer Legends profile. Saved-list matches apply these choices before Deployment and do not offer them again during readiness. See the [source, persistence and visual checks](../verification/character-artillery-saved-equipment.md).

## Intercessor equipment

The workshop stores the Intercessor Sergeant's supported rifle and melee choices separately for each unit copy. It also lets each non-Sergeant miniature carry a saved Grenade Launcher choice. One model per five may take a launcher, so a five-model squad can equip one and a ten-model squad can equip two. The controls keep equipped choices available for removal and disable only the remaining choices once the unit reaches its cap. These options add no points under the current local profile. The Sergeant retains its Bolt Pistol.

Every model choice is stored against its stable model ID, checked against the squad limit, and included in canonical match admission. The saved equipment is applied before Deployment, so saved-list matches do not ask for the Sergeant's weapons or Grenade Launcher assignments again. Edit the saved list before starting another match. Equipment remains authoritative; the miniature appearance follows it when a compatible local sculpt is available.

Seven complete ForceOrg/TTS Sergeant assemblies currently have reviewed exact loadout mappings. Other supported combinations use the default Sergeant sculpt. The preview identifies the saved equipment and shows a cached matching sculpt when available; otherwise it explains which fallback will be used. The role-specific Sergeant sculpt takes priority over a per-model visual fallback when an exact equipment mapping is ready.

## Heavy Intercessor Heavy Bolters

Each Heavy Intercessor Squad copy can save one Heavy Bolter replacement for each five starting models. The Sergeant cannot take it. Choices are stored per eligible miniature's stable model ID, capped and rechecked at local match admission, then installed before Deployment. Saved-list matches skip the duplicate Army Preparation choice; standalone exercises retain it. The Workshop and saved-list runtime regression cover the per-model choices and cap. Appearance hints compare the selected Heavy Bolt Rifle or Heavy Bolter with local catalog metadata but do not certify sculpt parity.

## Assault Intercessor Sergeant equipment

Each Assault Intercessor Squad copy can save the Sergeant's Heavy Bolt Pistol replacement (Hand Flamer or Plasma Pistol) and Chainsword replacement (Power Fist, Power Weapon or Thunder Hammer). Both choices are keyed to the Sergeant's stable model ID and rechecked against the local source profile at match admission. Saved-list matches install them before Deployment and skip the duplicate Army Preparation choices; standalone exercises retain those setup controls. Appearance guidance compares local equipment hints with the selected pistol and melee profiles, but does not certify sculpt parity. These replacements do not change points under the source profile.

## Eliminator model equipment

Each model in a supported three-model Eliminator Squad has an independent saved ranged weapon. The Sergeant can use the Bolt Sniper Rifle, Las Fusil or Instigator Bolt Carbine; each ordinary Eliminator can use the Bolt Sniper Rifle or Las Fusil. The model selector keeps these choices tied to stable model IDs when a unit copy is split, saved or reopened.

Current-catalog admission validates every model choice and groups identical unit configurations. Match construction applies the saved weapons before deployment and removes those models from the duplicate preparation-choice path. The Army Builder preview shows the selected miniature's weapon and tries an exact compatible local visual when available. If there is no exact sculpt, the built-in or shared miniature remains visible and the equipment stays unchanged. Other loadout-bearing profiles still use their existing match-preparation options unless they have an explicit saved-list control.

## Outrider Squad equipment

Each Outrider copy saves the Sergeant's Chainsword replacement and each model's Heavy Bolt Pistol/Plasma Pistol choice against stable model IDs. The Sergeant may take a Power Weapon or Thunder Hammer, and a unit may take one Plasma Pistol per three models. Current-catalog admission checks the cap for both supported unit sizes. These options do not change points.

Saved-list matches apply the selected equipment before Deployment and lock it for that match, so Army Preparation does not ask for the same choices again. The preview checks the configured ranged and melee profiles against local ForceOrg hints when available; missing or uncertain visual matches keep the normal fallback. Outrider visual metadata does not certify sculpt parity.

## Ravenwing Darkshroud equipment

Each Ravenwing Darkshroud copy can save its Heavy Bolter or source-listed Assault Cannon replacement. The Army Builder stores that choice against its stable model ID, current-catalog admission carries it into the canonical match roster, and saved-list matches equip it before Deployment and suppress the duplicate preparation choice. The selected profile is used by the local visual matcher where available; a missing exact variant leaves the fallback miniature in place. The saved Assault Cannon path is covered by the local Darkshroud regression, but visual equipment hints do not certify sculpt parity.

## Land Speeder cannon

Each Land Speeder copy can save its source-listed Onslaught Gatling Cannon or Pyrecannon. The choice is tied to the copy's stable model ID, checked by local catalog admission, and installed before Deployment in saved-list matches. The same cannon choice is not requested again during match preparation; standalone exercises keep their setup option. Appearance hints can compare local weapon labels to the selected cannon, but they do not certify sculpt parity.

## Land Speeder Vengeance cannon

Each Land Speeder Vengeance copy can save its Heavy Bolter or source-listed Assault Cannon. The Army Builder ties the choice to its stable model ID; current local admission preserves differently configured copies, and saved-list matches install the exact profile before Deployment. Appearance matching compares recorded weapon labels only and does not certify sculpt parity.

## Hellblaster Sergeant pistol

Each Hellblaster Squad copy can save the Sergeant's Bolt Pistol or its free Plasma Pistol replacement. The choice is tied to the Sergeant's stable model ID, checked against the local Hellblaster profile at admission and applied before Deployment in saved-list matches. Army Preparation does not ask for this persistent choice again; standalone exercises keep their existing setup control. Appearance hints compare local weapon labels and do not certify sculpt parity.

## Inceptor model equipment

Each Inceptor in a saved squad can use Assault Bolters or replace them with Plasma Exterminators. The Army Builder saves the choice per stable model ID, and the current-catalog admission checks one source-listed choice for every model in each copy. The option does not change points or squad size. Saved-list matches apply the selected profiles before Deployment and lock them for that match; standalone exercises retain the existing setup choice. The preview tries an equipment-matched local sculpt and reports when an exact Plasma Exterminator sculpt is unavailable. Gallery hints compare recorded weapon labels only and do not certify sculpt parity.

## Scout Squad model equipment

Each Scout's Boltgun or permitted replacement is saved against its stable model ID. The Sergeant may take a Shotgun and replace the Combat Knife with a Chainsword; other Scouts may take Shotguns, while the one Sniper Rifle and one Heavy Bolter or Missile Launcher per five starting models are rechecked at admission. Different Scout copies retain different loadouts. Saved-list matches apply these weapons before Deployment and suppress the duplicate Army Preparation choices; standalone exercises and older saved lists without model equipment keep their existing setup flow. The Workshop and saved-list runtime regression cover the configured equipment. The miniature preview labels it and requests a compatible local visual when one is available. A missing local sculpt does not change the equipment; visual hints do not certify sculpt parity.

## Invader ATV model equipment

Each Invader ATV model can save its Onslaught Gatling Cannon or replace it with a Multi-melta for 5 points. The Army Builder stores that choice against the model's stable ID. Admission carries the per-model choices through canonical grouping and includes each Multi-melta surcharge in the points check. Saved-list matches install the selected profile before Deployment and skip the duplicate setup choice; standalone exercises keep their existing preparation control. The Workshop and saved-list runtime regression cover mixed model choices and the surcharge. The preview checks local weapon hints and keeps the normal fallback when no compatible visual is ready.

## Reiver Squad gear

Grav-chutes and Grapnel Launchers are saved separately for each Reiver unit copy because they apply to the squad as a whole. Current-catalog admission carries the two source-listed choices through canonical grouping; local saved-list matches apply them before Deployment and lock repeat Army Preparation changes. New Reiver entries start with neither optional item selected. Older entries without explicit saved gear continue to offer those match-specific preparation choices. The Workshop and saved-list runtime regression cover independent gear on separate copies. The preview does not claim exact wargear sculpt matching.

## Aggressor Squad weapon package

Each Aggressor miniature can use its default Flamestorm Gauntlets or the source-listed replacement of Auto Boltstorm Gauntlets plus a Fragstorm Grenade Launcher. The Army Builder stores each choice against the stable model ID. Current-catalog admission preserves mixed squads and differently equipped copies; saved-list matches install and lock each model's complete ranged package before Deployment, so Army Preparation does not ask twice. Battle Readiness summarizes packages per unit. Standalone exercises retain one Army Preparation choice per model. A focused offline regression covers save/reopen, legacy migration, model controls, admission, match materialization, readiness and setup suppression. This path uses the audited [Aggressor Squad source scope](../marine-aggressor-squad.md); it does not certify sculpt parity or full army legality.

## Necron per-model equipment

Each Necron Warrior can use a Gauss flayer or Gauss reaper; each Immortal can use a Gauss blaster or Tesla carbine. The Army Builder saves each selection against that model's stable ID, validates the per-model choices against the local Necrons App v1.2 profile, and includes them in the canonical saved-list roster. Saved-list matches apply the choices before deployment and suppress the duplicate Army Preparation prompt. The list's points do not change for these choices under the selected source profile.

The Appearance preview uses the selected source weapon record to look for a compatible local sculpt. When catalog weapon hints match or conflict with the saved choice, the gallery explains that comparison; unverified hints are labelled as metadata only. When no exact weapon visual is ready, it keeps the normal unit appearance and reports that fallback; it never changes equipment to match a miniature. The rules facts come from snapshot `20261031T053336Z`; remaining Necron profiles stay subject to their own construction and support gates.

Each Canoptek Macrocyte can save one of four local source-listed equipment packages: Gauss scalpel, Tesla caster, Atomiser beam + Nanoscarab Projector, or Accelerator Mandible. The two specialist packages are limited to one model each per unit and are rechecked at current-catalog admission. The selected equipment is fixed for that saved-list match and included in local match construction. The gameplay roster projection also preserves the canonical per-model choices for LAN submission; separate-machine behavior remains unverified. Its preview checks both ranged and melee equipment against local ForceOrg hints when available; missing exact visuals use the standard fallback without changing rules.

Each Canoptek Spyder can save its three independent source-listed equipment options per model: two Particle Beamers, Fabricator Claw Array and Gloom Prism. The controls preserve combined choices, and current-catalog admission carries each model's switches into local saved-army matches. Army Preparation no longer repeats those persistent selections. The gameplay roster projection also converts these saved switches into canonical per-model fields before stripping local model IDs; separate-machine LAN behavior is still unverified. The appearance preview checks the selected weapon and equipment records against local ForceOrg hints; an unavailable exact match keeps the ordinary miniature fallback. These sourced options do not add points.

Each of the two Canoptek Tomb Crawlers can save its ranged weapon. The transdimensional isolator is limited to one model per unit; the Builder prevents selecting it twice and current-catalog admission rechecks the cap. Saved-list matches apply the selected profiles before Deployment without repeating the Army Preparation choice. The gameplay roster projection preserves the canonical per-model choices while removing local IDs; separate-machine LAN behavior is still unverified. Appearance matching uses the selected ranged and fixed melee records when a local sculpt is available.

The Annihilation Barge can save its Gauss cannon or source-listed Tesla cannon, and the Monolith can save four Gauss Flux Arcs or four Death Rays. These vehicle choices are stored per stable model, applied before Deployment and locked against a second Army Preparation selection for saved-list matches. Their previews compare the selected weapons with local ForceOrg hints and retain the normal fallback when no exact sculpt is ready. The choices do not change points.

Appearance cards report whether a local look is ready, queued or downloading, still needs preparation, is missing, or failed during conversion/validation. Cards keep the saved assignment available and explain that the built-in fallback remains visible; visual availability never blocks saving an otherwise admitted army or changes equipment legality. These statuses cover the local gallery and current preparation flow, not every cache or import failure path.

## Saved battle formation candidates

The **Army** tab can store a Warlord candidate against a stable model ID for a Character entry. It can also save a Character or Support miniature's proposed attachment to a specific unit copy. Both references stay local to the saved list; when that list starts a local match, the IDs are mapped to the accepted canonical roster and replayed through the current public Warlord and attachment choices. Mandatory-character rules, eligible bodyguard links and formation limits remain authoritative. A stale or newly illegal candidate blocks launch with a review message. If no candidate is saved, resolve the choice during Battle Readiness.

Saved formation candidates are applied only for local saved-army matches. The current LAN roster submission does not carry them, so LAN players still declare Warlords and attachments during Battle Readiness. These local checks do not certify full army legality or broaden the admitted rules profiles.

## Local appearances and preparation

Each unit copy can use one local paint appearance shared by its models. A reviewed per-model sculpt fallback remains available for other distinct roles. These choices are saved only in the local profile and are removed before the gameplay roster is sent to a peer.

Every miniature now stores an explicit **Auto** or **Manual** appearance mode by stable model ID. Auto follows the unit look, equipment/role candidates and local fallback order. Manual preserves the selected sculpt even when its files are unavailable; the board shows a fallback and the saved choice remains available to retry. Existing profile files infer Manual from a non-empty legacy override and infer Auto otherwise.

Every saved unit copy now receives a stable local identity; each model identity is derived from its copy and model slot. Manual model sculpts are stored against that model ID, while the existing flat slot array remains a migration/compatibility view. Legacy overrides migrate when the profile loads; shrinking and restoring a composition keeps overrides for the same model slots. Reopening or repricing a list keeps those identities, and splitting one copy for a one-copy choice preserves its equipment and appearance data. These local IDs and appearance references are omitted from match roster traffic. This is persistence infrastructure; it does not expand the rules or legality scope of the selected army.

The board's local visual resolver keeps a renderable per-model override first, then tries equipment/role-compatible variants from the unit's appearance family, the saved unit appearance, army palette and remaining same-family variants. If those fail, it tries the datasheet's local default mapping, then the built-in miniature. An unavailable manual, unit-copy or palette selection stays saved and produces a resolver warning; it does not change the loadout. Match review reports readiness for explicit saved looks; automatic equipment/role candidates are checked during launch preparation. In the Appearance tab, the shared 3D preview stays with the selection controls. Searchable two-column appearance cards show local readiness; the player can choose a unit-copy appearance or an override for only the selected model, and reset either choice to the automatic resolver. Each candidate card shows **Strong**, **Partial**, **Role only**, **Unverified** or **Conflict** evidence confidence separately from local asset readiness, with the evidence rationale in its tooltip and selected-card detail. Strong means supported local weapon hints cover the saved physical weapon labels or a reviewed role mapping matches; Partial reports incomplete weapon-label coverage. These labels describe metadata coverage, not probability or sculpt parity. For supported Intercessor Sergeant, Grenadier, Hellblaster, Assault Intercessor Sergeant, Heavy Intercessor, Eliminator, Outrider, Inceptor, Darkshroud, Land Speeder and Invader ATV comparisons, the detail also relates hints to saved equipment. The explicit **Apply this look to similar models** action is available when the saved model schema can compare role and equipment deterministically; it currently covers Intercessors, Eliminators, Necron Warriors, Immortals, Canoptek Macrocytes, Canoptek Spyders, Canoptek Tomb Crawlers, Annihilation Barges and Monoliths. It affects only matching models in the selected unit copy and never changes equipment or another copy. These hints describe visual candidates only and do not establish game-rule legality or certify a sculpt by sight. Thumbnail images and object-by-object visual certification remain open. Intercessor lists prepare the seven mapped Sergeant loadout sculpts and the supported Grenadier role sculpt so saved equipment can select those models in a match. Common models keep the unit's single paint choice. Missing visuals do not block roster rules or gameplay. Assets, mappings and appearance settings remain on the current computer.

Starting a saved-army match takes a local appearance snapshot alongside the frozen gameplay match. The local match save keeps the selected unit-copy sculpts, stable per-model overrides and palette references, and checks them against the saved canonical roster when loading. Later edits to an Army Builder list do not replace that match's appearances. The snapshot contains references only; an unavailable cached model still falls through to the normal local fallback. Prepared GLB packages reuse cached mesh resources across separate miniature scene instances. This cache is local and is kept out of LAN state so each computer resolves its own assets.

Downloads and appearance assignments do not establish rules support. The full army legality and separate-machine multiplayer behavior remain outside the current certification boundary.

## Lists and privacy

Profiles and lists belong to the local computer. The match shares only canonical gameplay selections such as unit identity, composition and equipment. Private profile/list names, notes, ForceOrg mappings, model files, paint choices and camera state are not match data.

The broad OpenHammer API catalog and its cache do not supply new construction choices. Historical adapters remain isolated from the current army workshop. See [saved army matches](saved-army-matches.md) and the [current support matrix](../project/support-matrix.md) for implementation limits.

## Invictor and Ancient equipment

Each Invictor Tactical Warsuit copy can store its Incendium Cannon or Twin Ironhail Autocannon. Each Ancient can store its Bolt Rifle or source-listed Power Weapon replacement. These choices belong to stable model identities and are installed before Deployment for saved-list matches; duplicate preparation changes are blocked. Equipment updates remain draft changes until **Save list** is used. The rules and source boundaries remain those of the [Invictor audit](../marine-invictor-tactical-warsuit.md) and [Ancients audit](../marine-ancients.md).

## Optional vehicle equipment

The Army Workshop also saves the supported vehicle options on each one-model unit copy. Vindicator and Whirlwind copies can record their Hunter-killer Missile and Storm Bolter options. Hammerfall Bunker copies can select the Heavy Bolter or Heavy Flamer Array. Nephilim Jetfighter copies can select Twin Heavy Bolters or Nephilim Lascannons. The Legends profiles Cerberus, Typhon and Falchion expose their individually listed optional weapons and replacement packages.

Standard Rhino copies can also save the audited no-cost Hunter-killer Missile choice. Each copy stays independent; saved-list matches install the missile before Deployment and lock its duplicate preparation control. The existing source audit and local weapon profile are reused. This transfers that option into persistent army data; it does not certify the Rhino's other rules or full army legality.

These records use explicit per-profile choices and the existing local weapon builders. Saved-list matches apply them after source-profile defaults, then prevent the same loadout from being changed during match preparation. The focused local regression checks seven profiles, separate configurations across two copies, rejected value types, Workshop controls and duplicate-choice suppression. Legends profiles remain subject to their event-use conditions. Equipment and visual appearance remain separate; local weapon metadata does not establish sculpt parity. Full army legality, complete option coverage for every admitted datasheet and separate-machine LAN remain open. See the [coverage ledger](../project/army-builder-coverage.md) and [verification record](../verification/verification-results.md#optional-vehicle-saved-equipment--13-november-2026).

## Dreadnought equipment

Each Dreadnought copy saves its Assault Cannon replacement, linked melee/ranged package and Storm Bolter replacement. The local source validator permits only the 12 combinations allowed by the verified Legends profile, including the rule that the Heavy Flamer cannot accompany the Missile Launcher + Crushing Feet package. Each Venerable Dreadnought (Legends) copy saves its primary weapon and Dreadnought Fist/ranged package, covering all 32 source-listed combinations. Both profiles install their exact ranged and melee weapon arrays before Deployment and lock duplicate preparation actions. The saved army restart check covers a configured Dreadnought across a separate-process disk reopen and frozen match snapshot. Equipment does not determine its visual model; sculpt parity and event legality remain outside this check. See the [Dreadnought audit](../marine-dreadnought.md), [Venerable Dreadnought audit](../marine-venerable-dreadnought-legends.md) and [verification record](../verification/verification-results.md#dreadnought-saved-equipment--13-november-2026).

The Brutalis Dreadnought saves the linked Bolt Rifle/Brutalis Fists replacement with Brutalis Talons independently from its Twin Heavy Bolter/Twin Multi-melta choice. Saved matches apply those weapons before Deployment and suppress duplicate setup actions. The local validator accepts all four combinations, and the saved copy limit remains three. See the [Brutalis audit](../marine-brutalis-dreadnought.md) and [verification record](../verification/verification-results.md#brutalis-saved-equipment--13-november-2026).

## Aircraft equipment

Stormhawk Interceptor copies can save the Las-talon or Icarus Stormcannon and choose the Skyhammer Missile Launcher, Twin Heavy Bolter or Typhoon Missile Launcher. Stormtalon Gunship copies can choose the Skyhammer Missile Launcher, Twin Heavy Bolter, Twin Lascannon or Typhoon Missile Launcher. The Army Workshop validates these selections against the local Legends profiles and installs the matching weapon records before Deployment. Match preparation no longer repeats a choice already saved with the army. The focused local regression checks every listed choice and keeps configured copies separate from defaults. Event eligibility, exact sculpt parity and full army legality remain unverified. See the [Stormhawk audit](../marine-stormhawk-interceptor.md), [Stormtalon audit](../marine-stormtalon-gunship.md) and [verification record](../verification/verification-results.md#aircraft-saved-equipment--13-november-2026).

## Space Wolves Dreadnought equipment

Bjorn can save the Assault Cannon, Helfrost Cannon or Multi-melta. The Space Wolves Venerable Dreadnought can save its primary weapon, Storm Bolter/Heavy Flamer and Combat Weapon or Fenrisian Great Axe + Blizzard Shield package; the local validator rejects the Great Axe + Blizzard Shield with a non-Assault Cannon. Wulfen Dreadnought can save its Storm Bolter/Heavy Flamer and Fenrisian Great Axe/Blizzard Shield choices. These three profiles use their shared local weapon factory and lock saved choices against duplicate match-preparation edits. The Space Wolves Venerable Dreadnought is a different datasheet from the Venerable Dreadnought (Legends) described above. See the [Space Wolves walker audit](../marine-space-wolves-walkers.md) and [verification record](../verification/verification-results.md#space-wolves-walker-saved-equipment--13-november-2026). Sculpt parity, full army legality and separate-machine LAN remain unverified.

## Death Company Dreadnought equipment

Each Death Company Dreadnought copy can save its Twin Heavy Bolter or Twin Multi-melta and its linked Blood Fists + Bolt Rifles or Blood Talons package. The local profile factory validates and materializes all four combinations. Saved-list matches apply the selected ranged and melee profiles before Deployment and suppress duplicate match-preparation changes. The focused local regression checks separate copy configurations, Workshop controls and forced-edit rejection. See the [Death Company Dreadnought audit](../marine-death-company-dreadnought.md) and [verification record](../verification/verification-results.md#death-company-dreadnought-saved-equipment--13-november-2026). Full army legality, sculpt parity and separate-machine LAN remain unverified.

## Death Company Captain equipment

The foot Death Company Captain can save its Heavy Bolt Pistol or Inferno Pistol independently from its Master-crafted Chainsword, Power Fist or Relic Weapon. The Jump Pack Captain saves a complete source-listed package: Heavy Bolt Pistol + Chainsword; one of three pistols with Power Fist; one of three pistols with Relic Weapon; or Thunder Hammer + Relic Shield or Chainsword + Relic Shield. The saved choice is checked against the local weapon factory and installed before Deployment. Match preparation does not ask for the same choice again, and the Jump Pack Captain's Relic Shield keeps its extra Wound. This covers these two local profiles only; full army legality, exact sculpt parity and separate-machine LAN remain open. See the [Blood Angels character scope record](../space-marines-coverage.md) and [verification record](../verification/verification-results.md#death-company-captain-saved-equipment--13-november-2026).

The Blood Angels Captain also saves its Heavy Bolt Pistol/Inferno Pistol and Master-crafted Chainsword/Power Fist/Relic Weapon choices independently. The local validator admits all six combinations, and saved matches materialize the exact weapons before Deployment while suppressing a second setup choice. The adapter uses the audited 11e profile and does not change army repeat limits. Sculpt parity, full army legality and separate-machine LAN remain open. See the [Captain audit](../marine-blood-angels-captain.md) and [verification record](../verification/verification-results.md#blood-angels-captain-saved-equipment--13-november-2026).

The shared-book Captain can save its ranged package and melee weapon separately. The Army Workshop accepts seven legal packages and rejects Relic Shield + Power Fist. Its Relic Shield adds the source-listed Wound in the prepared match. These saved choices preserve the audited one-to-three-copy limit and remove duplicate setup prompts. See the [shared Captain audit](../marine-captain.md) and [verification record](../verification/verification-results.md#shared-captain-saved-equipment--13-november-2026).

The shared-book Captain With Jump Pack saves one of seven complete packages: Heavy Bolt Pistol + Chainsword; Hand Flamer or Plasma Pistol with Chainsword; Heavy Bolt Pistol with Power Fist or Relic Weapon; Thunder Hammer + Relic Shield; or Chainsword + Relic Shield. The Workshop keeps each package together, and the saved Relic Shield adds its Wound before Deployment. The audited one-to-three-copy limit is unchanged. See the [Jump Pack Captain audit](../marine-captain-with-jump-pack.md) and [verification record](../verification/verification-results.md#jump-pack-captain-saved-equipment--13-november-2026).

The Captain in Gravis Armour can save the default Master-crafted Heavy Bolt Rifle and Master-crafted Power Weapon or one of three complete Boltstorm Gauntlet + relic packages. These choices are validated against the local profile factory, applied before Deployment and locked for the saved-list match. The existing copy limit is unchanged. Saved equipment describes rules state; it does not certify an exact local sculpt match. See the [Gravis Captain audit](../marine-captain-gravis.md) and [verification record](../verification/verification-results.md#gravis-captain-saved-equipment--13-november-2026).

The Captain in Terminator Armour can save its Storm Bolter or Combi-weapon and its Relic Weapon or Relic Fist independently. Saved matches apply the exact weapon profiles before Deployment and suppress duplicate preparation choices; the Combi-weapon retains all three firing profiles. The copy limit is unchanged. See the [Terminator Captain audit](../marine-terminator-captain.md) and [verification record](../verification/verification-results.md#terminator-captain-saved-equipment--13-november-2026).

The Captain on Bike can save its Heavy Bolt Pistol/Plasma Pistol and Master-crafted Power Weapon/Thunder Hammer replacements independently for each copy. The Workshop and current-catalog admission preserve different choices across copies; the source-audited Incursion and Strike Force copy caps remain unchanged. Saved profiles materialize before Deployment and suppress duplicate preparation controls. The 90 × 52 mm oval base remains a bounding-circle placement proxy. See the [Captain on Bike audit](../marine-captain-on-bike.md) and [verification record](../verification/verification-results.md#captain-on-bike-saved-equipment--13-november-2026).

## Castellan equipment

The Black Templars Castellan can save its Combi-weapon or Heavy Bolt Pistol independently from its Master-crafted Power Weapon or Chainsword. The local adapter validates all four packages against the current profile factory; saved-list matches install those exact weapons before Deployment and block duplicate match-preparation edits. The existing construction repeat limit is unchanged because the runtime capability record does not specify a limit. See the [Castellan audit](../marine-castellan.md) and [verification record](../verification/verification-results.md#castellan-saved-equipment--13-november-2026).

The Black Templars Marshal can save its Plasma Pistol or Combi-weapon. The local factory validates both choices and supplies the unchanged Master-crafted Power Weapon; saved-list matches materialize both weapon profiles before Deployment and suppress the repeated setup choice. The runtime repeat limit is unchanged. See the [Marshal audit](../marine-marshal.md) and [verification record](../verification/verification-results.md#marshal-saved-equipment--13-november-2026).

The shared-book Lieutenant can save one of nine ranged packages, one of three Ceramite Fists replacements and an optional Storm Shield. The local validator allows that shield only with Neo-volkite; saved matches materialize the selected ranged/melee profiles and apply the 4+ invulnerable save to the Lieutenant model. When the Workshop changes away from Neo-volkite, it clears the dependent shield and keeps the other equipment selections. See the [Lieutenant audit](../marine-lieutenant.md) and [verification record](../verification/verification-results.md#lieutenant-saved-equipment--13-november-2026).

## Sanguinary Guard per-model equipment

For each Sanguinary Guard model, choose its default Angelus Boltgun or replace it with an Inferno Pistol. The saved 3-model unit allows one Inferno Pistol; the 6-model unit allows two. The limit is checked when saving the roster, and different copies keep independent choices. Saved-list matches apply the selected weapons before Deployment and remove the duplicate Army Preparation choice. Standalone/training setup can still use the reversible preparation choice. See the [Sanguinary Guard audit](../marine-sanguinary-guard.md) and [verification record](../verification/verification-results.md#sanguinary-guard-saved-equipment--13-november-2026).

## Death Company per-model equipment

The foot and Jump Pack Death Company squads save melee and pistol choices on each model. The foot squad can also add a Grenade Launcher to a Bolt Rifle Fire carrier. The Workshop validates the separate weapon quotas for the selected 5- or 10-model size; each unit copy keeps its own choices. Saved matches apply the loadouts before Deployment and lock those choices for the match. Jump Pack records do not include the foot squad's Grenade Launcher option. See the [foot squad audit](../marine-death-company-marines.md), [Jump Pack audit](../marine-death-company-marines-with-jump-packs.md) and [verification record](../verification/verification-results.md#death-company-marines-saved-equipment--13-november-2026).

## Tarantula Sentry Battery per-model equipment

For each Tarantula model, keep the Twin Heavy Bolter or replace it with a Twin Lascannon. Different models within a 1-, 2- or 3-model unit can use different weapons, and each copy saves its own choices. Saved-list matches install the weapons before Deployment and do not offer the same preparation option again. This is a Warhammer Legends datasheet; competitive use requires event organiser approval. See the [Tarantula audit](../marine-tarantula-sentry-battery.md) and [verification record](../verification/verification-results.md#tarantula-sentry-battery-saved-equipment--13-november-2026).

### Heavy and Space Wolves saved equipment

Configure the Redemptor weapons and optional Icarus in the Unit inspector; Macro Plasma adds 10 points to the live total. Centurion Assault and Devastator squads have separate equipment controls for each model in a 3- or 6-model squad. Wolf Guard Battle Leader can save its ranged and melee replacements; Storm Shield adds one Wound. Save the list before starting a match. These saved choices are applied before Deployment and are not repeated during readiness. Centurions retain their Legends/event restrictions. See [reviewed scope and evidence](../verification/heavy-saved-equipment.md).

### Saved transport weapons and systems

Land Raider, Crusader, Redeemer, Excelsior, Razorback, Relic Razorback, Repulsor, Repulsor Executioner, Impulsor and the Black Templars Repulsor/Executioner/Impulsor save their reviewed equipment per vehicle copy. Use the Unit inspector selectors and Save list. Priced options show their additional cost. Impulsor systems share one exclusive selector; the BT pintle selector allows either Heavy Stubber or Multi-melta. Saved Shield Dome and Orbital Comms effects apply before Deployment. Common Executioner totals include the equipped Laser surcharge (270/290 with Laser; 260/280 with Plasma); the BT version uses its own source prices. Older saved matches retain their preparation path. Chapter, Legends and geometry restrictions still apply. See [source scope and verification](../verification/transport-saved-equipment.md).

### Saved squad specialist equipment

Firestrike models can save different turret weapons. Infiltrators can save one Helix Gauntlet bearer per squad; remove it from the current bearer before selecting another. Bladeguard show the Sergeant pistol choices and fixed pistols on ordinary models. Use Save list to keep changes. New matches apply these choices before Deployment and do not ask again; Helix healing and Bladeguard combat decisions remain available when their rules permit. See [reviewed scope and evidence](../verification/squad-specialist-saved-equipment.md).

### Black Templars Gladiator equipment

BT Lancer, Reaper and Valiant can save an additional Multi-melta on each vehicle copy. The selector adds ten points. Valiant keeps its two fixed weapons; their twenty-point cost is already included in the saved default total. The Add form shows the equipped default price and later-copy tiers. Save the list before starting a match. Existing frozen matches keep their captured equipment and prices. See [reviewed source scope and evidence](../verification/templar-gladiator-saved-equipment.md).

### Corvus and Mastodon saved pairs

Corvus Blackstar saves its Hurricane Bolter, primary cannon replacement and whole launcher-pair replacement. Mastodon saves its two independent weapon pairs; each selector replaces both weapons in that pair. Save the list before starting a match. The source lists no surcharge for these choices. Saved equipment is fixed for the new match; later edits affect future matches. Chapter, Legends/event and footprint limits still apply. See [source scope and evidence](../verification/large-transport-saved-equipment.md).

### Saved Thunderwolf and Wulfen equipment

Each Thunderwolf can save its pistol or Boltgun/Storm Shield package. Plasma Pistols are limited to one per three models; each cavalry shield adds five points and grants only its bearer a 4+ invulnerable save. Each Wulfen can save Death Totem or Stormfrag Auto-launcher. The two Wulfen datasheets keep their different defaults, fixed melee weapons and shield characteristics. Save the list before starting a match. Invalid choices preserve the draft and restore the selected value. Source effects apply before Deployment, and the new match does not ask for these choices again. See [source scope and verification](../verification/space-wolves-squad-saved-equipment.md).

Wolf Scouts and Wolf Guard Headtakers also use saved per-model equipment for the existing admitted 6/12-model compositions. Workshop controls and appearance sharing distinguish leaders, ordinary models and Hunting Wolves. Saved validation enforces role eligibility and Scout weapon/mine caps; readiness cannot alter these records. Source profiles, Headtaker partial composition scope, live mine use and formation splitting are preserved. See the [mixed Space Wolves audit](../verification/mixed-space-wolves-saved-equipment.md).

Assault Intercessors with Jump Packs, Blood Claws and Grey Hunters use saved role-specific model equipment. Model zero is the Sergeant/Pack Leader; ordinary equipment restrictions and Jump Plasma caps apply to the complete unit. Grey Hunters retain Bolt Carbines. Equipment choices are locked in the match, while Old Greymanes remains a formation declaration. See [bounded evidence](../verification/sergeant-squad-saved-equipment.md).

Eradicators with Melta Rifles, Desolation Squad and Sternguard Veteran Squad also save role-specific equipment. Ordinary Eradicators supply Multi-melta carriers; Desolation Sergeant Vengor adds five points; Sternguard special guns share the per-five allowance and Sergeant melee remains independent. Exact inventories apply before Deployment and cannot be reconfigured in the match. See [source resolution and bounded evidence](../verification/specialist-squad-saved-equipment.md).

Standard Terminators, Assault Terminators and Wolf Guard Terminators also save exact per-model equipment. Ordinary special-weapon caps and leader-role restrictions apply to the full unit; Cyclones keep Storm Bolters and add ten points, while Assault/Wolf Guard shields add five points and one bearer Wound. These records apply once before Deployment and cannot be reconfigured during the match. See [bounded source/verification evidence](../verification/terminator-saved-equipment.md).

Deathwing Terminators and Knights save weapons per model and Watcher in the Dark once per unit copy. Use the whole-unit checkbox above the miniature rows; it is free and creates no bearer/model slot. Saved matches lock equip/remove choices while leaving triggered Watcher use available. Catalog refresh and copy splitting preserve unit choices, including existing Reiver gear. See [bounded evidence](../verification/deathwing-saved-equipment.md).

### Deathwatch saved equipment

Deathwatch Veterans and Deathwatch Terminators can save equipment for each model in supported five- or ten-model units. The Watch Sergeant has separate ranged and melee selectors. Ordinary Veterans share the per-five weapon and Storm Shield caps; one may take Black Shield Blades. Terminators keep their Sergeant's ranged special fixed, and up to three ordinary Terminators can select a special weapon. Storm Shields add five points and one Wound to the bearer; Cyclone Missile Launchers add ten points. The Workshop shows these dense choices in scrollable model cards. Save the army before starting a match; its saved choices are applied before Deployment and cannot be changed during that match. See the [source and bounded verification](../verification/deathwatch-saved-equipment.md).

### Vanguard Veteran saved equipment

Both Vanguard Veteran squads save equipment separately for each model in supported five- or ten-model units. The Warhammer Legends squad can replace each Bolt Pistol with a Storm Shield or one of its listed pistols. Jump Pack Sergeant pistol/melee options stay separate from the ordinary models' two-per-five Plasma Pistol allowance; any model may choose the source-listed Combat Shield. These options have no surcharge, and the Jump Pack's first-two/third-plus prices remain in effect. The Jump Pack inspector stacks each model name above its two selectors; ordinary models' fixed melee is shown disabled. Save the army before starting a match; saved equipment applies before Deployment and cannot be changed during that match. See the [source and bounded evidence](../verification/vanguard-veteran-saved-equipment.md).

### Sword Brethren saved equipment

Each Sword Brother can save one complete Heavy Bolt Pistol/melee package. The Workshop offers the locally priced 4-, 5-, 9- and 10-model sizes and enforces the source limits across each unit: up to two Hand Flamers plus one Plasma Pistol, Thunder Hammer and Twin Lightning Claws per four models. Master-crafted Power Weapons have no additional cap. These choices add no points, and the existing copy prices remain in effect. Save the list before starting a match; saved weapons apply before Deployment and cannot be changed during that match. Sizes 6–8 remain unavailable because the selected local export does not price them. See the [source audit and bounded verification](../verification/sword-brethren-saved-equipment.md).

### Scout Bike Squad saved equipment (Warhammer Legends)

Each Scout Biker can save the Twin Boltgun/Grenade Launcher choice, including the Sergeant. Only the Sergeant can replace the Bolt Pistol, with one of the eleven choices listed by the local Legends datasheet. These options add no points; 3/6-model copies remain 75/150 points with their existing copy limits. Save the army before starting a match; saved weapons apply before Deployment and cannot be changed during that match. Event eligibility and exact sculpt matching are not certified. See the [local source audit and bounded evidence](../verification/scout-bike-saved-equipment.md).

### Ravenwing saved equipment

Ravenwing Black Knights (3 or 6 models) and the three-model Ravenwing Command Squad can save which model replaces its Plasma Talon with a Grenade Launcher. Both squads allow one per three models, so a six-model Black Knight unit may save two different bearers. The Command Squad's Ancient, Apothecary and Champion remain fixed roles. The choice adds no points, and source copy tiers remain intact. The Workshop stacks each model label above its selector; longer squads scroll inside the inspector. Saved weapons apply before Deployment, and the same equipment cannot be changed during that match. See the [local source audit and bounded evidence](../verification/ravenwing-saved-equipment.md).

### Indomitor Kill Team saved equipment

The fixed ten-model Indomitor copy contains three Aggressors, three Eradicators and four Heavy Intercessors. Each Aggressor may save the Auto Boltstorm Gauntlets and Fragstorm Grenade Launcher replacement; one Eradicator may take the Multi-melta; and up to two Heavy Intercessors may take Deathwatch Heavy Bolters. The Workshop labels each role and shows only its eligible choice. These options add no points, and the existing 280/300-point copy tiers remain. Saved weapons apply before Deployment and cannot be changed during the match. See the [local source audit and bounded evidence](../verification/indomitor-saved-equipment.md).

### Crusader Squad saved equipment

The 10- and 20-model Crusader Squad uses source-role cards for its Sword Brother, Neophytes and Initiates. The Sword Brother can take a Hand Flamer; any Neophyte can switch to a Shotgun and Combat Knife; and Initiates can switch to a Heavy Bolt Pistol and Chainsword. For every ten models, up to two Initiates can instead select a Power Fist or Pyreblaster, combined. These options add no points. The catalog retains Wahapedia's 160/305 totals; MFM v1.0 lists 150/290, so event-cost certification remains open. Save the list before starting a match; saved weapons apply before Deployment and cannot be changed during that match. The Crusader movement rules also remain partial. See the [local source audit and bounded evidence](../verification/crusader-saved-equipment.md).

### Decimus Kill Team saved equipment

The Workshop supports the source-compatible ten-model Decimus composition. Its Gravis Veterans can each replace an Infernus Heavy Bolter with a Frag Cannon or Hellstorm Bolt Rifle plus Grenade Launcher; Heavy Veterans can replace a Heavy Thunder Hammer with a Power Weapon and Storm Shield; Stalker Veterans can replace a Stalker Bolt Rifle with a Plasma Incinerator. Each replacement is limited to one per five models, so the ten-model unit allows up to two of each. The Storm Shield's 4+ invulnerable save applies to its bearer. These choices add no points. The five-model row remains blocked because the source requires at least six roles, and the catalog's Wahapedia 210 points differ from the existing MFM v1.0 cross-check of 190. Save the army before the match; equipment is applied before Deployment and locked for that match. See the [local source audit and bounded evidence](../verification/decimus-saved-equipment.md).

### Fortis Kill Team saved equipment

For the fixed ten-model Fortis Kill Team, the Workshop saves each eligible replacement on its model card. The Castellan can select Superfrag, Superkrak or Vengor Launcher; the Sergeant's melee and ranged replacements have separate selectors; one of the two Deathwatch Bolt Rifle Intercessors can take an Astartes Grenade Launcher; and one of the two Plasma Incinerator Intercessors can take a Plasma Pistol. The Grenade Launcher is limited to one per five models, and only one Plasma Pistol can be selected per unit. These choices add no points, and the existing 210/225 copy prices remain. Save the army before the match; saved weapons apply before Deployment and cannot be changed during that match. See the [local source and bounded evidence](../verification/fortis-saved-equipment.md).

### Spectrus Kill Team saved equipment

For the fixed ten-model Spectrus Kill Team, the Workshop saves each replacement on the matching model card. Either Sniper Infiltrator can choose a Las Fusil or Instigator Bolt Carbine instead of its Bolt Sniper Rifle. Either Special-issue Infiltrator can replace its Combat Knife with the complete Deathwatch Bolt Carbine and Ceramite Fists package. One of the four Marksmen can replace its Deathwatch Marksman Bolt Carbine with a Helix Gauntlet. The two Occulus Infiltrators keep their fixed equipment. These choices add no points, and the existing 185/185/195 copy prices remain. Save the list before starting the match; saved weapons apply before Deployment and cannot be changed during that match. See the [local source and bounded evidence](../verification/spectrus-saved-equipment.md).
