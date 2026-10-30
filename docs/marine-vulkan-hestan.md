# Vulkan He’stan — shared-book datasheet scope

## Source and provenance

This audit follows the 11th-edition [Wahapedia Vulkan He’stan datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Vulkan-He-stan), Space Marines book `000000139`, datasheet `000002726`. The current live page was checked on 27 October 2026 and identifies Space Marines App 2.8.1 / October 2026. Datasheet facts were checked against the verified local Space Marines export snapshot `20261021T130623Z`, retrieved on 21 October 2026. The snapshot specification revision, 23-file manifest, manifest hashes and relevant CSV hashes are in the [machine-readable audit](marine-vulkan-hestan-audit.json).

Vulkan is one 105-point model on a 40 mm base with no equipment-option rows. The fixed profile, composition, cost, keywords and default loadout match the pinned export. The per-profile comparison reports no fixed-data differences; its parent comparison is not globally certified because of unrelated structural errors in the wider export.

| Weapon | Profile | Source traits |
|---|---|---|
| Bolt Pistol | 12 in, A1, BS2+, S5, AP-1, D1 | Close-Quarters |
| Gauntlet of the Forge | 12 in, D6+3, Torrent, S6, AP-1, D1 | Close-Quarters |
| Spear of Vulkan | Melee, A6, WS2+, S7, AP-2, D2 | Devastating Wounds |

All three fixed weapons pass through the Equipment and AttackPlan paths.

## Implemented source scope

Vulkan’s base Feel No Pain 6+ applies against any wound and resolves through the shared wound-prevention path. Seeker of the Unfound selects one battlefield objective after Vulkan is deployed. While he is within range of that marker, he has OC 10, Leadership 5+ and Feel No Pain 4+. The checks cover the deployment gate, a valid objective selection, owner/stale-choice rejection without state mutation, save/restore of the normalized decision, and return to the base profile after leaving objective range.

Forgefather can be used once in Vulkan’s Shooting phase to select one visible enemy unit within 24 inches. Friendly Adeptus Astartes Melta and Torrent attacks against that target gain +2 Strength for the phase. The local scope checks the visibility and range gates, an opaque terrain blocker, once-per-phase use, Eradicator Melta and Vulkan’s actual Torrent AttackPlans, and that an unmarked enemy and ordinary weapon receive no bonus.

The suite also checks Combat Doctrines, Transhuman Strategist and Warlord CP timing. Both players’ rosters materialize from the current consolidated Space Marines catalog, and duplicate admission is rejected. The source-listed common-book Leader targets are Assault Intercessor Squad, Bladeguard Veteran Squad, Company Heroes, Eradicator Squad with Melta Rifles and Infernus Squad. The shared relation regression checks all 153 common-book Leader/Support links and rejects an unlisted Intercessor target for Vulkan.

## Verification and limits

The focused offline run passed 5/5 processes: import, Python checks, Vulkan’s current-catalog scope suite, Vulkan profile parity and all 153 common-book Leader/Support links. The run reports `network: false`, `legacy_starter_staged: false` and no headless cleanup diagnostics. The exact command and artifact hash are recorded in the [verification log](verification/verification-results.md); the [machine-readable audit](marine-vulkan-hestan-audit.json) records the source snapshot and checksums.

This closes Vulkan’s common-book local datasheet scope. Salamanders Chapter restrictions and rules, the Legends Vanguard Veteran pairing, cross-sheet list legality, whole-army legality, network validation, full matches and human playtesting remain outside this scope. Network validation is deferred to final integration.
