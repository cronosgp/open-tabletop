Subsequent increment (18 October 2026): [Bladeguard Veterans](marine-bladeguard.md) are now admitted as an additional Judiciar bodyguard; the historical increment below records the earlier boundary.

# Judiciar — current e11 implementation

Reviewed 18 October 2026 against [Wahapedia Judiciar](https://wahapedia.ru/wh40k11ed/factions/space-marines/Judiciar), datasheet `000002707`, shared book `000000139`, App. Space Marines (11th edition). The local export revision is 16 October 2026, 21:03:46 GMT+3. Chapter, Legends and Boarding Actions variants are excluded.

The admitted fixed profile is one 50-point model on a 40mm base, M6/T5/Sv3/W4/Ld6/OC1. It carries an Absolvor Bolt Pistol and Executioner Relic Blade (five attacks, WS2+, S7, AP-2, D2, Precision and Devastating Wounds). Its 4+ invulnerable save applies only to melee attacks. It has no Explosives keyword or weapon replacements.

The Judiciar occupies the Support slot and must attach before checked preparations finish. Currently admitted bodyguards are Intercessors, Assault Intercessors, Infernus and Sternguard. Hellblasters are ineligible; Bladeguard awaits its own admission. It may be Warlord. Construction checks reserve enough eligible slots across Judiciar and Lieutenant selections, including their overlapping bodyguard choices.

Tempormortis gives its current unit Fights First. The fight queue recalculates this passive from the living battlefield source, preserving charge and Counteroffensive priority independently. Source death or removal stops the passive; a historical ability implementation cannot activate it. When both sides have eligible first-priority units, the existing alternating owner selection remains active.

## Integration and validation

Conditional invulnerable saves are explicit model-defense metadata. Both attachment paths retain the condition without granting it to bodyguards. Attack preparation, grouped defenses, automatic resolution and manual/Precision allocation receive the attack type. General saving throws remain independent, and a better universal invulnerable save takes precedence. Invalid conditional values fail validation even during ranged attacks.

The dedicated suite exercises current admission, prices and weapons, Support declarations, slot competition, save isolation, automatic damage, manual/Precision save evaluation, source removal, historical gating and opposing Fights First selection. Existing controls expose this passive-only unit without an added action window. The selected-model card and technical details explicitly label conditional protection as `InSv 4+ melee`.

The UI brief preserves the existing panel layout, typography, semantic colors and action hierarchy; only saving-throw copy changes. The player must distinguish conditional protection without hover or an extra click. Real Godot captures `.tools/judiciar-defense-before.png` and `.tools/judiciar-defense-after.png` were inspected at 1600x1000 with matching framing and a staged admitted-profile formation (Judiciar attached to Intercessors, model 300 selected). The new text fits the card. These captures do not prove deployment legality, a completed match or other viewport sizes. Historical import identity `8dcb-987c-1ab4-b976` is an alias only; all rules and points resolve from the current Wahapedia profile.

The [audit](marine-judiciar-audit.json) records the numeric comparison and final local regression. Network validation remains deferred to final integration. Full army, faction and match certification remain false.
