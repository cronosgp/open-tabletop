# Kayvaan Shrike

Wahapedia's local e11 export is the rules authority for this profile. Kayvaan Shrike is shared-book datasheet `000002708` (`000000139`), a single 40 mm model for 95 points with M12, T4, Sv3+, 4+ invulnerable, 5W, Ld6+ and OC1. Blackout and Raven's Talons use the source-exported weapon profiles in [the runtime profile](../scripts/edition_11/current_reference_marine_profiles.gd).

## Implemented scope

- **Leader:** may lead Assault Intercessors With Jump Packs and Vanguard Veteran Squad With Jump Packs. Both exact source-listed identities are admitted; neither is substituted with a non-Jump Pack squad.
- **Deep Strike:** uses the existing reserve ingress rules.
- **Lone Operative:** active while Shrike is standalone and disabled while he is part of an attached unit.
- **Trifold Path of Shadow:** Shrike's unit has Stealth and applies a -3 inch detection-range modifier while he is alive on the battlefield. The benefit applies to the combined unit while he leads a bodyguard.
- **Echo of the Ravenspire:** at the end of the opponent's Fight phase, if his unit is unengaged, its controller can place the whole unit in Strategic Reserves. It uses the existing reserve ingress flow when it returns.
- Combat Doctrines and Transhuman Strategist use the shared current runtime implementations.

## Local checks and boundaries

`tests/test_kayvaan_shrike.gd` checks the source profile and weapon traits, both Leader links and an unsupported target, Deep Strike, standalone/attached Lone Operative behavior, Trifold Path's Stealth and detection modifier, Echo's phase/engagement gate and reserve transition, and Warlord/Transhuman Strategist behavior. The consolidated construction catalog admits Shrike at 95 points.

The check covers the current ground-level detection proxy and standard reserve ingress system. Network validation is deferred to final integration; this increment does not certify full faction or army legality.
