# Saved-army matches

## Current scope

New training matches accept lists from the consolidated local Space Marines catalog. **Start tactical training** selects distinct Fire and Manoeuvre / Close Assault forces with current abilities and Gladius/Core stratagems. The general saved-list picker retains the 550-point mirror as its default and offers both tactical forces separately. Saved current-catalog lists can start a local match with their own unit count, up to 24 units per player. New match turns on implemented unit abilities for those lists. Both players need the same points category and limit. All use the list's own points ceiling; points and profiles come from the local catalog. Neither scenario certifies complete army legality. See [tactical training](tactical-training.md).

Historical lists, including Necron profiles and MFM-priced rosters, remain readable and editable as legacy drafts. They are not eligible for new matches through the current construction flow. This does not delete or migrate existing saves.

## Start a local match

1. Open **New match** from the title screen.
2. Choose a saved list for each player in **Local match • saved armies**. The current Space Marines practice list is selected by default for both players.
3. Review each list's admission result and points. The compact local precheck shows roster blockers and separate Quick Match/configured readiness. **Review readiness details** expands the selected options, ability gaps, chapter context and exact setup errors. **Open Army Workshop** appears when a roster or saved formation candidate blocks the match. These checks do not certify full army legality.
4. Choose **Quick Match** to use the selected lists, saved Warlords and Leader/Support assignments, implemented current unit abilities, standard terrain, and no optional mission or training modules. It skips the configured match options but still checks the current roster and formation rules, then prepares local visuals when enabled before entering deployment.
5. Choose **Start configured match** to use the current selections under **Advanced match options**. Both actions are blocked by invalid lists or stale/illegal saved formation candidates; the configured action also checks its selected mission and rules modules. The precheck is a local admission check for implemented rules, not a complete event-legality review.

A local match uses the equipment saved on each selected army copy. Intercessor, Assault Intercessor Sergeant, Heavy Intercessor, Eliminator, Outrider, Ravenwing Darkshroud, Land Speeder, Land Speeder Vengeance, Hellblaster Sergeant, Inceptor, Scout Squad, Invader ATV, Reiver Squad and supported Necrons choices are applied before Deployment and fixed for that match, so Army Preparation does not repeat those selections. Inceptor, Scout and Invader ATV weapon choices are stored independently for each model; Reiver Grav-chutes and Grapnel Launchers are stored per unit copy. The Invader ATV Multi-melta surcharge is included in the local points check. Older Scout lists without saved model equipment and older Reiver lists without an explicit gear record retain their existing match-setup choices. Edit a saved list before starting another match. Other supported preparation choices remain available where shown. Use **Save a copy of player …'s list to my profile** to create an editable copy; edits do not change the preset.

Saved Execrator, Phobos Lieutenant, Terminator Chaplain and Rapier Carrier equipment also transfers independently per model copy. The Execrator conditional weapon restriction and the Chaplain shield Wound adjustment are validated locally; no persistent weapon choice is repeated during readiness. See the [equipment migration evidence](../verification/character-artillery-saved-equipment.md).

## Start saved-list LAN training

1. Select the lists and review the training scope in **New match**.
2. Open **Play over LAN** and accept **LAN: accept partial training rules**. The existing Host and Join actions start saved-list training while this option is accepted.
3. Player 1 hosts and Player 2 joins. Each connected player chooses only their own list in the in-match **Choose your army** panel and explicitly selects **Submit my army list**. Lists selected on the New match screen are not submitted automatically. Saved Warlord and Leader/Support candidates travel as match-local unit/model coordinates; stable profile IDs and local visual data stay on the player's computer.
4. The panel reports which player has submitted and who is still waiting. The host admits both lists against its current local catalog, then rechecks saved formation candidates against the active rules before creating the frozen match setup. Unsaved or scenario-specific choices remain in Battle Readiness. A failed list or stale/illegal candidate stays in army selection and reports the host's validation reason.

The host-authoritative LAN path exists, but current Space Marine network validation remains deferred until final integration. Focused local checks cover formation reference mapping and match-side rule validation; they do not exercise a host/guest session. Local and loopback checks are not evidence of cross-machine validation.

## Models and data boundaries

Models are presentation only; they do not change rules, bases or eligibility. A local saved-army match stores a separate, validated snapshot of its local appearance references so later Army Builder edits do not change a reopened match. New matches created through the local New Match flow bind each saved copy to its canonical unit index in the frozen match roster, even when equipment grouping changes the order. Schema v3 snapshots preserve each model's Auto/Manual mode; schema v1 unbound and schema v2 copy-bound snapshots remain readable. Appearance data is stored separately from gameplay state and is not included in LAN roster traffic; each computer resolves its own visual links and cached files. Missing local assets keep the match playable with the existing fallback. See [model import](../data/forceorg-import.md), [construction catalog policy](../construction-catalog-policy.md) and the [support matrix](../project/support-matrix.md).

After admission and any optional visual preflight, local saved-match creation writes an initial recovery checkpoint before the first Deployment command. The checkpoint includes the frozen gameplay state and local appearance snapshot, so the match can be reopened even if the process stops during setup or Deployment. A focused regression confirms that later source-list edits do not alter the checkpoint and that a separate process resumes after one unit has committed during Deployment. Broader mission-dependent and LAN recovery remain under review.

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
