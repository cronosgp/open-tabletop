# Gameplay UI

The game opens on a dedicated title screen over the existing 3D battlefield. Its primary action is **Start guided match** when no compatible local save exists; a compatible save adds **Continue saved match**. **New match** opens the existing setup flow. Armies, Models, History and Tools remain available through secondary navigation. The Play tab remains the contextual action panel during combat.

## Title screen and combat HUD

The interface uses 1920×1080 as its layout reference while preserving the project's 1280×800 initial window. The title screen is a Godot UI composition over the local procedural battlefield and any already imported local miniatures; it adds no generated artwork or model files. At launch, the menu intercepts board input. In a local match it also blocks board interactions while open. In LAN, opening the local menu does not pause or change the match state for either player.

The combat HUD stays outside the scrolling sidebar. Its top bar shows round, phase, decision owner, current objective score and connection. The selected-unit card shows owner, living-model count, the selected model's wounds, defense profile, effective OC and Battle-shock state; movement distance or an active action appears when relevant. The panel under Play contains only the actions and choices applicable to the current phase or pending decision. Disabled choices retain the validator's explanation. Tutorial, glossary hover text and scope warnings remain available.

Full profiles, equipment, ability effects, mission state, raw dice and technical session data remain accessible through tooltips, the technical-details foldout, completed result details, dice tray and History. The attack forecast remains conditional and separate from resolved damage and recorded dice. The HUD only presents engine state; it does not alter validators, host authority or game state.

The **Return to title screen** action shows the same menu during a match. Its **Return to current match** action closes the local overlay. LAN continues while that overlay is open. Saved-match resume availability is computed by the normal save compatibility checks for configuration, rules/data pack, state structure and journal integrity; merely finding a save file does not enable Continue.

## Guided first session (D1)

**Entry:** Title screen → **Start guided match**. This starts a local 290-point sample that the new player controls for both sides. It selects the checked Space Marine and Necron starter lists, current e11 unit abilities, the selected CA mission and required checked-roster options. Automatic model downloads are turned off so the board opens with built-in visuals. The starters teach the interface and construction checks; they are not a full-match army legality certificate. The separate 930/880-point lists documented in [Track A A5](../project/track-a-a5.md) carry the scoped full-match certification.

| Moment | Player goal | In-game guidance and feedback |
|---|---|---|
| Mission setup | Resolve the selected mission's roll-offs and declarations | A gold guide card shows the numbered step, progress, immediate task, limits and hover definitions for terms such as roll-off and attacker/defender. The decision banner identifies the current choice and owner. |
| Army setup | Confirm required leaders, Warlords, Support assignments and reserve declarations | The guide names the required declarations and defines Leader, Warlord and Reserve. The next step stays gated until required choices are resolved. |
| Deployment | Place each unit and continue | The guide explains the marked zone and preview positions. The board shows placement and count; incomplete or invalid placement cannot be confirmed. |
| Movement | Select a friendly miniature, start a Normal move, reposition and confirm | The guide defines Normal move and confirmation, and states the boundary on legal movement. The decision banner and movement controls remain visible. |
| Shooting | Select a friendly unit, choose an eligible enemy, assign attacks and confirm | The guide defines eligible target and attack plan. Assignments are reviewed and validated before confirmation; the completed attack summary shows the result. |
| Completion | Continue the match or explore | The guide calls out the completed sample steps and offers continuing or exploring. It reiterates that the sample does not certify full army legality or every rule. |

The card uses a numbered header, progress bar, gold border, readable action/boundary text and muted-blue keyword chips with hover tooltips. It does not rely on color alone. It applies only to a local first-session sample, stays out of LAN setup and does not persist tutorial progress. Existing save/recovery behavior still applies to the match itself. A fresh launch or another match starts with the guide hidden until selected again.

## Contextual weapon glossary (D2 pilot)

During an attack plan, hover a weapon/profile row or the selected profile control to read concise explanations for the profile's listed, recognized weapon abilities. The target selector explains that its current choices passed the attack planner's checks; the Lethal Hits choice explains the automatic-wound trade-off. Hover a movement type to see its eligibility and consequences, including Advance, the two Fall Back modes and remaining stationary. The Begin and Confirm movement controls explain when positions are committed. Charge and Fight placement controls explain the 2D6 charge roll, selected targets, pile-in and consolidation limits. Hover the phase banner or progression control for the current phase's purpose and Core Rules section. In the supported Battle-shock and Command Re-roll windows, the unit, die, accept and stratagem controls explain their choices, CP cost and applicable limits. Disabled movement, contact, attack, defense and objective controls retain the validator's reason and add the applicable Core Rules reference where one is defined. Help names the relevant 11e Core Rules section and includes a link to the reference.

The pilot covers only the weapon abilities the attack engine currently recognizes, the seven turn parts shown by this build, core movement/charge/Fight placement choices, selected blocked-action groups and the supported core-stratagem decision windows. It explains the rule term but does not claim that every effect is active in every match: match options and the implementation scope still govern resolution. Missing glossary entries are called out explicitly. A complete unit-ability and faction-stratagem glossary remains future work; faction entries require a current official GW cross-check before certification.

**Rules boundary:** descriptions were checked against the June 2026 11th-edition Core Rules at [Wahapedia](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) and cross-checked against the [official Games Workshop Core Rules PDF](https://assets.warhammer-community.com/eng_01-06_warhammer40k_new40k_core_rules-was6fbu1ix-hfewhmxyiy.pdf). These summaries use §§01.07, 03, 04.01.03, 06.03, 07–12, 15.01–15.04 and 24.04–24.38 where applicable. No discrepancy was identified between the current 11e sources for this pilot. Older official 10e sources give Insane Bravery a different timing; those are superseded here and are not used. Faction-stratagem help remains outside this certification until its current source can be cross-checked. Later official updates may change the version boundary.

## Contextual actions

Play groups controls into Movement/coherency, Charge/contact placement, Attacks, Resolve attack/damage, Objective actions and Phase progression. Groups with no relevant controls are hidden.

During an attack draft only its group is displayed, including Confirm and Cancel. Pending movement, contact placement, coherency removal and attack/Hazardous allocation focus the corresponding group until that decision finishes. Other groups return after the pending decision is resolved. This changes presentation, not host validation or the rules protocol.

An unavailable action has a reason next to its group and on the disabled action's tooltip. Movement, attack planning, allocation and objective eligibility reuse rule validators. Charge/contact guidance follows the current eligibility checks. Completed exercises, missing peers and opponent-owned decisions identify the responsible state/player. Plan confirmation errors update as assignments change; a valid selection clears the old explanation. Available alternative actions in a group remain usable, for example declining Precision while no character is selected.

The **Direct Precision** button requires a selected character. A selection of -1 is reserved for the explicit **Do not use Precision** button, rather than accidentally accepting the decline through a button labeled as directing Precision.

## Validation and remaining work

Context guidance tests cover no/valid attacker selection, incomplete/complete plans, exclusive editing with cancellation, mandatory allocation, Precision decline, waiting for the opponent, movement selection and charge restrictions. The guidance does not change match state. Ten related local suites passed for this increment, and shooting/Precision guidance screens were rendered and inspected at 1280x800 on Windows. New separate-machine network and Linux checks were not performed.

## Compact selection card

Play now starts with a compact card: unit name and owner, living models in that unit, selected model wounds, T/Sv/InSv, morale/effective OC and assigned FNP. Movement remaining and an active Secure Ground action appear when relevant. No selection and destroyed selections are explicitly identified. Mixed defenses use the selected model's own profile.

**Show equipment and technical details** expands the existing equipment/profile list and technical state. The expansion choice survives ordinary refreshes and selection changes. Mandatory Precision/Hazardous/damage choices, eligible models, defensive group profiles and fight/contact/movement queues remain in a separate visible area, so collapsing details cannot hide them. Hazardous raw rolls remain in expanded technical details and completed combat history.

Six local suites passed for the card increment (selection card, action guidance, gameplay layout, allocation practice, local models and cache lookup). The selected mixed-profile/FNP card and collapsed Precision view were rendered and visually inspected at 1280x800. No new network/Linux validation was performed.

## Guided attack and defense flow

Attack editing presents four steps: select a living model from the attacking unit; choose its weapon/profile, target and any fixed melee count; assign and repeat; review and confirm to roll dice. The review names the selected model/unit, counts assignments and distinct target units, and lists the resolution order from the first assignment to each target. Cancel discards the local draft. Weapon and target dropdowns preserve their selections on refresh and do not expand the sidebar to fit long names.

Pending Precision, defensive group order, damage and Hazardous choices show stage-specific instructions and the responsible player. An eligible-model dropdown names the unit, model ID and remaining wounds. Selecting an item only changes board selection; the existing confirm button applies the decision through host validation. Returning to the prompt clears selection without declining Precision. The explicit decline button remains available for Precision; other required choices cannot be cancelled. Opponent-owned choices disable the picker locally. No save/damage rolls are exposed ahead of the existing rules sequence.

Six local suites passed for this increment: guided attacks, contextual action guidance, selection card, allocation practice, attack plans and mixed defenders. Tests check draft review without state changes, correct/incorrect model selection, named eligible choices, explicit confirmation, prompt reset, save timing guidance, opponent ownership and stale panel hiding. Planner and Precision screens were visually inspected at 1280x800. Network/Linux were not newly verified.

## Results and history

The latest local/host notice appears before the selection card and action controls. It is separate from the completed-result summary and historical events; a notice is not proof that an entire attack has finished.

The always-visible resolved line shows the latest outcome and total damage applied. Hover it for the complete result by target, including attacks, destroyed models, FNP and excess damage. Raw dice stay in the collapsed **Show resolved dice and full result** tray or the detailed **Show combat history and dice** panel. Hazardous wounds lost by the attacker, prevented wounds and unallocated discarded wounds remain separate from defending-target losses. During another pending attack the previous result is identified as previous; partial pending pools are not summarized as complete.

**Show combat history and dice** expands the existing detailed log. It starts collapsed, preserves expansion across refreshes, and preserves the reader's scroll position when history content has not changed. New history content still scrolls to the latest entries. Controls/help text follows the result/history area rather than interrupting the summary.

Six local suites passed for this increment: combat results UI, guided attacks, selection card, action guidance, gameplay layout and allocation practice. New checks cover real attack completion, damage/prevention/excess separation, raw dice visibility, pending versus completed results, separate Hazardous totals, expansion, scroll preservation and hiding obsolete results in preview mode. Summary and expanded-history screens were rendered and inspected at 1280x800. No new network/Linux validation was performed.

## Track D3 presentation pilot

The board can show an optional compact Wounds bar above each living model, with current/maximum Wounds and the selected model's effective OC, Battle-shocked and movement state. The bar color is accompanied by exact numbers, and the toggle tooltip spells out its green/amber/red thresholds; color is not the only signal. The toggle hides these tags when the board is crowded. During an attack draft, the UI uses the same prepared attack batches as the resolver to show each pool's damage range if every declared attack becomes one unsaved wound. It labels this as a conditional scenario, before saves and prevention; critical or extra hits, failed hits/wounds, saves and damage prevention can change the result. It is not a probability estimate or a rules outcome.

After a completed attack, up to 72 labeled tiles sit in a dark, bordered dice tray and show attack-count, hit, wound, save, damage, Hazardous and prevention dice. Each tile includes drawn D6 pips; the number and roll stage remain in text. Random characteristics show the underlying D6 faces and the resolver's converted attack/damage result separately. New result tiles can briefly tumble into place, with an **Animate new dice results** toggle to disable the motion. The animation reveals only the final values already resolved by the host; it never rolls separate visual dice. Final hit and wound faces show hit/wound, miss/fail or critical with a symbol, shape and color; replaced faces are omitted from this compact view but remain in the full recorded history. Save, attack-count, damage, Hazardous and prevention dice are not yet classified as success/failure. The selected model's overhead label adds OC, Battle-shock and movement cues; other models show wounds only. The presentation does not add random outcomes or alter host resolution.

The dice panel identifies whether results came from the local engine or LAN host, and shows the latest history entry containing recorded D6 plus a shortened current hash-chain tip. The History tab also shows that chain tip, so the recorded sequence and dice can be inspected together. Tooltips expose the full tip and explain the boundary: loading a matching save verifies its committed journal prefix against record hashes and the saved state, which helps detect changes to that history. This is not an independent proof that the host RNG was fair or unpredictable; the host remains authoritative. A LAN client is directed to the host's match history rather than being shown a local chain it does not possess.

**Rules boundary:** hit and wound labels reuse the attack resolver's final dice and thresholds. Snap-shooting sixes are shown as hits, not critical hits, in line with the current 11e Core Rules. The pilot only labels critical thresholds currently represented by the resolver; special critical thresholds not implemented by the selected profile mechanics remain outside this display. These labels were checked against June 2026 11e Core Rules §§05.01–05.02 and Snap Shooting §15.09 at [Wahapedia](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) and cross-checked against the [official Games Workshop Core Rules PDF](https://assets.warhammer-community.com/eng_01-06_warhammer40k_new40k_core_rules-was6fbu1ix-hfewhmxyiy.pdf). This is presentation of the supported match engine's results, not a separate legality claim.

## Redesign verification

Godot rendered the title screen and combat HUD from the actual main scene at 1280×800 and 1920×1080. The viewport captures were visually inspected for clipping, panel fit and board visibility. The focused gameplay-layout, selection-card and combat-results UI suites passed after the redesign. They cover the title-screen resume fallback, overlay state preservation, compact selected-model data and collapsed raw dice. No full host/guest network session was run for this change; the LAN overlay check uses the client UI state without connecting another machine.

Core-rules work and broader host/guest/rejoin validation remain on the overall roadmap.

## Play HUD and Army Workshop

The Play tab keeps round/phase, decision owner, objective score and connection in the fixed top strip. The selected unit/model summary now sits in a bordered compact card; phase actions stay contextual, while attack forecasts remain conditional and resolved damage/dice remain separate. The tab stays narrow enough to keep the board visible.

Armies opens a profile-scoped library with points, unit count and a selected roster detail. Editing opens as a focused view with unit composition, copies and per-miniature visual choices. A visual assignment is saved in the local army profile; the rules admission path constructs a canonical selection from rule fields only, so appearance data does not enter match state or LAN snapshots. Changing a unit's model count clears its saved points until recalculated. Saving a planned list does not claim official army legality.

The **Download unit models** action filters the scanned ForceOrg/TTS catalog to compatible complete OBJ variants for the selected unit and downloads missing variants to the local model cache. Each miniature can use a different downloaded variant. Unsupported formats, missing URLs or failed downloads keep that slot on its default miniature and report the reason/status. Existing global unit visuals remain the fallback. Imported assets and file paths remain in local settings/cache; no model is added to the repository.

The library shows the active local profile only. Existing saved armies remain readable without appearance fields; their empty visual slots are initialized when edited. The saved roster schema does not require a version migration because visual variant IDs are optional local presentation fields and admission strips them before match setup.

This increment's focused UI and local-model tests were added but could not be run in the editing environment because no Godot executable or active Godot window was available. Therefore fresh live captures at 1280×800 and 1920×1080 are still pending; earlier captures documented above predate the Army Workshop changes.

## D4 camera focus pilot

The combat HUD offers **Focus** when a miniature is selected. Clicking it or pressing **F** eases the local camera toward the center of that miniature's visible unit. It uses the board positions already presented in the scene, keeps the current camera height, angle and zoom, and does not move models or submit a match action. Players can continue to orbit, pan and zoom normally. The button is disabled without a visible selection. Automatic framing around the active decision and projectile tracers remain future D4 work; this pilot has not been runtime-tested or captured yet.

With **Animate board feedback** enabled in Play, state changes can briefly ease a unit's models to their new positions, float a wound delta above a damaged or restored model, or mark a destroyed model as **OUT**. The toggle disables these presentation effects. Cues are derived from the resolved model state and do not perform dice rolls. Projectiles and attack impact flashes are not included yet. This increment has not been run in Godot; movement previews, reanimation, repeated damage and short-window readability still need live review.
