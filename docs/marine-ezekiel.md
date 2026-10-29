# Ezekiel (Dark Angels App)

**Status:** source-bounded local scope passed on 28 October 2026. The checks cover the fixed profile, all three weapon modes, his four unit abilities, all seven source Leader links and current-catalog admission. They do not certify complete Dark Angels or Space Marines army legality.

## Source identity

- [Wahapedia 11th-edition Ezekiel](https://wahapedia.ru/wh40k11ed/factions/space-marines/Ezekiel), Dark Angels App datasheet `000000226`, book `000000023`.
- The current page was checked on 28 October 2026 against Dark Angels App revision 2.8.1 (October 2026). Fixed facts come from verified local Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, export specification revision `20260817b`; source row stamp `2026-10-21 16:06:23 GMT+3`.
- The machine audit records the scoped slice manifest and source-file SHA-256 hashes. The Ezekiel slice has no structural validation errors. The parent export has 68 errors outside this slice; this profile audit does not treat them as passed. Raw export files remain outside Git.

## Profile and weapons

- One model, 110 points, one supported copy. M6, T5, Sv2+, W5, Ld6+, OC1, 4+ invulnerable save, a 25 mm base and PSYKER Level 3. All eleven source keywords are represented.
- **Mind Wipe** has two 12-inch Psychic profiles. Focused Witchfire is A1, BS2+, S6, AP-2, D3+3, with Devastating Wounds, Hazardous, Precision, Psychic, Anti-Character 4+ and Close-quarters. Witchfire is A1, BS2+, S6, AP-2, D6, with Devastating Wounds, Precision, Psychic and Close-quarters.
- **The Deliverer:** 12", A1, BS2+, S5, AP-1, D2, Precision and Close-quarters.
- **Traitor’s Bane:** A4, WS2+, S6, AP-3, D2, Precision and Psychic.

## Rules and attachments in the checked scope

- **Book of Salvation:** the unit’s melee attacks gain +1 Attack. The shared AttackPlan accounts for the extra attack when allocating the selected model’s attacks.
- **Psychic Hood:** Ezekiel’s attached unit receives Feel No Pain 4+ against Psychic attacks and mortal wounds through the shared prevention resolver.
- **Engulfing Fear:** once per phase in the owner’s Shooting phase, an un-Battle-shocked Ezekiel unit may make a D6 Psychic roll. On a 1, his unit becomes Battle-shocked. The player then selects one enemy within 12 inches of Ezekiel; it makes a Battle-shock roll at -1. The target controller can use the supported Tempered in Battle reroll when eligible.
- **Chief Librarian:** Ezekiel is recorded as PSYKER Level 3. Under the current [Psychic Abilities with a Psychic Level rule](https://wahapedia.ru/wh40k11ed/the-rules/rules-appendix/), the same psychic ability cannot be used more than once per phase.
- **Whispers of the Shadow Forest:** when an enemy targets Ezekiel’s un-Battle-shocked unit, its controller may make a D6 Psychic roll once that phase. On a 1, Ezekiel’s unit becomes Battle-shocked; otherwise, attacks against it have -1 to Hit until the phase ends. The choice uses the existing persisted pre-attack Shrouding decision window.
- Leader, Combat Doctrines, Warlord eligibility and Transhuman Strategist use the shared local paths. Ezekiel can lead Assault Intercessors, Bladeguard Veterans, Hellblasters, Infernus Marines, Intercessors, Sternguard Veterans or Inner Circle Companions; all seven source links are represented.

## Verification and limits

The current-catalog focused run passed **4/4 processes** at `.tools/verification/20261028T120027007826Z/results.json` (SHA-256 `174180AE06115085E8BB3E216D2581E8FEF4A068A0409E5D67D2C2504697504A`; `network: false`, no legacy starter staged, no cleanup diagnostics). It includes import, Python checks, Ezekiel’s dedicated regression and the shared Leader/Support link suite. A related targeted run passed **6/6 processes** at `.tools/verification/20261028T120048353698Z/results.json` (SHA-256 `676A9C49DDDFE5D7C0D0A1917880527AD90700F3FF533043E910F085C422D7AA`; `network: false`, legacy starter staged for the existing capability and Phobos Librarian regressions, no cleanup diagnostics). The dedicated suite covers catalog admission, profile fields, all weapon modes through Equipment/AttackPlan, attachment to Inner Circle Companions, Book of Salvation, Psychic Hood, both Psychic abilities, ownership and the once-per-phase gates.

These checks are local and offline. They do not certify the parent export globally, complete army legality, network behavior, complete-match behavior or human playtesting. Forge World, Legends, Boarding Actions and other alternate modes are outside this scope.
