Current Track A status: A1–A5 are integrated for the checked 930-point Gladius vs 880-point Awakened infantry match. The selected CA mission, ten fixed-loadout profiles, MFM 1.6 construction checks and required infantry core effects are documented in the [roadmap](docs/roadmap.md). Enable the checked-rosters option in Match setup. Other rosters and optional equipment remain outside certification.

# Open Tabletop

[![CI](https://github.com/cronosgp/open-tabletop/actions/workflows/verify.yml/badge.svg)](https://github.com/cronosgp/open-tabletop/actions/workflows/verify.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE) [![Godot 4.7.2](https://img.shields.io/badge/Godot-4.7.2-478cbf)](https://godotengine.org)

An open-source tabletop prototype in Godot, intended for two-player Warhammer 40,000 play through versioned rules and user-supplied visuals. Current delivery is a movement demo and restricted combat/training exercises, not a complete supported official edition.

**Current status:** [support matrix](docs/support-matrix.md). **Roadmap to the final product:** [roadmap](docs/roadmap.md). Historical increment reports: [rules status](docs/rules-status.md).

## Run offline

Use **Godot 4.7.2 stable**, standard edition, no .NET. Import `project.godot` and press **F5**. A clean checkout opens the original movement demonstration without external data, miniatures, Python or downloads.

- Left-click a miniature's base to select it; right-click to request movement.
- Scroll to zoom, middle-drag to orbit, WASD to pan.
- Local mode controls both players; **End turn** advances the active side.
- **Host LAN** accepts one guest; enter its LAN IP and **Join**, or use `127.0.0.1` in two instances on one computer. Host UDP port: **24560**.

The movement demo uses original rules and six placeholders. Combat/training is a separate mode requiring optional starter data. Direct LAN and loopback are supported; internet relay/discovery remains pending. Versioned match saves and autosave support local continuation and reopening the LAN host; guest seats use locally stored credentials and a fresh challenge on reconnection, including host restart. See [match persistence](docs/match-persistence.md).

## Optional combat exercises

Python 3.10+ is needed only for preparation/testing tools:

```text
python tools/prepare_starter.py
```

This explicitly downloads the community snapshot pinned by revision and hashes in `data/starter.lock.json`; existing packs are checked without overwriting. `python tools/prepare_starter.py --check` verifies it offline. Optional data remains in ignored `data/imported/` and is not distributed in the demo build.

In **Match setup**, choose the 3D combat exercise, custom five-round objective training, two units per player, or the synthetic mixed-defense/Precision rules lab. Configure the same exercise on both peers before connecting. **Play** exposes contextual movement, attack-planning and mandatory allocation decisions. See [gameplay UI](docs/gameplay-ui.md) and [tactical controls](docs/tactical-controls.md).

**Prepare custom match: deploy, then play 5 rounds** adds alternating unit deployment inside marked zones before the first turn. The host checks complete bases, collisions, terrain endpoints and coherency; setup progress survives guest reconnection while the host stays open. This mode uses fixed training lists and a versioned configuration manifest. See [prepared match](docs/prepared-match.md).

Implemented areas include individual movement, coherency, morale, shooting, charges/melee, selected weapon mechanics, defender choices, damage prevention, ground terrain and custom scoring. Their exact limits are documented in the [support matrix](docs/support-matrix.md). Main-scene training uses the user-selected **43 × 43-inch / Incursion / 1,000-point preset**. The prepared checked-roster option validates the documented 930/880 lists for the selected CA mission; the general training preset does not certify arbitrary armies.

## Army lists and local profiles

Open **Listas** to create armies, select faction/edition, add units and priced model-count variants, and choose a 500/1,000/2,000/3,000-point preset or custom budget. The optional OpenHammer catalog downloads all available records on explicit refresh and remains available offline. Editable starter bases, search, unit categories, custom mixed-faction planning, notes, saved copies and separate local profiles are supported.

**Local match with two armies:** open **Match setup → LOCAL MATCH • TWO ARMIES**. Seven offline default/reference lists (four small presets, two mixed 480/500-point forces, and an Overlord/Warriors/Immortals force at 245/500 local points) are available immediately alongside saved profile lists. Select both sides and press **Create local match with these two lists**; save independent copies to your profile when desired. Automatic ForceOrg models reuse existing links/cache or download and link supported visuals in the background. With no configured source, the ForceOrg catalog is downloaded automatically on the first local match. You can also choose a local JSON in **Models / Import**. Model failures keep placeholders and never block the match. See [local setup](docs/saved-army-matches.md) and [automatic models](docs/forceorg-import.md).

Saved lists retain their cost snapshots until explicit repricing. **Nova lista compatível com treino** creates starter-compatible Intercessor/Warrior rosters that can be selected in **Match setup** for local/LAN partial training. Each peer selects its own list; the host validates local-pack points, composition and shared budget before deployment. Mixed core-profile lists can use up to six squads of the four supported types; see [reference armies](docs/reference-armies.md). Prepared-match options now include [Intercessor Objective Secured](docs/objective-secured.md) and [Immortal Implacable Eradication as a limited training reference](docs/implacable-eradication.md). Official legality, other unit/faction abilities and arbitrary catalog-unit matches remain pending. See [army builder](docs/army-builder.md) and [saved-list matches](docs/saved-army-matches.md).

## User miniatures

**Models / Import** scans a local ForceOrg/TTS JSON save, previews OBJ meshes with an optional diffuse texture, and saves a visual mapping to a unit definition. Existing local/cache files are supported. The player can also explicitly download the selected model's referenced files over HTTPS and preview them before saving the association. Nothing downloads merely by entering a match or scanning a save.

No third-party miniatures are bundled or transferred to peers. Visual mappings never change authoritative bases, statistics, collisions or sight proxies. Missing local assets use placeholders. See [ForceOrg import](docs/forceorg-import.md) and [real-content validation](docs/model-import-validation.md).

## Verify and build

```text
python tools/verify.py --godot /path/to/godot --profile demo --network
python tools/verify.py --godot /path/to/godot --profile full --network
python tools/build_demo.py --godot /path/to/godot
```

The demo test profile is offline except for local loopback; full checks require the pinned starter snapshot. Tests run in an isolated copy and separate user-data profiles, with timeouts and JSON/log reports. The default build creates a demo PCK and checks headless startup. Native Windows/Linux targets require matching export templates. Full instructions and verification limits: [verification](docs/verification.md), [latest results](docs/verification-results.md).

## Architecture and product scope

- Rules modules under `scripts/edition_11/` validate commands independently of rendering.
- The host validates both players' actions, resolves dice and replicates state; revisions reject stale commands. Host authority does not protect against a malicious host.
- `scripts/main.gd` currently combines board presentation, UI and ENet session handling; gradual separation is on the roadmap.
- [Data packs](docs/data-packs.md) have explicit identities, provenance and hashes. External providers are optional preparation/catalog services; match resolution stays local.
- Local visuals remain separate from unit identity and gameplay geometry.

The first functional release targets Windows/Linux, one scenario and a restricted set of fully implemented lists/rules. Preparation, deployment, mission completion, saving/recovery and remote connection must work together before expanding coverage. Later goals include legal army construction, additional versioned rules packs, supported host customization and a battlefield editor. See [backlog](docs/backlog.md).

## Content boundary

Original demo content and external game content have separate licensing requirements. Download availability does not establish redistribution permission. Imported community data and user-supplied visuals do not automatically become redistributable project assets. The project's own code and original demo content are licensed under the [MIT License](LICENSE). Warhammer 40,000 and related names and marks are property of Games Workshop; imported community data and user-supplied visuals are not redistributed and remain under their own terms.



The **Histórico** tab provides paged, read-only match history and dice results backed by an independent journal. Saves validate the committed journal prefix before resuming; see [match history](docs/match-history.md).

Prepared matches can opt into **Insane Bravery** before Command battle-shock tests, with CP costs, use limits and resumable decisions. Select the same option on both LAN peers; see [core stratagems](docs/core-stratagems.md).

An additional **Command Re-roll avanço/carga** option pauses after eligible Advance/Charge rolls, before movement or target selection. Accept for free or spend 1 CP to replace the Advance D6 or both Charge D6; the new result is mandatory. Saves, history and authenticated host restart preserve the choice and usage limit. See [core stratagems](docs/core-stratagems.md).

The additional **re-roll acerto/ferimento** option pauses hit/wound pools before later rolls. Select one eligible D6 or accept for free; the host enforces 1 CP and the shared phase limit. Twin-linked dice cannot be re-rolled again. Save re-rolls use a separate option; damage uses a separate option; weapon Hazardous, attack-count and Desperate Escape re-rolls use separate options. See [core stratagems](docs/core-stratagems.md).

Enable **Próxima partida: re-roll de defesa** for the defender to replace one save D6 for 1 CP before sorting saves and resolving damage. The choice survives saves and authenticated host restart, and shares the player’s Command Re-roll phase limit. See [core stratagems](docs/core-stratagems.md).

Enable **Próxima partida: re-roll de dano** to replace one random damage die before Feel No Pain and casualties, keeping the chosen recipient fixed. Starter lists still have fixed damage. To try D3 without editing code, enable the option and open the synthetic allocation lab; this practice mode starts with 2 CP per player. Saves and authenticated host restart preserve the choice. See [core stratagems](docs/core-stratagems.md).

Enable **Próxima partida: re-roll Hazardous** for a 1 CP choice of one weapon Hazardous die before mortal-wound allocation. Try the prepared mode with varied equipment and model 100’s plasma supercharge profile. The result is mandatory, including a worse roll; saves and authenticated host restart preserve the choice. Attack-count and Desperate Escape re-rolls use separate options. See [core stratagems](docs/core-stratagems.md).

Enable **Próxima partida: re-roll de nº ataques** to replace one random attack-count die for 1 CP before hit rolls. Other dice and bonuses stay fixed. In the synthetic lab, select **Synthetic random-A practice rifle** (A D3+1); the enabled practice mode starts with 2 CP per player. Starter lists retain fixed A. Saves and authenticated host restart preserve the decision. Desperate Escape re-rolls use a separate option. See [core stratagems](docs/core-stratagems.md).


Enable **Next match: Desperate Escape re-roll** before a prepared or saved-list match to replace one escape hazard D6 for 1 CP before mortal wounds or movement. Battle-shocked units cannot use this friendly stratagem; accepting is free. The original pool and pending choice survive saves, history and authenticated host restart. See [Desperate Escape re-rolls](docs/escape-rerolls.md).


Historical training increments include [June Intercessor Hail of Bolts](docs/hail-of-bolts.md) and [June Oath of Moment](docs/oath-of-moment.md), with saved-list setup and authenticated pending-attack recovery. Oath is superseded by current Combat Doctrines; these older profiles do not certify the current Codex or complete legal armies. See the current [Track A](docs/track-a.md) requirements below.

[Reanimation Protocols](docs/reanimation-protocols.md) supports Warriors/Immortals returns, living Overlord healing and admitted Overlord attachments at the end of own Command, with model choice, validated placement previews and save/LAN recovery. Other attached compositions, slain Characters and Resurrection Orb remain unsupported.

**Rules target: official e11.** Consult the user's [e11 reference](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) and current official updates; see [source policy](docs/source-assessment.md#required-rules-baseline). [Current Combat Doctrines + Gladius Codex Discipline](docs/combat-doctrines.md) has Command-start selection, effective Assault shooting, Tactical/Assault charge eligibility and one shared extra Gladius use, including save/LAN recovery. Enable **Next prepared match: 11e Combat Doctrines + Gladius**. This option cannot combine with historical Oath. The checked profile is documented in Track A; historical profiles remain isolated from current Codex certification.


[Awakened Dynasty Command Protocols](docs/awakened-dynasty.md) now provides the current e11 led-unit hit bonus, with a usable Overlord preset and validated pre-deployment attachment declaration. Admitted attachments now combine with Reanimation, retaining their combined starting strength and surviving leader ability under e11; this is partial training, not a certified legal Necron game.

[Current e11 unit abilities](docs/current-unit-abilities.md) covers ten fixed-profile unit types, including Assault/Heavy Intercessors, Lieutenant and Royal Warden. Enable the current-unit option in Advanced match options; it exposes Leader/Support/Warlord setup, Terminator reserves/Homer, named phase abilities and free wound/healing rerolls. The current option isolates superseded Marine profiles. The selected official mission and latest MFM 1.6 fixed-profile prices are available in checked-roster matches; arbitrary list legality remains outside scope.

Selected current mission: enable **Next prepared match: CA 2026-27 / Battlefield Dominance**. See [mission scope and sources](docs/chapter-approved-mission.md) for Hammer and Anvil, fixed secondaries, preparation, scoring and current legality boundaries.
