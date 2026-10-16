> **Superseded.** The forward-looking plan now lives in [roadmap.md](roadmap.md). This file is retained as historical backlog notes; many items below are already implemented — see the [support matrix](support-matrix.md) for current state.

# Future backlog

## Current checkpoint — 16 October 2026

Latest rules increment: [Desperate Escape Command Re-roll](escape-rerolls.md) closes the planned re-roll gap for supported training movement and weapons, with pending-pool save/journal and authenticated host-restart recovery. Immortal Implacable Eradication is also available as a limited [training reference](implacable-eradication.md); current official datasheet verification remains pending.

Local two-list setup, six presets/reference forces, save/rejoin/history and automatic ForceOrg catalog/model download/linking are now implemented. [Mixed reference armies](reference-armies.md) add Terminators and Immortals, canonical costs and up to six squads per player. [Intercessor Objective Secured](objective-secured.md) is now implemented as an explicit prepared-match capability. Current priority: complete the other verified abilities, faction rules, commanders/attachments and legal construction for the two reference forces. Older sections below describe prior increments; statements requiring only manual model acquisition or saying persistence is pending are superseded by [current support](support-matrix.md), [model workflow](forceorg-import.md) and [verification](verification-results.md).

## Army builder and local profiles — initial implementation available

The user requested custom lists, point budgets/categories, standard starting bases and persistence in player profiles. The new **Listas** tab implements the [army planner](army-builder.md): all OpenHammer catalog pages per edition, faction/unit/role filters, explicit priced variants, custom point limits, editable starter bases and separate local profile libraries. Online refresh is explicit and cached for offline use. Source composition/costs remain reference data. Admitting saved armies into enforced matches, complete legality, detachments and equipment remain pending; the existing fixed training rosters remain playable.

Follow-up v23: [compatible saved lists](saved-army-matches.md) now enter local/LAN partial training, with one/two Intercessor or Warrior units per player, canonical pack points, shared budget, independent peer selection and deployment rejoin. Admission of arbitrary units and complete official legality remain pending. Match persistence is the next continuity milestone.

## Initial scenario baseline

User-selected testing baseline is **Incursion / 1,000 points per army / 43 × 43 inches**. Main-scene combat exercises now use these board dimensions and scenario metadata. Practice rosters remain explicitly unvalidated by points; terrain, deployment zones and representative legal armies still need scenario work. See [initial test scenario](initial-test-scenario.md).

## Gameplay UI and information clarity — near-term priority

Requested by the user after the v21 status review. The current sidebar mixes match setup, technical state, model details and mandatory decisions; improving this is part of the gameplay roadmap, alongside rules work.

First increment: a context summary at the top of the sidebar identifies the round, readable phase and actual decision owner (which can differ from the active player), plus mandatory Precision, defensive group, damage, Hazardous, contact placement and coherency decisions. It also identifies waiting for a peer and completed exercises.

Completed layout increment: **Match setup** and **Play** now have independent scrolling areas. Round, phase, decision owner, connection identity and custom-training scores/objective control remain above both tabs. Starting combat opens Play; returning to the preview opens Match setup. State refreshes preserve a deliberately selected tab so configuration remains accessible during play.

Next steps:

1. Completed: separate match setup from in-match controls and keep round, phase, decision owner and objectives visible while scrolling.
2. Completed initial contextual controls: action groups, exclusive pending-decision/attack-edit views, adjacent blocking reasons and disabled-action tooltips. See [gameplay UI](gameplay-ui.md). Further usability review remains part of item 6.
3. Completed selection-card baseline: selected unit/owner, living model count, wounds, defenses, OC/morale and FNP remain compact; equipment and technical state expand on demand. Pending decisions/group profiles remain visible independently. Raw-dice log cleanup remains in item 5.
4. Completed guided-flow baseline: numbered planning instructions, named selected models, assignment/target-order review and explicit confirm/cancel; named eligible-model picker and stage-specific instructions for Precision, defense groups, damage and Hazardous. Picking a model never commits a decision.
5. Completed results/history baseline: latest notice precedes selection/actions; last completed attack has named target totals, prevention/excess and separate Hazardous self-damage; combat history/dice expand on demand and preserve scroll on unchanged refreshes. A broader keyword glossary and wording/accessibility review remain pending.
6. Verify these flows locally and as host/guest at typical window sizes, including reconnects and mandatory opponent decisions. Check text clipping, scroll access and visual cues without relying on color alone.

Completion means a player can identify who acts, what to do next, valid targets and the reason for a blocked action without reading the technical log. This work does not enable unsupported rules. Battlefield editing remains lower priority.

## Player model imports — ForceOrg / TTS

Updated acquisition preference: **Baixar arquivos deste modelo** now downloads the selected OBJ/diffuse image directly to a player-selected local folder, with progress, cancel, size/time limits, validation and preview. TTS/cache is optional; scanning does not trigger downloads or assign unit visuals. Seven local suites and two real in-game model downloads plus actual-transfer cancellation passed. Remaining format/composite/platform limitations still apply.

Confirmed workflow: the player independently obtains ForceOrg through its Workshop/downloader and selects that local collection in our import settings. Ship the importer/configuration only. First verify the actual downloader output, then implement local collection discovery and compatible mesh/texture adapters; do not require manual GLB conversion as the default workflow. Do not invoke acquisition tools, bundle the collection or transfer third-party assets to other players. See [confirmed source and workflow](forceorg-import.md).

Requested by the user. Add a Models / Import configuration for local TTS saved objects/table saves, source/cache paths, reference scanning, model preview, explicit mapping to our unit/model identifiers and persistent scale/rotation/offset settings. The initial adapter supports local OBJ with an explicit diffuse image; GLB and richer material handling follow. Report AssetBundles as requiring a compatible conversion. Preserve authoritative gameplay bases and placeholder fallbacks, including for peers without the local asset. Do not execute source scripts or automatically bundle/download third-party models.

Runtime import is available under **Models / Import**: scan a local ForceOrg/TTS save, search static embedded catalogs and child components, locate uniquely matching OBJ/diffuse files in a selected cache folder or choose manually, preview, persist the unit-definition mapping and render it on the board. Real validation passed for two Intercessors and one Necron component, including texture decoding, persistence/fresh launch and loopback/rejoin. Cache lookup does not download or auto-apply mappings. Missing/changed mapped files use placeholders; gameplay geometry/rules remain separate. Remaining work: arbitrary dynamic catalogs, actual TTS cache variants, composite assembly, per-model sculpt variants, richer materials/formats, Linux and separate-machine networking. See [real validation](model-import-validation.md).

The supplied backup is a utility-table save with external references; it is not a verified full miniature catalog. Its license does not grant the maintainer rights to license the save assets for our distribution. Source assessment, current instructions, scope, acceptance criteria and implementation order: [ForceOrg import](forceorg-import.md). It is separate from the low-priority battlefield builder.

## Player battlefield builder — low priority

Deferred by user decision. This does not displace the rules implementation roadmap.

Keep Godot. Eventually provide an in-game terrain library, placement/rotation/snapping, undo/redo, terrain boundaries and categories, floors, objective placement, saved maps and sharing. Custom model import and multiplayer asset transfer follow later. Visual assets must remain separate from authoritative gameplay geometry. Introduce a versioned battlefield format before building the editor.

Current priority: continue core rules and improve gameplay UI/information clarity. No battlefield-editor implementation is scheduled yet.
