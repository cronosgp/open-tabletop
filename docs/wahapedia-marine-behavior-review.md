# Marine ability behavior: bounded validation

18 October 2026. This increment compares current Wahapedia e11 effects with the existing fixed-profile implementation and adds regression coverage for live sources, modifiers, timing and serialized decisions. It does not certify every interaction, optional loadout, chapter or complete army.

## Source and behavior scope

| Source / rule | Behavior checked |
|---|---|
| [Intercessors](https://wahapedia.ru/wh40k11ed/factions/space-marines/Intercessor-Squad), Bolter Discipline | Own Shooting only; attacker or target objective proximity; no melee bonus; loss when all Intercessor sources die, including a surviving attached Captain |
| Same page, Tactical Mainstay | Battle-shock action exception and shooting after starting an action; Advance/Fall Back and charge restrictions still apply; a surviving Captain loses the shooting exception when the Intercessor sources are gone |
| [Assault Intercessors](https://wahapedia.ru/wh40k11ed/factions/space-marines/Assault-Intercessor-Squad), Targeted Intercession | Melee Strength/AP after charging; propagation to an attached Lieutenant; loss when all bodyguard sources die; base profiles remain immutable |
| [Heavy Intercessors](https://wahapedia.ru/wh40k11ed/factions/space-marines/Heavy-Intercessor-Squad), Unyielding | Save bonus requires controlling an objective; enemy control, zero OC and Battle-shock cases; existing combat suite resolves an actual modified save |
| [Terminators](https://wahapedia.ru/wh40k11ed/factions/space-marines/Terminator-Squad), Fury of the First | AP bonus at exactly nine inches using base-edge unit distance, and rejection beyond the engine tolerance |
| Same page, Deep Strike / Teleport Homer | Existing reserve suite covers round limits, preview/confirmation, enemy distances, coherent arrival, Homer placement and removal after an enemy move ends |
| [Captain](https://wahapedia.ru/wh40k11ed/factions/space-marines/Captain), Strategic Acumen | Public command selection, one use per turn, local doctrine, expiration at next own Command rather than opponent Command; existing doctrine suite checks shared doctrine accounting |
| Same page, Finest Hour | Eligible selected fighter, Captain-only bonus, split attack pools, once-per-battle use and no bonus leak into later turns |
| [Lieutenant](https://wahapedia.ru/wh40k11ed/factions/space-marines/Lieutenant), Demi-company Commander | Trigger after Captain's selection, serialized pending reaction, once per turn, same local doctrine and expiration |
| Same page, Tactical Precision | Live Lieutenant supplies conditional Lethal Hits to its attached unit; Monster/Vehicle exclusion; bodyguards lose the effect when the Lieutenant dies, while a surviving Lieutenant retains its own effect |
| [Faction rules](https://wahapedia.ru/wh40k11ed/factions/space-marines/#Transhuman-Strategist), Transhuman Strategist | Existing unit-ability suite checks one CP grant per battle round from a living Captain Warlord |

The current [core objective control rule](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/#Controlling-Objectives) supplies the controlling-unit condition. The current [Combat Doctrines](https://wahapedia.ru/wh40k11ed/factions/space-marines/#Combat-Doctrines) rule supplies selection limits and replacement; the [Gladius rule](https://wahapedia.ru/wh40k11ed/factions/space-marines/#Codex-Discipline) supplies the extra selection. Rule effects were checked on the live e11 pages during this review. No separate GW confirmation is required by the project's source policy.

The new `test_marine_ability_boundaries.gd` works with the actual fixed-profile factory, equipment selectors and public unit-action commands, alongside direct modifier boundary checks. Existing actual-combat tests cover attack pool construction, saves and split targets. Passing helper-level checks is not being presented as a complete match playtest.

## Verification infrastructure

The isolated verifier previously copied scripts/tests/tools but omitted the project-authored keyword-context JSON used by the new Python audit tests. `tools/verify.py` now stages that specific file. Downloaded source catalogs and the player's saved profile remain outside the test project.

The first new boundary fixture entered Shooting before attaching a Captain; attachment correctly rebuilt the deployment state. The fixture now enters the phase under test after attachment. No gameplay fix was needed for that fixture failure.

## Remaining boundaries

Local verification evidence: `.tools/verification/20261018T043434895517Z/results.json`. Resource import, 30 Python tests, main-scene startup and all five selected local Godot suites passed: current unit abilities, actual combat, doctrines, reserves and the new Marine ability boundaries. That run as a whole failed because its host/client network pair timed out at 45 seconds. The initial timeout did not report a script error. [Machine-readable audit](wahapedia-marine-behavior-audit.json) preserves the local result and network limitation separately.

The isolated network retry with a 90-second process timeout passed: `.tools/verification/20261018T043645284754Z/results.json`, five processes PASS (import, Python, startup, host and client). Its existing scenario verifies authenticated local reconnection and a fresh host restoring pending state/RNG during Necron Reanimation. This resolves the timeout-only validation result for that scenario, without establishing the cause of the first timeout or certifying separate-machine performance.

This review does not enable non-Deep-Strike reserve workflows, transports, other units, optional wargear/enhancements, chapter-specific rules or complete army legality. It does not exhaust every casualty order, timed modifier, return-to-play or interrupted reaction interaction. The existing host/client recovery suite exercises shared option/state persistence through a Necron reanimation scenario; it must not be described as a full network test of every Marine ability. Separate-machine LAN, Linux and graphical review were not performed in this increment.

Full-match certification remains false. The next work is mission/core/detachment interaction reconciliation and missing declared-scope behaviors. Subsequent increment: [Explosives](explosives.md) now implements the core card for existing eligible profiles; this earlier datasheet-behavior audit alone did not cover it. The structural catalog does not need another bulk inventory pass before addressing these concrete gaps.
