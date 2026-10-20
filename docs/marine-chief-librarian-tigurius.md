# Chief Librarian Tigurius

Wahapedia's local e11 export is the single rules source for this profile. Tigurius is shared-book datasheet `000001611` (`000000139`), one 40 mm model for 115 points, with M6, T5, Sv3+, 4+ invulnerable, 5W, Ld6+ and OC1. The fixed loadout is Bolt Pistol, Storm of the Emperor's Wrath and Rod of Tigurius. The weapon characteristics and traits are transcribed into [the runtime profile](../scripts/edition_11/current_reference_marine_profiles.gd).

## Implemented scope

- **Leader:** Sternguard Veteran Squad, Vanguard Veteran Squad, Infernus Squad, Assault Intercessor Squad, Bladeguard Veteran Squad, Intercessor Squad and Desolation Squad are listed by the source. Six exact identities are selectable and can be attached. The non-Jump-Pack Vanguard Veteran Squad identity is not admitted locally; it is not replaced with Vanguard Veteran Squad with Jump Packs.
- **Hood of Hellfire:** Tigurius and his attached unit receive Feel No Pain 4+ against Psychic attacks and mortal wounds, through the normal wound-prevention flow.
- **Prescience (level 2):** once in Tigurius's own Movement phase, make a psychic test. On a 1 his unit becomes Battle-shocked. His unit gains +1 to saving throws until the start of his next turn.
- **Telepathic Assault (level 1):** once in Tigurius's own Shooting phase, make a psychic test. On a 1 his unit becomes Battle-shocked. Select a visible enemy within 24 inches to suffer 2D3 mortal wounds, routed through ordinary defender allocation and applicable prevention.
- His separate level-2 and level-1 powers each have their own per-turn use, consistent with his source Psyker level 3.
- Combat Doctrines and Transhuman Strategist are inherited from the shared current runtime implementation.

## Local checks and boundaries

`tests/test_chief_librarian_tigurius.gd` checks the local profile values, weapon traits, listed Leader links available in the catalog, Warlord eligibility, Hood of Hellfire, both psychic powers, Prescience duration, Battle-shock on a psychic roll of 1, and Telepathic Assault mortal allocation. The consolidated construction catalog admits the 115-point profile.

The source lists Vanguard Veteran Squad as a Leader target, but that distinct non-Jump-Pack datasheet is not among the locally admitted profiles. The corresponding pairing is therefore unavailable. This increment does not certify full faction or army legality. The fixed-data comparison remains deferred while its available snapshot is structurally invalid; network validation remains deferred to the final integration stage.
