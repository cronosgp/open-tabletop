# Sternguard Veterans — current e11 implementation

Reviewed 18 October 2026 against [Wahapedia Sternguard Veteran Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Sternguard-Veteran-Squad), datasheet `000002255` in shared book `000000139`, and the local export updated 16 October 2026, 21:03:46 GMT+3. The separate Black Templars `Sternguard-Veteran-Squad-1` page remains excluded. Deathwing is a conditional Dark Angels keyword and is not added to the shared runtime profile.

Five models cost 105 points and ten cost 210; Incursion admits at most two copies, so third-copy prices are not used. Models have 32mm bases, T5 and two wounds. The Sergeant starts with a Chainsword; ordinary Veterans start with Ceramite Fists. Everyone retains a Bolt Pistol and an Artificer Firearm with selectable Infernus, Purgatus and Damnatus profiles.

The Sergeant can replace the Chainsword with a Power Fist or Power Weapon. One ordinary Veteran per five Sternguard models may replace the Artificer Firearm with a Heavy Bolter or Pyrecannon. The Sergeant cannot use that option; attached models do not increase the allowance. Replacing a special weapon with another type remains possible at the cap, and restoring the firearm frees the slot. Every option is reversible before army preparation ends.

Veteran Marksmen combines ranged hit re-rolls of 1 with existing hit policies, preserving a stronger re-roll policy. It never permits re-rolling a replacement die, melee hits or snap-shooting hits. The existing resolver applies automatic re-rolls of failed natural 1s. The live unit source also applies to attached models and disappears when no living battlefield Sternguard source remains. Reviewed Captain and Lieutenant attachment links are admitted; other Leader links remain unimplemented.

Artificer profiles retain Assault, their individual Rapid Fire parameters and Damnatus Melta 2. The Pyrecannon uses Torrent and Blast 2. The Heavy Bolter is this sheet's Strength 5 weapon; it does not inherit Eradicator Strength or Overlapping Destruction. Default and optional weapons are covered by the profile digest and match identity.

The existing preparation selector exposes the new equipment choices. A real Godot capture of the admitted preparation fixture is `.tools/marksmen-sternguard.png`; this is staged controls evidence at 1600x1000, not a completed match or a rules certificate. Final local validation is recorded in [the shared audit](marine-marksmen-audit.json). Network validation is deferred; full faction, army and match certification remain false.
