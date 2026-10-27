# Blast and random characteristics

The current increment follows the [11e Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/), specifically random characteristics and Blast. It does not enable every imported weapon.

Enable **Next match: varied training equipment**, select the second Intercessor and open the attack planner. Its launcher now offers the imported launch Frag profile: A4, Blast 1. Krak retains its imported fixed D3 value (three damage), rather than substituting the older conflicting provisional record.

Blast adds its value per complete five models in the declared target unit. Target size is frozen at declaration; earlier pools killing models do not reduce the bonus. Engaged targets remain prohibited. Raw profile validation runs before count expansion.

The kernel supports positive fixed characteristics and bounded expressions D3, D6, up to 20 dice and an optional positive constant, such as 2D6+3. Ranged random A is generated separately per selected weapon before its attack pool. Random melee A now supports one target per weapon; random-A split declarations remain restricted. No random-A/D profile has been added to the curated roster solely to demonstrate this engine support.

Random damage is generated per damaging attack after its recipient is selected, with wounded-model priority and excess damage discarded. Successful saves consume no damage dice. Defender-choice mode persists the pending choice and rolls only when the host accepts a valid recipient; invalid choices and invalid dice do not partially commit state. Generated counts and damage results are retained in pool records and shown in the result log. The random-characteristic increment introduced protocol v16; the current advanced-defense increment uses v21.

Hazardous and infantry Close-quarters are now supported in the combat exercise; see [Hazardous](hazardous.md). The isolated attack lab still rejects Hazardous because it has no attacking-unit allocation model. Hunter and Extra Attacks are implemented in [weapon selection](weapon-selection.md). [Devastating Wounds](devastating-wounds.md) is now supported. [Mixed defenders and attached combat profiles](advanced-defense.md) are now supported. The battlefield builder remains low priority.

Validation for this increment: test_random_weapons covers expression bounds, D3 conversion, independent generation per weapon, Blast X thresholds, delayed random damage, invalid-recipient/die transactions and no damage spill. test_equipment covers the imported Frag profile and frozen target size. Existing allocation, attack-plan and combat tests exercise compatibility with fixed characteristics.

Twenty-one local suites and the ranged equipment host/client loopback scenario passed on Windows for this increment. The Frag selector and completed plan were rendered and visually inspected. Separate-machine LAN and Linux remain unverified.





