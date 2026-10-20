# Victrix Honour Guard

This profile uses the local Wahapedia 11th-edition export as its rules source. Datasheet `000004185` in shared book `000000139` has 3/6-model configurations at 120/250 points, with a 15-point Banner of Macragge equipped by the Chapter Ancient. The runtime prices those fixed banner configurations at 135/265 points and the source-listed third-plus tiers at 165/295. This admitted slice uses the Ancient, Champion and Guard at three models, then the Ancient, Champion and four Guards at six models; other legal role combinations are not yet exposed as construction choices.

## Profile and rules

- M6, T5, Sv2+, W3, Ld6+, OC2 on 40 mm bases.
- A three-model configuration contains a Chapter Ancient, Chapter Champion and one Victrix Honour Guard. A six-model configuration contains the same Ancient and Champion with four Victrix Honour Guard.
- The Ancient has a Master-crafted Bolt Carbine and Master-crafted Power Weapon. The Champion has Blades of Honour (Twin-linked, Precision). Each ordinary Guard has a Master-crafted Bolt Carbine (Rapid Fire 1, Assault) and Master-crafted Power Weapon.
- **Glory of Ultramar:** after an enemy unit shoots in the opponent’s Shooting phase, a casualty caused by those attacks opens an optional D6-inch Surge move. Placement checks distance, terrain path, base overlap and coherency.
- **Honour Guard of Macragge:** attacks targeting the unit receive -1 to wound.
- **Banner of Macragge:** at end of the owner’s Movement phase, the Ancient secures an objective controlled by the unit. Once per battle per army, when selected to fight, the unit may add 1 Attack and 1 Strength to its melee attacks.
- **Leader:** Cato Sicarius can attach to this exact bodyguard unit. Other bodyguard targets remain rejected. Captain of the Honour Guard is implemented conditionally: when Marneus Calgar is in the army, Cato becomes Support while retaining Victrix as his exact target.
- **Combat Doctrines** use the shared current runtime implementation.

## Local checks and limits

`tests/test_victrix_honour_guard.gd` checks source identity and prices, both model counts, per-role loadouts and keywords, ability registration, wound modification, the exact Cato attachment, the Glory trigger and movement, Banner timing and once-per-army fight effect. The local catalog includes the profile. Network validation remains deferred to final integration, and this increment does not certify full faction or army legality.
