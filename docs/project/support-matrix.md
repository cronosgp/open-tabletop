# Current support matrix

Updated 24 October 2026. This matrix describes implemented and admitted scope; it is not a claim that the whole edition or every selectable profile is fully supported. See the [roadmap](roadmap.md) for next work and [verification results](../verification/verification-results.md) for evidence.

**Tactical UX candidate:** guided training now enables defender selection through its existing allocation path. The UI Keep action submits no replacement die, and presentation changes expose decisions, placement errors and recorded combat stages. Local presentation checks, bounded mirror/tactical loopback and PCK smoke passed within their recorded scope. These changes do not broaden rule eligibility; new human acceptance remains pending. See the [experience progress report](tactical-training-experience-progress.md).

**Rules/data source:** Wahapedia `/wh40k11ed/` is the definitive project reference. New army construction choices come only from the consolidated local runtime catalog. Final integration has started for the bounded training profile; network validation for broader current Marine scope remains pending. See [source assessment](../data/source-assessment.md) and [construction catalog policy](../construction-catalog-policy.md).

**Command doctrine UI follow-up:** free Strategic Acumen and paid Adaptive Strategy now use separate action/unit/doctrine selectors, with cost, effect, duration and an already-active warning. Local button checks and actual 1280×800/1024×768 captures are recorded in the experience progress report. This changes presentation only; existing rule limits and the open human acceptance gate remain.

| Area | Available | Remaining / limit |
|---|---|---|
| Offline startup | Project-owned movement demo; local two-list setup; offline preparation and exercises | Bundled broad current-edition army content |
| Combat | Movement, morale, shooting, charge, alternating fights, attack planning, defender allocation and selected weapon/unit abilities | Arbitrary armies and every core/faction interaction |
| Phase progression | Command, Movement, Shooting, Charge and Fight; normalized decisions and persisted frames for selected phase-close, pre-dice attack declarations/reactions and damage allocation, Movement, Charge, unengaged Fight/Bladeguard choices, Fight-contact placement, reserve/Rapid Ingress, Repulsor Combat Embarkation, normal Transport disembarkation, multi-passenger Drop Pod Assault, phase-start and reaction workflows; Command healing retains its phase-close frame across normalized Narthecium selection, rejects a premature close without mutation, survives serialization through healing confirmation and resumes after opponent end-phase choices; End-of-Turn coherency and Desperate Escape mortal-wound choices use stable decision and option IDs with rule-derived eligible models; Desperate Escape suspends the Movement frame through every required wound allocation and resumes the same frame for placement; post-movement Cato Sicarius, Combi-weapon Lieutenant Evade and Survive, deferred Techmarine Blessings, Responsive Tactics/Masterful Tactics/Hunter’s Instincts responses, and pre-move Mobile stratagem choices retain the relevant Movement frame; Flawless Riders retains its Charge declaration frame while the selected move resumes; selected post-attack Tactical Fluidity, Purgation Run, Glory of Ultramar and Invictor mark-replacement decisions retain the attack frame through response and placement; Vengeful Stars and Hail of Vengeance use normalized post-attack choices and persisted Shooting-reaction frames, with attack admission limited to the decision owner's bound reactive shooter; both paths resolve reactive attacks through the public Shooting command; Hail is checked from an actual model destruction through normalized defender allocation and retaliatory fire, while Vengeful is checked from a public Captain attack-plan, defender allocation that destroys the last Immortal, Overlord choice and retaliatory fire against the destroying Marine unit; Vengeful's nested defender save-roll decision and attack/reaction frames survive serialization; supported Undying Legions choices retain the attack frame through the defender's Reanimation reroll and return placement, then complete without advancing the phase; End-of-Turn casualties suspend one phase-close frame across both players' choices and resume it when coherency is restored; child frames require a suspended parent, and command admission blocks raw pending action/transport state, malformed UnitActions windows or unrecognized window kinds, and malformed Movement, Charge, contact, damage-allocation, Hazardous or Deadly Demise records before deriving decisions; phase close also validates its UnitActions container and transport window before reading either; a shared pending-state type guard rejects malformed decision containers before actor/UI projection, command dispatch, local save/resume or host snapshot acceptance; no-choice phase close completes its temporary frame, and opponent Rapid Ingress opens only when an eligible reserve arrival option exists; attack-allocation and unit-choice dispatchers reject unrelated work when Deadly Demise lacks its choice projection; unprojected choices also pass pending-work and frame admission; unrelated commands stop during active frames while matching Movement/Charge/Fight-contact continuations and validated Overwatch/Heroic Intervention phase-close continuations remain admitted; pending Deadly Demise also blocks without its choice projection | Shared action/frame lifecycle and phase-close coverage across all supported pending workflows; a generic trigger registry remains deferred until a source-checked timing needs it; see [phase/action/decision flow](../architecture/phase-action-decision-flow.md) |
| Unit catalog | All 85 shared-book Space Marine identities, including Wardens of Ultramar, are represented in the local Wahapedia e11 catalog and pass the local construction publication gate | Catalog selection does not imply complete rules, options, interactions or faction legality; four Necron profiles remain outside this Marine catalog |
| Marine rules | Local profile, combat, construction and materialization checks for bounded admitted increments. Tempered in Battle is admitted for eligible Astartes bearers under Wrath of the Rock; its Command Battle-shock fallback without Core Stratagems, Desperate Escape, Fearsome Assault and Adamantine Terror Leadership decisions suspend, serialize, block phase close and resume after the choice; the no-Core fallback and supported Core Stratagem command/escape Battle-shock accept and re-roll choices use normalized command validation. Prepared matches support independent per-player detachment assignments. Local checks also cover Vanguard Ambushers, the three Ironstorm stratagems, selected Spearpoint and Flawless Riders effects, and source-to-defender flow for supported mortal-wound triggers. | Remaining options, combinations and shared interactions are incomplete; network validation and full faction/army legality remain uncertified. |
| Other factions | Four retained Necron training/reference profiles and their bounded mechanics | Consolidation/admission into the current construction catalog and broader faction completeness |
| Army construction | Local catalog choices, declared sizes/prices, saved drafts and bounded admission checks | General-purpose legal-list validation, all duplicate/attachment/equipment/detachment rules and all factions |
| Mission | Selected CA 2026-27 Battlefield Dominance / Hammer and Anvil profile with fixed secondaries, preparation, scoring and five-round result; separate custom training scenario | Other mission/deck/layout configurations and full match certification with current faction scope |
| Stratagems and reactions | Documented Command Re-roll windows, Fire Overwatch, Heroic Intervention, Counteroffensive, Epic Challenge, Insane Bravery and selected faction cards within their profile gates | Other cards and timings; exact options remain capability- and profile-gated |
| Battlefield | Shared ground-level board, selected deployment/terrain geometry and objective layout | Upper floors, complete vertical movement, exact imported-mesh visibility and player battlefield editor |
| Multiplayer | Authoritative host, LAN/direct address, snapshots, seat credentials and existing host-restart recovery paths; the focused current-reference and tactical loopback pairs now pass setup, deployment, pending Fire Overwatch recovery, synchronized ranged combat and final-state checks. The latest isolated current-reference/tactical re-audit passed **6/6 processes** at `.tools/verification/20261024T075949863687Z/results.json`, explicitly checking the tactical experiment metadata at admission, guest rejoin, host save and completed-match checkpoints. The complete local demo profile passed both loopback roles at `.tools/verification/20261024T080319927934Z/results.json` (13/13, `network: true`, `legacy_starter_staged: false`); the earlier isolated network replay passed 4/4 at `.tools/verification/20261024T044319660501Z/results.json`. The selected current logs contain no cleanup diagnostics after the UI ownership, title fallback and Command-panel cue fixes. | Separate-machine LAN evidence, pending-decision recovery between separate machines, broader current Marine validation and negotiation remain. Historical UI-heavy roles still need individual lifecycle audits. |
| Persistence | Versioned snapshots, atomic replace/checksum, autosave, local/LAN resume, RNG continuation and hash-chained event/dice journal with verified reconstruction | Visual replay, multiple slots, journal compaction and cross-version migration |
| Models | Local mapping/preview and explicit ForceOrg/TTS visual import/download workflows | Broader formats, composite assembly and per-model variants; visuals never determine rules geometry |
| Delivery | Offline verification runner, CI definition and demo export presets; the latest data-free demo baseline passed 13/13 locally with loopback in `.tools/verification/20261024T080319927934Z/results.json`; the current demo PCK passed import, clean-tree tactical smoke, export, startup, title/guide assertions and exported-pack tactical smoke in `.tools/verification/build-20261024T080456779917Z/results.json`. CI now passes an explicit 300-second process budget for the demo, tactical and export steps | Remote CI rerun on the corrected revision, native Windows/Linux builds requiring matching 4.7.2 export templates, and supported cross-platform match validation |

## Evidence levels

**Tactical training increment:** the initial local action now selects Fire and Manoeuvre versus Close Assault, with Gladius and current abilities/Core stratagems enabled, catalog-derived totals and a side-swap control. The title summary names the four practice opportunities before launch; Guided Help then adds four phase-labelled optional experiments covering leader abilities, CP stratagems, plasma/Hazardous and Bladeguard stance decisions without forcing a tutorial sequence. Help and the open Command panel mark `READY NOW` only when the current legal choice projection exposes a leader ability, CP stratagem or Bladeguard stance; they do not grant actions or CP. An incompatible saved match now receives an actionable title-screen fallback while the exact technical cause remains in the tooltip, and the first valid primary action receives keyboard/gamepad focus. The old mirror remains selectable. This new scenario has separate evidence requirements; prior mirror loopback results do not validate it. See [configuration and boundaries](../guides/tactical-training.md).

Its focused local suites now cover five-round progression, paid Adaptive Strategy, pending-decision save/load, standard/supercharged plasma with Hazardous allocation, a declared and placed charge, Bladeguard stance serialization/admission and both engaged units' melee attacks through Fight completion. The combat regression uses controlled test dice after real public setup/deployment/movement. The focused host/client loopback now passes both the 550-point mirror and the asymmetric tactical profile, including deployment and pending Fire Overwatch recovery, synchronized ranged combat, invalid guest-command rejection and matching canonical final state hashes; the current tracker audit also verifies the tactical experiment metadata survives host/client checkpoints. This does not establish separate-machine LAN, network coverage of every local combat interaction, competitive balance or army legality. See the training guide for exact reports and later validation limits.

The latest focused tactical workflow passed **4/4 processes** at `.tools/verification/20261024T075744731933Z/results.json` (`network: false`, `legacy_starter_staged: false`); it includes the persisted experiment checklist starting at 0/4, the `DONE = observed • OPEN = available` legend, real Captain ability and accepted Bladeguard stance markers, a completed stratagem marker after the live paid choice, a save/resume assertion for that marker, and standard/supercharged plasma plus Hazardous markers after real attack resolution. The focused cue regression passed **3/3** at `.tools/verification/20261024T060132409617Z/results.json`; the latest targeted UI/layout gate passed **5/5** at `.tools/verification/20261024T064117338648Z/results.json`. These cover separate Leader, CP, combined and Bladeguard opportunity assertions, the phase-labelled experiment list, current-window cue, absence of a false `READY NOW` during preparation, the live legal-opportunity cue in Help and the open Command panel, coherency continuation, incompatible-save recovery copy, primary-action focus and the integrated tactical combat flow. Actual Godot/OpenGL title, Help and Command-panel captures were regenerated and inspected at 1280×800 and 1024×768; `.tools/tactical-command-cue-1280.png`, `.tools/tactical-command-cue-1024.png`, `.tools/tactical-bladeguard-1280.png` and `.tools/tactical-bladeguard-1024.png` show the cue in the normal action flow, while the compact list fits both. These are rendered-layout and local workflow evidence only; human comprehension, remote CI, native builds and separate-machine LAN remain open.

The historical cleanup audit was refreshed on the same revision: `test_stratagems`, `test_combat_doctrines` and `test_current_unit_abilities` passed together with no RID/ObjectDB diagnostics in `.tools/verification/20261024T052827480848Z/results.json`. This narrows the cleanup concern for those exact suites; it does not clear the remaining historical UI-heavy roles or change the current-catalog evidence boundary.

Keep these distinct when describing a feature:

1. **Catalogued:** identity and source metadata exist.
2. **Implemented:** the host/runtime enforces the bounded behavior.
3. **Locally validated:** focused local cases passed for the stated scope.
4. **Network validated:** host/guest, stale/duplicate commands and recovery passed for that scope.
5. **Certified:** named lists, mission, battlefield, options and version boundary were reviewed together.

Headless checks, loopback host/client, graphical review, separate-machine LAN, Windows/Linux interoperability and native export are separate forms of evidence. A pass at one level does not imply another.

Latest recovery result (23 October): `.tools/verification/20261023T225711261053Z/results.json` passed import, Python checks and all four host/client processes without test-only tracing. The current-reference pair finished at revision 135 with 550 points per side, score 5–0 and matching canonical hash `aa9107e190eb1a0417217e0be6f541018a80c7c8339d35c4ae280136a0d46d4f`; the tactical pair finished at revision 139 with 290/235 points, score 0–0 and matching canonical hash `e0688daa3a9ec54c00caa1a8993c4459bae67b27bfc5444d555493e779589f85`. Headless renderer cleanup diagnostics remain in the raw role logs, but no lifecycle assertion failed. Loopback is now repeatable evidence for these bounded profiles; separate-machine LAN and broader rules coverage remain open. See the training checkpoint for reports and current limits.

**Recent A2 local evidence:** Suboden Khan’s Wrath of the First Khan, Stormlance Wind-Swift Evasion, Spearpoint Withdraw and Regroup, Parabolic Jetleap, Echo of the Ravenspire, end-of-Fight Tactical Fluidity, Resurrection Orb, Eternal Revenant and Undying Legions are exercised through normalized choices and persisted continuations. Suboden transitions to End-of-Turn coherency; Wind-Swift returns after placement; reserve choices survive save/restore; Tactical Fluidity keeps its frame through Fall Back placement; Orb Reanimation preserves phase-close timing; Eternal Revenant restores remaining end choices; Undying Legions holds the attack frame through defender-owned Reanimation without advancing the phase. Other pending workflows remain under audit.

**Public command boundary evidence:** The tested mission-preparation and roster declaration steps submit exact projected options through `MatchCommandService`. `Protocol of the Hungry Void` admits its eligible Necron owner during the opponent's Fight actor window only for the current legal option; wrong-owner and stale-revision submissions leave state unchanged. This is bounded local command-admission evidence, not LAN validation or broader Necron rules support.

**Desperate Escape command evidence:** The tested hazard re-roll/accept reaction and mortal-wound allocation submit current normalized options through `MatchCommandService`. Wrong-owner, stale-option and resolved-decision replay commands leave state unchanged; the suspended Movement continuation remains active across multiple allocations and resumes after the last wound. This is local workflow evidence for the exercised escape path.

**Terminator Chaplain preparation evidence:** Relic Shield/bolter loadout, standalone Deep Strike reserve and attached Chaplain/Terminator reserve declarations use their projected public setup choices. The tested reserve path rejects the wrong owner and stale option, enforces the half-points limit and accepts the combined reserve cost when eligible.

**Aggressor preparation evidence:** Whole-unit alternate loadout selection and restoration use projected public setup commands; wrong-owner and stale-option submissions are rejected unchanged, and the chosen weapon package remains available to the later attack plan.

**Ancient loadout evidence:** Both Ancient equipment combinations submit through the projected public setup command; wrong-owner and stale-option requests are rejected unchanged before the selected melee/ranged weapon sets are checked.

**Current Captain loadout evidence:** Ranged upgrades, the independent Power Fist choice and default restoration submit through projected public setup commands. Wrong-owner and stale-option requests are rejected unchanged; the tested weapon profiles and wound effect stay tied to the selected loadout.

**Emergency transport evidence:** A destroyed transport's Emergency Disembark exposes passenger-owned Hazard allocation followed by active-player placement through normalized UnitActions commands. The suspended attack and decision identity survive save/restore; phase close remains blocked until passenger setup completes, then the original attack continuation resumes. This is a bounded local path, not complete transport or Deadly Demise coverage.

**Normal transport evidence:** Rapid Disembark's no-Hazard placement step exposes a normalized owner decision, preserves its transport frame and decision identity through save/restore, blocks phase close, and completes through normalized model placement and confirmation. Hazard allocation and other transport variants remain covered only to the limits stated in their focused tests.

**Drop Pod Assault evidence:** Rapid Ingress declaration, preview and confirmation use `MatchCommandService`; mandatory passenger choices use normalized UnitActions commands through sequential disembarkation. The decision and nested continuation survive save/restore; the same Drop Pod frame resumes for the next passenger and closes with its ingress parent after the last confirmation. This is local workflow evidence for the exercised two-passenger case.

**Ironstorm Headhunter evidence:** A public Vehicle attack declaration opens the normalized owner decision before dice. The focused path checks wrong-owner rejection without mutation, save/restore identity, Shooting close blocking, both stratagem use and pass, then completes the attack and its local reroll choices. This is continuation evidence for the exercised attack, not certification of all Ironstorm rules interactions.

**Cato movement-reaction evidence:** Knight Champion's post-movement use, model placement and confirmation now use normalized UnitActions choices. The completed Movement frame persists through placement, wrong-owner submission is rejected without mutation, and confirmation completes the frame. This is local continuation evidence for the tested reaction path.

**Other post-movement response evidence:** The Combi-weapon Lieutenant's Evade and Survive use, decline, placement and confirmation, plus Techmarine Blessings start/defer/end choices, now use normalized UnitActions commands. Their Movement continuation is retained through the exercised response paths; the Evade case also preserves a pre-existing decision.

**Tactical Fluidity evidence:** Wind-Swift Evasion's post-Fight Normal Move confirmation and Fall Back placement and confirmation now use normalized UnitActions commands. This adds command-path evidence to the selected placement continuations; it does not broaden Stormlance rules coverage.

**Post-attack response evidence:** Invictor Forward Assault mark replacement and Victrix Glory of Ultramar's Surge move now use normalized choices. The exercised replacement retains the attack frame through save/restore and resumes the attack after selecting the new mark; this does not establish broader Invictor or Victrix support.

**Purgation Run evidence:** A public Land Speeder attack-plan opens the response; normalized use, placement and confirmation retain the attack frame through save/restore and complete the Normal Move. This is bounded local evidence for that Land Speeder workflow.

**Captain Phobos Tactical Fluidity evidence:** The post-shot D6 choice and Normal Move placement/confirmation use normalized commands. The workflow rejects opponent commands without mutation, preserves the attack-frame continuation through save/restore, and blocks phase close until placement completes. The end-of-Fight Fall Back path remains covered separately.

**Attack reroll evidence:** Power of the Machine Spirit and Ironstorm Auto-targeters Hit/Wound reroll and decline choices use normalized UnitActions commands. The exercised Machine Spirit choice retains its decision identity through save/restore, rejects the opponent without mutation and blocks phase close while the attack is pending. Other attack-roll windows remain covered only by their respective focused evidence.

**Command Re-roll evidence:** The Hit/Wound attack reaction test now submits accept/reroll through the same normalized stratagem envelope as the UI and checks save/restore identity, invalid owner/revision/die/RNG rejection, CP use and attack-frame resumption. This remains isolated attack-roll coverage.

**Fight activation choice evidence:** Captain Titus's Righteous Fury enters through `MatchCommandService`; the opponent's submission is rejected without mutation, and the accepted choice activates the ability once. It resolves immediately within the Fight activation.

Captain Phobos's Command Doctrine and Strategic Acumen choices also use the command service in the tested start-of-Command path, including passing the remaining window before the next phase-specific checks.

**Repulsor Charge reaction evidence:** Combat Embarkation choices pass through the normalized defender decision. The charging player is rejected without mutation, Charge close stays blocked while the response is pending, and pass/embark both resume target selection.

**Bladeguard Fight evidence:** The attacker and defender stances and decline choices use normalized UnitActions decisions before dice. The pending attack resumes with the selected stance modifiers, and decline preserves the stance for a later legal trigger.

**Apothecary healing evidence:** Narthecium selection and healing-order decisions use normalized commands, including allocation, returned-model placement, reset and confirmation. The Command-close frame survives save/restore and resumes after the end-phase pass.

**Implacable Eradication evidence:** The attack's free Hit/Wound reroll and continue choices use normalized decisions. The defender decision survives save/restore, rejects the attacker without mutation, prevents a second reroll, and resumes attack resolution.

The second Implacable wound-reroll attempt now reuses its original decision and option IDs through `MatchCommandService`; the stale envelope is rejected without mutation.

**Responsive Tactics evidence:** Activation, placement cancel and post-move decline use normalized UnitActions decisions. Cancel returns to the same response window, and the Movement frame completes after the final pass.

**Pre-battle Scout evidence:** Scout move and Strategic Reserves set-up declaration, model previews and confirmation use normalized commands for the Scout Squad and standalone Phobos Librarian cases. The checks retain movement/deployment bounds and automatic advancement to `start_turn` after the final queued choice.

**Strategium Command evidence:** The Wardens' post-deployment Strategium selection and reserve declaration now use the public command service. The opposing player is rejected without mutation, and the authorized selection continues through reserve placement before Scouts begin.

**Shared UnitActions command evidence:** Current-unit-abilities, preparation and unit-ability regressions submit player choices through the public command service. My Will Be Done's discount is projected in the pending Core Stratagem reaction and resolves through normalized `COMMAND_REACTION`; wrong-owner, stale-revision and stale-option requests leave state unchanged, and Insane Bravery spends the discount without CP. Deployment-time UnitActions decisions now take priority from the currently deploying unit's owner; Vulkan's Seeker of the Unfound regression verifies normalized ownership, save/restore identity and invalid submissions. Rule tests have no remaining direct `UnitActions.apply`, `Combat.unit_action` or `C.unit_action` calls. All ten registered pending-decision source families have a public command path and focused regression; contextual scan references exist for all 53 admitted UnitActions window kinds. The bounded local A2 continuation audit now maps all eight frame families; **no known command-route or continuation gaps remain in that scope**. This does not certify every rules interaction or network behavior. See the [A2 audit](../verification/a2-pending-workflow-audit.md).

The detachment-stratagem regression now submits a choice through normalized `SELECT_UNIT_CHOICE` whenever the current pending projection includes it; immediate choices without a projection remain on their direct domain path.

**Command Re-roll evidence:** The saved Movement and Charge reactions submit through normalized `COMMAND_REACTION` after decision/frame serialization. Advance placement and Charge target selection resume from the original frame, while accepting or rerolling preserves the expected dice and CP costs.

The Eradicator Melta damage decision now submits both the optional reroll and keep result through normalized `SELECT_UNIT_CHOICE`; the attack applies the full Melta-adjusted damage roll and discards excess damage as required by the existing attack resolution.

Chief Librarian Tigurius's eligible Warlord declaration now also uses `MatchCommandService`; the opponent is rejected without mutation before the authorized owner records the choice.

Kayvaan Shrike's Warlord declaration uses its projected UnitActions decision envelope; the opponent is rejected without mutation before the authorized player records the Warlord.

Caanok Var's immediate Cold and Calculating Lethal Hits and Sustained Hits selections now use `SELECT_UNIT_CHOICE`; the opponent is rejected without mutation on the Shooting-phase choice.

Tor Garadon's immediate Signum Array target selection uses raw public `SELECT_UNIT_CHOICE` because it has no persisted projection. The opponent is rejected without mutation, and the selected enemy loses cover for the Shooting phase.

The Marine ability-boundary regression now submits projected trigger choices through their decision envelope and immediate Strategic Acumen, Demi-company Commander and Finest Hour choices through raw public `SELECT_UNIT_CHOICE`.

**Selected ability-window evidence:** Darnath Lysander's phase-start Rampart, Hailstrike's post-shot mark and Thunderstrike's Shattered Defences mark use normalized decisions and reject the opponent without state changes. The post-shot effects apply only to eligible hit targets; the completed attack does not remain suspended for these choices.

**Incursor post-shot evidence:** Divinator-class Auspexes now submits its projected scan through `MatchCommandService`; the other player is rejected without mutation, and the authorized scan marks the selected target before the same shooting declaration resumes.

The Phobos Librarian's immediate Soul Sight choice also submits through `MatchCommandService`. Because it is not persisted as a pending decision, the command uses the raw current choice and still rejects the non-active player without mutation; the separate Shrouding reaction keeps its normalized decision envelope.

**Captain Strategic Acumen evidence:** The current-reference Captain's immediate Command-phase choice passes through `MatchCommandService` and rejects the opposing player without mutation. This action is not held as a pending decision in the exercised path.

The Terminator Captain's immediate Strategic Acumen selection also uses public `SELECT_UNIT_CHOICE`; the opponent is rejected without mutation before the owner selects the doctrine.

The Phobos Lieutenant test now submits the immediate Captain Strategic Acumen selection and the resulting persisted Demi-company Commander reaction through `MatchCommandService`; the opposing player cannot submit the immediate choice.

The Chaplain attachment during deployment uses its projected UnitActions envelope; the opposing player is rejected without mutation, then the owner attaches the Chaplain to the source-listed bodyguard.

The Judiciar's conditional Support attachment also uses a projected UnitActions command and rejects the opponent without mutation before attaching to the allowed bodyguard.

Both Ancient and Bladeguard Ancient Support declarations now submit through projected UnitActions commands; opponent attempts are rejected without mutation and the Support role remains distinct from the Leader slot.

**Banner of Macragge evidence:** Victrix's Fight activation submits its projected UnitActions option through the public command service; opponent ownership is rejected without mutation and the once-per-army effect is checked.

**Driven from Cover and Adamantine Terror evidence:** The mandatory Infernus post-shot hit mark blocks phase close until the owner selects one eligible target; opponent submissions are rejected. Adamantine Terror resolves sequential Tempered in Battle results under the target controller's normalized decisions, with decision identity restored between results.

**Command Reanimation end-window evidence:** After healing, the remaining owner's pass is validated against its normalized projection; the opponent is rejected without mutation, and phase close resumes only after the authorized pass.

**Phobos Shrouding evidence:** The defender's pre-dice reaction uses the normalized decision envelope. The attacker cannot submit it, phase close remains blocked, and the same serialized attack declaration resumes after the psychic choice.

**Feirros repair evidence:** Master of the Forge's pre-move defer and post-move vehicle repair use normalized UnitActions decisions; the opponent is rejected without mutation at each choice.

**Chaplain start-window evidence:** Spiritual Leader is submitted through the normalized phase-start decision projection; wrong-player submissions are rejected and the authorized choice clears Battle-shock without spending CP.

**Additional normalized-choice evidence:** Smokescreen activation and pass, Firestrike Servo-turrets' extra Fire Overwatch, Eliminator Optics selection/cancellation, Infiltrator Omni-Scramblers, Teleport Homer start-of-battle choices, Chapter Approved mission preparation/deployment/turn-order choices, and Gladiator Lancer Aquilon hit/wound rerolls now exercise the public command service. Foreign owners and stale revisions are rejected in the relevant flows. A completed deployment can retain its exhausted order index while first-turn CP and phase progression continue; this verifies these bounded paths, not all unit actions or profile legality.

**Additional public-command evidence:** Chaplain Spiritual Leader stale-revision rejection, Chaplain on Bike Catechism target selection and no-doctrine preparation choice, and the Core Epic Challenge immediate Fight choice now use `MatchCommandService`. The Catechism test rejects a non-priority player without mutation. These checks exercise the named choices only; Epic Challenge is an immediate command path rather than a persisted pending decision.

**Decision rejection evidence:** Apothecary Narthecium confirmation and Bladeguard attacker stance now exercise public-command rejection for foreign owners and stale revisions while preserving healing/attack declarations. Their authorized choices continue through normalized decision envelopes. These checks cover the named healing and stance workflows only.

**Preparation and phase-command evidence:** Tempered in Battle's integration path now advances Command and selects the no-doctrine option through `MatchCommandService` before opening the Leadership decision. This verifies the named Command-close sequence and does not expand doctrine or morale rules coverage.

The Marine ability-boundary regression also resolves its initial no-doctrine preparation choice through the public command service before checking the local ability boundaries.

**Roster preparation evidence:** the Biologis regression now submits its Warlord, Support attachment and roster confirmation through `MatchCommandService`; these remain local roster checks and do not certify general list legality.

The shared current-unit-ability regression now fails closed in its helper when a pending UnitActions choice exists but the selected option is not in that decision; it no longer falls through to the domain path for that pending work.

Marneus Calgar's conditional Support attachment and Thunderhawk Insertion preparation choice now submit through projected public UnitActions decisions; a foreign player is rejected without mutation. His Movement-phase Master Tactician choice also uses the public match command. This evidence covers these local choices only.

Caanok Var's Cerebrex Logic Engine Scout selection now uses its projected preparation decision through `MatchCommandService`; the opposing player is rejected without mutation. This is local choice-flow evidence, not broader roster legality certification.

**Mortal-wound decision evidence:** Hammer of Wrath, Telepathic Assault, Explosives, Haywire Mine, Tank Shock and Ballistus Deadly Demise submit defender allocations through normalized UnitActions commands. Charge and attack frames are retained through the relevant packets, wrong-owner submissions are rejected without mutation, and phase close remains blocked while mandatory choices remain. This covers the listed local source paths; it does not certify every mortal-wound trigger or combination.

Explosives also now submits its stale-revision rejection through the same public command envelope as its valid activation, confirming the old request leaves state unchanged.

The Ironstorm interaction regression additionally routes Tank Shock, Hammer of Wrath, Telepathic Assault, Haywire Mine, Layered Ceramite and the selected mortal allocation through `MatchCommandService`, validating the combined local defender flow across those named sources.

**Core reaction evidence:** Fire Overwatch, Leap to Defend and Into the Fray are exercised through public normalized phase-end choices. Overwatch retains decision identity through save/restore and decline; both Heroic Intervention modes spend the correct CP, open the responder's charge and remain under the phase-close frame while that charge is pending.

The ordinary Vehicle Tank Shock follow-up after Brutalis's free Charge-triggered use now submits through `MatchCommandService`; the opposing player is rejected without mutation, and the authorized use pays the ordinary CP cost.

Tigurius's immediate Prescience choice now also uses `MatchCommandService`, where the opponent is rejected without mutation. Telepathic Assault retains its public-command coverage; this evidence covers those named local psychic choices, not every psychic timing.

The Terminator Librarian's Might of Heroes, failed psychic test and Thunderous Force choices now use the public match command. The opposing player is rejected without mutation; these local checks do not imply broad psychic-system certification.

The current Librarian's Force Dome and Veil of Time choices, including failed psychic tests, now also use the public match command; wrong-player Force Dome submission is rejected unchanged.

Aethon Shaan's immediate Master of Shadows Command selection uses the raw public `SELECT_UNIT_CHOICE` command because it has no persisted projection; the opponent is rejected without mutation. Its selected Charge re-roll uses the normalized `COMMAND_REACTION` envelope and preserves the zero-CP effect.

Lord of the Ravenwing's charge re-roll now uses the normalized stratagem decision through `COMMAND_REACTION`; the foreign owner is rejected, the Charge frame and decision survive save/restore, and the stale resolved decision cannot be replayed.

Flawless Riders' Charge path now resolves the resulting Charge-roll reaction through the same public stratagem decision; the opponent is rejected without mutation before Charge continues.

Honour of Vigilance's Devastator Doctrine Advance re-roll now uses the normalized stratagem command; the opponent is rejected unchanged and the owner replaces the die without paying CP.

Wrath of the Chapter's Tacticus Advance re-roll also uses `COMMAND_REACTION`; the wrong player is rejected without mutation and the authorized free re-roll retains the movement continuation.

Led Sudden Storm's Advance re-roll now uses normalized `COMMAND_REACTION` after `begin_movement`; the opposing player is rejected without mutation, and the authorized re-roll retains the free CP effect and movement continuation.

Stormseer's Wisdom and Supercharged Engines Advance re-rolls also use normalized `COMMAND_REACTION`; wrong-owner submissions are rejected without mutation, and authorized results retain their free CP effects.

The Necron Command Battle-shock accept choice in the Reanimation hand-off now uses the normalized stratagem command; the opponent is rejected without mutation, and the accepted roll proceeds into the existing Reanimation decision.

Leap to Defend and Into the Fray now submit their follow-up Charge-roll acceptance through normalized `COMMAND_REACTION`; the active player cannot accept the responder-owned Leap roll, and both authorized continuations retain their phase-close behavior.

The Terminator Captain's Unstoppable Valour Charge reroll and eligible paid Command Re-roll now use normalized `COMMAND_REACTION`; wrong-owner and stale-revision Valour submissions leave Charge unchanged, while authorized choices replace the dice and the paid alternative spends one CP.

Chapter Approved terrain, role roll-off, attacker/defender selection and Battle Ready declarations in the roster-validation integration now submit through their projected `mission-preparation` options and public `SELECT_UNIT_CHOICE` commands. The dedicated mission progression suite independently exercises these setup steps; this command-path evidence does not certify mission rules beyond those focused cases.

The same roster integration now routes Warlord, Support attachment and setup-completion declarations through public `SELECT_UNIT_CHOICE`, using the current UnitActions envelope when projected. The test still exercises checked-roster blocking and formation persistence; it does not certify full army legality.

Bladeguard Sergeant pistol preparation choices also use the projected public `SELECT_UNIT_CHOICE` envelope; the local regression rejects wrong-owner and stale-option submissions unchanged. This covers command admission and loadout application only. It does not establish remote multiplayer behavior or certify all Bladeguard rules.

Scout Squad gun and Sergeant wargear preparation choices likewise use projected public `SELECT_UNIT_CHOICE`. Local coverage keeps the five- and ten-model equipment limits and verifies wrong-owner and stale-option rejection. It does not establish network behavior or complete rules certification.

Vanguard Veteran shield, pistol and Sergeant melee preparation choices also use projected public `SELECT_UNIT_CHOICE`. Local coverage retains individual bearer effects and the five-model Plasma Pistol cap; it does not establish network behavior or full rules certification.

Invader ATV Multi-melta swaps and cannon restoration also use projected public `SELECT_UNIT_CHOICE`. Local checks retain the per-model equipment cost and reject wrong-owner and stale-option submissions. This does not establish network behavior or complete rules certification.

Reiver Grav-chutes and Grapnel Launchers likewise use projected public `SELECT_UNIT_CHOICE`; local checks reject wrong-owner and stale-option attempts and retain the resulting ability checks. This does not establish network behavior or complete rules certification.

The `Protocol of the Hungry Void` immediate choice is also admitted through public `SELECT_UNIT_CHOICE` when its eligible owner is not the current Fight actor. The command remains bound to the server's current legal option and revision checks; this local coverage does not establish network validation.
