# Cato Sicarius

This profile uses the local Wahapedia 11th-edition export as its rules source. Cato Sicarius is shared-book datasheet `000004184` (`000000139`), a single 40 mm model for 115 points with M6, T5, Sv2+, 4+ invulnerable, 5W, Ld6+ and OC1. The Artisan Plasma Pistol and all three Talassarian Tempest Blade profiles are transcribed into the runtime profile.

## Implemented scope

- **Leader:** the local export lists Victrix Honour Guard (`000004185`) as Cato's exact bodyguard target. The Victrix profile is now admitted, and Cato can attach to that exact target. Other bodyguards are rejected.
- **Captain of the Honour Guard:** the source changes Cato's Leader role to Support when Marneus Calgar is in the army. Marneus Calgar is now admitted. Local checks confirm that Cato changes to Support only while Calgar is in the army, retains Victrix Honour Guard as his exact target, and cannot be selected as Warlord in that army.
- **Knight Champion of Macragge:** once in the opponent's Movement phase per army, when an enemy unit ends a move within 8 inches and Cato's unit is unengaged, the controller may make a Normal Move up to 6 inches. The implementation validates movement distance, terrain, base spacing, coherency and an unengaged endpoint.
- **Honour or Death:** Heroic Intervention targeting Cato's unit costs 1 fewer CP, to a minimum of 0. The discount is limited to that stratagem and uses the shared reaction cost resolver.
- Combat Doctrines and Transhuman Strategist use the shared current runtime implementations.

## Local checks and boundaries

`tests/test_cato_sicarius.gd` checks the exported profile and weapon traits, ability registration, Warlord eligibility, the exact Leader boundary, Heroic Intervention discount scope, the opponent-movement trigger, optional movement and persisted use state. The local construction catalog admits Cato at 115 points.

The exact Victrix attachment target and Calgar-dependent Support replacement pass local checks. Network validation remains deferred to final integration; this increment does not certify full faction or army legality.
