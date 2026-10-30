# Advanced defense and allocation

The current combat implementation is protocol **v21**. Both peers need the same build and exercise. This increment adds Feel No Pain, Monster/Vehicle shooting exceptions, random melee A against one target, mixed defensive groups, attached-unit combat profiles and Precision. It remains a partial core-rules exercise, with army construction and unlisted faction/unit abilities disabled.

## Try the rules

Select **Start rules lab: mixed defense / Precision** from the sidebar on both peers before connecting, or use it locally. Model 100 has a synthetic Precision/Devastating rifle and a random-A melee blade plus an Extra Attacks blade. Its target has different W/Sv profiles, two characters and a bodyguard with Feel No Pain 5+. This is explicitly a synthetic teaching scenario, not a legal army loadout. The ordinary imported Intercessor/Warrior exercise remains available.

Select model 100 and plan or right-click an enemy to attack. Precision first lets the attacker select a visible character or press **Do not use Precision**. The defender then selects one model from each eligible group to declare the order. Details show the groups' W, Sv and InSv. Saves remain hidden until the order is complete. Green rings and the eligible-model list identify valid choices. After saves, allocate damaging attacks and devastating packets through the same button.

The isolated attack lab also has **Test Feel No Pain**, with zero off and targets 2–6. This is an explicit test context, not an imported ability granted to the selected datasheet. Unsupported target 1 rejects.

## Implemented behavior

| Rule | Current behavior |
|---|---|
| Feel No Pain | One roll for each prospective lost wound, including normal attack damage, Devastating Wounds, Hazardous and desperate-escape mortals. Applicable profiles do not stack; the best applicable threshold is used. Roll through the packet until the model dies; discard excess after death. |
| Conditional prevention | Assigned profiles support all, normal-only or mortal-only wounds. Unknown conditions and malformed thresholds reject before damage commits. |
| Monster/Vehicle shooting | Engaged models can shoot with the applicable hit penalties. Engaged MONSTER/VEHICLE models can target engaged units they are fighting and unengaged enemies; during their own Shooting phase, §17.03 also lets them target other engaged enemy MONSTER/VEHICLE units. During the controlling player's Shooting phase, unengaged attackers can target engaged Monster/Vehicle units with the required penalty. Blast cannot target engaged units. Sidearm exemptions are per model, and Heavy applies only while unengaged. Final hit modifiers are capped after combining effects. See [Shooting at engaged Monsters and Vehicles](shooting-at-engaged-monsters-vehicles.md) for focused verification and remaining boundaries. |
| Random melee A | Assign one whole weapon to one target, then generate A per physical weapon at resolution. Ordinary and Extra Attacks weapons remain separate sources. Fixed-count splitting remains supported; random-A splitting remains explicitly restricted. |
| Defensive groups | Non-character models share a group only when W/Sv/InSv match. Each character has its own group. Wounded non-character groups precede other non-characters; wounded characters precede healthy characters. Each group's own profile checks its saves as casualties advance the current group. |
| Attached combat | Use the highest living bodyguard T while any bodyguard remains, otherwise the highest remaining leader/support T. Role metadata distinguishes non-character support from bodyguards. Characters remain part of the single attached unit after bodyguard loss in 11e. Living keywords, model Leadership and individual OC are respected. |
| Precision | The attacking player chooses a visible character before group order and saves, or declines. That group becomes current until destroyed. Devastating packets also go there while it survives, then return to the normal mortal-wound priority. Visibility uses the existing terrain proxies. |

Rules basis: [11e Core Rules §§01.03, 05.02.01, 05.03–05.04, 10.06, 17.03, 19 and 24.12/24.28](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/). No older-edition bodyguard separation behavior is applied.

## State and scenario APIs

The host owns all profiles, rolls and choices. Pending snapshots store Precision selection, declared group order, save rolls, packet cursor, prevention results and accepted recipients. Wrong-player, wrong-group, hidden-character, wounded-priority and stale-revision requests reject. Invalid dice preserve the current command's state and earlier accepted decisions. Normal damage, mortal damage, prevented wounds and discarded excess have separate history fields. The automatic defender assist chooses a legal default group order; it still pauses for the attacker's optional Precision decision.

Optional per-model fields are `defense` (toughness/save_target/invulnerable_target), `feel_no_pain` (an array of target/against rules), `leadership_target`, `objective_control` and `attachment_role` (bodyguard/leader/support). W comes from model max_wounds. The squad's attached flag activates bodyguard Toughness selection. These are server-owned scenario data, never client-provided weapon or defense values.

`Combat.Attachments.form_practice_unit` constructs one bodyguard unit plus at most one leader and one support component before the exercise starts. It validates friendly, distinct, intact components, resolved defensive profiles and coherent placement; merges starting strength; preserves each component's equipment, defensive profile, Leadership and OC; and includes the attachment identity in compatibility hashing. It does not validate official datasheet/Munitorum Field Manual attachment permissions or enable leader aura/ability propagation. It is a scenario-construction API, not an army editor.

## Validation and remaining scope

Thirty local suites and fifteen host/client loopback scenarios passed on Windows for this increment. New tests cover prevention before death/excess, conditional and non-stacking FNP, transactional dice errors, Monster/Vehicle targeting/modifiers, random melee sources, group ordering before save revelation, changing defensive saves after casualties, attached-role Toughness, character retention, per-model Leadership/OC, Precision/Devastating fallback, and rejoin during both group ordering and prevention. The synthetic practice exercise has its own UI and network/rejoin checks. Precision, group-order and FNP/Devastating panels were rendered and visually inspected.

Remaining restrictions include random-A melee splitting, arbitrary damage modifiers/reductions, conditional abilities beyond the declared FNP scopes, aura/leader ability propagation, official roster and attachment legality, full imported-mesh/hull visibility, upper-floor visibility and vertical combat movement beyond the bounded training surfaces, official missions and stratagems. Linux and separate-machine LAN remain unverified. The battlefield builder stays low priority.

Further core-rule work continues without another per-increment approval: remaining weapon keywords and damage modifiers, followed by reserves/transports and broader unit abilities. Existing legal-geometry exceptions remain restricted where the implementation cannot yet prove the complete required move.
