# Aethon Shaan — current e11 implementation

This draft uses the pinned local Wahapedia 11e export only: shared Space Marines source `000000139`, datasheet `000004148`, updated `2026-10-16T21:03:46+03:00`. It records one 105-point model on a 50 mm base with M14, T5, Sv3+, W5, Ld6+, OC1 and a 4+ invulnerable save. The fixed loadout is Heavy Bolt Pistol and Claws of Severax. The pistol is 18", A1, BS2+, S5, AP-1, D1, Close-quarters. The claws are A7, WS2+, S5, AP-2, D2, Twin-linked, and have Sustained Hits 2 only against targets without MONSTER or VEHICLE.

The local export gives Shaan the character, Epic Hero, Infantry, Jump Pack, Fly, Tacticus, Smoke, Explosives, Imperium, Adeptus Astartes, Chapter Master and Raven Guard keywords. This datasheet has no Leader target list. His Character status makes him eligible to be selected as Warlord.

The local ability inventory also lists Deep Strike, Lone Operative, Stealth, Combat Doctrines and Transhuman Strategist. Deep Strike uses the existing reserve and ingress flow. Lone Operative protects Shaan while he is a standalone unit and turns off if he is in an Attached unit. Stealth grants the supported ranged benefit of cover. Combat Doctrines participates in the current Marine doctrine setup. If Shaan is the Warlord, Transhuman Strategist grants 1 CP at the start of the battle round, once per round.

Master of Shadows selects one friendly Adeptus Astartes Infantry unit in the Command phase and lets it re-roll Charge rolls until the start of the next Command phase. Both dice are replaced together, and the final result is mandatory. Blackwing Mantle is usable once per phase per army; it permits a Heroic Intervention targeting Shaan's unit regardless of other uses that phase, reduces that use by 1 CP (to a minimum of 0), and does not consume or block Heroic Intervention uses on other units. The Charge phase can continue to offer other eligible Heroic Interventions after the special use resolves.

Focused local validation covers the source profile and weapon traits, all seven listed abilities, Warlord selection and CP, Master of Shadows selection, the free charge re-roll and duration, plus Blackwing Mantle use before or after the ordinary Heroic Intervention. The profile is admitted through the consolidated local runtime catalog. The bounded source comparison has zero numeric or identity differences; Aethon passes its fixed-data checks.

Network checks remain deferred to final integration. This draft does not certify full faction or army legality.
