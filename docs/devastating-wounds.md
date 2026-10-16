# Devastating Wounds

Enable **Next match: varied training equipment**, start a combat or objective-training match, and select the first Intercessor. Its melee planner now offers the imported **Thunder Hammer**, A3 / WS4+ / S8 / AP-2 / D3 (fixed three damage), with Devastating Wounds. It is an alternative ordinary melee weapon to knives or chainsword. The roster remains curated practice equipment, not an army construction validator.

## Attack and allocation order

An unmodified wound roll of six triggers Devastating Wounds. The critical attack makes no armour or invulnerable save. Non-critical wounds from the same gathered group of identical attacks follow the usual save sequence. Resolve that group's normal damage before its devastating mortal damage, then continue to the next weapon pool or target.

Each critical wound creates a separate mortal-damage packet equal to the selected weapon's D. Choose one eligible defending model for that packet; it can damage at most that model, and excess is discarded. This differs from Hazardous, whose ordinary mortal wounds can continue through multiple models. [Advanced defense](advanced-defense.md) now supports mixed groups, characters, Precision and Feel No Pain. The chosen packet recipient is fixed; prevention resolves each prospective wound and stops at destruction.

Both automatic allocation assist and defender-choice mode follow this order. In defender-choice mode, normal damaging attacks pause first; devastating attacks then use **Allocate Devastating Wounds to selected model** and a **no save** notice. Random D is rolled only after the host accepts the recipient. Failed saves, mortal packets, accepted choices and damage dice remain in pending snapshots. Reconnection does not reroll them. Bad dice or invalid/stale choices preserve previously accepted state.

Lethal Hits automatic wounds have no wound roll and do not trigger Devastating Wounds. Declining the existing Lethal Hits option allows the wound roll. Twin-linked rerolls can produce a critical wound. Sustained hits generate their own wound rolls. Modifying a five to six does not produce a critical wound; an unmodified six remains critical with a negative wound modifier.

Activation completion, fight queue advancement and elimination wait until all normal and devastating damage is resolved, followed by any required Hazardous choices. If normal damage destroys the target unit, remaining devastating packets are discarded without further damage dice. Their attacks are never redirected.

## History and limits

Pool records distinguish critical wounds, devastating wounds, resolved devastating attacks, applied normal damage, applied mortal damage and discarded excess. Manual allocation records identify each packet's kind and recipient. The isolated attack lab also supports the imported hammer and reports devastating damage separately; it retains its existing isolated-calculation scope.

Rules basis: [Core Rules §§02.02.03, 06.02, 24.10 and 24.23](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/). Mixed defending groups, attached combat, Precision and assigned Feel No Pain are now supported in [advanced defense](advanced-defense.md). Allocation/destruction-triggered abilities remain disabled. Random melee A supports one target; splitting it remains restricted. Protocol is v21; both peers need the updated build.

Validation: 24 local suites and ten host/client loopback scenarios passed on Windows. New coverage includes no saves for critical wounds, normal-before-mortal ordering, per-critical excess discard, Lethal/Twin-linked/Torrent/Sustained interactions, random D after recipient choice, invalid dice transactions, target destruction, ranged and melee lifecycle integration, Hazardous sequencing, imported hammer use and reconnection during pending mortal allocation. Hammer planning and the defender's mortal-allocation panel were rendered and visually inspected. Linux and separate-machine LAN remain unverified.

Those defense/shooting blocks are now implemented in [advanced defense](advanced-defense.md), with the documented scope. Further core work includes remaining weapon keywords and damage modifiers. Battlefield editing remains low priority.

